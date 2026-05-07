# Java To-Do DevOps Project
## Description

This project implements a complete CI/CD pipeline for a Java Spring Boot To-Do application.

The application is containerized with Docker and will be automatically deployed to AWS EC2 instances using Jenkins, Terraform and Ansible.

The project includes two environments:
- Development
- Production

---

## Technologies Used

- Java 17
- Spring Boot
- Maven
- Docker
- Jenkins
- Terraform
- Ansible
- AWS EC2
- GitHub
- Docker Hub

---

## Application Features

The application provides a simple REST API for task management.

Available endpoints:

- `GET /tasks`
- `POST /tasks`
- `PUT /tasks/{id}`
- `DELETE /tasks/{id}`
- `GET /health`

---

## Local Run

### Run with Maven

```bash
mvn spring-boot:run -Dspring-boot.run.arguments=--server.port=8081
