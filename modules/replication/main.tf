##############################################################################
# COS bucket Replication submodule
##############################################################################
locals {
  account_id    = data.ibm_iam_account_settings.iam_account_settings.account_id
  service_name  = "cloud-object-storage"
  resource_type = "bucket"

  # Multiple replication rules may target the same destination bucket.
  # Create one IAM authorization policy per unique target bucket
  # to avoid duplicate policy creation.
  unique_targets = {
    for rule in var.replication_rules :
    rule.rule_id => {
      target_cos_instance_guid = rule.target_cos_instance_guid
      target_bucket_name       = rule.target_bucket_name
    }
    if !rule.skip_iam_authorization_policy
  }
}

##############################################################################
# Retrieve account ID
##############################################################################
data "ibm_iam_account_settings" "iam_account_settings" {
}

##############################################################################
# Configure IAM authorization policies for each unique target bucket
##############################################################################

resource "ibm_iam_authorization_policy" "policy" {
  for_each = local.unique_targets

  roles = ["Writer"]
  subject_attributes {
    name  = "accountId"
    value = local.account_id
  }
  subject_attributes {
    name  = "serviceName"
    value = local.service_name
  }
  subject_attributes {
    name  = "serviceInstance"
    value = var.source_cos_instance_guid
  }
  subject_attributes {
    name  = "resource"
    value = var.source_bucket_name
  }
  subject_attributes {
    name  = "resourceType"
    value = local.resource_type
  }
  resource_attributes {
    name  = "accountId"
    value = local.account_id
  }
  resource_attributes {
    name  = "serviceName"
    value = local.service_name
  }
  resource_attributes {
    name  = "serviceInstance"
    value = each.value.target_cos_instance_guid
  }
  resource_attributes {
    name  = "resource"
    value = each.value.target_bucket_name
  }
  resource_attributes {
    name  = "resourceType"
    value = local.resource_type
  }
}

##############################################################################
# Configure replication rules
##############################################################################

resource "ibm_cos_bucket_replication_rule" "cos_replication_rule" {
  depends_on      = [ibm_iam_authorization_policy.policy]
  bucket_crn      = var.source_bucket_crn
  bucket_location = var.source_bucket_location
  endpoint_type   = var.bucket_endpoint_type

  dynamic "replication_rule" {
    for_each = var.replication_rules
    content {
      rule_id                         = replication_rule.value.rule_id
      enable                          = replication_rule.value.enable
      priority                        = replication_rule.value.priority
      prefix                          = replication_rule.value.prefix
      deletemarker_replication_status = replication_rule.value.deletemarker_replication_status
      destination_bucket_crn          = replication_rule.value.destination_bucket_crn
    }
  }
}
