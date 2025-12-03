########################################################################################################################
# Resource Group
########################################################################################################################

locals {
  prefix = var.prefix != null ? trimspace(var.prefix) != "" ? "${var.prefix}-" : "" : ""
}

module "tfe" {
  source                          = "../.."
  instance_name                   = "${local.prefix}${var.instance_name}"
  region                          = var.region
  existing_resource_group_name    = var.existing_resource_group_name
  resource_tags                   = var.resource_tags
  tfe_license                     = var.tfe_license
  tfe_license_secret_crn          = var.tfe_license_secret_crn
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  admin_email                     = var.admin_email
  tfe_organization                = var.tfe_organization_name
  postgres_deletion_protection    = var.postgres_deletion_protection
  add_to_catalog                  = var.add_to_catalog
  secrets_manager_crn             = var.secrets_manager_crn
  secrets_manager_secret_group_id = var.secrets_manager_secret_group_id
}
