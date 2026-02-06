variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud platform API key to deploy resources."
  sensitive   = true
}

variable "prefix" {
  type        = string
  nullable    = true
  description = "The prefix to add to all resources that this solution creates (e.g `prod`, `test`, `dev`). To skip using a prefix, set this value to null or an empty string. [Learn more](https://terraform-ibm-modules.github.io/documentation/#/prefix.md)."

  validation {
    # - null and empty string is allowed
    # - Must not contain consecutive hyphens (--): length(regexall("--", var.prefix)) == 0
    # - Starts with a lowercase letter: [a-z]
    # - Contains only lowercase letters (a–z), digits (0–9), and hyphens (-)
    # - Must not end with a hyphen (-): [a-z0-9]
    condition = (var.prefix == null || var.prefix == "" ? true :
      alltrue([
        can(regex("^[a-z][-a-z0-9]*[a-z0-9]$", var.prefix)),
        length(regexall("--", var.prefix)) == 0
      ])
    )
    error_message = "Prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It must not end with a hyphen('-'), and cannot contain consecutive hyphens ('--')."
  }

  validation {
    # must not exceed 16 characters in length
    condition     = var.prefix == null || var.prefix == "" ? true : length(var.prefix) <= 16
    error_message = "Prefix must not exceed 16 characters."
  }
}

variable "existing_resource_group_name" {
  type        = string
  description = "The name of an existing resource group to provision the resources."
  default     = "Default"
}

variable "instance_name" {
  description = "The name for the IBM Cloud Object Storage instance provisioned by this solution. If a value is passed for `prefix`, the instance will be named with the prefix value in the format of `<prefix>-value`."
  type        = string
  default     = "cos-instance"
}

variable "plan" {
  description = "The plan to use when Object Storage instances are created. [Learn more](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-provision)."
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "cos-one-rate-plan"], var.plan)
    error_message = "The specified plan is not a valid selection!"
  }
}

variable "resource_tags" {
  description = "A list of resource tags to apply to the Object Storage instance."
  type        = list(string)
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the Object Storage instance created by the module. [Learn more](https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial)."
  default     = []
}

variable "resource_keys" {
  description = "The definition of the resource keys to generate. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-cos/tree/main/solutions/instance/DA-types.md#resource-keys)."
  type = list(object({
    name                      = string
    generate_hmac_credentials = optional(bool, false)
    role                      = optional(string, "Reader")
    service_id_crn            = optional(string, null)
  }))
  default = []
}

variable "existing_secrets_manager_instance_crn" {
  type        = string
  default     = null
  description = "The CRN of existing secrets manager to use to create service credential secrets for COS instance."
}

variable "existing_secrets_manager_endpoint_type" {
  type        = string
  description = "The endpoint type to use if `existing_secrets_manager_instance_crn` is specified. Possible values: public, private."
  default     = "private"
  validation {
    condition     = contains(["public", "private"], var.existing_secrets_manager_endpoint_type)
    error_message = "Only \"public\" and \"private\" are allowed values for 'existing_secrets_endpoint_type'."
  }
}

variable "service_credential_secrets" {
  type = list(object({
    secret_group_name        = string
    secret_group_description = optional(string)
    existing_secret_group    = optional(bool)
    service_credentials = list(object({
      secret_name                                 = string
      service_credentials_source_service_role_crn = string
      secret_labels                               = optional(list(string))
      secret_auto_rotation                        = optional(bool)
      secret_auto_rotation_unit                   = optional(string)
      secret_auto_rotation_interval               = optional(number)
      service_credentials_ttl                     = optional(string)
      service_credential_secret_description       = optional(string)

    }))
  }))
  default     = []
  description = "Service credential secrets configuration for COS. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-cos/tree/main/solutions/instance/DA-types.md#service-credential-secrets)."

  validation {
    # Service roles CRNs can be found at https://cloud.ibm.com/iam/roles, select Cloud Object Storage and select the role
    condition = alltrue([
      for group in var.service_credential_secrets : alltrue([
        # crn:v?:bluemix; two non-empty segments; three possibly empty segments; :serviceRole or role: non-empty segment
        for credential in group.service_credentials : can(regex("^crn:v[0-9]:bluemix(:..*){2}(:.*){3}:(serviceRole|role):..*$", credential.service_credentials_source_service_role_crn))
      ])
    ])
    error_message = "service_credentials_source_service_role_crn must be a serviceRole CRN. See https://cloud.ibm.com/iam/roles"
  }

  validation {
    condition     = length(var.service_credential_secrets) > 0 ? var.existing_secrets_manager_instance_crn != null : true
    error_message = "When passing a value for 'service_credential_secrets', a value must be passed for 'existing_secrets_manager_instance_crn'."
  }
}

