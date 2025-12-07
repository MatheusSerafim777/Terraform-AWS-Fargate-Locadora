# Variáveis do projeto Locadora - AWS Fargate

variable "aws_region" {
  description = "Região AWS para deploy dos recursos"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Nome do ECS Cluster"
  type        = string
  default     = "locadora-cluster"
}

variable "service_name" {
  description = "Nome do ECS Service"
  type        = string
  default     = "locadora-service"
}

variable "task_family" {
  description = "Nome da família da Task Definition"
  type        = string
  default     = "locadora-task"
}

variable "task_cpu" {
  description = "CPU para a task (em unidades de CPU)"
  type        = string
  default     = "1024"
}

variable "task_memory" {
  description = "Memória para a task (em MB)"
  type        = string
  default     = "2048"
}

variable "desired_count" {
  description = "Número desejado de tasks em execução"
  type        = number
  default     = 1
}

# Variáveis de Banco de Dados
variable "postgres_user" {
  description = "Usuário do PostgreSQL"
  type        = string
  default     = "postgres"
  sensitive   = true
}

variable "postgres_password" {
  description = "Senha do PostgreSQL"
  type        = string
  default     = "postgres"
  sensitive   = true
}

variable "postgres_db" {
  description = "Nome do banco de dados PostgreSQL"
  type        = string
  default     = "loc001"
}

# Variáveis de PgAdmin
variable "pgadmin_email" {
  description = "Email padrão para acesso ao PgAdmin"
  type        = string
  default     = "postgres@gmail.com"
}

variable "pgadmin_password" {
  description = "Senha padrão para acesso ao PgAdmin"
  type        = string
  default     = "postgres"
  sensitive   = true
}

# Variáveis de Imagens Docker
variable "spring_image" {
  description = "Imagem Docker do backend Spring Boot"
  type        = string
  default     = "matheusserafim/spring-boot-locadora:1.0"
}

variable "react_image" {
  description = "Imagem Docker do frontend React"
  type        = string
  default     = "matheusserafim/react-locadora:2.0"
}

variable "postgres_image" {
  description = "Imagem Docker do PostgreSQL"
  type        = string
  default     = "postgres:15"
}

variable "pgadmin_image" {
  description = "Imagem Docker do PgAdmin"
  type        = string
  default     = "dpage/pgadmin4"
}

# Variáveis de Portas
variable "react_port" {
  description = "Porta do frontend React"
  type        = number
  default     = 5173
}

variable "spring_port" {
  description = "Porta do backend Spring Boot"
  type        = number
  default     = 8080
}

variable "postgres_port" {
  description = "Porta do PostgreSQL"
  type        = number
  default     = 5432
}

variable "pgadmin_port" {
  description = "Porta do PgAdmin"
  type        = number
  default     = 80
}
