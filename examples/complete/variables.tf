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
  description = "Prefix for name of all resource created by this example"

  validation {
    error_message = "var.prefix must begin and end with a letter and contain only letters, numbers, and - characters."
    condition = (var.prefix == null || var.prefix == "" ? true :
      alltrue([
        can(regex("^[a-z][-a-z0-9]*[a-z0-9]$", var.prefix)),
        length(regexall("--", var.prefix)) == 0
      ])
    )
  }
  default = "tfe-complete"
}

variable "region" {
  type        = string
  description = "Region where resources are created"
  default     = "us-south"
}

variable "existing_resource_group_name" {
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

variable "add_to_catalog" {
  type        = bool
  description = "Whether to add this instance as an engine to your account's catalog settings. Defaults to true. MAY CONFLICT WITH EXISTING INSTANCES YOUR IN CATALOG SETTINGS."
  default     = true
}

variable "postgres_deletion_protection" {
  type        = bool
  description = "Enable deletion protection within terraform. This is not a property of the resource and does not prevent deletion outside of terraform. The database can not be deleted by terraform when this value is set to 'true'. In order to delete with terraform the value must be set to 'false' and a terraform apply performed before the destroy is performed. The default is 'true'."
  default     = true
}

##############################################################################
# Secrets Manager
##############################################################################

variable "secrets_manager_crn" {
  type        = string
  description = "The CRN of the existing Secrets Manager instance. If not set, secrets will not be stored in a Secrets Manager instance."
  default     = null
}

variable "secrets_manager_secret_group_id" {
  type        = string
  description = "The existing secrets group ID to store secrets in. If not set, secrets will be stored in `<var.prefix>` secret group."
  default     = null
}

variable "tfe_license_secret_crn" {
  type        = string
  description = "The CRN of the Secrets Manager secret containing the license key for TFE"
  default     = null
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
