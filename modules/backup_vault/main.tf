##############################################################################
# Module to create a Backup Vault in an existing COS instance
##############################################################################

# Locals
locals {
  create_s2s        = var.kms_encryption_enabled && !var.skip_kms_iam_authorization_policy ? true : false
  cos_instance_guid = module.cos_crn_parser.service_instance
  kms_key_guid      = var.kms_key_crn != null ? module.kms_crn_parser[0].resource : ""
  kms_instance_guid = var.kms_key_crn != null ? module.kms_crn_parser[0].service_instance : ""
  kms_service_name  = var.kms_key_crn != null ? module.kms_crn_parser[0].service_name : ""
  kms_account_id    = var.kms_key_crn != null ? module.kms_crn_parser[0].account_id : ""
}

# Parse COS details
module "cos_crn_parser" {
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.4.1"
  crn     = var.existing_cos_instance_id
}

# If KMS encryption enabled, parse details from the KMS key CRN
module "kms_crn_parser" {
  count   = local.create_s2s ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.4.1"
  crn     = var.kms_key_crn
}

# If KMS encryption enabled, create required IAM auth policy to allow COS to read the root key
resource "ibm_iam_authorization_policy" "policy" {
  count                       = local.create_s2s ? 1 : 0
  source_service_name         = "cloud-object-storage"
  source_resource_instance_id = local.cos_instance_guid
  roles                       = ["Reader"]
  description                 = "Allow the COS instance ${local.cos_instance_guid} to read the root key ${local.kms_key_guid} from the instance ${local.kms_instance_guid}"
  resource_attributes {
    name     = "serviceName"
    operator = "stringEquals"
    value    = local.kms_service_name
  }
  resource_attributes {
    name     = "accountId"
    operator = "stringEquals"
    value    = local.kms_account_id
  }
  resource_attributes {
    name     = "serviceInstance"
    operator = "stringEquals"
    value    = local.kms_instance_guid
  }
  resource_attributes {
    name     = "resourceType"
    operator = "stringEquals"
    value    = "key"
  }
  resource_attributes {
    name     = "resource"
    operator = "stringEquals"
    value    = local.kms_key_guid
  }
  # Scope of policy now includes the key, so ensure to create new policy before
  # destroying old one to prevent any disruption to every day services.
  lifecycle {
    create_before_destroy = true
  }
}

# workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4478
resource "time_sleep" "wait_for_authorization_policy" {
  depends_on       = [ibm_iam_authorization_policy.policy]
  count            = local.create_s2s ? 1 : 0
  create_duration  = "30s"
  destroy_duration = "30s"
}

# Create Backup Vault instance
resource "ibm_cos_backup_vault" "backup_vault" {
  depends_on                          = [time_sleep.wait_for_authorization_policy]
  backup_vault_name                   = var.name
  service_instance_id                 = var.existing_cos_instance_id
  region                              = var.region
  activity_tracking_management_events = var.activity_tracking_management_events
  metrics_monitoring_usage_metrics    = var.metrics_monitoring_usage_metrics
  kms_key_crn                         = var.kms_key_crn
}
