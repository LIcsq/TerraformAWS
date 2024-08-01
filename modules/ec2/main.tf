resource "aws_instance" "web" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  vpc_security_group_ids = var.security_group_ids

  user_data = var.user_data

  tags = merge(
    var.default_tags,
    {
      Name = "${var.project_name}-web"
    }
  )
}


