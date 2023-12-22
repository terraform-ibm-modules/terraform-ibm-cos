# Profile for IBM Cloud Framework for Financial Services

This code is a version of the [parent root module](../../) that includes a default configuration that complies with the relevant controls from the [IBM Cloud Framework for Financial Services](https://cloud.ibm.com/docs/framework-financial-services?topic=framework-financial-services-about). See the [Example for IBM Cloud Framework for Financial Services](/examples/fscloud/) for logic that uses this module. The profile assumes you are deploying into an account that is in compliance with the framework.

The default values in this profile were scanned by [IBM Code Risk Analyzer (CRA)](https://cloud.ibm.com/docs/code-risk-analyzer-cli-plugin?topic=code-risk-analyzer-cli-plugin-cra-cli-plugin#terraform-command) for compliance with the IBM Cloud Framework for Financial Services profile that is specified by the IBM Security and Compliance Center. The scan passed for all applicable rules with the following exceptions:

> rule-8cbd597c-7471-42bd-9c88-36b2696456e9 - Check whether Cloud Object Storage network access is restricted to a specific IP range

The IBM Cloud Framework for Financial Services mandates the application of an inbound network-based allowlist in front of the IBM Cloud Object Storage instance. You can comply with this requirement with the `bucket_cbr_rules` and `instance_cbr_rules` variables in the module. Use these variables to create a narrow context-based restriction rule that is scoped to the IBM Cloud Storage instance. CRA does not support checking for context-based restrictions, so you can ignore the failing rule after you set the context-based restrictions.

### Usage

```hcl
provider "ibm" {
  ibmcloud_api_key = "XXXXXXXXXX"
  region           = "us-south"
}

module "replication_rule" {
  source                 = "terraform-ibm-modules/cos/ibm//modules/replication_rule"
  version                = "X.X.X" # Replace "latest" with a release version to lock into a specific release
  origin_bucket_crn      = "crn:v1:bluemix:public:logdnaat:us-south:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX::"
  destination_bucket_crn = "crn:v1:bluemix:public:logdnaat:us-south:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX::"
  replication_rule       = {
    rule_id                         = "Replicate of bucket to another bucket"
    enable                          = true
    priority                        = 50
    deletemarker_replication_status = false
  }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0, <1.6.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | 1.56.1 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_cos_bucket_replication_rule.replication_rule](https://registry.terraform.io/providers/ibm-cloud/ibm/1.56.1/docs/resources/cos_bucket_replication_rule) | resource |
| [ibm_iam_authorization_policy.policy](https://registry.terraform.io/providers/ibm-cloud/ibm/1.56.1/docs/resources/iam_authorization_policy) | resource |
| [ibm_iam_account_settings.iam_account_settings](https://registry.terraform.io/providers/ibm-cloud/ibm/1.56.1/docs/data-sources/iam_account_settings) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_destination_bucket_crn"></a> [destination\_bucket\_crn](#input\_destination\_bucket\_crn) | The CRN of the destination bucket | `string` | `null` | no |
| <a name="input_destination_bucket_instance_guid"></a> [destination\_bucket\_instance\_guid](#input\_destination\_bucket\_instance\_guid) | The COS instance GUID of the destination bucket | `string` | `null` | no |
| <a name="input_destination_bucket_name"></a> [destination\_bucket\_name](#input\_destination\_bucket\_name) | The name of the destination bucket | `string` | `null` | no |
| <a name="input_origin_bucket_crn"></a> [origin\_bucket\_crn](#input\_origin\_bucket\_crn) | The CRN of the origin bucket | `string` | n/a | yes |
| <a name="input_origin_bucket_instance_guid"></a> [origin\_bucket\_instance\_guid](#input\_origin\_bucket\_instance\_guid) | The COS instance GUID of the origin bucket | `string` | n/a | yes |
| <a name="input_origin_bucket_location"></a> [origin\_bucket\_location](#input\_origin\_bucket\_location) | The origin bucket location | `string` | n/a | yes |
| <a name="input_origin_bucket_name"></a> [origin\_bucket\_name](#input\_origin\_bucket\_name) | The name of the origin bucket | `string` | `null` | no |
| <a name="input_replication_rule"></a> [replication\_rule](#input\_replication\_rule) | Rule for replication | <pre>object({<br>    rule_id                         = optional(string)<br>    enable                          = optional(bool)<br>    prefix                          = optional(string)<br>    priority                        = optional(number)<br>    deletemarker_replication_status = optional(bool)<br>  })</pre> | `{}` | no |
| <a name="input_skip_iam_authorization_policy"></a> [skip\_iam\_authorization\_policy](#input\_skip\_iam\_authorization\_policy) | Skip creation of authorization policy | `bool` | `false` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_replicated_rule"></a> [replicated\_rule](#output\_replicated\_rule) | ibm\_cos\_bucket\_replication\_rule resource output |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
