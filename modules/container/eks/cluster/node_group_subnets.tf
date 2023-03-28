locals {
  node_group_subnet_ids = distinct(flatten([ for ngt in var.node_group_templates : ngt.subnet_ids if ngt.enabled]))
}
