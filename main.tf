##############################################################################
# Create Cloud Object Storage instance and a bucket
##############################################################################

module "cos" {
  source                   = "terraform-ibm-modules/cos/ibm"
  version                  = "10.7.0"
  resource_group_id        = var.resource_group_id
  region                   = var.region
  create_cos_instance      = var.existing_cos_instance_id != null ? false : true
  existing_cos_instance_id = var.existing_cos_instance_id
  cos_instance_name        = var.cos_instance_name
  cos_tags                 = var.resource_tags
  bucket_name              = var.cos_bucket_name
  add_bucket_name_suffix   = true
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
  source              = "./modules/ocp-vpc"
  region              = var.region
  resource_group_id   = var.resource_group_id
  resource_tags       = var.resource_tags
  access_tags         = var.access_tags
  ocp_version         = var.ocp_version
  ocp_entitlement     = var.ocp_entitlement
  existing_vpc_id     = var.existing_vpc_id
  existing_cluster_id = var.existing_cluster_id
  vpc_name            = var.vpc_name
  cluster_name        = var.cluster_name
}

########################################################################################################################
# ICD Postgres
########################################################################################################################

module "icd_postgres" {
  source             = "terraform-ibm-modules/icd-postgresql/ibm"
  version            = "4.4.0"
  resource_group_id  = var.resource_group_id
  name               = var.postgres_instance_name
  postgresql_version = "16" # TFE supports up to Postgres 16 (not 17)
  region             = var.region
  service_endpoints  = "public-and-private"
  member_host_flavor = "multitenant"
  service_credential_names = {
    "tfe" : "Operator"
  }
  deletion_protection = var.postgres_deletion_protection
}

########################################################################################################################
# Redis
########################################################################################################################

module "redis" {
  count  = var.existing_redis_hostname == null ? 1 : 0
  source = "./modules/redis"
}

locals {
  redis_host        = var.existing_redis_hostname != null ? var.existing_redis_hostname : module.redis[0].redis_host
  redis_pass_base64 = var.existing_redis_password_base64 != null ? var.existing_redis_password_base64 : module.redis[0].redis_password_base64
}

########################################################################################################################
# TFE
########################################################################################################################

module "license" {
  count   = var.tfe_license_secret_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.3.3"
  crn     = var.tfe_license_secret_crn
}

# retrieving secret about the arbitrary secret
data "ibm_sm_arbitrary_secret" "tfe_license" {
  count       = var.tfe_license_secret_crn != null ? 1 : 0
  instance_id = module.license[0].service_instance
  region      = module.license[0].region
  secret_id   = module.license[0].resource
}

locals {
  # concatenating secondary host with the domain configured on CIS to compute the full secondary hostname FQDN
  tfe_secondary_hostname_fqdn = var.tfe_secondary_host != null && var.existing_cis_instance_domain != null ? "${var.tfe_secondary_host}.${var.existing_cis_instance_domain}" : null

  tfe_license = var.tfe_license_secret_crn != null ? data.ibm_sm_arbitrary_secret.tfe_license[0].payload : var.tfe_license
}

module "tfe_install" {
  source                    = "./modules/tfe-install"
  cluster_id                = module.ocp_vpc.cluster_id
  cluster_resource_group_id = var.resource_group_id
  namespace                 = var.tfe_namespace
  tfe_license               = local.tfe_license
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

  tfe_organization = var.tfe_organization

  # tfe secondary hostname management
  tfe_secondary_hostname_fqdn        = local.tfe_secondary_hostname_fqdn
  tfe_secondary_hostname_secret_name = var.tfe_secondary_hostname_secret_name
  tfe_secondary_hostname_certificate = var.tfe_secondary_hostname_existing_secret_crn != null ? "${data.ibm_sm_public_certificate.tfe_secondary_hostname_certificate[0].certificate}${data.ibm_sm_public_certificate.tfe_secondary_hostname_certificate[0].intermediate}" : null
  tfe_secondary_hostname_key         = var.tfe_secondary_hostname_existing_secret_crn != null ? data.ibm_sm_public_certificate.tfe_secondary_hostname_certificate[0].private_key : null
}

########################################################################################################################
# Connect to Catalog Management
########################################################################################################################

