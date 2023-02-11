output ec2_instance_id {
  description = "Unique identifier of the newly created EC2 instance"
  value = aws_instance.single.id
}

output ec2_instance_name {
  description = "Name of the newly created EC2 instance"
  value = aws_instance.single.tags["Name"]
}