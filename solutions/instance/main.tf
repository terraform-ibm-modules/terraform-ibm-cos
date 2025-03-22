module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.6"
  resource_group_name          = var.use_existing_resource_group == false ? ((var.prefix != null && var.prefix != "") ? "${var.prefix}-${var.resource_group_name}" : var.resource_group_name) : null
  existing_resource_group_name = var.use_existing_resource_group == true ? var.resource_group_name : null
}

module "cos" {
  source              = "../../modules/fscloud"
  resource_group_id   = module.resource_group.resource_group_id
  create_cos_instance = true
  cos_instance_name   = (var.prefix != null && var.prefix != "") ? "${var.prefix}-${var.cos_instance_name}" : var.cos_instance_name
  resource_keys       = var.resource_keys
  cos_plan            = var.cos_plan
  cos_tags            = var.cos_tags
  access_tags         = var.access_tags
  instance_cbr_rules  = var.cos_instance_cbr_rules
}

resource "ibm_iam_authorization_policy" "secrets_manager_key_manager" {
  count                       = var.skip_secrets_manager_cos_iam_auth_policy || var.existing_secrets_manager_instance_crn == null ? 0 : 1
  depends_on                  = [module.cos]
  source_service_name         = "secrets-manager"
  source_resource_instance_id = local.existing_secrets_manager_instance_guid
  target_service_name         = "cloud-object-storage"
  target_resource_instance_id = module.cos.cos_instance_guid
  roles                       = ["Key Manager"]
  description                 = "Allow Secrets Manager with instance id ${local.existing_secrets_manager_instance_guid} to manage key for the COS instance"
}

# workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4478
resource "time_sleep" "wait_for_cos_authorization_policy" {
  depends_on      = [ibm_iam_authorization_policy.secrets_manager_key_manager]
  create_duration = "30s"
}

locals {
  service_credential_secrets = [
    for service_credentials in var.service_credential_secrets : {
      secret_group_name        = service_credentials.secret_group_name
      secret_group_description = service_credentials.secret_group_description
      existing_secret_group    = service_credentials.existing_secret_group
      secrets = [
        for secret in service_credentials.service_credentials : {
          secret_name                                 = secret.secret_name
          secret_labels                               = secret.secret_labels
          secret_auto_rotation                        = secret.secret_auto_rotation
          secret_auto_rotation_unit                   = secret.secret_auto_rotation_unit
          secret_auto_rotation_interval               = secret.secret_auto_rotation_interval
          service_credentials_ttl                     = secret.service_credentials_ttl
          service_credential_secret_description       = secret.service_credential_secret_description
          service_credentials_source_service_role_crn = secret.service_credentials_source_service_role_crn
          service_credentials_source_service_crn      = module.cos.cos_instance_id
          secret_type                                 = "service_credentials" #checkov:skip=CKV_SECRET_6
        }
      ]
    }
  ]

  existing_secrets_manager_instance_crn_split = var.existing_secrets_manager_instance_crn != null ? split(":", var.existing_secrets_manager_instance_crn) : null
  existing_secrets_manager_instance_guid      = var.existing_secrets_manager_instance_crn != null ? element(local.existing_secrets_manager_instance_crn_split, length(local.existing_secrets_manager_instance_crn_split) - 3) : null
  existing_secrets_manager_instance_region    = var.existing_secrets_manager_instance_crn != null ? element(local.existing_secrets_manager_instance_crn_split, length(local.existing_secrets_manager_instance_crn_split) - 5) : null

  # tflint-ignore: terraform_unused_declarations
  validate_sm_crn = length(local.service_credential_secrets) > 0 && var.existing_secrets_manager_instance_crn == null ? tobool("`existing_secrets_manager_instance_crn` is required when adding service credentials to a secrets manager secret.") : false
}

module "secrets_manager_service_credentials" {
  count                       = length(local.service_credential_secrets) > 0 ? 1 : 0
  depends_on                  = [time_sleep.wait_for_cos_authorization_policy]
  source                      = "terraform-ibm-modules/secrets-manager/ibm//modules/secrets"
  version                     = "1.25.4"
  existing_sm_instance_guid   = local.existing_secrets_manager_instance_guid
  existing_sm_instance_region = local.existing_secrets_manager_instance_region
  endpoint_type               = var.existing_secrets_manager_endpoint_type
  secrets                     = local.service_credential_secrets
}