resource "ibm_cm_account" "cm_account_instance" {
  count = var.add_to_catalog ? 1 : 0
  terraform_engines {
    name            = var.terraform_enterprise_engine_name
    type            = "terraform-enterprise"
    public_endpoint = module.tfe_install.tfe_console_url
    # private_endpoint = "<private_endpoint>"
    api_token = module.tfe_install.token
    da_creation {
      enabled                    = var.enable_automatic_deployable_architecture_creation
      default_private_catalog_id = var.default_private_catalog_id
      polling_info {
        dynamic "scopes" {
          for_each = var.terraform_engine_scopes
          content {
            name = scopes.value.name
            type = scopes.value.type
          }
        }
      }
    }
  }
}

########################################################################################################################
# Store Credentials in Secrets Manager
########################################################################################################################

module "existing_secrets_manager_crn" {
  count   = var.existing_secrets_manager_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.3.3"
  crn     = var.existing_secrets_manager_crn
}

module "secrets_manager_secret_group" {
  count                    = var.existing_secrets_manager_crn != null && var.existing_secrets_manager_secret_group_id == null ? 1 : 0
  source                   = "terraform-ibm-modules/secrets-manager-secret-group/ibm"
  version                  = "1.3.25"
  secret_group_name        = var.secrets_manager_secret_group_name
  secret_group_description = "Secret group for storing secrets created by the Terraform Enterprise Deployable Architecture."
  secrets_manager_guid     = module.existing_secrets_manager_crn[0].service_instance
  region                   = module.existing_secrets_manager_crn[0].region
}

locals {
  secret_group_id = var.existing_secrets_manager_crn == null ? null : var.existing_secrets_manager_secret_group_id != null ? var.existing_secrets_manager_secret_group_id : module.secrets_manager_secret_group[0].secret_group_id
}

module "redis_password_secret" {
  count                   = var.existing_secrets_manager_crn != null ? 1 : 0
  source                  = "terraform-ibm-modules/secrets-manager-secret/ibm"
  version                 = "1.9.1"
  region                  = module.existing_secrets_manager_crn[0].region
  secrets_manager_guid    = module.existing_secrets_manager_crn[0].service_instance
  secret_group_id         = local.secret_group_id
  secret_name             = var.redis_password_secret_name
  secret_description      = "Password for the Terraform Enterprise redis instance."
  secret_type             = "arbitrary"
  secret_payload_password = local.redis_pass_base64
}


########################################################################################################################
# IBM Cloud Internet Service instance management for TFE secondary hostname domain
########################################################################################################################

data "ibm_cis" "existing_cis_instance" {
  count             = var.existing_cis_instance_name != null && var.existing_cis_instance_resource_group_id != null ? 1 : 0
  name              = var.existing_cis_instance_name
  resource_group_id = var.existing_cis_instance_resource_group_id
}

data "ibm_cis_domain" "existing_cis_instance_domain" {
  count  = var.existing_cis_instance_name != null && var.existing_cis_instance_domain != null ? 1 : 0
  domain = var.existing_cis_instance_domain
  cis_id = data.ibm_cis.existing_cis_instance[0].id
}

module "tfe_dns_record" {
  count           = var.existing_cis_instance_name != null && var.existing_cis_instance_domain != null && var.create_tfe_secondary_host_on_cis ? 1 : 0
  source          = "terraform-ibm-modules/cis/ibm//modules/dns"
  version         = "2.2.4"
  cis_instance_id = data.ibm_cis.existing_cis_instance[0].id
  domain_id       = data.ibm_cis_domain.existing_cis_instance_domain[0].domain_id
  dns_record_set = [
    {
      type    = "CNAME"
      name    = "${var.tfe_secondary_host}.${var.existing_cis_instance_domain}"
      content = module.tfe_install.tfe_hostname
      ttl     = 900
    }
  ]
}

module "crn_parser_secrets_manager" {
  count   = var.tfe_secondary_hostname_existing_secret_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.3.0"
  crn     = var.tfe_secondary_hostname_existing_secret_crn
}

data "ibm_sm_public_certificate" "tfe_secondary_hostname_certificate" {
  count       = var.tfe_secondary_hostname_existing_secret_crn != null ? 1 : 0
  instance_id = module.crn_parser_secrets_manager[0].service_instance
  region      = module.crn_parser_secrets_manager[0].region
  secret_id   = module.crn_parser_secrets_manager[0].resource
}
