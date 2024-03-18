# Terraform Module database/aurora/serverless

Provisions an AWS Aurora Serverless V2 cluster in PostgreSQL compatibility mode.

## Default Aurora cluster configuration

* Master username is a random alphanumeric character sequence.
* Master user password is a random character sequence with supported special characters.
* Master user information is stored as a AWS SecretsManager secret.
* Aurora storage is encrypted using AWS KMS customer managed keys.

