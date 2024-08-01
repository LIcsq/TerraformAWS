variable "subnets" {
  description = "List of subnet IDs for the ELB"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the ELB"
  type        = list(string)
}

variable "instance_id" {
  description = "Instance ID to attach to the target group"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "default_tags" {
  description = "Default tags to apply to resources"
  type        = map(string)
}

