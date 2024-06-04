locals {

  osms_dynamic_group_workload = {
    dynamic_group_name        = "DG-${local.environment_prefix}-${local.workload_prefix}"
    dynamic_group_description = "OCI ELZ Dynamic Group - ${local.workload_prefix}"

    general_matching_rule = <<EOT
    Any {
      instance.compartment.id = '${module.workload_compartment.compartment_id}'
    }
    EOT
  }

  bastion = {
    name = "BAS-${local.environment_prefix}-${local.workload_prefix}"
  }

}

module "osms_dynamic_group" {
  source        = "../../modules/dynamic-group"
  tenancy_ocid  = var.tenancy_ocid
  description   = local.osms_dynamic_group_workload.dynamic_group_description
  name          = local.osms_dynamic_group_workload.dynamic_group_name
  matching_rule = local.osms_dynamic_group_workload.general_matching_rule

  depends_on = [module.workload_compartment]
}

module "bastion" {
  source                               = "../../modules/bastion"
  count                                = var.enable_bastion ? 1 : 0
  target_subnet_id                     = module.workload_spoke_SUB001_subnet.subnets["${local.workload_prefix}-EXP-SPK-SUB-${local.region_key[0]}-SUB001"]
  bastion_client_cidr_block_allow_list = var.bastion_client_cidr_block_allow_list
  bastion_name                         = local.bastion.name
  # compartment_id                       = var.security_compartment_id
  compartment_id = data.terraform_remote_state.external_stack_remote_state.outputs.prod_environment.compartments.security.id
}
