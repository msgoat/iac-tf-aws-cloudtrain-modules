data "aws_subnet" "given" {
  count = length(var.node_group_subnet_ids)
  id    = var.node_group_subnet_ids[count.index]
}