# Java To-Do DevOps Project

## Project Description

This project implements a complete CI/CD pipeline for a Java Spring Boot To-Do application.

The application is containerized with Docker and automatically deployed to AWS EC2 instances using Jenkins, Terraform, and Ansible.

The project includes two environments:

- Development
- Production

The pipeline supports:
- automated build,
- automated testing,
- Docker image creation,
- Docker image publishing,
- deployment automation,
- Production deployment.

# Technologies Used

| Technology | Purpose |
| Java       | Backend application |
| Spring Boot | REST API framework |
| Maven       | Build and dependency management |
| Docker      | Containerization |
| Docker Hub  | Docker image registry |
| Jenkins     | CI/CD automation |
| Terraform   | Infrastructure as Code |
| Ansible     | Deployment automation |
| AWS EC2     | Cloud virtual machines |
| GitHub      | Source code repository |

# Project Architecture

Developer
    ↓
GitHub Repository
    ↓
Jenkins Pipeline
    ↓
Maven Build + Tests
    ↓
Docker Build
    ↓
Docker Hub Push
    ↓
Deploy DEV
    ↓
Manual Approval
    ↓
Deploy PROD
    ↓
AWS EC2

# Application Features

The application provides a REST API for task management.

Available endpoints:
GET /tasks
POST /tasks
PUT /tasks/{id}
DELETE /tasks/{id}
GET /health

# Local Run

## Run with Maven

mvn spring-boot:run -Dspring-boot.run.arguments=--server.port=8081

# Docker

Docker is used to containerize the Spring Boot application.

The application runs inside a Docker container instead of directly on the host machine.

Advantages:
- portability,
- isolated runtime environment,
- easier deployment,
- consistent execution.

## Docker Commands

### Build Docker Image
docker build -t java-todo-devops .

### Run Docker Container
docker run -d -p 8081:8080 java-todo-devops

### View Running Containers
docker ps

### Stop Container
docker stop <container_id>

# Docker Hub

Docker Hub is used as a container registry.

Jenkins pushes Docker images to Docker Hub.

Ansible later pulls the images on AWS EC2 instances during deployment.

Example image:
ileanaboboescu07/java-todo-devops:dev-v1

# AWS Infrastructure with Terraform

Terraform is used for Infrastructure as Code (IaC).

The infrastructure is defined using code instead of manual AWS configuration.

Terraform automatically provisions:
- EC2 instances,
- Security Groups,
- network access rules.

## Resources Created

- Development EC2 instance
- Production EC2 instance
- Security Group for SSH and application access

# Terraform Files

## main.tf

Defines AWS infrastructure resources:
- AWS provider,
- Security Groups,
- EC2 instances.

## variables.tf

Defines reusable variables:
- AWS region,
- EC2 instance type,
- SSH key name.

## outputs.tf

Displays useful outputs after deployment:
- Development server public IP,
- Production server public IP.

# Terraform Commands

## Initialize Terraform
terraform init

## Preview Infrastructure Changes
terraform plan

## Create Infrastructure
terraform apply

## Destroy Infrastructure
terraform destroy


# Elastic IP

Elastic IPs are used to provide static public IP addresses.

Without Elastic IP:
- the public IP changes after stopping and starting EC2 instances.

With Elastic IP:
- the public IP remains permanent.

Benefits:
- stable SSH access,
- stable Jenkins deployment configuration,
- stable browser access.

# SSH Access

## Development Server
ssh -i ~/.ssh/devops-final-key-v2.pem ubuntu@DEV_IP

## Production Server
ssh -i ~/.ssh/devops-final-key-v2.pem ubuntu@PROD_IP


# Deployment Automation with Ansible

Ansible is used to automate application deployment on AWS EC2 instances.

The Ansible playbook performs the following actions:

- connects to EC2 instances via SSH,
- installs Docker,
- pulls the Docker image from Docker Hub,
- removes old containers,
- starts the new application container.

# Ansible Files

## inventory.ini

Contains:
- target servers,
- SSH configuration,
- SSH private key path.

## deploy-dev.yml

Deployment playbook for the Development environment.

## deploy-prod.yml

Deployment playbook for the Production environment.


# Run Ansible Deployment

## Deploy Development
ansible-playbook ansible/deploy-dev.yml -i ansible/inventory.ini

## Deploy Production
ansible-playbook ansible/deploy-prod.yml -i ansible/inventory.ini


# Jenkins CI/CD

Jenkins runs inside a Docker container on the Ubuntu VM.

The Jenkins container uses the host Docker daemon through Docker socket mount:

-v /var/run/docker.sock:/var/run/docker.sock

This allows Jenkins to:
- build Docker images,
- push images to Docker Hub,
- automate deployments.

The Docker group ID from the host system was added to the Jenkins container to allow Docker access.

# Jenkins Pipeline Stages

The Jenkins pipeline automates the entire CI/CD process.

Pipeline stages:

1. Checkout source code from GitHub
2. Build application using Maven
3. Run automated tests
4. Build Docker image
5. Push Docker image to Docker Hub
6. Deploy automatically to Development environment
7. Wait for manual approval
8. Deploy automatically to Production environment

# Jenkinsfile Overview

The Jenkinsfile defines the CI/CD pipeline.

Important stages:

## Build Stage
sh 'mvn clean package'

Compiles and packages the application.

## Test Stage
sh 'mvn test'

Runs automated tests.

## Docker Build Stage
sh 'docker build -t ileanaboboescu07/java-todo-devops:dev-v1 .'

Builds the Docker image.

## Docker Push Stage
sh 'docker push ileanaboboescu07/java-todo-devops:dev-v1'

Pushes the image to Docker Hub.

## Deploy DEV Stage
sh 'ansible-playbook ansible/deploy-dev.yml -i ansible/inventory.ini'

Deploys the application to the Development environment.

## Approval Stage
input 'Deploy to Production?'

Waits for manual approval before Production deployment.

## Deploy PROD Stage
sh 'ansible-playbook ansible/deploy-prod.yml -i ansible/inventory.ini'

Deploys the application to the Production environment.


# Application Access

## Development Environment
http://DEV_IP:8081/tasks

## Production Environment
http://PROD_IP:8081/tasks


# Create Task Example
curl -X POST http://3.76.178.231:8081/tasks \-H "Content-Type: application/json" \-d '{"title":"Test task"}'

Check tasks in browser:
http://IP:8081/tasks

If the endpoint returns:
[]

it means:
- the application is running correctly,
- the REST API works,
- the task list is currently empty.


# Problems Solved During Implementation

The project implementation included solving several DevOps issues:

- Docker daemon permission issues inside Jenkins container,
- SSH key permission configuration,
- Docker socket access inside Jenkins container,
- Docker Hub authentication,
- Ansible host verification issues,
- Elastic IP configuration,
- Jenkins container configuration,
- AWS public IP changes after EC2 restart...
