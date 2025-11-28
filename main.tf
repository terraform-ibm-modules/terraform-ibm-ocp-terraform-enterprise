########################################################################################################################
# Resource Group
########################################################################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.4.0"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.existing_resource_group_name == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.existing_resource_group_name
}

##############################################################################
# Create Cloud Object Storage instance and a bucket
##############################################################################

module "cos" {
  source                   = "terraform-ibm-modules/cos/ibm"
  version                  = "10.5.10"
  resource_group_id        = module.resource_group.resource_group_id
  region                   = var.region
  create_cos_instance      = var.existing_cos_instance_id != null ? false : true
  existing_cos_instance_id = var.existing_cos_instance_id
  cos_instance_name        = var.cos_instance_name != null ? var.cos_instance_name : "${var.prefix}-tfe"
  cos_tags                 = var.resource_tags
  bucket_name              = var.cos_bucket_name != null ? var.cos_bucket_name : "${var.prefix}-tfe-bucket"
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
# ICD Postgres
########################################################################################################################

module "icd_postgres" {
  source             = "terraform-ibm-modules/icd-postgresql/ibm"
  version            = "4.3.0"
  resource_group_id  = module.resource_group.resource_group_id
  name               = var.postgres_instance_name != null ? var.postgres_instance_name : "${var.prefix}-data-store"
  postgresql_version = "16" # TFE supports up to Postgres 16 (not 17)
  region             = var.region
  service_endpoints  = var.postgres_service_endpoints
  member_host_flavor = "multitenant"
  service_credential_names = {
    "tfe" : "Operator"
  }
  deletion_protection = var.postgres_deletion_protection
}

########################################################################################################################
# VPC
########################################################################################################################

# defining ACL rules to allow traffic to/from the ICD Postgres instance based on the selected service endpoints and VPE configuration
locals {

  postgres_public_acl_rules = flatten([
    for subnet, cidr in var.subnets_zones_cidr :
    concat(
      [
        {
          name        = "allow-postgres-outbound-${subnet}"
          action      = "allow"
          direction   = "outbound"
          source      = cidr
          destination = "0.0.0.0/0"
          tcp = {
            source_port_max = 65535
            source_port_min = 1
            port_min        = module.icd_postgres.port
            port_max        = module.icd_postgres.port
          }
        }
      ],
      [
        {
          name        = "allow-postgres-inbound-${subnet}"
          action      = "allow"
          direction   = "inbound"
          source      = "0.0.0.0/0"
          destination = cidr
          tcp = {
            source_port_max = module.icd_postgres.port
            source_port_min = module.icd_postgres.port
            port_max        = 65535
            port_min        = 1
          }
        }
      ]
    )
    ]
  )

  # ACL rules allowing traffic from/to the subnet CIDRs when VPE is enabled
  postgres_vpe_acl_rules = flatten([
    for subnet, cidr in var.subnets_zones_cidr : [
      {
        name        = "allow-postgres-outbound-to-vpe-${subnet}"
        action      = "allow"
        direction   = "outbound"
        source      = cidr
        destination = cidr
        tcp = {
          source_port_max = 65535
          source_port_min = 1
          port_min        = module.icd_postgres.port
          port_max        = module.icd_postgres.port
        }
      },
      {
        name        = "allow-postgres-inbound-from-vpe-${subnet}"
        action      = "allow"
        direction   = "inbound"
        source      = cidr
        destination = cidr
        tcp = {
          source_port_max = module.icd_postgres.port
          source_port_min = module.icd_postgres.port
          port_max        = 65535
          port_min        = 1
        }
      }
    ]
  ])

  # if postgres_add_acl_rule is true, concatenate the appropriate postgres ACL rules to the VPC ACL rules (according to var.postgres_vpe_enabled flag value)
  final_acl_rules = var.postgres_add_acl_rule ? (var.postgres_vpe_enabled == true ? concat(var.vpc_acl_rules, local.postgres_vpe_acl_rules) : concat(var.vpc_acl_rules, local.postgres_public_acl_rules)) : var.vpc_acl_rules
  # final_acl_rules = var.postgres_vpe_enabled == true ? concat(var.vpc_acl_rules, local.postgres_vpe_acl_rules) : concat(var.vpc_acl_rules, local.postgres_public_acl_rules)
}

module "ocp_vpc" {
  source             = "./modules/ocp-vpc"
  region             = var.region
  prefix             = var.prefix
  resource_group_id  = module.resource_group.resource_group_id
  resource_tags      = var.resource_tags
  access_tags        = var.access_tags
  ocp_version        = var.ocp_version
  ocp_entitlement    = var.ocp_entitlement
  existing_vpc_id    = var.existing_vpc_id
  vpc_acl_rules      = local.final_acl_rules
  subnets_zones_cidr = var.subnets_zones_cidr
}

module "icd_postgres_vpe" {
  count   = var.postgres_vpe_enabled ? 1 : 0
  source  = "terraform-ibm-modules/vpe-gateway/ibm"
  version = "4.8.4"
  region  = var.region
  cloud_service_by_crn = [
    {
      crn          = (module.icd_postgres.crn)
      service_name = "postgresql"
    }
  ]
  service_endpoints = var.service_endpoints
  vpc_name          = module.ocp_vpc.vpc_name
  vpc_id            = module.ocp_vpc.vpc_id
  subnet_zone_list  = module.ocp_vpc.vpc_subnet_zone_list
  resource_group_id = module.resource_group.resource_group_id
}


# attach rules to the VPC default security group to enable traffic from the OCP cluster's workers to the ICD Postgres instance
# if the VPE gateway to postgres is enabled, restrict access to the subnet CIDRs, otherwise allow from anywhere
resource "ibm_is_security_group_rule" "vpc_kubecluster_sg_rule" {
  for_each = {
    for subnet in module.ocp_vpc.vpc_subnet_zone_list :
    "${subnet.name}_${subnet.zone}" => {
      id   = subnet.id
      zone = subnet.zone
      cidr = subnet.cidr
    }
  }
  group     = module.ocp_vpc.vpc_default_security_group
  direction = "inbound"
  local     = var.postgres_vpe_enabled == true ? each.value.cidr : "0.0.0.0/0"
  remote    = module.ocp_vpc.kube_cluster_sg.id
  tcp {
    port_min = module.icd_postgres.port
    port_max = module.icd_postgres.port
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

  tfe_organization = var.tfe_organization
}

########################################################################################################################
# Connect to Catalog Management
########################################################################################################################

locals {
  terraform_enterprise_engine_name = var.terraform_enterprise_engine_name != null ? var.terraform_enterprise_engine_name : "${var.prefix}-tfe"
}

resource "ibm_cm_account" "cm_account_instance" {
  count = var.add_to_catalog ? 1 : 0
  terraform_engines {
    name            = local.terraform_enterprise_engine_name
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
