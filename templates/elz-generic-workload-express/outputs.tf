output "workload" {
  value = {
    environment_prefix        = local.environment_prefix
    workload_compartment_name = local.workload_compartment.name
    workload_compartment_id   = module.workload_compartment.compartment_id
    spoke_vcn                 = module.workload_spoke_vcn.vcn_id
    bastion_id                = var.enable_bastion ? module.bastion[0].bastion_ocid : null
    workload_SUB001_cidr         = var.workload_private_spoke_subnet_SUB001_cidr_block
    workload_SUB002_cidr         = var.workload_private_spoke_subnet_SUB002_cidr_block
    workload_SUB003_cidr          = var.workload_private_spoke_subnet_SUB003_cidr_block
    
  }
}
