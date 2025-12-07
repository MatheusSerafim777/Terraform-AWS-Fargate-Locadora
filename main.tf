terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # evita tags automáticas que podem causar AccessDenied em ambientes com políticas restritas
  default_tags { tags = {} }
}

# Descoberta automática de VPC / Subnets
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_caller_identity" "current" {}

# ECS Cluster
resource "aws_ecs_cluster" "locadora_cluster" {
  name = var.cluster_name
}

# Security Group: liberar portas do app
resource "aws_security_group" "locadora_sg" {
  name        = "locadora-security-group"
  description = "SG para Locadora + Portainer"
  vpc_id      = data.aws_vpc.default.id

  # Frontend React
  ingress {
    description = "React Frontend"
    from_port   = var.react_port
    to_port     = var.react_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Backend Spring
  ingress {
    description = "Spring Boot API"
    from_port   = var.spring_port
    to_port     = var.spring_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Postgres
  ingress {
    description = "Postgres"
    from_port   = var.postgres_port
    to_port     = var.postgres_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # PgAdmin
  ingress {
    description = "PgAdmin"
    from_port   = var.pgadmin_port
    to_port     = var.pgadmin_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # Allow all outbound (necessário para pull de imagens)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "locadora_task" {
  family                   = var.task_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory

  # Nota: NÃO defini execution_role_arn nem task_role_arn porque o Lab tem restrições iam:PassRole

  container_definitions = jsonencode([
    {
      name      = "db_postgres"
      image     = var.postgres_image
      essential = true
      portMappings = [
        { containerPort = var.postgres_port, protocol = "tcp" }
      ]
      environment = [
        { name = "POSTGRES_USER", value = var.postgres_user },
        { name = "POSTGRES_PASSWORD", value = var.postgres_password },
        { name = "POSTGRES_DB", value = var.postgres_db }
      ]
    },
    {
      name      = "spring"
      image     = var.spring_image
      essential = true
      portMappings = [
        { containerPort = var.spring_port, protocol = "tcp" }
      ]
      dependsOn = [
        { containerName = "db_postgres", condition = "START" }
      ]
      environment = [
        { name = "SPRING_DATASOURCE_URL", value = "jdbc:postgresql://localhost:${var.postgres_port}/${var.postgres_db}" },
        { name = "SPRING_DATASOURCE_USERNAME", value = var.postgres_user },
        { name = "SPRING_DATASOURCE_PASSWORD", value = var.postgres_password }
      ]
    },
    {
      name      = "react"
      image     = var.react_image
      essential = true
      portMappings = [
        { containerPort = var.react_port, protocol = "tcp" }
      ]
      dependsOn = [
        { containerName = "spring", condition = "START" }
      ]
    },
    {
      name      = "pg_admin"
      image     = var.pgadmin_image
      essential = false
      portMappings = [
        { containerPort = var.pgadmin_port, protocol = "tcp" }
      ]
      dependsOn = [
        { containerName = "db_postgres", condition = "START" }
      ]
      environment = [
        { name = "PGADMIN_DEFAULT_EMAIL", value = var.pgadmin_email },
        { name = "PGADMIN_DEFAULT_PASSWORD", value = var.pgadmin_password }
      ]
    },
  ])
}

# ECS Service
resource "aws_ecs_service" "locadora_service" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.locadora_cluster.id
  task_definition = aws_ecs_task_definition.locadora_task.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.locadora_sg.id]
    assign_public_ip = true
  }
}
