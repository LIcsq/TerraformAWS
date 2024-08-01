output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "redis_endpoint" {
  value = module.elasticache.redis_endpoint
}

output "ec2_public_ip" {
  value = aws_eip.ec2.public_ip
}

output "elb_dns_name" {
  value = module.elb.elb_dns_name
}


