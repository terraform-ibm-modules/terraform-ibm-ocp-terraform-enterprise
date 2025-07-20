########################################################################################################################
# Resource Group
########################################################################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.2.1"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.existing_resource_group_name == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.existing_resource_group_name
}

##############################################################################
# Create Cloud Object Storage instance and a bucket
##############################################################################

module "cos" {
  source                   = "terraform-ibm-modules/cos/ibm"
  version                  = "9.1.0"
  resource_group_id        = module.resource_group.resource_group_id
  region                   = var.region
  create_cos_instance      = var.existing_cos_instance_id != null ? false : true
  existing_cos_instance_id = var.existing_cos_instance_id
  cos_instance_name        = var.cos_instance_name != null ? var.cos_instance_name : "${var.prefix}-tfe"
  cos_tags                 = var.resource_tags
  bucket_name              = var.cos_bucket_name != null ? var.cos_bucket_name : "${var.prefix}-tfe-bucket"
  create_cos_bucket        = true
  retention_enabled        = var.cos_retention # disable retention for test environments - enable for stage/prod
  kms_encryption_enabled   = false
  resource_keys = [
    {
      name                      = "tfe-credentials"
      generate_hmac_credentials = true
      role                      = "Writer"
    }
  ]
}


########################################################################################################################
# VPC
########################################################################################################################

module "ocp_vpc" {
  source            = "./modules/ocp-vpc"
  region            = var.region
  prefix            = var.prefix
  resource_group_id = module.resource_group.resource_group_id
  resource_tags     = var.resource_tags
  access_tags       = var.access_tags
  ocp_version       = var.ocp_version
  ocp_entitlement   = var.ocp_entitlement
  existing_vpc_id   = var.existing_vpc_id
}

########################################################################################################################
# ICD Postgres
########################################################################################################################

module "icd_postgres" {
  source             = "terraform-ibm-modules/icd-postgresql/ibm"
  version            = "3.22.27"
  resource_group_id  = module.resource_group.resource_group_id
  name               = var.postgres_instance_name != null ? var.postgres_instance_name : "${var.prefix}-data-store"
  pg_version         = "16" # TFE supports up to Postgres 16 (not 17)
  region             = var.region
  service_endpoints  = "public-and-private"
  member_host_flavor = "multitenant"
  service_credential_names = {
    "tfe" : "Operator"
  }
}

########################################################################################################################
# Redis
########################################################################################################################

module "redis" {
  count  = var.redis_host_name == null ? 1 : 0
  source = "./modules/redis"
}

locals {
  redis_host        = var.redis_host_name != null ? var.redis_host_name : module.redis[0].redis_host
  redis_pass_base64 = var.redis_password_base64 != null ? var.redis_password_base64 : module.redis[0].redis_password_base64
}

########################################################################################################################
# TFE
########################################################################################################################

module "tfe_install" {
  source                    = "./modules/tfe-install"
  cluster_id                = module.ocp_vpc.cluster_id
  cluster_resource_group_id = module.resource_group.resource_group_id
  namespace                 = var.tfe_namespace
  tfe_license               = var.tfe_license
  tfe_database_host         = "${module.icd_postgres.hostname}:${module.icd_postgres.port}"
  tfe_database_user         = module.icd_postgres.service_credentials_object.credentials["tfe"].username
  tfe_database_password     = module.icd_postgres.service_credentials_object.credentials["tfe"].password

  tfe_s3_bucket     = module.cos.bucket_name
  tfe_s3_region     = var.region
  tfe_s3_access_key = module.cos.resource_keys["tfe-credentials"].credentials["cos_hmac_keys.access_key_id"]
  tfe_s3_secret_key = module.cos.resource_keys["tfe-credentials"].credentials["cos_hmac_keys.secret_access_key"]
  tfe_s3_endpoint   = module.cos.s3_endpoint_public

  tfe_redis_host     = local.redis_host
  tfe_redis_password = local.redis_pass_base64

  admin_username = var.admin_username
  admin_password = var.admin_password
  admin_email    = var.admin_email
}

########################################################################################################################
# Connect to Catalog Management
########################################################################################################################

data "ibm_cm_account" "cm_account" {}

locals {
  terraform_enterprise_engine_name = var.terraform_enterprise_engine_name != null ? var.terraform_enterprise_engine_name : "${var.prefix}-tfe"

  data = { # this will become a provider call once `terraform_engines` is added to it
    id   = data.ibm_cm_account.cm_account.id
    _rev = data.ibm_cm_account.cm_account.rev

    # pass thru
    account_filters = {
      include_all      = data.ibm_cm_account.cm_account.account_filters[0].include_all,
      id_filters       = length(data.ibm_cm_account.cm_account.account_filters[0].id_filters) != 0 ? data.ibm_cm_account.cm_account.account_filters[0].id_filters[0] : {},
      category_filters = length(data.ibm_cm_account.cm_account.account_filters[0].category_filters) != 0 ? data.ibm_cm_account.cm_account.account_filters[0].category_filters[0] : {},
    }

    terraform_engines = [
      {
        name            = local.terraform_enterprise_engine_name
        type            = "terraform-enterprise"
        public_endpoint = module.tfe_install.tfe_hostname
        api_token       = module.tfe_install.token
        da_creation = {
          enabled                    = var.enable_automatic_deployable_architecture_creation
          default_private_catalog_id = var.default_private_catalog_id
          # "polling_info": { // If polling info is not provided, we will try to auto-create DAs in all workspaces in all orgs
          #   "scopes": [
          #     {
          #       "name": "kz-test",
          #       "type": "project" // Type can be project | org | workspace to poll on to auto-create DAs
          #     }
          #   ]
          # }
        }
      }
    ]
  }
  data_json = jsonencode(local.data)
}

resource "restapi_object" "tfe-engines" {
  path           = "/api/v1-beta/catalogaccount"
  data           = local.data_json
  create_method  = "PUT" # Specify the HTTP method for updates
  update_method  = "PUT"
  destroy_method = "PUT"
}
