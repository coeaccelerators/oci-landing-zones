# Provider 
# current_user_ocid                            = ""
# region                                       = ""
# tenancy_ocid                                 = ""
# api_fingerprint                              = ""
# api_private_key_path                         = ""

#####################################################
# Workload Expansion Compartment Variable
#####################################################
resource_label = "RL"
# environment_prefix         = ""
# environment_compartment_id = ""
# workload_parent_compartment_id      = ""
# workload_compartment_name               = ""
# workload_name   = ""
# workload_prefix = ""

enable_compartment_delete = true

#####################################################
# Workload Expansion IAM Group Variable
#####################################################
# identity_domain_name         = ""
# identity_domain_url     = ""
# network_compartment_id  = ""
# security_compartment_id = ""
# enable_datasafe         = false
# workload_admin_group_name                    = ""
# application_admin_group_name                 = ""
# database_admin_group_name                    = ""
# datasafe_reports_group_name                  = ""
# datasafe_admin_group_name                    = ""
# network_admin_group_name                     = ""
# security_compartment_name                    = ""

#####################################################
# Workload Expansion Security Group Variable
#####################################################
enable_bastion                       = false
bastion_client_cidr_block_allow_list = ["0.0.0.0/0"]

#####################################################
# Workload Expansion Network Variables 
#####################################################
# vcn_display_name                                 = ""
# vcn_dns_label                                = ""
#workload_spoke_vcn_cidr                      = ["172.21.0.0/19"]
#workload_private_spoke_subnet_SUB001_cidr_block = "172.21.30.0/24"
#workload_private_spoke_subnet_SUB002_cidr_block = "172.21.20.0/24"
#workload_private_spoke_subnet_SUB003_cidr_block  = "172.21.0.0/20"
enable_nat_gateway_spoke     = true
enable_service_gateway_spoke = true
#drg_id                                       = ""
#hub_vcn_id                                   = ""
#hub_public_subnet_cidr_block                 = ""
#hub_private_subnet_cidr_block                = ""
workload_private_spoke_subnet_SUB001_dns_label = "sub001"
workload_private_spoke_subnet_SUB002_dns_label = "sub002"
workload_private_spoke_subnet_SUB003_dns_label = "sub003"


#nat_gateway_display_name = ""
#service_gateway_display_name = ""
# route_table_display_name                    = ""
# security_list_display_name                  = ""
# workload_private_spoke_subnet_SUB001_display_name = ""
# workload_private_spoke_subnet_SUB002_display_name = "" 
# workload_private_spoke_subnet_SUB003_display_name = ""

#####################################################
# Workload Expansion Monitoring Variables
#####################################################
# default_log_group_id              = ""
workload_topic_endpoints          = []
enable_workload_monitoring_alarms = false

# hub_vcn_cidr_block = ""
# db_port = ""

customer_onprem_ip_cidr        = []
ipsec_connection_static_routes = [""]
nat_gw_spoke_check             = [""]
service_gw_spoke_check         = [""]
is_baseline_deploy             = true
is_create_alarms               = false