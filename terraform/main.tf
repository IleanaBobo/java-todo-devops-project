terraform {
  backend "s3" {
    bucket = "java-todo-tfstate"
    key    = "terraform.tfstate"
    region = "eu-central-1"
  }
}

 provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "devops_sg" {
  name        = "devops-final-sg"
  description = "Allow SSH and app traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Application"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "dev_server" {
  ami                    = "ami-02003f9f0fde924ea"
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.devops_sg.id]

  tags = {
    Name = "devops-dev-server"
    Environment = "dev"
  }
}

resource "aws_instance" "prod_server" {
  ami                    = "ami-02003f9f0fde924ea"
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.devops_sg.id]

  tags = {
    Name = "devops-prod-server"
    Environment = "prod"
  }
}

resource "aws_eip" "dev_eip" {
instance = aws_instance.dev_server.id

tags = {
Name = "dev-elastic-ip"
}
}

resource "aws_eip" "prod_eip" {
instance = aws_instance.prod_server.id

tags = {
Name = "prod-elastic-ip"
}
}