variable "skip_secrets_manager_cos_iam_auth_policy" {
  type        = bool
  default     = false
  description = "Whether an IAM authorization policy is created for Secrets Manager instance to create a service credential secrets for Cloud Object Storage. Set to `true` to use an existing policy."
}

variable "provider_visibility" {
  description = "Set the visibility value for the IBM terraform provider. Supported values are `public`, `private`, `public-and-private`. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/guides/custom-service-endpoints)."
  type        = string
  default     = "private"

  validation {
    condition     = contains(["public", "private", "public-and-private"], var.provider_visibility)
    error_message = "Invalid visibility option. Allowed values are 'public', 'private', or 'public-and-private'."
  }
}

##############################################################
# Backup Vault instances
##############################################################

variable "backup_vault_region_list" {
  description = "List of regions where a Backup Vault will be created. If empty, none will be created."
  type        = list(string)
  default     = []
  nullable    = false # do not allow null as its used in a for loop
}

variable "existing_kms_instance_crn" {
  description = "The CRN of the key management instance to create a new root key in to encrypt the data in the Backup Vault instances. Alternatively use 'existing_kms_key_crn' to use an existing key, or set both to `null` to use the default IBM Cloud encryption."
  type        = string
  default     = null

  validation {
    condition = anytrue([
      can(regex("^crn:(.*:){3}(kms|hs-crypto):(.*:){2}[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}::$", var.existing_kms_instance_crn)),
      var.existing_kms_instance_crn == null,
    ])
    error_message = "The provided KMS instance CRN in the input 'existing_kms_instance_crn' in not valid."
  }
}

variable "existing_kms_key_crn" {
  description = "The CRN of the key management service root key to encrypt the data in the Backup Vault instances. Alternatively use 'existing_kms_instance_crn' to create a new key in an existing instance, or set both to `null` to use the default IBM Cloud encryption."
  type        = string
  default     = null

  validation {
    condition     = var.existing_kms_instance_crn != null ? var.existing_kms_key_crn == null : true
    error_message = "Pass a value for 'existing_kms_key_crn' to use an existing key, or 'existing_kms_instance_crn' to create a new key. You cannot pass a value for both."
  }
}

variable "kms_endpoint_type" {
  type        = string
  description = "The endpoint for communicating with the Key Protect or Hyper Protect Crypto Services instance. Possible values: `public`, `private`. Applies only if creating a Backup Vault with your own key."
  default     = "private"
  validation {
    condition     = can(regex("^(public|private)$", var.kms_endpoint_type))
    error_message = "The kms_endpoint_type value must be 'public' or 'private'."
  }
}

variable "kms_key_ring_name" {
  type        = string
  default     = "cos-backup-key-ring"
  description = "The name for the new key ring to store the key. Applies only if passing a value for `existing_kms_key_crn` and creating a Backup Vault. If a prefix input variable is passed, it is added to the value in the `<prefix>-value` format."
}

variable "kms_key_name" {
  type        = string
  default     = "cos-backup-key"
  description = "The name for the new root key. Applies only if passing a value for `existing_kms_key_crn` and creating a Backup Vault. If a prefix input variable is passed, it is added to the value in the `<prefix>-value` format."
}

variable "skip_kms_iam_authorization_policy" {
  type        = bool
  description = "Set to true to skip the creation of an IAM authorization policy that grants the Object Storage instance 'Reader' access to the KMS key. This policy must exist in your account for encryption to work. Applies only if creating a Backup Vault with your own key."
  default     = false
}

##############################################################
# Context-based restriction (CBR)
##############################################################

variable "cos_instance_cbr_rules" {
  type = list(object({
    description = string
    account_id  = string
    rule_contexts = list(object({
      attributes = optional(list(object({
        name  = string
        value = string
    }))) }))
    enforcement_mode = string
    tags = optional(list(object({
      name  = string
      value = string
    })), [])
    operations = optional(list(object({
      api_types = list(object({
        api_type_id = string
      }))
    })))
  }))
  description = "The list of context-based restriction rules to create for the instance.[Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-cos/blob/main/solutions/instance/DA-cbr_rules.md)."
  default     = []
  # Validation happens in the rule module
}
