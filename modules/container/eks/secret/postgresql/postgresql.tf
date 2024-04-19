data aws_db_instance given {
  db_instance_identifier = var.db_instance_id
}

locals {
  db_instance_name = data.aws_db_instance.given.tags["Name"]
}