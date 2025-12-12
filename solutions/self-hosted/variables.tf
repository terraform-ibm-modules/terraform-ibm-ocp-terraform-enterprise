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
  default     = null
  sensitive   = true
}

variable "admin_username" {
  type        = string
  description = "The user name of the TFE admin user"
  default     = "admin"
}

variable "admin_email" {
  type        = string
  description = "The email address of the TFE admin user"
  default     = "test@example.com"
}

variable "admin_password" {
  type        = string
  description = "The password for the TFE admin user. 10 char minimum"
  sensitive   = true
}

variable "tfe_organization_name" {
  type        = string
  description = "If set, the name of the TFE organization to create. If not set, the module will not create an organization."
  default     = "default"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,63}$", var.tfe_organization_name))
    error_message = "The TFE organization name must only contain letters, numbers, underscores (_), and hyphens (-), and must not exceed 63 characters."
  }
}

variable "postgres_deletion_protection" {
  type        = bool
  description = "Enable deletion protection within terraform. This is not a property of the resource and does not prevent deletion outside of terraform. The database can not be deleted by terraform when this value is set to 'true'. In order to delete with terraform the value must be set to 'false' and a terraform apply performed before the destroy is performed. The default is 'true'."
  default     = true
}

variable "add_to_catalog" {
  type        = bool
  description = "Whether to add this instance as an engine to your account's catalog settings. Defaults to true. MAY CONFLICT WITH EXISTING INSTANCES YOUR IN CATALOG SETTINGS."
  default     = true
}

##############################################################################
# Secrets Manager
##############################################################################

variable "secrets_manager_crn" {
  type        = string
  description = "The CRN of the existing Secrets Manager instance. If set, secrets will be stored in a Secrets Manager instance."
  default     = null
}

variable "secrets_manager_secret_group_id" {
  type        = string
  description = "The existing secrets group ID to store secrets in. If not set, secrets will be stored in `<var.prefix>-tfe-secrets-group` secret group."
  default     = null

  validation {
    condition = (
      !(var.secrets_manager_crn == null &&
      var.secrets_manager_secret_group_id != null)
    )
    error_message = "`secrets_manager_secret_group_id` is not required when `secrets_manager_crn` is not specified."
  }

  validation {
    condition = anytrue([
      var.secrets_manager_secret_group_id == null,
      var.secrets_manager_secret_group_id == "default",
      can(regex("^[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}", var.secrets_manager_secret_group_id))
    ])
    error_message = "The value provided for 'secrets_manager_secret_group_id' is not valid."
  }
}

variable "tfe_license_secret_crn" {
  type        = string
  description = "The CRN of the Secrets Manager arbitrary secret containing the license key for TFE"
  default     = null

  validation {
    condition     = !(var.tfe_license == null && var.tfe_license_secret_crn == null)
    error_message = "Exactly one of `tfe_license_secret_crn` or `tfe_license` must be set"
  }

  validation {
    condition     = !(var.tfe_license != null && var.tfe_license_secret_crn != null)
    error_message = "Only one of `tfe_license_secret_crn` or `tfe_license` must be set"
  }

  validation {
    condition = anytrue([
      var.tfe_license_secret_crn == null,
      can(regex("^crn:v\\d:(.*:){2}secrets-manager:(.*:)([aos]\\/[\\w_\\-]+):[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}:secret:[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$", var.tfe_license_secret_crn))
    ])
    error_message = "The value provided for 'tfe_license_secret_crn' is not valid."
  }
}

##############################################################################
# Custom domain support
##############################################################################

variable "existing_cis_instance_name" {
  description = "Existing IBM Cloud Internet Service instance providing the support for the base domain of custom hostname to use for Terraform Enterprise instance. It is required to configure a custom hostname. Default to null."
  type        = string
  default     = null
}

variable "existing_cis_instance_resource_group_id" {
  description = "Existing Resource Group ID for the existing IBM Cloud Internet Service instance. It is required to configure a custom hostname. Default to null."
  type        = string
  default     = null
}

variable "existing_cis_instance_domain" {
  description = "The base domain configured on existing IBM Cloud Internet Service instance for the custom hostname to use for Terraform Enterprise instance. It is required to configure a custom hostname. Default to null."
  type        = string
  default     = null
}

variable "tfe_custom_hostname" {
  description = "The custom hostname to use with the base domain for the Terraform Enterprise instance. Default to null."
  type        = string
  default     = null
  validation {
    condition     = var.tfe_custom_hostname == null || (var.tfe_custom_hostname != null && var.existing_cis_instance_name != null && var.existing_cis_instance_resource_group_id != null && var.existing_cis_instance_domain != null && var.tfe_custom_domain_existing_secret_crn != null)
    error_message = "If var.tfe_custom_hostname all the inputs var.existing_cis_instance_name var.existing_cis_instance_resource_group_id var.existing_cis_instance_domain and var.tfe_custom_domain_existing_secret_crn must be not null."
  }
}

variable "create_tfe_custom_hostname_on_cis" {
  description = "Flag to create the custom hostname entry on existing IBM Cloud Internet Service instance for the base domain selected. If enabled a CNAME entry will be created on the DNS configuration towards the default Terraform Enterprise instance route. Default to false."
  type        = bool
  default     = false
}

variable "tfe_custom_domain_existing_secret_crn" {
  description = "CRN of the existing secret storing the TLS certificate for the custom hostname of the Terraform Enterprise instance. It is required to configure a custom hostname. Default to null."
  type        = string
  default     = null
}

variable "tfe_custom_domain_secret_name" {
  description = "The secret name to be used to store the TLS certificate on the OCP cluster for the custom hostname. Default to null. If null and a custom domain is used the secret is named 'terraform-enterprise-certificates-secondary'."
  type        = string
  default     = null
}
