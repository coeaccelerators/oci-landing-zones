
locals {

  # default_log_group_id = var.default_log_group_id != "" ? var.default_log_group_id : local.default_log_group_id

  vcn_flow_log = {
    log_display_name    = "${var.resource_label}-OCI-ELZ-VCN-FLOW-LOG-${local.environment_prefix}-${var.workload_name}"
    log_type            = "SERVICE"
    log_source_category = "all"
    log_source_service  = "flowlogs"
    log_source_type     = "OCISERVICE"
  }

  subnets_map = {
    SPK1 : module.workload_spoke_SUB001_subnet.subnets["OCI-ELZ-${local.workload_prefix}-EXP-SPK-SUB-${local.region_key[0]}-SUB001"]
    SPK2 : module.workload_spoke_SUB002_subnet.subnets["OCI-ELZ-${local.workload_prefix}-EXP-SPK-SUB-${local.region_key[0]}-SUB002"]
    SPK3 : module.workload_spoke_SUB003_subnet.subnets["OCI-ELZ-${local.workload_prefix}-EXP-SPK-SUB-${local.region_key[0]}-SUB003"]
  }

}

module "vcn_flow_log" {
  source = "../../modules/service-log-old"

  service_log_map     = local.subnets_map
  log_display_name    = local.vcn_flow_log.log_display_name
  log_type            = local.vcn_flow_log.log_type
  log_group_id        = local.default_log_group_id
  log_source_category = local.vcn_flow_log.log_source_category
  log_source_service  = local.vcn_flow_log.log_source_service
  log_source_type     = local.vcn_flow_log.log_source_type

  providers = {
    oci = oci.backup_region
  }
  
}
