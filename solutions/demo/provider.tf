########################################################################################################################
# Terraform providers
########################################################################################################################


provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
  visibility       = "public"
}

# Download cluster config which is required to connect to cluster
data "ibm_container_cluster_config" "cluster_config" {
  cluster_name_id   = module.tfe.cluster_id
  resource_group_id = module.tfe.resource_group_id
  config_dir        = "${path.module}/kubeconfig"
}

provider "helm" {
  kubernetes {
    host                   = data.ibm_container_cluster_config.cluster_config.host
    token                  = data.ibm_container_cluster_config.cluster_config.token
    cluster_ca_certificate = data.ibm_container_cluster_config.cluster_config.ca_certificate
  }
}

provider "kubernetes" {
  host                   = data.ibm_container_cluster_config.cluster_config.host
  token                  = data.ibm_container_cluster_config.cluster_config.token
  cluster_ca_certificate = data.ibm_container_cluster_config.cluster_config.ca_certificate
}

provider "kubectl" {
  host                   = data.ibm_container_cluster_config.cluster_config.host
  token                  = data.ibm_container_cluster_config.cluster_config.token
  cluster_ca_certificate = data.ibm_container_cluster_config.cluster_config.ca_certificate
  load_config_file       = false # https://github.com/gavinbunney/terraform-provider-kubectl/issues/333
}

provider "tfe" {
  hostname = module.tfe_install.tfe_hostname
  token    = base64encode(module.tfe_install.token)
}
data "ibm_iam_auth_token" "auth_token" {
  depends_on = [module.tfe.cluster_id]
}

provider "restapi" {
  uri = "https://cm.globalcatalog.cloud.ibm.com"
  headers = {
    Authorization = data.ibm_iam_auth_token.auth_token.iam_access_token
  }
  write_returns_object = true
}
