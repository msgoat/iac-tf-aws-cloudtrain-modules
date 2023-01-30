# Terraform Module postgresql

Provisions a PostgreSQL instance managed by AWS RDS.

## Default PostgreSQL instance configuration

* Master username is a random alphanumeric character sequence.
* Master user password is a random character sequence with supported special characters.
* Master user information is stored as a AWS SecretsManager secret.
* PostgreSQL storage is encrypted using AWS KMS customer managed keys.

## TODO's

| TODO | Status      |
| --- |-------------| 
| add support of customer master keys | pending |