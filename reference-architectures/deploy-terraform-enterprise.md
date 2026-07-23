---
copyright:
  years: 2026
lastupdated: "[{LAST_UPDATED_DATE}]"

subcollection: deployable-reference-architectures

# The release that the reference architecture describes
version: 1.0

deployment-url: https://cloud.ibm.com/catalog/7a4d68b4-cf8b-40cd-a3d1-f49aff526eb3/architecture/deploy-arch-ibm-terraform-enterprise-42170cf3-6337-453e-8d2d-ffabd48c4914-global

docs: https://cloud.ibm.com/docs/solution-guide

image_source: https://github.com/terraform-ibm-modules/terraform-ibm-terraform-enterprise/reference-architectures/diagram-quick-start.svg


use-case: TOPICS-Terraform

industry: SoftwareAndPlatformApplications

content-type: reference-architecture

production: true

---

{{site.data.keyword.attribute-definition-list}}


# Terraform Enterprise (TFE) on IBM Cloud
{: #deploy-tfe-byol}
{: toc-content-type="reference-architecture"}

Terraform Enterprise (TFE) on IBM Cloud streamlines how organizations set up and manage infrastructure as code.


This deployable architecture automates the deployment of a complete TFE infrastructure stack on IBM Cloud using your existing HashiCorp Terraform Enterprise license.

## Architecture diagram
{: #architecture-diagram}

The following diagram shows the architecture of the Terraform Enterprise on IBM Cloud.

![Terraform Enterprise on IBM Cloud](/reference-architectures/diagram-quick-start.svg "Architecture diagram for Terraform Enterprise on IBM Cloud"){: caption="A description that prints on the page" caption-side="bottom"}


## Design concepts
{: #design-concepts}

The following heat map illustrates the design concepts and their relationships.

![Scope of the design requirements](/reference-architectures/deploy-tfe-enterprise.svg "Scope of the design requirements"){: caption="Scope of the design requirements" caption-side="bottom"}



## Requirements
{: #requirements}

The following table outlines the requirements that are addressed in this architecture.

| Aspect | Requirements |
| -------------- | -------------- |
| Compute            | Red Hat OpenShift Container Platform for container orchestration|
| Storage            | Cloud Object Storage for state files, PostgreSQL for metadata, Redis for caching |
| Networking         | Multi-zone VPC with private connectivity and optional custom domains|
| Security           | Key Protect encryption, IAM access control, and Secrets Manager integration|
| Resiliency         | Multi-zone deployment with automated backups and high availability|
{: caption="Requirements" caption-side="bottom"}

## Components
{: #components}

The following table outlines the products or services used in the architecture for each aspect.

| Requirement | Component |	Reasons for choice | Alternative choice|
| -------------- | -------------- | -------------- | -------------- |
| Provide infrastructure-as-code automation platform | Terraform Enterprise on OpenShift | Delivers enterprise-grade Terraform automation with team collaboration, policy enforcement, and state management | Use open-source Terraform with manual state management and CI/CD pipelines |
| Support containerized TFE deployment | Red Hat OpenShift cluster (minimal 2-node) | Provides Kubernetes orchestration with enterprise support and integrated security features | Use IBM Kubernetes Service (IKS) or managed Kubernetes  |
| Ensure network isolation and security | VPC with multi-zone subnets | Isolates TFE infrastructure from public internet while allowing controlled access | Use single-zone VPC or deploy on classic infrastructure |
| Store Terraform state files and backups | Cloud Object Storage | Provides durable, scalable S3-compatible storage with encryption at rest | Use external S3-compatible storage or NFS volumes |
| Provide relational database for TFE metadata | PostgreSQL | Provides scalable relational database with high availability and backup capabilities | Use managed database service like IBM Cloud Databases or external PostgreSQL cluster |
| Enable session and queue management | Redis (on-cluster deployment) | Provides fast in-memory caching for TFE sessions and background jobs | Use IBM Cloud Databases for Redis (ICD Redis) |
| Encrypt data at rest and in transit | Key Protect with multiple encryption keys | Manages encryption keys for COS, PostgreSQL, backups, and VSI volumes | Use Hyper Protect Crypto Services (HPCS) for FIPS 140-2 Level 4 compliance |
| Support custom domain for TFE | Cloud Internet Services (CIS) with DNS | Provides custom domain configuration and SSL termination | Use default OpenShift route hostname |
| Build custom TFE agent image | Custom TFE Agent Image Builder | Provides customized TFE agent images with specific configurations | Use default TFE agent image or build custom image |

## Next steps
{: #next-steps}

To deploy this architecture, understand [Terraform Enterprise (TFE) Bring Your Own License](/docs/ibm-cloud-provider-for-terraform?topic=ibm-cloud-provider-for-terraform-deploying-tfe-byol).
