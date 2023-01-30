terraform {
  backend "s3" {
    bucket = "${tf_s3_bucket_name}"
    dynamodb_table = "${tf_dynamodb_table_name}"
    key = "${tf_state_key_name}"
  }
}
