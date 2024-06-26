##########################################################################################################
# Copyright (c) 2022,2023 Oracle and/or its affiliates, All rights reserved.                             #
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl. #
##########################################################################################################

variable "create_nat_gateway" {
  type = bool
}
variable "create_service_gateway" {
  type = bool
}
variable "nat_network_compartment_id" {
  type = string
}
variable "nat_vcn_id" {
  type = string
}
variable "nat_gateway_display_name" {
  type = string
}
variable "sgw_network_compartment_id" {
  type = string
}
variable "sgw_vcn_id" {
  type = string
}
variable "service_gateway_display_name" {
  type = string
}

