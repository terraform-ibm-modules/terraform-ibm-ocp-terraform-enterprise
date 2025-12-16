<!-- Update this title with a descriptive name. Use sentence case. -->
# IBM Cloud OpenShift Terraform Enterprise modules

[![Incubating](https://img.shields.io/badge/status-Incubating%20(Not%20yet%20consumable)-red)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-ocp-terraform-enterprise?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-ocp-terraform-enterprise/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

## Overview

This repository provides a top-level Terraform module for deploying and managing HashiCorp Terraform Enterprise (TFE) on IBM Cloud Red Hat OpenShift clusters. The module automates the setup of namespaces, secrets, Helm releases, OpenShift routes, and supporting resources required for a production-grade TFE installation.
It provides also the option to setup a secondary hostname for the Terraform Enterprise instance from an existing domain registered on an existing instance of IBM Cloud Internet Service.

**Status:** This module is working but still incubating (alpha version). Interfaces and behaviors may change. Early adopters are encouraged to try it and provide feedback.


## Required access policies

You need the following permissions to run this module:

- IBM Cloud Resource Group: `Viewer` access on the resource group
- IBM Cloud OpenShift: `Editor` or `Administrator` access to the cluster
- IBM Cloud Object Storage: `Manager` or `Writer` access for the S3 bucket
- IBM Cloud Databases for PostgreSQL/Redis: `Manager` or equivalent access
- Ability to create and manage Kubernetes resources in the target OpenShift namespace
- IBM Cloud Internet Service: `Reader` or `Writer` access to read domain details or to create a CNAME entry for the DNS
- IBM Cloud Secrets Manager: `Reader` and `Writer` access to read and write secrets

## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
