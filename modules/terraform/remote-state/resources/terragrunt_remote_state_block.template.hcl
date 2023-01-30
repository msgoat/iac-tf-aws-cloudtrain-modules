remote_state {
  backend = "s3"
  generate = {
    path = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket = "${tf_s3_bucket_name}"
    dynamodb_table = "${tf_dynamodb_table_name}"
    key = "$${path_relative_to_include()}/terraform.tfstate"
  }
}