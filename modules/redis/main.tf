locals {
  namespace    = "redis-tfe"
  release_name = "redis"
}

resource "helm_release" "redis_install" {
  name             = local.release_name
  repository       = "oci://registry-1.docker.io/bitnamicharts"
  chart            = "redis"
  namespace        = local.namespace
  create_namespace = true
  timeout          = 1200
  wait             = true
  recreate_pods    = true
  force_update     = true
  reset_values     = true
}

data "kubernetes_secret_v1" "redis_password" {
  depends_on = [helm_release.redis_install]
  metadata {
    name      = local.release_name
    namespace = local.namespace
  }
}
