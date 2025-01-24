variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud platform API key to deploy resources."
  sensitive   = true
}

variable "prefix" {
  type        = string
  description = "(Optional) Prefix to add to all resources created by this solution. To not use any prefix value, you can set this value to `null` or an empty string."
  default     = "cos"
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
        # crn:v?:bluemix; two non-empty segments; three possibly empty segments; :serviceRole: non-empty segment
        for credential in group.service_credentials : can(regex("^crn:v[0-9]:bluemix(:..*){2}(:.*){3}:serviceRole:..*$", credential.service_credentials_source_service_role_crn))
      ])
    ])
    error_message = "service_credentials_source_service_role_crn must be a serviceRole CRN. See https://cloud.ibm.com/iam/roles"
  }
}

variable "skip_cos_sm_auth_policy" {
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
# Context-based restriction (CBR)
##############################################################
variable "instance_cbr_rules" {
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
  description = "The list of context-based restriction rules to create for the instance.[Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-cos/blob/main/solutions/instance/DA-cbr_rules.md)"
  default     = []
  # Validation happens in the rule module
}
