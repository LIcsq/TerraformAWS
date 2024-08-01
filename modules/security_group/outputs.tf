output "web_security_group_id" {
  value = aws_security_group.web.id
}

output "rds_security_group_id" {
  value = aws_security_group.rds.id
}

output "elasticache_security_group_id" {
  value = aws_security_group.elasticache.id
}

output "elb_security_group_id" {
  value = aws_security_group.elb.id
}

