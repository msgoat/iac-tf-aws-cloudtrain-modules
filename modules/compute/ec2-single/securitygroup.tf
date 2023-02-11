# create a default security group for EC2 instance
resource aws_security_group default {
  name        = "sec-${data.aws_region.current.name}-${var.solution_fqn}-${var.instance_name}-default"
  description = "Controls all inbound and outbound traffic passed through the EC2 instances"
  vpc_id      = data.aws_vpc.given.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.given.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # from here we have to connect to anything within this region
  }
  tags = merge({
    "Name" = "sg-${data.aws_region.current.name}-${var.solution_fqn}-${var.instance_name}-default"
  }, local.module_common_tags)
}
