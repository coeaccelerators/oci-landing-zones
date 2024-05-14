######################################################################
#     Workload | Workload Expansion Spoke Network Configuration      #
######################################################################
locals {

  w_prefix = var.is_prod_workload ? "P" : "N"
  workload_prefix = join ("-", [var.workload_name,  local.w_prefix])

  vcn_dns_label   = lower(var.workload_name)

  drg_id = data.terraform_remote_state.external_stack_remote_state.outputs.prod_environment.drg_id

  workload_nat_gw_spoke_check     = var.enable_nat_gateway_spoke == true ? var.nat_gw_spoke_check : []
  #workload_service_gw_spoke_check = var.service_gw_spoke_check
  workload_service_gw_spoke_check = var.enable_service_gateway_spoke == true ? var.service_gw_spoke_check : []
  
  ipsec_connection_static_routes = var.enable_vpn_or_fastconnect == "VPN" && var.enable_vpn_on_environment ? var.ipsec_connection_static_routes : []
  customer_onprem_ip_cidr        = var.enable_vpn_or_fastconnect == "FASTCONNECT" ? var.customer_onprem_ip_cidr : []

  vcn_display_name = var.vcn_display_name != "" ? var.vcn_display_name : "OCI-ELZ-${local.workload_prefix}-EXP-SPK-VCN-${local.region_key[0]}"

  route_table_display_name      = var.route_table_display_name != "" ? var.route_table_display_name : "OCI-ELZ-${local.workload_prefix}-EXP-SPK-RTPRV-${local.region_key[0]}"
  security_list_display_name    = var.security_list_display_name != "" ? var.security_list_display_name : "OCI-ELZ-${local.workload_prefix}-EXP-SPK-Security-List"

  route_table_display_name_SUB001 = "${local.route_table_display_name}-SUB001"
  route_table_display_name_SUB002 = "${local.route_table_display_name}-SUB002"
  route_table_display_name_SUB003 = "${local.route_table_display_name}-SUB003"
  
  security_list_display_name_SUB001 = "${local.security_list_display_name}-SUB001"
  security_list_display_name_SUB002 = "${local.security_list_display_name}-SUB002"
  security_list_display_name_SUB003 = "${local.security_list_display_name}-SUB003"

  nat_gateway_display_name      = var.nat_gateway_display_name != "" ? var.nat_gateway_display_name : "OCI-ELZ-${local.workload_prefix}-EXP-SPK-NAT-${local.region_key[0]}"
  service_gateway_display_name  = var.service_gateway_display_name != "" ? var.service_gateway_display_name : "OCI-ELZ-${local.workload_prefix}-EXP-SPK-SGW-${local.region_key[0]}"
    
  spoke_route_rules_options = {
    route_rules_hub_vcn = {
      "hub-public-subnet" = {
        network_entity_id = local.drg_id
        destination       = var.hub_public_subnet_cidr_block
        destination_type  = "CIDR_BLOCK"
      }
      "hub-private-subnet" = {
        network_entity_id = local.drg_id
        destination       = var.hub_private_subnet_cidr_block
        destination_type  = "CIDR_BLOCK"
      }
    }
    route_rules_spoke_vcn = {
      for index, route in var.workload_spoke_vcn_cidr : "spoke-vcn-rule-${index}" => {
        network_entity_id = local.drg_id
        destination       = var.workload_spoke_vcn_cidr[index]
        destination_type  = "CIDR_BLOCK"
      }
    }
    route_rules_nat_spoke = {
      for index, route in local.workload_nat_gw_spoke_check : "nat-gw-rule-${index}" => {
        network_entity_id = module.workload-spoke-nat-gateway[0].nat_gw_id
        destination       = "0.0.0.0/0"
        destination_type  = "CIDR_BLOCK"
      }
    }
    route_rules_srvc_gw_spoke = {
      for index, route in local.workload_service_gw_spoke_check : "service-gw-rule-${index}" => {
        network_entity_id = module.workload-spoke-service-gateway[0].service_gw_id
        destination       = data.oci_core_services.service_gateway.services[1]["cidr_block"]
        destination_type  = "SERVICE_CIDR_BLOCK"

      }
    }
    route_rules_vpn = {
      for index, route in local.ipsec_connection_static_routes : "cpe-rule-${index}" => {
        network_entity_id = local.drg_id
        destination       = route
        destination_type  = "CIDR_BLOCK"
      }
    }
    route_rules_fastconnect = {
      for index, route in local.customer_onprem_ip_cidr : "fc-rule-${index}" => {
        network_entity_id = local.drg_id
        destination       = route
        destination_type  = "CIDR_BLOCK"
      }
    }
  }

  spoke_route_rules = {
    route_rules = merge(local.spoke_route_rules_options.route_rules_hub_vcn,
      local.spoke_route_rules_options.route_rules_spoke_vcn,
      local.spoke_route_rules_options.route_rules_nat_spoke,
      local.spoke_route_rules_options.route_rules_srvc_gw_spoke,
      local.spoke_route_rules_options.route_rules_fastconnect,
    local.spoke_route_rules_options.route_rules_vpn)
  }

  workload_expansion_subnet_map = {
    Workload-Spoke-SUB001-Subnet = {
      name                       = var.workload_private_spoke_subnet_SUB001_display_name != "" ? var.workload_private_spoke_subnet_SUB001_display_name : "OCI-ELZ-${local.workload_prefix}-EXP-SPK-SUB-${local.region_key[0]}-SUB001"
      description                = "SUB001 Subnet"
      dns_label                  = var.workload_private_spoke_subnet_SUB001_dns_label
      cidr_block                 = var.workload_private_spoke_subnet_SUB001_cidr_block
      prohibit_public_ip_on_vnic = true
    }
    Workload-Spoke-SUB002-Subnet = {
      name                       = var.workload_private_spoke_subnet_SUB002_display_name != "" ? var.workload_private_spoke_subnet_SUB002_display_name : "OCI-ELZ-${local.workload_prefix}-EXP-SPK-SUB-${local.region_key[0]}-SUB002"
      description                = "SUB002 Subnet"
      dns_label                  = var.workload_private_spoke_subnet_SUB002_dns_label
      cidr_block                 = var.workload_private_spoke_subnet_SUB002_cidr_block
      prohibit_public_ip_on_vnic = true
    }
    Workload-Spoke-SUB003-Subnet = {
      name                       = var.workload_private_spoke_subnet_SUB003_display_name != "" ? var.workload_private_spoke_subnet_SUB003_display_name : "OCI-ELZ-${local.workload_prefix}-EXP-SPK-SUB-${local.region_key[0]}-SUB003"
      description                = "SUB003 Subnet"
      dns_label                  = var.workload_private_spoke_subnet_SUB003_dns_label
      cidr_block                 = var.workload_private_spoke_subnet_SUB003_cidr_block
      prohibit_public_ip_on_vnic = true
    }
    
  }

  ip_protocols = {
    ICMP   = "1"
    TCP    = "6"
    UDP    = "17"
    ICMPv6 = "58"
  }

 security_list_ingress_ssh = {
    protocol                 = local.ip_protocols.TCP
    #source                   = var.hub_private_subnet_cidr_block
    source                   = data.terraform_remote_state.external_stack_remote_state.outputs.prod_environment.hub_private_subnet_cidr
    description              = "SSH Traffic from Hub"
    source_type              = "CIDR_BLOCK"
    tcp_destination_port_min = 22
    tcp_destination_port_max = 22
  }
  security_list_ingress_icmp = {
    protocol    = local.ip_protocols.ICMP
    #source      = var.hub_private_subnet_cidr_block
    source      = data.terraform_remote_state.external_stack_remote_state.outputs.prod_environment.hub_private_subnet_cidr
    description = "All ICMP Taffic from Hub"
    source_type = "CIDR_BLOCK"
    icmp_type   = 3
    icmp_code   = 4
  }
  security_list_ingress_vcn = {
    protocol    = local.ip_protocols.ICMP
    # source      = var.hub_vcn_cidr_block
    source      = data.terraform_remote_state.external_stack_remote_state.outputs.hub_vcn_cidr
    description = "VCN ICMP Traffic"
    source_type = "CIDR_BLOCK"
    icmp_type   = 3
  }
  security_list_egress_all = {
    destination      = "0.0.0.0/0"
    protocol         = "all"
    description      = "All egress Traffic"
    destination_type = "CIDR_BLOCK"
  }

}

