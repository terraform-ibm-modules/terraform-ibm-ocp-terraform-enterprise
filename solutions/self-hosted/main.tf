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
  vpc_name                                 = "${local.prefix}vpc"
  cluster_name                             = "${local.prefix}cluster"
  postgres_instance_name                   = "${local.prefix}data-store"
  cos_instance_name                        = "${local.prefix}cos"
  cos_bucket_name                          = "${local.prefix}cos-bucket"
  tfe_license                              = var.tfe_license
  tfe_license_secret_crn                   = var.tfe_license_secret_crn
  admin_username                           = var.admin_username
  admin_password                           = var.admin_password
  admin_email                              = var.admin_email
  tfe_organization                         = var.tfe_organization_name
  postgres_deletion_protection             = var.postgres_deletion_protection
  postgres_vpe_enabled                     = var.postgres_vpe_enabled
  postgres_service_endpoints               = var.postgres_service_endpoints
  subnets_zones_cidr                       = var.subnets_zones_cidr
  vpc_acl_rules                            = var.vpc_acl_rules
  postgres_add_acl_rule                    = var.postgres_add_acl_rule
  add_to_catalog                           = var.add_to_catalog
  existing_secrets_manager_crn             = var.secrets_manager_crn
  existing_secrets_manager_secret_group_id = var.secrets_manager_secret_group_id
  secrets_manager_secret_group_name        = "${local.prefix}secrets-group"
  redis_password_secret_name               = "${local.prefix}redis-password"
  # TFE secondary hostname management
  tfe_secondary_host                         = var.tfe_secondary_host
  existing_cis_instance_name                 = var.existing_cis_instance_name
  existing_cis_instance_resource_group_id    = var.existing_cis_instance_resource_group_id
  existing_cis_instance_domain               = var.existing_cis_instance_domain
  create_tfe_secondary_host_on_cis           = var.create_tfe_secondary_host_on_cis
  tfe_secondary_hostname_existing_secret_crn = var.tfe_secondary_hostname_existing_secret_crn
  tfe_secondary_hostname_secret_name         = var.tfe_secondary_hostname_secret_name
}
