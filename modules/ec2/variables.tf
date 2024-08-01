variable "ami" {
  description = "The ID of the AMI to use for the instance"
  type        = string
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet to associate with the instance"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with"
  type        = list(string)
}

variable "user_data" {
  description = "The user data to provide when launching the instance"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "default_tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
}

