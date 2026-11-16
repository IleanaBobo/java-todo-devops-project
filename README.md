# Java To-Do DevOps Project

# Project Overview

This project is a complete DevOps CI/CD implementation for a Java Spring Boot To-Do application.

The project automates:

* infrastructure provisioning,
* application build,
* testing,
* Docker image creation,
* Docker image publishing,
* deployment to AWS EC2 instances,
* Development and Production environments.

The entire flow is automated using:

* Jenkins,
* Terraform,
* Docker,
* Ansible,
* AWS,
* GitHub.


Production deployment is controlled separately through a dedicated Terraform pipeline and Production pipeline.

---

# Technologies Used

| Technology  | Purpose                         |
| ----------- | ------------------------------- |
| Java        | Backend application             |
| Spring Boot | REST API framework              |
| Maven       | Build and dependency management |
| Docker      | Containerization                |
| Docker Hub  | Docker image registry           |
| Jenkins     | CI/CD automation                |
| Terraform   | Infrastructure as Code          |
| Ansible     | Deployment automation           |
| AWS EC2     | Cloud virtual machines          |
| AWS S3      | Terraform remote backend        |
| GitHub      | Source code repository          |
| ngrok       | GitHub webhook testing          |

---

# Project Architecture

Developer
    ↓
GitHub Repository
    ↓
Jenkins Pipelines
    ↓
Terraform Infrastructure
    ↓
AWS EC2 Instances
    ↓
Docker Build + Push
    ↓
Docker Hub
    ↓
Ansible Deployment
    ↓
Running Application

---

# Project Flow

## Development Flow

1. Developer pushes code to `dev` branch.
2. Jenkins runs the DEV pipeline.
3. Maven builds the application.
4. Automated tests run.
5. Docker image is created.
6. Docker image is pushed to Docker Hub.
7. Ansible deploys the application automatically to DEV EC2.

---

## Production Flow

1. Code is merged into `main` branch.
2. Terraform pipeline is started manually.
3. User chooses Terraform action:

   * apply
   * destroy
4. Terraform provisions AWS infrastructure.
5. Terraform pipeline finishes successfully.
6. Production pipeline starts automatically.
7. Maven build and tests run.
8. Docker image is built.
9. Docker image is pushed to Docker Hub.
10. Ansible deploys the application to Production EC2.

---

# Branch Strategy

## dev branch

Used for:

* development,
* testing,
* automatic deployment to Development environment.

The DEV Jenkins pipeline uses:

Branch: dev
Jenkinsfile: Jenkinsfile-dev

---

## main branch

Used for:

* stable production-ready code,
* Terraform infrastructure deployment,
* Production deployment.

The PROD Jenkins pipeline uses:

Branch: main
Jenkinsfile: Jenkinsfile-prod

Terraform pipeline uses:

Branch: main
Jenkinsfile: Jenkinsfile-terraform

---

# Docker Multi-Stage Build

The project uses a multi-stage Docker build.

This reduces image size and separates:

* build environment,
* runtime environment.

Dockerfile:

1. Build Java application using Maven
2. Generate JAR file
3. Create lightweight runtime image
4. Run Spring Boot application

Port mapping:
8081:8080

Where:
- 8081 = host/server port
- 8080 = application port inside container


---

# Jenkins Pipelines

The project contains 3 separate Jenkins pipelines.

---

# 1. DEV Pipeline

File:

Jenkinsfile-dev

Pipeline stages:

1. Checkout code from GitHub
2. Build application with Maven
3. Run tests
4. Build Docker image
5. Push Docker image to Docker Hub
6. Deploy automatically to DEV environment
7. Cleanup workspace

Docker image:

ileanaboboescu07/java-todo-devops:dev-v1

---

# 2. Production Pipeline

File:

Jenkinsfile-prod

Purpose:

* Production deployment.

Pipeline stages:

1. Checkout code from GitHub
2. Build application
3. Run tests
4. Build Docker image
5. Push Docker image to Docker Hub
6. Deploy automatically to Production environment
7. Cleanup workspace

Docker image:

ileanaboboescu07/java-todo-devops:prod-v1

The Production pipeline starts automatically after Terraform pipeline success.

triggers {
    upstream(upstreamProjects: 'todo-terraform-prod', threshold: hudson.model.Result.SUCCESS)
}


---

# 3. Terraform Pipeline

File:

Jenkinsfile-terraform

Purpose:

* Infrastructure provisioning.

Pipeline stages:

1. Checkout code
2. Terraform init
3. Terraform plan
4. Terraform apply

Terraform actions are selected through Jenkins parameters:

parameters {
    choice(
        name: 'ACTION',
        choices: ['apply', 'destroy'],
        description: 'Choose Terraform action'
    )
}

Terraform currently uses:

terraform apply -auto-approve tfplan

The destroy stage is currently commented for safety.

---

# Terraform Infrastructure

Terraform provisions:

* DEV EC2 instance,
* PROD EC2 instance,
* Security Group,
* Elastic IPs.

---

# Terraform Files

## main.tf

Defines:

* AWS provider,
* EC2 instances,
* Security Groups,
* Elastic IPs,
* S3 backend.

---

## variables.tf

