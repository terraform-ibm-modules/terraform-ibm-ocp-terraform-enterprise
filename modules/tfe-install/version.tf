terraform {
  required_version = ">= 1.9.0"

  # Each required provider's version should be a flexible range to future proof the module's usage with upcoming minor and patch versions.
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">= 1.70.0, <2.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.0.0, <4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.1, <4.0.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.19.0, <2.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 3.0.1, <4.0.0"
    }
    external = {
      source  = "hashicorp/external"
      version = ">= 2.3.5, <3.0.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0, <4.0.0"
    }
  }
}
