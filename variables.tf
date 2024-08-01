variable "vault_token" {
  description = "Vault token for authentication"
  type        = string
  default     = ""  
}

variable "vault_addr" {
  description = "Vault ip for vault server"
  type        = string
  default     = ""
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "wordpress-project"
}

variable "default_tags" {
  description = "Default tags to apply to resources"
  type        = map(string)
  default     = {
    "Environment" = "dev"
    "Project"     = "wordpress-project"
  }
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidr" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones for subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"] 
}

