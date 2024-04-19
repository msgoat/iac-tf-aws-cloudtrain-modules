variable region_name {
  description = "The AWS region to deploy into (e.g. eu-central-1)."
  type = string
}

variable solution_name {
  description = "The name of the AWS solution that owns all AWS resources."
  type = string
}

variable solution_stage {
  description = "The name of the current AWS solution stage."
  type = string
}

variable solution_fqn {
  description = "The fully qualified name of the current AWS solution."
  type = string
}

variable common_tags {
  description = "Common tags to be attached to all AWS resources"
  type = map(string)
}

variable db_instance_name {
  description = "Logical name of the PostgreSQL instance"
  type = string
}

variable db_database_name {
  description = "Name of the database to create within the PostgreSQL instance"
  type = string
}

variable db_instance_class {
  description = "Instance type of virtual machine running the PostgreSQL instance"
  type = string
  default = "db.t4g.micro"
}

variable db_min_storage_size {
  description = "Minimum storage size of the PostgreSQL instance in gigabytes"
  type = number
  default = 20
}

variable db_max_storage_size {
  description = "Maximum storage size of the PostgreSQL instance in gigabytes"
  type = number
  default = 30
}

variable db_storage_type {
  description = "EBS storage type used for th PostgreSQL instance"
  type = string
  default = "gp3"
}

variable db_version {
  description = "PostgreSQL version"
  type = string
  default = "16.1"
}

variable vpc_id {
  description = "Unique identifier of the VPC supposed to host the database"
  type = string
}

variable db_subnet_ids {
  description = "Unique identifiers of subnets supposed to host the single database instance or the database cluster nodes"
  type = list(string)
}

variable generate_url_friendly_password {
  description = "Generates URL-friendly database passwords without special characters, if set to true"
  type = bool
  default = false
}

variable db_snapshot_id {
  description = "Optional unique identifier of a previously created final snapshot the PostgreSQL instance should be restored from"
  type = string
  default = null
}

variable final_db_snapshot_enabled {
  description = "Controls if a final snapshot should be created before the PostgreSQL instance is deleted; default is `true`"
  type = bool
  default = true
}
