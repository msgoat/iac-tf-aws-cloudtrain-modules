# variables.tf
# ---------------------------------------------------------------------------
# Defines all input variable for this demo.
# ---------------------------------------------------------------------------

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

variable vpc_id {
  description = "Unique identifier of the VPC supposed to host the database"
  type = string
}

variable db_subnet_ids {
  description = "Unique identifiers of subnets supposed to host the single database instance or the database cluster nodes"
  type = list(string)
}

variable kubernetes_namespace {
  description = "Name of the Kubernetes namespace supposed to contain a database secret"
  type = list(string)
}
