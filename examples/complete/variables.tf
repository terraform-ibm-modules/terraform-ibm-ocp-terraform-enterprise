########################################################################################################################
# Input Variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud api key"
  sensitive   = true
}

variable "ibmcloud_provider_visibility" {
  type        = string
  description = "The IBM Cloud provider visibility setting"
  default     = "public"
}

variable "prefix" {
  type        = string
  description = "Prefix for name of all resource created by this example"
  validation {
    error_message = "Prefix must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([A-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix))
  }
  default = "tfe"
}

variable "region" {
  type        = string
  description = "Region where resources are created"
  default     = "us-south"
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to provision resources in, if unset a new resource group will be created"
  default     = null
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

variable "tfe_license" {
  type        = string
  description = "The license key for TFE"
  sensitive   = true
}

variable "admin_username" {
  description = "The user name of the TFE admin user"
  type        = string
  default     = "admin"
}

variable "admin_email" {
  description = "The email address of the TFE admin user"
  type        = string
  default     = "test@example.com"
}

variable "admin_password" {
  description = "The password for the TFE admin user. 10 char minimum"
  type        = string
  sensitive   = true
}

variable "tfe_organization_name" {
  description = "If set, the name of the TFE organization to create. If not set, the module will not create an organization."
  type        = string
  default     = "default"
  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,63}$", var.tfe_organization_name))
    error_message = "The TFE organization name must only contain letters, numbers, underscores (_), and hyphens (-), and must not exceed 63 characters."
  }
}

variable "add_to_catalog" {
  description = "Whether to add this instance as an engine to your account's catalog settings. Defaults to true. MAY CONFLICT WITH EXISTING INSTANCES YOUR IN CATALOG SETTINGS."
  type        = bool
  default     = true
}

variable "postgres_deletion_protection" {
  type        = bool
  description = "Enable deletion protection within terraform. This is not a property of the resource and does not prevent deletion outside of terraform. The database can not be deleted by terraform when this value is set to 'true'. In order to delete with terraform the value must be set to 'false' and a terraform apply performed before the destroy is performed. The default is 'true'."
  default     = true
}

variable "postgres_service_endpoints" {
  description = "Service endpoints for the Postgres instance to deploy. Default is `public-and-private`"
  default     = "public-and-private"
  type        = string
}

variable "postgres_vpe_enabled" {
  type        = bool
  description = "Enable VPE connection for the Postgres instance. Default is `false`. If true, a VPE gateway is created to the Postgres instance and TFE is configured with the VPE endpoint."
  default     = false
}

variable "vpc_acl_rules" {
  description = "Custom ACLs rules to attach to the VPC ones"
  type = list(object({
    action      = string
    before      = optional(string, null)
    destination = string
    direction   = string
    name        = string
    source      = string
    tcp = object({
      port_max        = optional(number, 65535)
      port_min        = optional(number, 1)
      source_port_max = optional(number, 65535)
      source_port_min = optional(number, 1)
    })
  }))
  default = [
    {
      name        = "allow-all-inbound"
      action      = "allow"
      direction   = "inbound"
      source      = "0.0.0.0/0"
      destination = "0.0.0.0/0"
      tcp = {
        port_max        = 65535
        port_min        = 1
        source_port_max = 65535
        source_port_min = 1
      }
    },
    {
      name        = "allow-all-outbound"
      action      = "allow"
      direction   = "outbound"
      source      = "0.0.0.0/0"
      destination = "0.0.0.0/0"
      tcp = {
        port_max        = 65535
        port_min        = 1
        source_port_max = 65535
        source_port_min = 1
      }
    }
  ]
}

variable "postgres_add_acl_rule" {
  type        = bool
  default     = true
  description = "Concatenate two rules to enable traffic to/from Postgres instance port to the VPC ACLs. If postgres_vpe_enabled is enabled the ACL rules will be configured VPC subnets CIDR as source and target, if postgres_vpe_enabled is disabled the ACL rules will use 0.0.0.0/0 as CIDR of Postgres instance references. Default true."
}

variable "subnets_zones_cidr" {
  description = "Map of zone name (key) and cidr to use in the zone (value)"
  type        = map(string)
  default = {
    "zone-1" = "10.10.10.0/24"
    "zone-2" = "10.20.10.0/24"
    "zone-3" = "10.30.10.0/24"
  }
}