#Get Service Gateway For Region .
data "oci_core_services" "service_gateway" {
  filter {
    name   = "name"
    values = [ ".*Object.*Storage", "All .* Services In Oracle Services Network"]
    regex  = true
  }
}

######################################################################
#                  Create Workload VCN Spoke                         #
######################################################################
module "workload_spoke_vcn" {
  source = "../../modules/vcn"

  vcn_cidrs           = var.workload_spoke_vcn_cidr
  compartment_ocid_id = module.workload_compartment.compartment_id
  vcn_display_name    = local.vcn_display_name
  vcn_dns_label       = local.vcn_dns_label
  enable_ipv6         = false

  providers = {
    oci = oci.home_region
  }
}
######################################################################
#          Create Workload VCN Spoke Security List                   #
######################################################################

module "workload_spoke_SUB001_security_list" {
  source = "../../modules/security-list"

  compartment_id             = module.workload_compartment.compartment_id
  vcn_id                     = module.workload_spoke_vcn.vcn_id
  security_list_display_name = local.security_list_display_name_SUB001

  egress_rules  = [local.security_list_egress_all]
  ingress_rules = [local.security_list_ingress_ssh, local.security_list_ingress_icmp, local.security_list_ingress_vcn]
}

module "workload_spoke_SUB002_security_list" {
  source = "../../modules/security-list"

