variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud platform API key to deploy resources."
  sensitive   = true
}

variable "prefix" {
  type        = string
  description = "(Optional) Prefix to append to all resources created by this solution."
  default     = null
  validation {
    error_message = "Prefix must begin with a lowercase letter and contain only lowercase letters, numbers, and - characters. Prefixes must end with a lowercase letter or number and be 16 or fewer characters."
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix)) && length(coalesce(var.prefix, " ")) <= 16
  }
}

variable "existing_resource_group" {
  type        = bool
  description = "Whether to use an existing resource group."
  default     = false
}

variable "resource_group_name" {
  type        = string
  description = "The name of a new or existing resource group to provision resources in. If a value is passed for `prefix`, and creating a new resource group, the group will be named with the prefix value in the format of `<prefix>-value`."
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

variable "cos_instance_name" {
  description = "The name for the IBM Cloud Object Storage instance provisioned by this solution. If a value is passed for `prefix`, the instance will be named with the prefix value in the format of `<prefix>-value`."
  type        = string
  default     = "cos-instance"
}

variable "cos_tags" {
  description = "A list of tags to apply to data in the Object Storage instance."
  type        = list(string)
  default     = []
}

variable "cos_plan" {
  description = "The plan to use when Object Storage instances are created. Possible values: `standard`."
  type        = string
  default     = "standard"
  # Validation happens in the fscloud module
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the Object Storage instance created by the module. [Learn more](https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial)."
  default     = []
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
      secret_name                             = string
      service_credentials_source_service_role = string
      secret_labels                           = optional(list(string))
      secret_auto_rotation                    = optional(bool)
      secret_auto_rotation_unit               = optional(string)
      secret_auto_rotation_interval           = optional(number)
      service_credentials_ttl                 = optional(string)
      service_credential_secret_description   = optional(string)

    }))
  }))
  default     = []
  description = "Service credential secrets configuration for COS. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-cos/tree/main/solutions/instance/DA-types.md#service-credential-secrets)."

  validation {
    # Service roles (for Cloud Object Storage) https://cloud.ibm.com/iam/roles
    # Reader, Writer, Manager, Content Reader, Object Reader, Object Writer, NONE
    condition = alltrue([
      for group in var.service_credential_secrets : alltrue([
        for credential in group.service_credentials : contains(
          ["Writer", "Reader", "Manager", "Content Reader", "Object Reader", "Object Writer", "NONE"], credential.service_credentials_source_service_role
        )
      ])
    ])
    error_message = "service_credentials_source_service_role role must be one of 'Writer', 'Reader', 'Manager', 'Content Reader', 'Object Reader', 'Object Writer', 'NONE', reference https://cloud.ibm.com/iam/roles and `Cloud Object Storage`"

  }
}

variable "skip_cos_sm_auth_policy" {
  type        = bool
  default     = false
  description = "Whether an IAM authorization policy is created for Secrets Manager instance to create a service credential secrets for Cloud Object Storage. Set to `true` to use an existing policy."
}
