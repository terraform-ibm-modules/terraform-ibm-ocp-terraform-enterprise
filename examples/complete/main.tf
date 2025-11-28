########################################################################################################################
# Resource Group
########################################################################################################################


locals {
  # these ACLs would enable traffic to/from the ICD postgres instance only from/to the VPE punctual IPs
  # as these ACLs are depending on VCP creation must be attached to the VPC after both VPC and VPE are created
  # leaving these here for documentation reference purposes
  # vpe punctual IPs for ACL rules
  # tflint-ignore: terraform_unused_declarations
  postgres_vpe_acl_rules_strict = flatten([
    for subnet, cidr in var.subnets_zones_cidr : [
      for vpe in module.tfe.icd_postgres_vpe[0].vpe_ips : concat([
        for vpe_ip_name, vpe_ip in vpe : {
          name        = "allow-postgres-inbound-from-vpe-${vpe_ip_name}"
          action      = "allow"
          direction   = "inbound"
          source      = vpe_ip.address
          destination = cidr
          tcp = {
            source_port_max = module.tfe.icd_postgres_port
            source_port_min = module.tfe.icd_postgres_port
          }
        }
        ],
        [
          for vpe_ip_name, vpe_ip in vpe : {
            name        = "allow-postgres-outbound-to-vpe-${vpe_ip_name}"
            action      = "allow"
            direction   = "outbound"
            destination = vpe_ip.address
            source      = cidr
            tcp = {
              source_port_max = module.tfe.icd_postgres_port
              source_port_min = module.tfe.icd_postgres_port
            }
          }
        ]
      )
    ]
  ])
}

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
  subnets_zones_cidr           = var.subnets_zones_cidr
  vpc_acl_rules                = var.vpc_acl_rules
  postgres_add_acl_rule        = var.postgres_add_acl_rule
}
