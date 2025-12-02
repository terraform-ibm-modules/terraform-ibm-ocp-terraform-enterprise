########################################################################################################################
# Resource Group
########################################################################################################################

module "tfe" {
  source                          = "../.."
  prefix                          = var.prefix
  region                          = var.region
  existing_resource_group_name    = var.existing_resource_group_name
  resource_tags                   = var.resource_tags
  tfe_license                     = var.tfe_license
  tfe_license_secret_crn          = var.tfe_license_secret_crn
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  admin_email                     = var.admin_email
  tfe_organization                = var.tfe_organization_name
  add_to_catalog                  = var.add_to_catalog
  postgres_deletion_protection    = var.postgres_deletion_protection
  postgres_vpe_enabled            = var.postgres_vpe_enabled
  postgres_service_endpoints      = var.postgres_service_endpoints
  subnets_zones_cidr              = var.subnets_zones_cidr
  vpc_acl_rules                   = var.vpc_acl_rules
  postgres_add_acl_rule           = var.postgres_add_acl_rule
  secrets_manager_crn             = var.secrets_manager_crn
  secrets_manager_secret_group_id = var.secrets_manager_secret_group_id
}
