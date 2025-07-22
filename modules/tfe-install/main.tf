data "ibm_container_vpc_cluster" "cluster" {
  cluster_name_id   = var.cluster_id
  resource_group_id = var.cluster_resource_group_id
}

resource "kubernetes_namespace" "tfe" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "tfe_pull_secret" {
  # This secret is used to pull the Terraform Enterprise image from the registry
  metadata {
    name      = "terraform-enterprise"
    namespace = kubernetes_namespace.tfe.metadata[0].name
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "images.releases.hashicorp.com" = {
          "username" = "terraform"
          "password" = var.tfe_license
          "email"    = "test@example.com"
          "auth"     = base64encode("terraform:${var.tfe_license}")
        }
      }
    })
  }
}

locals {
  route_name   = "tfe"
  tfe_hostname = "${local.route_name}-${var.namespace}.${data.ibm_container_vpc_cluster.cluster.ingress_hostname}" # Compute the TFE hostname based on the namespace and cluster ingress hostname. Not putting a depenency on the route resource here, as it is created after the helm release.
}


# ########################################################################################################################
# # Terraform Enterprise Helm Chart
# ########################################################################################################################
resource "helm_release" "tfe_install" {
  depends_on = [kubernetes_secret.tfe_pull_secret]

  name             = "terraform-enterprise"
  chart            = "${path.module}/helm-charts/tfe"
  namespace        = kubernetes_namespace.tfe.metadata[0].name
  create_namespace = false
  timeout          = 1200
  wait             = true
  recreate_pods    = true
  force_update     = true
  reset_values     = true

  set = [
    {
      name  = "image.tag"
      value = var.tfe_image_tag
    },
    {
      name  = "openshift.enabled"
      value = true
    },
    {
      name  = "env.secrets.TFE_LICENSE"
      value = var.tfe_license
    },
    {
      name  = "env.variables.TFE_HOSTNAME"
      value = local.tfe_hostname
    },
    {
      name  = "env.variables.TFE_LICENSE_REPORTING_OPT_OUT"
      value = true
    },
    {
      name  = "env.variables.TFE_USAGE_REPORTING_OPT_OUT"
      value = true
    },
    {
      name  = "env.variables.TFE_INSTALLATION_TYPE"
      value = "openshift"
    },
    {
      name  = "env.variables.TFE_DATABASE_HOST"
      value = var.tfe_database_host
    },
    {
      name  = "env.variables.TFE_DATABASE_PARAMETERS"
      value = "sslmode=require"
    },
    {
      name  = "env.variables.TFE_DATABASE_USER"
      value = var.tfe_database_user
    },
    {
      name  = "env.variables.TFE_DATABASE_NAME"
      value = var.tfe_database_name
    },
    {
      name  = "env.variables.TFE_RUN_PIPELINE_DRIVER"
      value = "kubernetes"
    },
    {
      name  = "env.variables.TFE_TLS_CERT_FILE"
      value = "/etc/ssl/private/terraform-enterprise/tls.crt"
    },
    {
      name  = "env.variables.TFE_VAULT_DISABLE_MLOCK"
      value = true
    },
    {
      name  = "env.secrets.TFE_ENCRYPTION_PASSWORD"
      value = var.tfe_encryption_password
    },
    {
      name  = "env.variables.TFE_RUN_PIPELINE_KUBERNETES_OPEN_SHIFT_ENABLED"
      value = true
    },
    {
      name  = "env.variables.TFE_HTTP_PORT"
      value = "8080"
    },
    {
      name  = "env.variables.TFE_TLS_KEY_FILE"
      value = "/etc/ssl/private/terraform-enterprise/tls.key"
    },
    {
      name  = "env.secrets.TFE_OBJECT_STORAGE_S3_SECRET_ACCESS_KEY"
      value = var.tfe_s3_secret_key
    },
    {
      name  = "env.secrets.TFE_DATABASE_PASSWORD"
      value = var.tfe_database_password
    },
    {
      name  = "env.secrets.TFE_REDIS_PASSWORD"
      value = var.tfe_redis_password
    },
    {
      name  = "env.variables.TFE_OBJECT_STORAGE_S3_ACCESS_KEY_ID"
      value = var.tfe_s3_access_key
    },
    {
      name  = "env.variables.TFE_REDIS_USE_AUTH"
      value = true
    },
    {
      name  = "env.variables.TFE_RUN_PIPELINE_KUBERNETES_POD_TEMPLATE"
      value = "eyJzZWN1cml0eUNvbnRleHQiOnsiYWxsb3dQcml2aWxlZ2VFc2NhbGF0aW9uIjpmYWxzZSwiY2FwYWJpbGl0aWVzIjp7ImRyb3AiOlsiQUxMIl19LCJydW5Bc05vblJvb3QiOnRydWUsInNlY2NvbXBQcm9maWxlIjp7InR5cGUiOiJSdW50aW1lRGVmYXVsdCJ9fX0=" # pragma: allowlist secret
    },
    {
      name  = "env.variables.TFE_OBJECT_STORAGE_S3_BUCKET"
      value = var.tfe_s3_bucket
    },
    {
      name  = "env.variables.TFE_OBJECT_STORAGE_TYPE"
      value = "s3"
    },
    {
      name  = "env.variables.TFE_REDIS_USE_TLS"
      value = false
    },
    {
      name  = "env.variables.TFE_REDIS_HOST"
      value = var.tfe_redis_host
    },
    {
      name  = "env.variables.TFE_OBJECT_STORAGE_S3_REGION"
      value = var.tfe_s3_region
    },
    {
      name  = "env.variables.TFE_OPERATIONAL_MODE"
      value = "external"
    },
    {
      name  = "env.variables.TFE_OBJECT_STORAGE_S3_ENDPOINT"
      value = var.tfe_s3_endpoint
    },
    {
      name  = "env.variables.TFE_RUN_PIPELINE_IMAGE"
      value = data.kubernetes_resource.tfe_agent_image_stream.object.status.dockerImageRepository
    },
    {
      name  = "env.variables.TFE_OBJECT_STORAGE_S3_USE_INSTANCE_PROFILE"
      value = false
    },
    {
      name  = "env.variables.TFE_RUN_PIPELINE_KUBERNETES_NAMESPACE"
      value = kubernetes_namespace.tfe.metadata[0].name
    },
    {
      name  = "agents.namespace.enabled"
      value = false
    },
    {
      name  = "agents.namespace.name"
      value = kubernetes_namespace.tfe.metadata[0].name
    },
    {
      name  = "serviceAccount.enabled"
      value = true
    },
    {
      name  = "serviceAccount.name"
      value = "tfe"
    },
    {
      name  = "env.secrets.TFE_IACT_TOKEN"
      value = random_string.iact_token.result
    }
  ]

  values = [<<-EOF
    container:
      securityContext:
        runAsUser: 1000
  EOF
  ]
}

