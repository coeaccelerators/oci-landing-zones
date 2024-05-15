##########################################################################################################
# Copyright (c) 2022,2023 Oracle and/or its affiliates, All rights reserved.                             #
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl. #
##########################################################################################################

module "logging" {
  source                              = "../elz-backup-logging"
  backup_region                       = var.backup_region
  environment_prefix                  = var.environment_prefix
  tenancy_ocid                        = var.tenancy_ocid
  security_compartment_id             = data.terraform_remote_state.external_stack_remote_state.outputs.prod_environment.compartments.security.id
  master_encryption_key               = module.security.key_id
  logging_compartment_id              = data.terraform_remote_state.external_stack_remote_state.outputs.prod_environment.compartments.logging.id
  resource_label                      = var.resource_label
  retention_policy_duration_amount    = var.retention_policy_duration_amount
  retention_policy_duration_time_unit = var.retention_policy_duration_time_unit
  home_compartment_name               = var.home_compartment_name
  home_compartment_id                 = data.terraform_remote_state.external_stack_remote_state.outputs.prod_environment.compartments.environment.compartment_id
  subnets_map                         = module.network.subnets
  providers = {
    oci               = oci
    oci.backup_region = oci.backup_region
  }

  depends_on = [module.security]
}