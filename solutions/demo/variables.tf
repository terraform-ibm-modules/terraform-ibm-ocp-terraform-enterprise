########################################################################################################################
# Input Variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud api key"
  sensitive   = true
}

variable "prefix" {
  type        = string
  nullable    = true
  description = "The prefix to add to all resources that this solution creates (e.g `prod`, `test`, `dev`). To skip using a prefix, set this value to null or an empty string. [Learn more](https://terraform-ibm-modules.github.io/documentation/#/prefix.md)."

  validation {
    # - null and empty string is allowed
    # - Must not contain consecutive hyphens (--): length(regexall("--", var.prefix)) == 0
    # - Starts with a lowercase letter: [a-z]
    # - Contains only lowercase letters (a–z), digits (0–9), and hyphens (-)
    # - Must not end with a hyphen (-): [a-z0-9]
    condition = (var.prefix == null || var.prefix == "" ? true :
      alltrue([
        can(regex("^[a-z][-a-z0-9]*[a-z0-9]$", var.prefix)),
        length(regexall("--", var.prefix)) == 0
      ])
    )
    error_message = "Prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It must not end with a hyphen('-'), and cannot contain consecutive hyphens ('--')."
  }

  validation {
    # must not exceed 16 characters in length
    condition     = var.prefix == null || var.prefix == "" ? true : length(var.prefix) <= 16
    error_message = "Prefix must not exceed 16 characters."
  }
}

variable "region" {
  type        = string
  description = "Region where resources are created"
  default     = "us-south"
}

variable "existing_resource_group_name" {
  type        = string
  description = "The name of an existing resource group to provision the resources. If not provided the default resource group will be used."
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
  description = "Custom ACLs rules to attach to the VPC ones. Default to open port 443 to VPC subnets"
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
    # rules needed to access tfe dashboard on public route
    {
      name        = "allow-https-inbound-zone-1"
      action      = "allow"
      direction   = "inbound"
      source      = "0.0.0.0/0"
      destination = "10.10.10.0/24"
      tcp = {
        source_port_max = 65535
        source_port_min = 1
        port_max        = 443
        port_min        = 443
      }
    },
    {
      name        = "allow-https-outbound-zone-1"
      action      = "allow"
      direction   = "outbound"
      source      = "10.10.10.0/24"
      destination = "0.0.0.0/0"
      tcp = {
        source_port_max = 443
        source_port_min = 443
        port_max        = 65535
        port_min        = 1
      }
    },
    {
      name        = "allow-https-inbound-zone-2"
      action      = "allow"
      direction   = "inbound"
      source      = "0.0.0.0/0"
      destination = "10.10.20.0/24"
      tcp = {
        source_port_max = 65535
        source_port_min = 1
        port_max        = 443
        port_min        = 443
      }
    },
    {
      name        = "allow-https-outbound-zone-2"
      action      = "allow"
      direction   = "outbound"
      source      = "10.20.10.0/24"
      destination = "0.0.0.0/0"
      tcp = {
        source_port_max = 443
        source_port_min = 443
        port_max        = 65535
        port_min        = 1
      }
    },
    {
      name        = "allow-https-inbound-zone-3"
      action      = "allow"
      direction   = "inbound"
      source      = "0.0.0.0/0"
      destination = "10.30.10.0/24"
      tcp = {
        source_port_max = 65535
        source_port_min = 1
        port_max        = 443
        port_min        = 443
      }
    },
    {
      name        = "allow-https-outbound-zone-3"
      action      = "allow"
      direction   = "outbound"
      source      = "10.30.10.0/24"
      destination = "0.0.0.0/0"
      tcp = {
        source_port_max = 443
        source_port_min = 443
        port_max        = 65535
        port_min        = 1
      }
    },
    # rules currently needed to pull images for redis into the cluster
    {
      name        = "allow-https-outbound-for-images-zone-1"
      action      = "allow"
      direction   = "outbound"
      source      = "10.10.10.0/24"
      destination = "0.0.0.0/0"
      tcp = {
        source_port_max = 65535
        source_port_min = 1
        port_max        = 443
        port_min        = 443
      }
    },
    {
      name        = "allow-https-outbound-for-images-zone-2"
      action      = "allow"
      direction   = "outbound"
      source      = "10.20.10.0/24"
      destination = "0.0.0.0/0"
      tcp = {
        source_port_max = 65535
        source_port_min = 1
        port_max        = 443
        port_min        = 443
      }
    },
    {
      name        = "allow-https-outbound-for-images-zone-3"
      action      = "allow"
      direction   = "outbound"
      source      = "10.30.10.0/24"
      destination = "0.0.0.0/0"
      tcp = {
        source_port_max = 65535
        source_port_min = 1
        port_max        = 443
        port_min        = 443
      }
    },
    {
      name        = "allow-https-inbound-for-images-zone-1"
      action      = "allow"
      direction   = "outbound"
      source      = "0.0.0.0/0"
      destination = "10.10.10.0/24"
      tcp = {
        source_port_max = 443
        source_port_min = 443
        port_max        = 65535
        port_min        = 1
      }
    },
    {
      name        = "allow-https-inbound-for-images-zone-2"
      action      = "allow"
      direction   = "outbound"
      source      = "0.0.0.0/0"
      destination = "10.20.10.0/24"
      tcp = {
        source_port_max = 443
        source_port_min = 443
        port_max        = 65535
        port_min        = 1
      }
    },
    {
      name        = "allow-https-inbound-for-images-zone-3"
      action      = "allow"
      direction   = "outbound"
      source      = "0.0.0.0/0"
      destination = "10.30.10.0/24"
      tcp = {
        source_port_max = 443
        source_port_min = 443
        port_max        = 65535
        port_min        = 1
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
