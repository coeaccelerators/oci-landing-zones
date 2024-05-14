# -----------------------------------------------------------------------------
# Compartment Resources 
# -----------------------------------------------------------------------------
locals {

  environment_prefix = data.terraform_remote_state.external_stack_remote_state.outputs.prod_environment.environment_prefix

  w_prefix = var.is_prod_workload ? "P" : "N"

  workload_prefix = join ("-", [var.workload_name,  local.w_prefix])

  workload_parent_compartment_id = var.is_prod_workload ? data.terraform_remote_state.external_stack_remote_state.outputs.prod_environment.compartments.prod.id : data.terraform_remote_state.external_stack_remote_state.outputs.prod_environment.compartments.nonprod.id

  workload_compartment = {
    name        = var.workload_compartment_name != "" ? var.workload_compartment_name : "OCI-ELZ-${local.environment_prefix}-${var.workload_name}-${local.region_key[0]}"
    id          = var.workload_parent_compartment_id != "" ? var.workload_parent_compartment_id : local.workload_parent_compartment_id
    description = "Workload Compartment"
  }

  group_names = var.enable_datasafe ? {
    workload_admin_group_name : var.workload_admin_group_name != "" ? var.workload_admin_group_name : "OCI-ELZ-UGP-${local.environment_prefix}-${var.workload_name}-WRK-ADMIN",
    application_admin_group_name : var.application_admin_group_name != "" ? var.application_admin_group_name : "OCI-ELZ-UGP-${local.environment_prefix}-${var.workload_name}-APP-ADMIN",
    database_admin_group_name : var.database_admin_group_name != "" ? var.database_admin_group_name : "OCI-ELZ-UGP-${local.environment_prefix}-${var.workload_name}-DB-ADMIN",
    workload_developer_group_name : var.workload_developer_group_name != "" ? var.workload_developer_group_name : "OCI-ELZ-UGP-${local.environment_prefix}-${var.workload_name}-WRK-DEV",
    datasafe_admin_group_name : var.datasafe_admin_group_name != "" ? var.datasafe_admin_group_name : "OCI-ELZ-UGP-${local.environment_prefix}-${var.workload_name}-DTSAFE-ADMIN",
    datasafe_reports_group_name : var.datasafe_reports_group_name != "" ? var.datasafe_reports_group_name : "OCI-ELZ-UGP-${local.environment_prefix}-${var.workload_name}-DTSAFE-REPORTS",
    } : {
    workload_admin_group_name : var.workload_admin_group_name != "" ? var.workload_admin_group_name : "OCI-ELZ-UGP-${local.environment_prefix}-${var.workload_name}-WRK-ADMIN",
    application_admin_group_name : var.application_admin_group_name != "" ? var.application_admin_group_name : "OCI-ELZ-UGP-${local.environment_prefix}-${var.workload_name}-APP-ADMIN",
    database_admin_group_name : var.database_admin_group_name != "" ? var.database_admin_group_name : "OCI-ELZ-UGP-${local.environment_prefix}-${var.workload_name}-DB-ADMIN",
    workload_developer_group_name : var.workload_developer_group_name != "" ? var.workload_developer_group_name : "OCI-ELZ-UGP-${local.environment_prefix}-${var.workload_name}-WRK-DEV",
  }

  base_group_names = {
    network_admin_group_name : var.network_admin_group_name != "" ? var.network_admin_group_name : "OCI-ELZ-UGP-${local.environment_prefix}-NET-ADMIN",
    # security_admin_group_name : var.security_admin_group_name != "" ? var.security_admin_group_name : "OCI-ELZ-UGP-${local.environment_prefix}-SEC-ADMIN",
  }

  # identity_domain_name = var.identity_domain_name != "" ? var.identity_domain_name : "OCI-ELZ-${local.environment_prefix}-IDT"
  identity_domain_name = data.terraform_remote_state.external_stack_remote_state.outputs.prod_environment.identity_domain.display_name

  identity_domain_url = var.identity_domain_url != "" ? var.identity_domain_url : data.terraform_remote_state.external_stack_remote_state.outputs.prod_environment.identity_domain.url

  parent_compartment_names = {
    #security_compartment_name : var.security_compartment_name != "" ? var.security_compartment_name : "OCI-ELZ-${local.environment_prefix}-SRD-SEC"
    security_compartment_name = data.terraform_remote_state.external_stack_remote_state.outputs.prod_environment.compartments.security.name
    # environment_compartment_name : var.environment_compartment_name != "" ? var.environment_compartment_name : "OCI-ELZ-${local.environment_prefix}-CMP"
    environment_compartment_name = data.terraform_remote_state.external_stack_remote_state.outputs.prod_environment.compartments.environment.name
  }

  parent_compartment_id = {
    security_compartment_id = var.security_compartment_id != "" ? var.security_compartment_id : data.terraform_remote_state.external_stack_remote_state.outputs.prod_environment.compartments.security.id
    environment_compartment_id = var.environment_compartment_id != "" ? var.environment_compartment_id :  data.terraform_remote_state.external_stack_remote_state.outputs.prod_environment.compartments.environment.id
  }

  workload_expansion_policy = {
    name        = "OCI-ELZ-WRK-EXP-${local.workload_prefix}-POLICY"
    description = "OCI Workload Expansion Policy"
    statements = concat([
      "Allow group ${local.identity_domain_name}/${local.group_names["workload_admin_group_name"]} to manage virtual-network-family in compartment ${module.workload_compartment.compartment_name}",
      "Allow group ${local.identity_domain_name}/${local.group_names["workload_admin_group_name"]} to manage alarms in compartment ${module.workload_compartment.compartment_name}",
      "Allow group ${local.identity_domain_name}/${local.group_names["workload_admin_group_name"]} to manage ons-topics in compartment ${module.workload_compartment.compartment_name}",
      "Allow group ${local.identity_domain_name}/${local.group_names["workload_admin_group_name"]} to manage ons-subscriptions in compartment ${module.workload_compartment.compartment_name}",
      "Allow group ${local.identity_domain_name}/${local.group_names["workload_admin_group_name"]} to manage logging-family in compartment ${module.workload_compartment.compartment_name}",
      "Allow group ${local.identity_domain_name}/${local.group_names["workload_admin_group_name"]} to manage streams in compartment ${module.workload_compartment.compartment_name}",
      "Allow group ${local.identity_domain_name}/${local.group_names["workload_admin_group_name"]} to read announcements in compartment ${module.workload_compartment.compartment_name}",
      "Allow group ${local.identity_domain_name}/${local.group_names["workload_admin_group_name"]} to read metrics in compartment ${module.workload_compartment.compartment_name}",
      "Allow group ${local.identity_domain_name}/${local.group_names["workload_admin_group_name"]} to read audit-events in compartment ${module.workload_compartment.compartment_name}",

      "Allow group ${local.identity_domain_name}/${local.group_names["application_admin_group_name"]} to manage load-balancers in compartment ${module.workload_compartment.compartment_name}",
      "Allow group ${local.identity_domain_name}/${local.group_names["application_admin_group_name"]} to manage volume-family in compartment ${module.workload_compartment.compartment_name}",
      "Allow group ${local.identity_domain_name}/${local.group_names["application_admin_group_name"]} to manage object-family in compartment ${module.workload_compartment.compartment_name}",
      "Allow group ${local.identity_domain_name}/${local.group_names["application_admin_group_name"]} to manage file-family in compartment ${module.workload_compartment.compartment_name}",
      "Allow group ${local.identity_domain_name}/${local.group_names["application_admin_group_name"]} to manage instance-family in compartment ${module.workload_compartment.compartment_name}",

      "Allow group ${local.identity_domain_name}/${local.group_names["database_admin_group_name"]} to manage autonomous-database-family in compartment ${module.workload_compartment.compartment_name}",
      "Allow group ${local.identity_domain_name}/${local.group_names["database_admin_group_name"]} to manage database-family in compartment ${module.workload_compartment.compartment_name}",

      "Allow group ${local.identity_domain_name}/${local.base_group_names["network_admin_group_name"]} to read metrics in compartment ${module.workload_compartment.compartment_name}",
      "Allow any-user to manage instances in compartment ${module.workload_compartment.compartment_name} where all { request.principal.type = 'cluster' }",
      "Allow any-user to use private-ips in compartment ${module.workload_compartment.compartment_name} where all { request.principal.type = 'cluster' }",
      "Allow any-user to use network-security-groups in compartment ${module.workload_compartment.compartment_name} where all { request.principal.type = 'cluster' }",
      ], flatten(
      var.enable_datasafe ? [
        "Allow group ${local.identity_domain_name}/${local.group_names["database_admin_group_name"]} to manage autonomous-databases in compartment ${module.workload_compartment.compartment_name}",
        "Allow group ${local.identity_domain_name}/${local.group_names["database_admin_group_name"]} to manage target-databases in compartment ${module.workload_compartment.compartment_name}",
        "Allow group ${local.identity_domain_name}/${local.group_names["database_admin_group_name"]} to manage data-safe-private-endpoints in compartment ${module.workload_compartment.compartment_name}",
        "Allow group ${local.identity_domain_name}/${local.group_names["database_admin_group_name"]} to manage virtual-network-family in compartment ${module.workload_compartment.compartment_name}",
        "Allow group ${local.identity_domain_name}/${local.group_names["database_admin_group_name"]} to manage database-family in compartment ${module.workload_compartment.compartment_name}",
        "Allow group ${local.identity_domain_name}/${local.group_names["database_admin_group_name"]} to manage data-safe-family in compartment ${module.workload_compartment.compartment_name}",
        "Allow group ${local.identity_domain_name}/${local.group_names["workload_admin_group_name"]} to manage data-safe-family in compartment ${module.workload_compartment.compartment_name}",

        "Allow group ${local.identity_domain_name}/${local.group_names["datasafe_reports_group_name"]} to manage data-safe-assessment-family in compartment ${module.workload_compartment.compartment_name}",
        "Allow group ${local.identity_domain_name}/${local.group_names["datasafe_reports_group_name"]} to read data-safe-report-definitions in compartment ${module.workload_compartment.compartment_name}",
        "Allow group ${local.identity_domain_name}/${local.group_names["datasafe_reports_group_name"]} to read data-safe-reports in compartment ${module.workload_compartment.compartment_name}",
        "Allow group ${local.identity_domain_name}/${local.group_names["datasafe_reports_group_name"]} to read data-safe-alerts in compartment ${module.workload_compartment.compartment_name}",
      ] : []
    ))
  }

  workload_expansion_developer_policy = {
    name        = "OCI-ELZ-WRK-EXP-${local.workload_prefix}-DEV-POLICY"
    description = "OCI Workload Expansion Developer Policy"
    statements = [
      "Allow group ${local.identity_domain_name}/${local.group_names["workload_developer_group_name"]} to manage load-balancers in compartment ${module.workload_compartment.compartment_name}",
      "Allow group ${local.identity_domain_name}/${local.group_names["workload_developer_group_name"]} to manage volume-family in compartment ${module.workload_compartment.compartment_name}",
      "Allow group ${local.identity_domain_name}/${local.group_names["workload_developer_group_name"]} to manage object-family in compartment ${module.workload_compartment.compartment_name}",
      "Allow group ${local.identity_domain_name}/${local.group_names["workload_developer_group_name"]} to manage file-family in compartment ${module.workload_compartment.compartment_name}",
      "Allow group ${local.identity_domain_name}/${local.group_names["workload_developer_group_name"]} to manage instance-family in compartment ${module.workload_compartment.compartment_name}",

      "Allow group ${local.identity_domain_name}/${local.group_names["database_admin_group_name"]} to manage autonomous-database-family in compartment ${module.workload_compartment.compartment_name}",
      "Allow group ${local.identity_domain_name}/${local.group_names["database_admin_group_name"]} to manage database-family in compartment ${module.workload_compartment.compartment_name}",
      "Allow group ${local.identity_domain_name}/${local.group_names["database_admin_group_name"]} to manage object-family in compartment ${module.workload_compartment.compartment_name}",
    ]
  }
  
  workload_expansion_policy_security = {
    name        = "OCI-ELZ-WRK-EXP-${local.workload_prefix}-SEC-POLICY"
    description = "OCI Workload Expansion Security Policy"

    statements = [
      "Allow group ${local.identity_domain_name}/${local.group_names["workload_admin_group_name"]} to read vaults in compartment ${local.parent_compartment_names.security_compartment_name}",
      "Allow group ${local.identity_domain_name}/${local.group_names["workload_admin_group_name"]} to inspect keys in compartment ${local.parent_compartment_names.security_compartment_name}",
      "Allow group ${local.identity_domain_name}/${local.group_names["workload_admin_group_name"]} to read vss-family in compartment ${local.parent_compartment_names.security_compartment_name}",
      "Allow group ${local.identity_domain_name}/${local.group_names["workload_admin_group_name"]} to use bastion in compartment ${local.parent_compartment_names.security_compartment_name}",
      "Allow group ${local.identity_domain_name}/${local.group_names["workload_admin_group_name"]} to manage bastion-session in compartment ${local.parent_compartment_names.security_compartment_name}",
    ]
  }

  datasafe_admin_policy = {
    name        = "OCI-ELZ-EXAWRK-EXP-${local.workload_prefix}-DTSAFE-ADMIN-POLICY"
    description = "OCI Exadata Workload Expansion Data Safe Admin Policy"

    statements = var.enable_datasafe ? [
      "Allow group ${local.identity_domain_name}/${local.group_names["datasafe_admin_group_name"]} to manage data-safe-family in compartment ${local.parent_compartment_names.environment_compartment_name}",
    ] : []
  }
}

