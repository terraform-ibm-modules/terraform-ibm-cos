# Secure COS Bucket Demo - Deployable Architecture

:exclamation: **Important:** This solution is not intended to be invoked by other modules, as it includes provider configuration. As a result, it is incompatible with the `for_each`, `count`, and `depends_on` arguments. For more information, see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers).

This is a specialized Deployable Architecture (DA) designed for creating a single, highly secure IBM Cloud Object Storage bucket with minimal inputs and hard-coded security features. It's intended for demonstration purposes and private catalog deployment.

## 🔐 Key Features

- **Hard-coded Security**: Enforced KMS encryption, object versioning, and object locking
- **Brazil Region**: Fixed to São Paulo (br-sao) for data sovereignty demonstration
- **Minimal Inputs**: Only requires bucket name, existing COS instance CRN, and KMS key CRN
- **Compliance Ready**: object versioning, 30-day object locking, lifecycle management
- **Cost Controlled**: 100GB hard quota and automatic archival policies

## 📋 Required Inputs

| Variable | Description |
|----------|-------------|
| `ibmcloud_api_key` | IBM Cloud API key for deployment |
| `bucket_name` | Name for the secure bucket (random suffix added) |
| `existing_cos_instance_id` | CRN of existing COS instance |
| `existing_kms_key_crn` | CRN of existing KMS key for encryption |

## 🛡️ Hard-coded Security Settings

- **Region**: Brazil São Paulo (br-sao)
- **Encryption**: Mandatory KMS encryption with customer keys
- **Versioning**: Object versioning enabled
- **Object Locking**: 30-day lock period
- **Lifecycle**: Archive to Glacier after 30 days, expire after 7 years
- **Quota**: 100GB hard limit
- **Endpoints**: Private management endpoints only

## 🚀 Usage Example

```hcl
module "secure_bucket_demo" {
  source = "github.com/terraform-ibm-modules/terraform-ibm-cos//solutions/secure-bucket-demo"
  ibmcloud_api_key         = var.ibmcloud_api_key      # pragma: allowlist secret
  bucket_name              = "my-demo-bucket"
  existing_cos_instance_id = "crn:v1:bluemix:public:cloud-object-storage:global:a/abc123:instance-id::"
  existing_kms_key_crn     = "crn:v1:bluemix:public:kms:br-sao:a/abc123:instance-id:key:key-id"
}
```

This DA is designed for controlled environments where security settings are pre-determined and users need minimal configuration options.
