# variables.tf

variable region_name {
  description = "The AWS region to deploy into (e.g. eu-central-1)."
  type = string
}

variable solution_name {
  description = "The name of the solution that owns all AWS resources."
  type = string
}

variable solution_stage {
  description = "The name of the current environment stage."
  type = string
}

variable solution_fqn {
  description = "The fully qualified name of the solution (i.e. solution_name + solution_stage in most cases)."
  type = string
}

variable common_tags {
  description = "Common tags to be attached to all AWS resources."
  type = map(string)
}

variable backend_name {
  description = "Name of the Terraform backend"
  type = string
  default = "terraform"
}