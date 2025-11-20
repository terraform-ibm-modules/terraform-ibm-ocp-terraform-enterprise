########################################################################################################################
# Resource Group
########################################################################################################################

module "tfe" {
  source                       = "../.."
  prefix                       = var.prefix
  region                       = var.region
  existing_resource_group_name = var.resource_group
  resource_tags                = var.resource_tags
  tfe_license                  = var.tfe_license
  admin_username               = var.admin_username
  admin_password               = var.admin_password
  admin_email                  = var.admin_email
  tfe_organization             = var.tfe_organization_name
  add_to_catalog               = var.add_to_catalog
  postgres_deletion_protection = var.postgres_deletion_protection
  postgres_vpe_enabled         = var.postgres_vpe_enabled
  postgres_service_endpoints   = var.postgres_service_endpoints
}
