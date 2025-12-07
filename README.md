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

## Estrutura do Projeto

```
Terraform-AWS-Fargate-Locadora/
├── main.tf                    # Configuração principal da infraestrutura
├── variables.tf               # Definição de variáveis do projeto
├── outputs.tf                 # Outputs do Terraform
├── docker-compose.yaml        # Configuração para execução local
└── README.md                  # Documentação do projeto
```

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

- Terraform >= 1.0 instalado
- AWS CLI configurado
- Docker (para execução local)
- Credenciais AWS com permissões adequadas

### Variáveis Configuráveis

O projeto possui variáveis definidas em `variables.tf` que podem ser customizadas:

**Infraestrutura:**
- `aws_region` - Região AWS (padrão: us-east-1)
- `cluster_name` - Nome do ECS Cluster
- `task_cpu` - CPU da task (padrão: 1024)
- `task_memory` - Memória da task (padrão: 2048)
- `desired_count` - Número de tasks (padrão: 1)

**Banco de Dados:**
- `postgres_user` - Usuário do PostgreSQL (padrão: postgres)
- `postgres_password` - Senha do PostgreSQL (padrão: postgres)
- `postgres_db` - Nome do banco (padrão: loc001)

**PgAdmin:**
- `pgadmin_email` - Email de acesso (padrão: postgres@gmail.com)
- `pgadmin_password` - Senha de acesso (padrão: postgres)

**Imagens Docker:**
- `spring_image` - Imagem do backend
- `react_image` - Imagem do frontend
- `postgres_image` - Imagem do PostgreSQL
- `pgadmin_image` - Imagem do PgAdmin

**Portas:**
- `react_port` - Porta do React (padrão: 5173)
- `spring_port` - Porta do Spring Boot (padrão: 8080)
- `postgres_port` - Porta do PostgreSQL (padrão: 5432)
- `pgadmin_port` - Porta do PgAdmin (padrão: 80)

## Deploy na AWS

### 1. Inicializar o Terraform

```bash
terraform init
```

### 2. Revisar variáveis (opcional)

Você pode criar um arquivo `terraform.tfvars` para customizar as variáveis:

```hcl
aws_region = "us-east-1"
cluster_name = "meu-cluster"
postgres_password = "senha-segura"
```

### 3. Planejar a infraestrutura

```bash
terraform plan
```

### 4. Aplicar a infraestrutura

```bash
terraform apply
```

### 5. Obter informações do deploy

Após o deploy, o Terraform exibirá os outputs definidos em `outputs.tf`:
- `cluster_name` - Nome do cluster ECS
- `service_name` - Nome do serviço
- `task_definition` - ARN da task definition
- `security_group_id` - ID do security group
- `account_id` - ID da conta AWS
- `vpc_id` - ID da VPC utilizada
- `subnet_ids` - IDs das subnets
- `region` - Região AWS

Para visualizar os outputs a qualquer momento:

```bash
terraform output
```

### 6. Obter o IP público da aplicação

Para obter o endereço IP público da task em execução no ECS:

```bash
aws ec2 describe-network-interfaces --network-interface-ids (aws ecs describe-tasks --cluster locadora-cluster --tasks (aws ecs list-tasks --cluster locadora-cluster --desired-status RUNNING --query "taskArns[0]" --output text) --query "tasks[0].attachments[0].details[?name=='networkInterfaceId'].value" --output text) --query "NetworkInterfaces[0].Association.PublicIp" --output text
```

## Execução Local com Docker Compose

Para rodar o projeto localmente:

```bash
docker-compose up -d
```

### Acessar os serviços localmente:
- **Frontend**: http://localhost:5173
- **Backend**: http://localhost:8080
- **PostgreSQL**: localhost:5432
- **PgAdmin**: http://localhost:15432

## Imagens Docker

- Frontend: `matheusserafim/react-locadora:2.0`
- Backend: `matheusserafim/spring-boot-locadora:1.0`
- Database: `postgres:15`
- PgAdmin: `dpage/pgadmin4`

## Segurança

O Security Group criado permite tráfego nas seguintes portas:
- **5173** - React Frontend
- **8080** - Spring Boot API
- **5432** - PostgreSQL
- **80** - PgAdmin

## Destruir Infraestrutura

Para remover todos os recursos criados na AWS:

```bash
terraform destroy
```

## Observações Importantes

- O projeto foi configurado para funcionar em ambientes AWS Lab com restrições de IAM
- Não utiliza roles customizadas (execution_role_arn e task_role_arn)
- Usa a VPC padrão da conta AWS
- Região padrão configurada: `us-east-1`
