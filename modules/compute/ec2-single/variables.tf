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

variable vpc_id {
  description = "Unique identifier of the VPC to host the EC2 instance(s)."
  type = string
}

variable subnet_id {
  description = "Unique identifier of the subnet to host the EC2 instance(s)."
  type = string
}

variable ami_id {
  description = "Unique identifier of the AMI all EC2 instances are supposed to be based on."
  type = string
}

variable instance_name {
  description = "Name of the EC2 instance; will be used as a suffix to the fully qualified instance name"
  type = string
}

variable instance_type {
  description = "EC2 instance type"
  type = string
}

variable instance_key_name {
  description = "Name of SSH key pair name to used for the EC2 instances"
  type = string
}

variable security_group_ids {
  description = "Unique identifiers of security groups to be attached to the EC2 instances"
  type = list(string)
  default = []
}

variable root_volume_size {
  description = "Size of the root volume of all EC2 instances"
  type = number
}

variable data_volume_size {
  description = "Size of the data volume (i.e. secondary volume) of all EC2 instances"
  type = number
}

