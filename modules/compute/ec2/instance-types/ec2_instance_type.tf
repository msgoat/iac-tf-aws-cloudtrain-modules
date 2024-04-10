locals {
  start_filter = { }
  core_filter = merge( local.start_filter, var.cores != 0 ? { "vcpu-info.default-cores" = tostring(var.cores) } : { })
  memory_filter = merge( local.core_filter, var.memory != 0 ? { "memory-info.size-in-mib" = tostring(var.memory * 1024) } : { })
  cpu_architecture_filter = merge( local.memory_filter, { "processor-info.supported-architecture" = var.cpu_architecture })
  end_filter = local.cpu_architecture_filter
}

data aws_ec2_instance_types this {

  dynamic "filter" {
    for_each = local.end_filter
    content {
      name = filter.key
      values = [filter.value]
    }
  }
}

data aws_ec2_instance_type this {
  for_each = toset(data.aws_ec2_instance_types.this.instance_types)
  instance_type = each.value
}