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

variable eks_cluster_id {
  description = "Unique identifier of an AWS EKS cluster"
  type = string
}

variable db_instance_id {
  description = "Unique identifier of an AWS RDS PostgreSQL instance"
  type = string
}

variable sm_secret_id {
  description = "Unique identifier of an AWS Secret Manager secret which contains the PostgreSQL user and password"
  type = string
}

variable kubernetes_namespace_names {
  description = "Names of the Kubernetes namespaces the secret should be created in"
  type = list(string)
}
