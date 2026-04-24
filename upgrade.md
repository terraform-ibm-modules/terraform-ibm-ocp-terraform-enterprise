# Upgrade notes

The following section provides details about the notes related with upgrading to a specific version.
Please consider that the notes for upgrading to a new major version are related with the changes from the previous major version. Upgrading skipping one or more major versions is discouraged.

### Version 4.0.0 Breaking change note

Upgrading to this version is a breaking change due to the deprecation of the kubernetes_config_map resource, moving to kubernetes_config_map_v1.
To prevent the configmap from being destroyed and recreated, please follow the steps below:

1. Update your terraform code to use v3.x.x of the kubernetes provider and to consume the new version of this module
2. Remove the old resource from the state.
By using terraform CLI:
`terraform state rm 'module.tfe.module.tfe_install.kubernetes_config_map.custom_tfe_start'`
By schematics CLI:
`ibmcloud schematics workspace state rm --id <WORKSPACE_ID> --address 'module.tfe.module.tfe_install.kubernetes_config_map.custom_tfe_start'`
3. Import the resource to the new address:
By using Terraform CLI:
`terraform import 'module.tfe.module.tfe_install.kubernetes_config_map_v1.custom_tfe_start' "<custom_tfe_start configmap resource ID>"`
By using Schematics CLI:
`ibmcloud schematics workspace import --id <WORKSPACE_ID> --address 'module.tfe.module.tfe_install.kubernetes_config_map_v1.custom_tfe_start' --resourceID "<custom_tfe_start configmap resource ID>"`
**Note** : Run terraform plan to confirm that the import was successful. Do not run the plan after renaming the resource in the configuration if the above steps haven't been applied yet.
