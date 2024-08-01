resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.default_tags,
    {
      Name = "${var.project_name}-subnet-group"
    }
  )
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.project_name}-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  subnet_group_name    = aws_elasticache_subnet_group.main.name
  security_group_ids   = [var.security_group_id]

  tags = merge(
    var.default_tags,
    {
      Name = "${var.project_name}-redis"
    }
  )
}


