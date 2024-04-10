output ec2_instance_types {
  description = "Found EC2 instance types"
  value = data.aws_ec2_instance_type.this
}
