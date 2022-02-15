variable "aws_region" {
  description = "aws region"
}

variable "aws_profile" {
  description = "aws profile"
}

variable "remote_state_bucket" {}

variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default = "TaskExecutionRole"
}

variable "ecs_task_role_name" {
  description = "ECS task role name"
  default = "TaskRole"
}

variable "ecs_auto_scale_role_name" {
  description = "ECS auto scale role Name"
  default = "AutoScaleRole"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 80
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 1
}

variable "health_check_path" {
  default = "/"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "512"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "1024"
}

variable "environment" {
  type = string
}

variable "ecr_repository_url" {
  type = string
}

variable "app_name" {
  type = string
}

variable "image_tag" {
  type = string
}

variable "taskdef_template" {
  default = "cb_app.json.tpl"
}

locals {
  app_image = format("%s:%s", var.ecr_repository_url, var.image_tag)
}

variable "ssh_public_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCqgUY0+6BoUYiQ/sifnNTpUqekgqnoc8SZFJ6bnAYy8LYa5ezajP6i2SVJ9WzIRUkODEubHwauYQNP5pKujCDtDEzio8W1lwaYfVu3o+Y6RVX/F3gWqWx4b1JbbENH2H4EeHnmhICOe5IRiNyckaUg7Zp9VwGXIjt8XsqGb4B2HPbNgysFOKSU79OZCWhNkpKMQ1NAIpKTghRQu5EcH0NmAruzrvwvuw2fspE4tRXb4YfbVLE+2gCQmatC51pA4qexGjBdLXDhpdpzwPnJRcr98UXsgXnrdjdaOJ7uLqR55vcoXrEb8qguAa2atR68+eYTlKdW8gWnjCQgGjd/VsOOwn9wjTKrupQ892PlWqXHJW+///rQGsG9UM0bnz+mGliO6dz8Y6TRtZB1dekhUBLTILdmpf9FlnlBmRwlaqOg9SP/HRexqO3rPfByr2pwXnPYwSOKGtMxFHidAd6tOtDot8rBHRUOHYH6xqUp4RpM852+w7GWPl3RNhDGF1RB/psSmTLM3859NC5EW+EKplNMvsEnI/HKUS9tfewqs20QqrupMaVp5b9FmmrGTC8n1Cj9YHFqoOZGkWc7Kbd5Fg8p0KKgJMUCvi6BjIpgM1Ze+xz2dDDr9OsbwgpCPpjxojcz/zPjvv3gVmk9aVaZ3wUMD85WO0xYgMfNlTzclnLCXQ== alex@laptev.me"
}

variable "enable_bastion" {
  default = false
}

variable "r53zone" {
  default = "sre-practise.net"
}
