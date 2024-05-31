# Pull the state file of the existing Resource Manager stack (the network stack) into this context
data "oci_resourcemanager_stack_tf_state" "stack2_tf_state" {
  stack_id   = var.lzexpress_baseline_backup_orm_stack_id
  local_path = "stack2.tfstate"
}

# Load the pulled state file into a remote state data source
data "terraform_remote_state" "external_stack_remote_state_backup" {
  backend = "local"
  config = {
    path = "${data.oci_resourcemanager_stack_tf_state.stack2_tf_state.local_path}"
  }
}

locals {
  
  hub_private_subnet_cidr_block = data.terraform_remote_state.external_stack_remote_state_backup.outputs.hub_private_subnet_cidr

  hub_public_subnet_cidr_block = data.terraform_remote_state.external_stack_remote_state_backup.outputs.hub_public_subnet_cidr

  hub_vcn_cidr_block = data.terraform_remote_state.external_stack_remote_state_backup.outputs.hub_vcn_cidr

  drg_id = data.terraform_remote_state.external_stack_remote_state_backup.outputs.drg_id

  default_log_group_id = data.terraform_remote_state.external_stack_remote_state_backup.outputs.default_group_id

}