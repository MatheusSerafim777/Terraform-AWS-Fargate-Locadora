# Sistema de Locadora - AWS Fargate + Terraform

Projeto de deploy de um sistema de locadora completo na AWS usando Terraform e ECS Fargate.

## Descrição

Sistema fullstack de locadora com frontend React, backend Spring Boot, banco de dados PostgreSQL e interface de administração PgAdmin, deployado na AWS usando infraestrutura como código com Terraform.

## Arquitetura

O projeto é composto por 4 containers principais:

- **Frontend React** (porta 5173) - Interface do usuário
- **Backend Spring Boot** (porta 8080) - API REST
- **PostgreSQL** (porta 5432) - Banco de dados
- **PgAdmin** (porta 80) - Administração do banco de dados

## Tecnologias

- **Terraform** - Infraestrutura como código
- **AWS ECS Fargate** - Orquestração de containers serverless
- **Docker** - Containerização
- **React** - Frontend
- **Spring Boot** - Backend
- **PostgreSQL 15** - Banco de dados
- **PgAdmin 4** - Gerenciamento do banco

## Recursos AWS Criados

- ECS Cluster (`locadora-cluster`)
- ECS Task Definition (1024 CPU, 2048 MB RAM)
- ECS Service (Fargate)
- Security Group com portas configuradas
- VPC e Subnets (usando a VPC padrão)

## Configuração

### Pré-requisitos

- Terraform instalado
- AWS CLI configurado
- Docker (para execução local)
- Credenciais AWS com permissões adequadas

### Variáveis de Ambiente

**Banco de Dados:**
- `POSTGRES_USER`: postgres
- `POSTGRES_PASSWORD`: postgres
- `POSTGRES_DB`: loc001

**PgAdmin:**
- `PGADMIN_DEFAULT_EMAIL`: postgres@gmail.com
- `PGADMIN_DEFAULT_PASSWORD`: postgres

## Deploy na AWS

### 1. Inicializar o Terraform

```bash
terraform init
```

### 2. Planejar a infraestrutura

```bash
terraform plan
```

### 3. Aplicar a infraestrutura

```bash
terraform apply
```

### 4. Obter informações do deploy

Após o deploy, o Terraform exibirá:
- Nome do cluster ECS
- Nome do serviço
- ARN da task definition
- ID do security group
- ID da conta AWS

## Execução Local com Docker Compose

Para rodar o projeto localmente:

```bash
docker-compose up -d
```

### Portas Locais:
- Frontend: 5173
- Backend: 8080
- PostgreSQL: 5432
- PgAdmin: 15432:80

## 📌 Imagens Docker

- Frontend: `matheusserafim/react-locadora:2.0`
- Backend: `matheusserafim/spring-boot-locadora:1.0`
- Database: `postgres:15`
- PgAdmin: `dpage/pgadmin4`

## 🔒 Segurança

O Security Group criado permite tráfego nas seguintes portas:
- 5173 (React)
- 8080 (Spring Boot)
- 5432 (PostgreSQL)
- 80 (PgAdmin)

> ⚠️ **Atenção**: O projeto está configurado para aceitar conexões de qualquer IP (0.0.0.0/0). Para produção, restrinja o acesso apenas aos IPs necessários.

## Destruir Infraestrutura

Para remover todos os recursos criados na AWS:

```bash
terraform destroy
```

## Observações

- O projeto foi configurado para funcionar em ambientes AWS Lab com restrições de IAM
- Não utiliza roles customizadas (execution_role_arn e task_role_arn)
- Usa a VPC padrão da conta AWS
- Região configurada: `us-east-1`
