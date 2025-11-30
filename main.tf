terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

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
  name = "locadora-cluster"
}

# Security Group: liberar portas do app
resource "aws_security_group" "locadora_sg" {
  name        = "locadora-security-group"
  description = "SG para Locadora + Portainer"
  vpc_id      = data.aws_vpc.default.id

  # Frontend React
  ingress {
    description = "React Frontend"
    from_port   = 5173
    to_port     = 5173
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Backend Spring
  ingress {
    description = "Spring Boot API"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Postgres
  ingress {
    description = "Postgres"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # PgAdmin
  ingress {
    description = "PgAdmin"
    from_port   = 80
    to_port     = 80
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
  family                   = "locadora-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"

  # Nota: NÃO definimos execution_role_arn nem task_role_arn porque o Lab tem restrições iam:PassRole

  container_definitions = jsonencode([
    {
      name      = "db_postgres"
      image     = "postgres:15"
      essential = true
      portMappings = [
        { containerPort = 5432, protocol = "tcp" }
      ]
      environment = [
        { name = "POSTGRES_USER", value = "postgres" },
        { name = "POSTGRES_PASSWORD", value = "postgres" },
        { name = "POSTGRES_DB", value = "loc001" }
      ]
    },
    {
      name      = "spring"
      image     = "matheusserafim/spring-boot-locadora:1.0"
      essential = true
      portMappings = [
        { containerPort = 8080, protocol = "tcp" }
      ]
      dependsOn = [
        { containerName = "db_postgres", condition = "START" }
      ]
      environment = [
        { name = "SPRING_DATASOURCE_URL", value = "jdbc:postgresql://localhost:5432/loc001" },
        { name = "SPRING_DATASOURCE_USERNAME", value = "postgres" },
        { name = "SPRING_DATASOURCE_PASSWORD", value = "postgres" }
      ]
    },
    {
      name      = "react"
      image     = "matheusserafim/react-locadora:2.0"
      essential = true
      portMappings = [
        { containerPort = 5173, protocol = "tcp" }
      ]
      dependsOn = [
        { containerName = "spring", condition = "START" }
      ]
    },
    {
      name      = "pg_admin"
      image     = "dpage/pgadmin4"
      essential = false
      portMappings = [
        { containerPort = 80, protocol = "tcp" }
      ]
      dependsOn = [
        { containerName = "db_postgres", condition = "START" }
      ]
      environment = [
        { name = "PGADMIN_DEFAULT_EMAIL", value = "postgres@gmail.com" },
        { name = "PGADMIN_DEFAULT_PASSWORD", value = "postgres" }
      ]
    },
  ])
}

# ECS Service
resource "aws_ecs_service" "locadora_service" {
  name            = "locadora-service"
  cluster         = aws_ecs_cluster.locadora_cluster.id
  task_definition = aws_ecs_task_definition.locadora_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.locadora_sg.id]
    assign_public_ip = true
  }
}

# Outputs
output "cluster_name" {
  description = "ECS Cluster name"
  value       = aws_ecs_cluster.locadora_cluster.name
}

output "service_name" {
  description = "ECS Service name"
  value       = aws_ecs_service.locadora_service.name
}

output "task_definition" {
  description = "Task Definition ARN"
  value       = aws_ecs_task_definition.locadora_task.arn
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.locadora_sg.id
}

output "account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}
