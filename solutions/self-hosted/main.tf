locals {
  prefix = var.prefix != null ? trimspace(var.prefix) != "" ? "${var.prefix}-" : "" : ""
}

########################################################################################################################
# Loading existing resource group
########################################################################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.4.0"
  existing_resource_group_name = var.existing_resource_group_name
}

module "tfe" {
  source                                   = "../.."
  region                                   = var.region
  resource_group_id                        = module.resource_group.resource_group_id
  resource_tags                            = var.resource_tags
  vpc_name                                 = "${local.prefix}tfe-vpc"
  cluster_name                             = "${local.prefix}tfe-cluster"
  postgres_instance_name                   = "${local.prefix}tfe-data-store"
  cos_instance_name                        = "${local.prefix}tfe-cos"
  cos_bucket_name                          = "${local.prefix}tfe-cos-bucket"
  tfe_license                              = var.tfe_license
  tfe_license_secret_crn                   = var.tfe_license_secret_crn
  admin_username                           = var.admin_username
  admin_password                           = var.admin_password
  admin_email                              = var.admin_email
  tfe_organization                         = var.tfe_organization_name
  postgres_deletion_protection             = var.postgres_deletion_protection
  add_to_catalog                           = var.add_to_catalog
  existing_secrets_manager_crn             = var.secrets_manager_crn
  existing_secrets_manager_secret_group_id = var.secrets_manager_secret_group_id
  secrets_manager_secret_group_name        = "${local.prefix}tfe-secrets-group"
}
