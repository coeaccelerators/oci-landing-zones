# Pull the state file of the existing Resource Manager stack (the network stack) into this context
data "oci_resourcemanager_stack_tf_state" "stack1_tf_state" {
  stack_id   = var.lzexpress_baseline_orm_stack_id
  local_path = "stack1.tfstate"
}

# Load the pulled state file into a remote state data source
data "terraform_remote_state" "external_stack_remote_state" {
  backend = "local"
  config = {
    path = "${data.oci_resourcemanager_stack_tf_state.stack1_tf_state.local_path}"
  }
}

locals {

  environment_prefix = data.terraform_remote_state.external_stack_remote_state.outputs.prod_environment.environment_prefix

  w_prefix = var.is_prod_workload ? "P" : "N"

  workload_prefix = join("-", [var.workload_name, local.w_prefix])

  hub_private_subnet_cidr_block = data.terraform_remote_state.external_stack_remote_state.outputs.prod_environment.hub_private_subnet_cidr

  hub_public_subnet_cidr_block = data.terraform_remote_state.external_stack_remote_state.outputs.prod_environment.hub_public_subnet_cidr

}