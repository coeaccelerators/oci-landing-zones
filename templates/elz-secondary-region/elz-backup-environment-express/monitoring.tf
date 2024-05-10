module "monitoring" {
  source             = "../elz-backup-monitoring"
  tenancy_ocid       = var.tenancy_ocid
  backup_region                     = var.backup_region
  environment_prefix = var.environment_prefix
  resource_label     = var.resource_label
  home_compartment_id  = data.terraform_remote_state.external_stack_remote_state.outputs.prod_environment.compartments.environment.compartment_id
  is_baseline_deploy           = var.is_baseline_deploy

  environment_compartment_id = data.terraform_remote_state.external_stack_remote_state.outputs.prod_environment.compartments.environment.id
  security_compartment_id    = data.terraform_remote_state.external_stack_remote_state.outputs.prod_environment.compartments.security.id
  network_compartment_id     = data.terraform_remote_state.external_stack_remote_state.outputs.prod_environment.compartments.network.id
  workload_compartment_id    = var.workload_compartment_id

  is_create_alarms         = var.is_create_alarms
  network_topic_endpoints  = var.network_topic_endpoints
  secops_topic_endpoints   = var.secops_topic_endpoints
  platform_topic_endpoints = var.platform_topic_endpoints
  identity_topic_endpoints = var.identity_topic_endpoints
  default_log_group_id     = module.logging.log_group_id

  workload_topic_endpoints = var.workload_topic_endpoints

  enable_security_monitoring_alarms = var.enable_security_monitoring_alarms
  enable_network_monitoring_alarms  = var.enable_network_monitoring_alarms
  enable_workload_monitoring_alarms = var.enable_workload_monitoring_alarms

  providers = {
    oci               = oci
    oci.backup_region = oci.backup_region
  }
}