locals {
  db_security_group_name = "sec-${var.region_name}-${var.solution_fqn}-postgres-${var.db_instance_name}"
}

resource aws_security_group postgresql {
  name = local.db_security_group_name
  vpc_id = var.vpc_id
  tags = merge({
    Name = local.db_security_group_name
  }, local.module_common_tags)
}

resource aws_security_group_rule allow_inbound_tcp_from_vpc_to_postgres {
  type = "ingress"
  description = "allow anyone within the VPC to access the PostgreSQL instance nodes"
  from_port = 5432
  to_port = 5432
  protocol = "tcp"
  cidr_blocks = [data.aws_vpc.network.cidr_block]
  security_group_id = aws_security_group.postgresql.id
}

resource aws_security_group_rule allow_any_outbound {
  type = "egress"
  from_port = 0
  to_port = 65535
  protocol = "all"
  cidr_blocks = [
    "0.0.0.0/0"]
  security_group_id = aws_security_group.postgresql.id
}