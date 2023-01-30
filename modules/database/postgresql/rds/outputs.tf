output db_instance_id {
  description = "Unique identifier of the DB instance"
  value = aws_db_instance.postgresql.arn
}

output db_host_name {
  description = "Host name of the DB endpoint"
  value = split(":", aws_db_instance.postgresql.endpoint)[0]
}

output db_host_ip {
  description = "IP address of the DB endpoint"
  value = aws_db_instance.postgresql.address
}

output db_port_number {
  description = "Port number of the DB endpoint"
  value = aws_db_instance.postgresql.port
}

output db_secret_name {
  description = "Name of the AWS SecretsManager secret holding username and password of the database admin user"
  value = aws_secretsmanager_secret.postgres.name
}

output db_secret_id {
  description = "Unique identifier of the AWS SecretsManager secret holding username and password of the database admin user"
  value = aws_secretsmanager_secret.postgres.id
}