  compartment_id             = module.workload_compartment.compartment_id
  vcn_id                     = module.workload_spoke_vcn.vcn_id
  security_list_display_name = local.security_list_display_name_SUB002

  egress_rules = [local.security_list_egress_all]
  ingress_rules = [local.security_list_ingress_ssh, local.security_list_ingress_icmp, local.security_list_ingress_vcn]

}

module "workload_spoke_SUB003_security_list" {
  source = "../../modules/security-list"

  compartment_id             = module.workload_compartment.compartment_id
  vcn_id                     = module.workload_spoke_vcn.vcn_id
  security_list_display_name = local.security_list_display_name_SUB003

  egress_rules  = [local.security_list_egress_all]
  ingress_rules = [local.security_list_ingress_ssh, local.security_list_ingress_icmp, local.security_list_ingress_vcn]
}


######################################################################
#          Create Workload VCN Spoke Subnet                          #
######################################################################
module "workload_spoke_SUB001_subnet" {
  source = "../../modules/subnet"

  subnet_map            = { Workload-Spoke-SUB001-Subnet = local.workload_expansion_subnet_map.Workload-Spoke-SUB001-Subnet }
  compartment_id        = module.workload_compartment.compartment_id
  vcn_id                = module.workload_spoke_vcn.vcn_id
  subnet_route_table_id = module.workload_spoke_route_table_SUB001.route_table_id
  subnet_security_list_id = toset([
    module.workload_spoke_SUB001_security_list.security_list_id
  ])
}

module "workload_spoke_SUB002_subnet" {
  source = "../../modules/subnet"

  subnet_map            = { Workload-Spoke-SUB002-Subnet = local.workload_expansion_subnet_map.Workload-Spoke-SUB002-Subnet }
  compartment_id        = module.workload_compartment.compartment_id
  vcn_id                = module.workload_spoke_vcn.vcn_id
  subnet_route_table_id = module.workload_spoke_route_table_SUB002.route_table_id
  subnet_security_list_id = toset([
    module.workload_spoke_SUB002_security_list.security_list_id
  ])
}

module "workload_spoke_SUB003_subnet" {
  source = "../../modules/subnet"

  subnet_map            = { Workload-Spoke-SUB003-Subnet = local.workload_expansion_subnet_map.Workload-Spoke-SUB003-Subnet }
  compartment_id        = module.workload_compartment.compartment_id
  vcn_id                = module.workload_spoke_vcn.vcn_id
  subnet_route_table_id = module.workload_spoke_route_table_SUB003.route_table_id
  subnet_security_list_id = toset([
    module.workload_spoke_SUB003_security_list.security_list_id
  ])
}

######################################################################
#          Create Workload VCN Spoke Gateway                         #
######################################################################
module "workload-spoke-nat-gateway" {
  source                   = "../../modules/nat-gateway"
  count                    = var.enable_nat_gateway_spoke ? 1 : 0
  nat_gateway_display_name = local.nat_gateway_display_name
  network_compartment_id   = module.workload_compartment.compartment_id
  vcn_id                   = module.workload_spoke_vcn.vcn_id
}

module "workload-spoke-service-gateway" {
  source                       = "../../modules/service-gateway"
  count                        = var.enable_service_gateway_spoke ? 1 : 0
  network_compartment_id       = module.workload_compartment.compartment_id
  service_gateway_display_name = local.service_gateway_display_name
  vcn_id                       = module.workload_spoke_vcn.vcn_id
}
######################################################################
#          Create Workload VCN Spoke Route Table                     #
######################################################################

module "workload_spoke_route_table_SUB001" {
  source                   = "../../modules/route-table"
  compartment_id           = module.workload_compartment.compartment_id
  vcn_id                   = module.workload_spoke_vcn.vcn_id
  route_table_display_name = local.route_table_display_name_SUB001
  route_rules              = local.spoke_route_rules.route_rules
}
module "workload_spoke_route_table_SUB002" {
  source                   = "../../modules/route-table"
  compartment_id           = module.workload_compartment.compartment_id
  vcn_id                   = module.workload_spoke_vcn.vcn_id
  route_table_display_name = local.route_table_display_name_SUB002
  route_rules              = local.spoke_route_rules.route_rules
}

module "workload_spoke_route_table_SUB003" {
  source                   = "../../modules/route-table"
  compartment_id           = module.workload_compartment.compartment_id
  vcn_id                   = module.workload_spoke_vcn.vcn_id
  route_table_display_name = local.route_table_display_name_SUB003
  route_rules              = local.spoke_route_rules.route_rules
}

######################################################################
#          Attach Workload Spoke VCN to DRG                          #
######################################################################
module "workload_spoke_vcn_drg_attachment" {
  source                        = "../../modules/drg-attachment"
  drg_id                        = local.drg_id
  vcn_id                        = module.workload_spoke_vcn.vcn_id
  drg_attachment_type           = "VCN"
  drg_attachment_vcn_route_type = "VCN_CIDRS"
}