module "workload_compartment" {
  source = "../../modules/compartment"

  #compartment_parent_id     = var.workload_parent_compartment_id
  compartment_parent_id     = local.workload_compartment.id
  compartment_name          = local.workload_compartment.name
  compartment_description   = local.workload_compartment.description
  enable_compartment_delete = var.enable_compartment_delete

  providers = {
    oci = oci.home_region
  }
}

# module "groups" {
#   source             = "../../modules/identity-domain-group"
#   identity_domain_id = var.identity_domain_id
#   group_names        = values(local.group_names)
# }

module "workload_admin_group" {
  source             = "../../modules/non-default-domain-group"
  idcs_endpoint      = local.identity_domain_url
  group_display_name = local.group_names.workload_admin_group_name
}
module "application_admin_group" {
  source             = "../../modules/non-default-domain-group"
  idcs_endpoint      = local.identity_domain_url
  group_display_name = local.group_names.application_admin_group_name
}
module "database_admin_group" {
  source             = "../../modules/non-default-domain-group"
  idcs_endpoint      = local.identity_domain_url
  group_display_name = local.group_names.database_admin_group_name
}
module "workload_developer_group" {
  source             = "../../modules/non-default-domain-group"
  idcs_endpoint      = local.identity_domain_url
  group_display_name = local.group_names.workload_developer_group_name
}
module "datasafe_admin_group" {
  count              = var.enable_datasafe ? 1 : 0
  source             = "../../modules/non-default-domain-group"
  idcs_endpoint      = local.identity_domain_url
  group_display_name = local.group_names.datasafe_admin_group_name
}
module "datasafe_reports_group" {
  count              = var.enable_datasafe ? 1 : 0
  source             = "../../modules/non-default-domain-group"
  idcs_endpoint      = local.identity_domain_url
  group_display_name = local.group_names.datasafe_reports_group_name
}

module "workload_expansion_policy" {
  source           = "../../modules/policies"
  compartment_ocid = module.workload_compartment.compartment_id
  policy_name      = local.workload_expansion_policy.name
  description      = local.workload_expansion_policy.description
  statements       = local.workload_expansion_policy.statements
}

module "workload_expansion_sec_policy" {
  source           = "../../modules/policies"
  compartment_ocid = local.parent_compartment_id.security_compartment_id
  policy_name      = local.workload_expansion_policy_security.name
  description      = local.workload_expansion_policy_security.description
  statements       = local.workload_expansion_policy_security.statements
}

module "datasafe_admin_policy" {
  count            = var.enable_datasafe ? 1 : 0
  source           = "../../modules/policies"
  compartment_ocid = local.parent_compartment_id.environment_compartment_id
  policy_name      = local.datasafe_admin_policy.name
  description      = local.datasafe_admin_policy.description
  statements       = local.datasafe_admin_policy.statements
}
