<!-- Update this title with a descriptive name. Use sentence case. -->
# IBM Cloud OpenShift Terraform Enterprise modules

[![Implemented](https://img.shields.io/badge/Status-Implemented%20(No%20quality%20checks)-yellowgreen)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-ocp-terraform-enterprise?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-ocp-terraform-enterprise/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

## Overview

This repository provides a top-level Terraform module for deploying and managing HashiCorp Terraform Enterprise (TFE) on IBM Cloud Red Hat OpenShift clusters. The module automates the setup of namespaces, secrets, Helm releases, OpenShift routes, and supporting resources required for a TFE installation.

**Status:** This module deploys a functional TFE infrastructure on IBM Cloud. However, it does not yet implement all production-ready requirements such as network isolation, security hardening, and compliance controls. The module interfaces and behaviors may change as these capabilities are added. Early adopters are encouraged to try it and provide feedback.

### TFE Secondary hostname

This module supports to configure the TFE instance with a [secondary hostname](https://developer.hashicorp.com/terraform/enterprise/deploy/reference/configuration#tfe_hostname_secondary) by:
- integrating it with an existing IBM Cloud Internet Services instance providing an already configured domain (i.e. `example.com`) for the DNS support
- providing the host to add to the existing domain DNS configuration (i.e. `tfe-host`) and to configure the route for the final secondary Fully Qualified Domain Name (FQDN) on the OCP cluster (i.e. `tfe-host.example.com`)
- integrating it with an existing secret on IBM Secrets Manager instance to pull the TLS certificate to configure for the OpenShift route that serves the secondary FQDN.

## Required access policies

You need the following permissions to run this module:

- IBM Cloud Resource Group: `Viewer` access on the resource group
- IBM Cloud OpenShift: `Editor` or `Administrator` access to the cluster
- IBM Cloud Object Storage: `Manager` or `Writer` access for the S3 bucket
- IBM Cloud Databases for PostgreSQL/Redis: `Manager` or equivalent access
- IBM Cloud Secrets Manager: `Writer` access if the generated secrets are to be stored in Secrets Manager
- IBM Cloud Secrets Manager: `SecretsReader` access if the Terraform Enterprise license key is in Secrets Manager
- Ability to create and manage Kubernetes resources in the target OpenShift namespace

## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.

## Notes

The module integrates with IBM Cloud Secret Manager service. This integration takes two forms. If an optional IBM Cloud Secrets Manager instance CRN and secret group ID are provided, then the Redis admin user password and Terraform Enterprise admin token will be stored in Secrets Manager and the new secret CRNs will be returned instead of the secret values. If an optional Terraform Enterprise license secret CRN is provided, then the license will be retrieved from Secrets Manager, avoiding the need to pass the license key as a string.

## Known issues

Tear down will fail at the Postgresql instance when delete protection is enabled. Set the delete protection flag to false and run `terraform apply --target 'module.<top level module name>.module.icd_postgres.ibm_database.postgresql_db'` before running the destroy to complete the tear down.