Defines reusable variables:

* region,
* instance type,
* key pair,
* AMI.

---

## outputs.tf

Displays:

* DEV public IP,
* PROD public IP.

---

# Terraform Remote State (S3 Backend)

Terraform state is stored remotely in AWS S3.

This prevents state loss when Jenkins workspace is cleaned.

Backend configuration:

terraform {
  backend "s3" {
    bucket = "java-todo-tfstate"
    key    = "terraform.tfstate"
    region = "eu-central-1"
  }
}


Benefits:

* persistent Terraform state,
* safer pipelines,
* infrastructure consistency,
* closer to real enterprise setup.

---

# Terraform Commands

## Terraform Init

terraform init -migrate-state -force-copy

---

## Terraform Plan

terraform plan -out=tfplan

Creates a Terraform execution plan.

The plan is saved locally into:

tfplan

---

## Terraform Apply

terraform apply -auto-approve tfplan

Applies the exact previously generated plan.

---

# What is tfplan?

`tfplan` is a temporary Terraform plan file.

Terraform first calculates:

* resources to create,
* resources to modify,
* resources to destroy.

The calculated plan is stored in:

tfplan

Terraform apply later executes that exact plan.

---

# Elastic IP

Elastic IPs provide static public IP addresses.

Without Elastic IP:

* EC2 public IP changes after restart.

With Elastic IP:

* public IP remains permanent.

Benefits:

* stable SSH access,
* stable Jenkins deployment,
* stable browser access.

---

# Jenkins Workspace

Jenkins creates local workspaces inside the Jenkins container.

Workspace location:

/var/jenkins_home/workspace


Examples:

todo-dev-pipeline
todo-prod-pipeline
todo-terraform-prod

Workspace contains:

* source code,
* Maven artifacts,
* Docker build context,
* Terraform files,
* tfplan,
* temporary files.

---

# Workspace Cleanup

DEV and PROD pipelines use:

post {
    always {
        cleanWs()
    }
}


This automatically cleans temporary Jenkins files after build completion.

Terraform pipeline does not use cleanup because Terraform state must remain persistent.

---

# Jenkins Container

Jenkins runs inside Docker.

Container access:

docker exec -it jenkins bash


---

# Useful Jenkins Container Commands

## Open Jenkins workspace

cd /var/jenkins_home/workspace

---

## View Terraform workspace

cd /var/jenkins_home/workspace/todo-terraform-prod/terraform


---

## List Terraform resources

terraform state list

---

## View Terraform state

cat terraform.tfstate


---

## Check Jenkins workspace size

du -h --max-depth=1 /var/jenkins_home/workspace

---

# Docker Commands

## Build Docker image

docker build -t java-todo-devops .

---

## Run Docker container

docker run -d -p 8081:8080 java-todo-devops

---

## View running containers

docker ps

---

# AWS EC2 Access

## DEV Server

ssh -i ~/.ssh/devops-final-key-v2.pem ubuntu@DEV_IP

---

## PROD Server

ssh -i ~/.ssh/devops-final-key-v2.pem ubuntu@PROD_IP

---

# Ansible Deployment

Ansible deploys the application automatically to AWS EC2.

Deployment steps:

1. Connect to EC2 using SSH
2. Install Docker
3. Pull Docker image
4. Remove old container
5. Start new container

---

# Ansible Commands

## Deploy DEV

ansible-playbook ansible/deploy-dev.yml -i ansible/inventory.ini

---

## Deploy PROD

ansible-playbook ansible/deploy-prod.yml -i ansible/inventory.ini

---

# Docker Hub

Docker images are stored in Docker Hub.

DEV image:

ileanaboboescu07/java-todo-devops:dev-v1

PROD image:

ileanaboboescu07/java-todo-devops:prod-v1

---

# Application Endpoints

## Get tasks

GET /tasks

---

## Create task

POST /tasks

---

## Update task

PUT /tasks/{id}

---

## Delete task

DELETE /tasks/{id}

---

## Health endpoint

GET /health

---

# Verify Application in Browser

## DEV

http://DEV_IP:8081/tasks

---

## PROD

http://PROD_IP:8081/tasks

---

# Create Task Example

curl -X POST http://IP:8081/tasks \
-H "Content-Type: application/json" \
-d '{"title":"Test task"}'

---

# Health Check Example

http://IP:8081/health

---

# Git Commands Used During Development

## Switch branch

git checkout dev

---

## Merge main into dev

git merge main

---

## Push changes

git push origin dev

---

# GitHub Webhook + ngrok

GitHub webhook was configured using ngrok.

ngrok exposes local Jenkins publicly.

Example:

ngrok http 60199

Webhook URL example:

https://example.ngrok-free.app/github-webhook/

---

# Future Improvements

Possible future improvements:

* Kubernetes deployment,
* Nginx reverse proxy,
* HTTPS with SSL,
* Monitoring with Prometheus/Grafana,
* GitHub Actions integration,
* Terraform modules,
* Blue/Green deployment,
* Docker Compose,

---

# Final Notes

This project demonstrates a complete DevOps workflow using real-world tools and technologies.
The project was implemented and configured manually step-by-step, including troubleshooting and infrastructure management tasks.

