# Outputs do projeto Locadora - AWS Fargate

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

output "vpc_id" {
  description = "VPC ID usada"
  value       = data.aws_vpc.default.id
}

output "subnet_ids" {
  description = "IDs das subnets utilizadas"
  value       = data.aws_subnets.default.ids
}

output "region" {
  description = "Região AWS utilizada"
  value       = var.aws_region
}
