# Cloud Object Storage Backup Vault module

Backup vaults store backup data in a secure, unmodifiable manner that provides a high degree of data integrity. Backup vaults are provisioned within a IBM Cloud Object Storage instance alongside buckets, but are managed and behave differently than buckets. [Learn more](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-bvm-overview).

**NOTE: terraform destroy will fail on the backup vault once a policy exists using that vault instance. Destroy will only work after all buckets using the vault have been destroyed and the initial_delete_after_days has been met.**

### Usage
```hcl
module "backup_vault" {
  source                   = "terraform-ibm-modules/cos/ibm//modules/backup_vault"
  version                  = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release
  name                     = "my-vault"
  existing_cos_instance_id = "crn:v1:bluemix:public:cloud-object-storage:global:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxxxxxxx-XXXX-XXXX-XXXX-xxxxxxxx::"
  region                   = "us-south""
  kms_encryption_enabled   = true
  kms_key_crn              = "crn:v1:bluemix:public:kms:us-south:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxxxxx-XXXX-XXXX-XXXX-xxxxxx:key:xxxxxx-XXXX-XXXX-XXXX-xxxxxx"
}
```

### Required IAM access policies

You need the following permissions to run this module.

- Account Management
    - **Resource Group** service
        - `Viewer` platform access
- IAM Services
    - **IBM Cloud Object Storage** service
        - `Editor` platform access
        - `Manager` service access

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.80.0, < 2.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5.1, < 4.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1, < 1.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cos_crn_parser"></a> [cos\_crn\_parser](#module\_cos\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.4.1 |
| <a name="module_kms_crn_parser"></a> [kms\_crn\_parser](#module\_kms\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.4.1 |

### Resources

| Name | Type |
|------|------|
| [ibm_cos_backup_vault.backup_vault](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/cos_backup_vault) | resource |
| [ibm_iam_authorization_policy.policy](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [random_string.name_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [time_sleep.wait_for_authorization_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_activity_tracking_management_events"></a> [activity\_tracking\_management\_events](#input\_activity\_tracking\_management\_events) | Whether to enable activity tracking management events for the Backup Vault instance. | `bool` | `true` | no |
| <a name="input_add_name_suffix"></a> [add\_name\_suffix](#input\_add\_name\_suffix) | Whether to add a randomly generated 4-character suffix to the Backup Vault name. | `bool` | `true` | no |
| <a name="input_existing_cos_instance_id"></a> [existing\_cos\_instance\_id](#input\_existing\_cos\_instance\_id) | The ID of the Object Storage instance to create the Backup Vault instance in. | `string` | n/a | yes |
| <a name="input_kms_encryption_enabled"></a> [kms\_encryption\_enabled](#input\_kms\_encryption\_enabled) | Whether to use key management service key encryption to encrypt data in the Backup Vault instance. | `bool` | `false` | no |
| <a name="input_kms_key_crn"></a> [kms\_key\_crn](#input\_kms\_key\_crn) | The CRN of the key management service root key to encrypt the data in the Backup Vault instance. Required if `kms_encryption_enabled` is set to `true`. | `string` | `null` | no |
| <a name="input_metrics_monitoring_usage_metrics"></a> [metrics\_monitoring\_usage\_metrics](#input\_metrics\_monitoring\_usage\_metrics) | Whether to enable usage metrics monitoring for the Backup Vault instance. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | The name to give the Backup Vault instance. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region to create the Backup Vault instance in. | `string` | `"us-south"` | no |
| <a name="input_skip_kms_iam_authorization_policy"></a> [skip\_kms\_iam\_authorization\_policy](#input\_skip\_kms\_iam\_authorization\_policy) | Set to true the skip the creation of an IAM authorization policy that grants the Object Storage instance 'Reader' access to the specified KMS key. This policies must exist in your account for encryption to work. Ignored if 'kms\_encryption\_enabled' is false. | `bool` | `false` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_backup_vault_crn"></a> [backup\_vault\_crn](#output\_backup\_vault\_crn) | The CRN of the Object Storage Backup Vault instance. |
| <a name="output_backup_vault_id"></a> [backup\_vault\_id](#output\_backup\_vault\_id) | The ID of the Object Storage Backup Vault instance. |
| <a name="output_backup_vault_name"></a> [backup\_vault\_name](#output\_backup\_vault\_name) | The name of the Object Storage Backup Vault instance. |
| <a name="output_cos_instance_crn"></a> [cos\_instance\_crn](#output\_cos\_instance\_crn) | The CRN of the Object Storage instance in which the Backup Vault exists. |
| <a name="output_cos_instance_guid"></a> [cos\_instance\_guid](#output\_cos\_instance\_guid) | The GUID of the Object Storage instance in which the Backup Vault exists. |
| <a name="output_cos_instance_id"></a> [cos\_instance\_id](#output\_cos\_instance\_id) | The ID of the Object Storage instance in which the Backup Vault exists. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
