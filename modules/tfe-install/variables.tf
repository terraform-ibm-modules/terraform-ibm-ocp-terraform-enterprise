##############################################################################
# Cluster variables
##############################################################################

variable "cluster_id" {
  type        = string
  description = "The ID of the cluster you wish to deploy Terraform Enterprise to"
}

variable "cluster_resource_group_id" {
  type        = string
  description = "The Resource Group ID of the cluster"
}

variable "namespace" {
  description = "The namespace to deploy Terraform Enterprise to. This namespace will be created if it does not exist."
  type        = string
  default     = "tfe"
}

#################################################################################
# Initialize Terraform Enterprise instance variables
#################################################################################

variable "admin_username" {
  description = "The user name of the Terraform Enterprise admin user"
  type        = string
}

variable "admin_email" {
  description = "The email address of the Terraform Enterprise admin user"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.admin_email))
    error_message = "Invalid email format for admin_email. Please provide a valid email address."
  }
}

variable "admin_password" {
  description = "The password for the Terraform Enterprise admin user"
  type        = string

  validation {
    condition     = length(var.admin_password) >= 10
    error_message = "The admin password must be at least 10 characters long."
  }
  sensitive = true
}

variable "tfe_organization" {
  description = "If set, the name of the Terraform Enterprise organization to create. If not set, the module will not create an organization."
  type        = string
  default     = "default"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,63}$", var.tfe_organization))
    error_message = "The Terraform Enterprise organization name must only contain letters, numbers, underscores (_), and hyphens (-), and must not exceed 63 characters."
  }
}

##############################################################################
# Terraform Enterprise Installation variables
##############################################################################

variable "tfe_license" {
  description = "The license key for Terraform Enterprise"
  type        = string
  sensitive   = true
}

variable "tfe_image_tag" {
  description = "The version tag of the Terraform Enterprise image to use"
  type        = string
  default     = "v202504-1"
}

variable "tfe_encryption_password" {
  description = "The encryption password for Terraform Enterprise"
  type        = string
  default     = "vincent"
  sensitive   = true
}

variable "tfe_database_host" {
  description = "The host of the database for Terraform Enterprise, including the port - e.g. 'hostname:port'"
  type        = string
}

variable "tfe_database_user" {
  description = "The database user for Terraform Enterprise"
  type        = string
}

variable "tfe_database_password" {
  description = "The database password for Terraform Enterprise"
  type        = string
  sensitive   = true
}

variable "tfe_database_name" {
  description = "The name of the database for Terraform Enterprise"
  type        = string
  default     = "ibmclouddb"
}

variable "tfe_s3_bucket" {
  description = "The S3 bucket name for Terraform Enterprise object storage"
  type        = string
  default     = "tfe-bucket-vincent"
}

variable "tfe_s3_region" {
  description = "The region for the S3 bucket"
  type        = string
  default     = "eu-es"
}

variable "tfe_s3_access_key" {
  description = "The access key for S3 object storage"
  type        = string
  sensitive   = true
}

variable "tfe_s3_secret_key" {
  description = "The secret key for S3 object storage"
  type        = string
  sensitive   = true
}

variable "tfe_s3_endpoint" {
  description = "The endpoint for S3 object storage"
  type        = string
  default     = "s3.eu-es.cloud-object-storage.appdomain.cloud"
}

variable "tfe_redis_host" {
  description = "The Redis host for Terraform Enterprise"
  type        = string
}

variable "tfe_redis_password" {
  description = "The Redis password for Terraform Enterprise"
  type        = string
  default     = ""
  sensitive   = true
}

variable "tfe_secondary_hostname_fqdn" {
  description = "The FQDN for the Terraform Enterprise secondary instance hostname. Default to null."
  type        = string
  default     = null
  validation {
    condition     = var.tfe_secondary_hostname_fqdn == null || (var.tfe_secondary_hostname_fqdn != null && var.tfe_secondary_hostname_certificate != null && var.tfe_secondary_hostname_key != null)
    error_message = "If var.tfe_secondary_hostname_fqdn the inputs parameters var.tfe_secondary_hostname_certificate and var.tfe_secondary_hostname_key cannot be null."
  }
}

variable "tfe_secondary_hostname_certificate" {
  description = "The TLS certificate for the Terraform Enterprise instance secondary hostname. It is required to configure the Terraform Enterprise secondary hostname. Default to null."
  type        = string
  default     = null
}

variable "tfe_secondary_hostname_key" {
  description = "The TLS certificate private key for the Terraform Enterprise instance secondary hostname. It is required to configure a Terraform Enterprise secondary hostname. Default to null."
  type        = string
  default     = null
}

variable "tfe_secondary_hostname_secret_name" {
  description = "The secret name to be used to store the TLS certificate on the OCP cluster for the Terraform Enterprise instance secondary hostname. Default to 'terraform-enterprise-certificates-secondary'."
  type        = string
  default     = "terraform-enterprise-certificates-secondary"
}
