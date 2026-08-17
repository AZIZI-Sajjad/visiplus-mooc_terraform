# Variable pour la clé d'accès AWS
variable "access_key" {
  # Type de la variable
  type = string
}

# Variable pour la clé secrète AWS
variable "secret_key" {
  # Type de la variable
  type = string
}

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Project name used to tag and prefix resources"
  type        = string
  default     = "aws-terraform-starter"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type (default is free-tier eligible)"
  type        = string
  default     = "t3.micro"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into the EC2 instance. Default is intentionally restrictive — override via tfvars."
  type        = string
  default     = "0.0.0.0/0"
}