resource "random_string" "iact_token" {
  length  = 10
  special = false
}

# resource "kubernetes_service_account" "tfe" {
#   metadata {
#     name      = "tfe"
#     namespace = kubernetes_namespace.tfe.metadata[0].name
#   }
# }

resource "kubernetes_role_binding" "tfe_admin" {

  metadata {
    name      = "tfe-anyuuid"
    namespace = kubernetes_namespace.tfe.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:openshift:scc:anyuid"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "tfe"
    namespace = var.namespace
  }
}

resource "kubectl_manifest" "tfe_route" {
  depends_on = [helm_release.tfe_install]

  yaml_body = <<-YAML
    apiVersion: route.openshift.io/v1
    kind: Route
    metadata:
      name: ${local.route_name}
      namespace: ${kubernetes_namespace.tfe.metadata[0].name}
    spec:
      to:
        kind: Service
        name: terraform-enterprise
      port:
        targetPort: https-port
      tls:
        termination: reencrypt
        insecureEdgeTerminationPolicy: None
  YAML
}

data "external" "admin_user_token" {
  depends_on = [kubectl_manifest.tfe_route]
  program = [
    "${path.module}/scripts/create_admin_user.sh",
    local.tfe_hostname,
    random_string.iact_token.result,
    var.admin_username,
    var.admin_email,
    var.admin_password
  ]
}

### Build custom TFE agent image
resource "kubectl_manifest" "tfe_agent_image_stream" {
  yaml_body = <<-YAML
    apiVersion: image.openshift.io/v1
    kind: ImageStream
    metadata:
      name: tfe-agent-ibmcloud
      namespace: ${kubernetes_namespace.tfe.metadata[0].name}
    spec:
      lookupPolicy:
        local: false
  YAML
}

resource "kubectl_manifest" "tfe_agent_build_config" {
  yaml_body = <<-YAML
    apiVersion: build.openshift.io/v1
    kind: BuildConfig
    metadata:
      name: tfe-agent-ibmcloud
      namespace: ${kubernetes_namespace.tfe.metadata[0].name}
    spec:
      source:
        type: Dockerfile
        dockerfile: |
          FROM hashicorp/tfc-agent
          USER root
          RUN mkdir /.tfc-agent && chmod 770 /.tfc-agent
          RUN chmod -R 777 /home

          # Download and install oc
          RUN curl -L https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz -o oc.tar.gz && \
          tar -xvzf oc.tar.gz -C /usr/local/bin oc && \
          tar -xvzf oc.tar.gz -C /usr/local/bin kubectl && \
          rm oc.tar.gz

          # Verify installation
          RUN oc version --client

          USER tfc-agent
      strategy:
        type: Docker
        dockerStrategy:
          from:
            kind: DockerImage
            name: hashicorp/tfc-agent
      output:
        to:
          kind: ImageStreamTag
          name: tfe-agent-ibmcloud:latest
      triggers:
        - type: ConfigChange
  YAML
}

data "kubernetes_resource" "tfe_agent_image_stream" {
  depends_on  = [kubectl_manifest.tfe_agent_image_stream]
  api_version = "image.openshift.io/v1"
  kind        = "ImageStream"
  metadata {
    name      = "tfe-agent-ibmcloud"
    namespace = kubernetes_namespace.tfe.metadata[0].name
  }
}

data "kubernetes_resource" "tfe_route" {
  depends_on  = [kubectl_manifest.tfe_route]
  api_version = "route.openshift.io/v1"
  kind        = "Route"
  metadata {
    name      = local.route_name
    namespace = kubernetes_namespace.tfe.metadata[0].name
  }
}

data "kubernetes_secret" "tfe_admin_token" {
  depends_on = [data.external.admin_user_token]
  metadata {
    name      = "tfe-admin-token"
    namespace = kubernetes_namespace.tfe.metadata[0].name
  }
}

resource "kubernetes_secret" "tfe_admin_token" {
  depends_on = [data.external.admin_user_token]

  metadata {
    name      = "tfe-admin-token"
    namespace = kubernetes_namespace.tfe.metadata[0].name
  }
  data = {
    token = (
      data.external.admin_user_token.result["token"] != null && data.external.admin_user_token.result["token"] != ""
      ? data.external.admin_user_token.result["token"]
      : (try(data.kubernetes_secret.tfe_admin_token.data.token, ""))
    )
  }
  type = "Opaque"
}
