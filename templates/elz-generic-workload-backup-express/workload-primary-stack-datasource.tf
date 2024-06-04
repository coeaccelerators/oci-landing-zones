# Pull the state file of the existing Resource Manager stack (the network stack) into this context
data "oci_resourcemanager_stack_tf_state" "stack1_tf_state" {
  stack_id   = var.lzexpress_primary_workload_orm_stack_id
  local_path = "stack1.tfstate"
}

# Load the pulled state file into a remote state data source
data "terraform_remote_state" "external_stack_remote_state_workload" {
  backend = "local"
  config = {
    path = "${data.oci_resourcemanager_stack_tf_state.stack1_tf_state.local_path}"
  }
}

locals {
  
  workload_compartment_id = data.terraform_remote_state.external_stack_remote_state_workload.outputs.workload.workload_compartment_id

  workload_compartment_name = data.terraform_remote_state.external_stack_remote_state_workload.outputs.workload.workload_compartment_name

}