terraform {
  required_version = ">= 1.9.0"

  # Ensure that there is always 1 example locked into the lowest provider version of the range defined in the main
  # module's version.tf (basic and add_rules_to_sg), and 1 example that will always use the latest provider version (advanced, fscloud and multiple mzr).
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = "1.80.4"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.37.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.68.0"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = "1.20.0"
    }
  }
}
