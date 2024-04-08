output "terraform_backend_file" {
  description = "Contents of the backend.tf file to be added to project"
  value       = local.terraform_backend_file
}

output "terraform_backend_config" {
  description = "Contents of the backend configuration file passed as command line argument `backend-config`"
  value       = local.terraform_backend_config
}

output "terragrunt_remote_state_block" {
  description = "Contents of remote_state block to be added to Terragrunt configuration files"
  value       = local.terragrunt_remote_state_block
}