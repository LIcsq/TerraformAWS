variable "db_name" {
  description = "The name of the database"
  type        = string
}

variable "username" {
  description = "The username for the database"
  type        = string
}

variable "password" {
  description = "The password for the database"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "The ID of the security group"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "default_tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

