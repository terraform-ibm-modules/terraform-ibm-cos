variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud platform API key to deploy resources."
  sensitive   = true
}

variable "prefix" {
  type        = string
  nullable    = true
  description = "The prefix to be added to all resources created by this solution. To skip using a prefix, set this value to null or an empty string. The prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It should not exceed 16 characters, must not end with a hyphen('-'), and can not contain consecutive hyphens ('--'). Example: prod-us-south."

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
  description = "The list of context-based restriction rules to create for the instance.[Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-cos/blob/main/solutions/instance/DA-cbr_rules.md)"
  default     = []
  # Validation happens in the rule module
}
