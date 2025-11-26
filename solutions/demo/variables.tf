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

variable "postgres_deletion_protection" {
  type        = bool
  description = "Enable deletion protection within terraform. This is not a property of the resource and does not prevent deletion outside of terraform. The database can not be deleted by terraform when this value is set to 'true'. In order to delete with terraform the value must be set to 'false' and a terraform apply performed before the destroy is performed. The default is 'true'."
  default     = true
}

variable "add_to_catalog" {
  description = "Whether to add this instance as an engine to your account's catalog settings. Defaults to true. MAY CONFLICT WITH EXISTING INSTANCES YOUR IN CATALOG SETTINGS."
  type        = bool
  default     = true
}

##############################################################################
# Secrets Manager
##############################################################################

variable "secrets_manager_crn" {
  description = "The CRN of the existing Secrets Manager instance. If set, secrets will be stored in a Secrets Manager instance."
  type        = string
  default     = null
}

variable "secrets_manager_secret_group_id" {
  description = "The existing secrets group ID to store secrets in. If not set, secrets will be stored in `<var.prefix>` secret group."
  type        = string
  default     = null

  validation {
    condition = (
      !(var.secrets_manager_crn == null &&
      var.secrets_manager_secret_group_id != null)
    )
    error_message = "`secrets_manager_secret_group_id` is not required when `secrets_manager_crn` is not specified."
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
      can(regex("^crn:v\\d:(.*:){2}secrets-manager:(.*:)([aos]\\/[\\w_\\-]+):[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}::$", var.tfe_license_secret_crn))
    ])
    error_message = "The value provided for 'tfe_license_secret_crn' is not valid."
  }
}
