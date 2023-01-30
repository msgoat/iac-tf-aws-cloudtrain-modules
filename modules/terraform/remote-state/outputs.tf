output terraform_backend_file {
  description = "Contents of the backend.tf file to be added to project"
  value = local.terraform_backend_file
}

output terragrunt_remote_state_block {
  description = "Contents of remote_state block to be added to Terragrunt configuration files"
  value = local.terragrunt_remote_state_block
}