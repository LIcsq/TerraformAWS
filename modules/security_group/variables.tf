variable "vpc_id" {
  description = "The ID of the VPC"
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

