provider "aws" {
  region = "us-east-1"
}

provider "vault" {
  address = var.vault_addr
  token   = var.vault_token
}

data "vault_kv_secret_v2" "db_credentials" {
  mount = "secret"
  name  = "db_credentials"
}

terraform {
  backend "s3" {
    bucket         = "myconfterraform"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
  }
}

module "vpc" {
  source              = "./modules/vpc"
  cidr_block          = var.cidr_block
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zones  = var.availability_zones
  project_name        = var.project_name
  default_tags        = var.default_tags
}

module "security_group" {
  source       = "./modules/security_group"
  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
  default_tags = var.default_tags
}

module "rds" {
  source            = "./modules/rds"
  subnet_ids        = module.vpc.private_subnet_ids
  db_name           = data.vault_kv_secret_v2.db_credentials.data["db_name"]
  username          = data.vault_kv_secret_v2.db_credentials.data["db_username"]
  password          = data.vault_kv_secret_v2.db_credentials.data["db_password"]
  security_group_id = module.security_group.rds_security_group_id
  project_name      = var.project_name
  default_tags      = var.default_tags
}

module "elasticache" {
  source               = "./modules/elasticache"
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.vpc.private_subnet_ids
  security_group_id    = module.security_group.elasticache_security_group_id
  project_name         = var.project_name
  default_tags         = var.default_tags
}

module "ec2" {
  source             = "./modules/ec2"
  subnet_id          = element(module.vpc.public_subnet_ids, 0)  
  ami                = "ami-03972092c42e8c0ca"  
  instance_type      = "t2.micro"
  security_group_ids = [module.security_group.web_security_group_id]  
  project_name       = var.project_name
  default_tags       = var.default_tags

  user_data = templatefile("${path.module}/wordpress_conf/install_wordpress.sh", {
    db_name     = data.vault_kv_secret_v2.db_credentials.data["db_name"],
    db_user     = data.vault_kv_secret_v2.db_credentials.data["db_username"],
    db_password = data.vault_kv_secret_v2.db_credentials.data["db_password"],
    db_host     = module.rds.rds_endpoint,
    redis_host  = module.elasticache.redis_endpoint
    })
}

resource "aws_eip" "ec2" {
  instance = module.ec2.instance_id
  domain   = "vpc"

  tags = merge(
    var.default_tags,
    {
      Name = "${var.project_name}-eip"
    }
  )
}

module "elb" {
  source             = "./modules/elb"
  subnets            = module.vpc.public_subnet_ids
  security_group_ids = [module.security_group.elb_security_group_id]
  project_name       = var.project_name
  default_tags       = var.default_tags
  instance_id        = module.ec2.instance_id
  vpc_id             = module.vpc.vpc_id
}


