##########################################################################################################
# Copyright (c) 2022,2023 Oracle and/or its affiliates, All rights reserved.                             #
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl. #
##########################################################################################################

output "hub_vcn_cidr" {
  value = var.vcn_cidr_block
}

output "hub_public_subnet_cidr" {
  value = var.public_subnet_cidr_block
}

output "hub_private_subnet_cidr" {
  value = var.private_subnet_cidr_block
}

output "drg_id" {
  value = module.network.drg_id
}

output "default_group_id" {
  value = module.logging.log_group_id
}

output "security_compartment_id" {
  value = data.terraform_remote_state.external_stack_remote_state.outputs.prod_environment.compartments.security.id
}

output "security_compartment_name" {
  value = data.terraform_remote_state.external_stack_remote_state.outputs.prod_environment.compartments.security.name
}

output "environment_compartment_id" {
  value = data.terraform_remote_state.external_stack_remote_state.outputs.prod_environment.compartments.environment.id
}

output "environment_compartment_name" {
  value = data.terraform_remote_state.external_stack_remote_state.outputs.prod_environment.compartments.environment.name
}

output "prod_environment_compartment_id" {
  value = data.terraform_remote_state.external_stack_remote_state.outputs.prod_environment.compartments.prod.id
}

output "nonprod_environment_compartment_id" {
  value = data.terraform_remote_state.external_stack_remote_state.outputs.prod_environment.compartments.nonprod.id
}

output "identity_domain_display_name" {
  value = data.terraform_remote_state.external_stack_remote_state.outputs.prod_environment.identity_domain.display_name
}

output "identity_domain_url" {
  value = data.terraform_remote_state.external_stack_remote_state.outputs.prod_environment.identity_domain.url
}

