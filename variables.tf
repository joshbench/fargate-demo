variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "The AWS CLI profile on the local filesystem to use"
  default     = "default"
}

variable "ecs_cluster_name" {
  description = "Name of the ecs cluster to create"
  default     = "example-ecs-cluster"
}

variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "jbench-fargate:latest"
}

variable "app_name" {
  description = "Name of the container to run as a task"
  default     = "jbench-fargate"
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 1
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "256"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "512"
}