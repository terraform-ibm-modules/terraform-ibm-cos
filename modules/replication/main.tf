##############################################################################
# COS bucket Replication submodule
##############################################################################

##############################################################################
# Retrieve account ID
##############################################################################
data "ibm_iam_account_settings" "iam_account_settings" {
}

##############################################################################
# Configure IAM authorization policy
##############################################################################

resource "ibm_iam_authorization_policy" "policy" {
  count = var.skip_iam_authorization_policy ? 0 : 1
  roles = [
    "Writer",
  ]
  subject_attributes {
    name  = "accountId"
    value = data.ibm_iam_account_settings.iam_account_settings.account_id
  }
  subject_attributes {
    name  = "serviceName"
    value = "cloud-object-storage"
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
    value = "bucket"
  }
  resource_attributes {
    name  = "accountId"
    value = data.ibm_iam_account_settings.iam_account_settings.account_id
  }
  resource_attributes {
    name  = "serviceName"
    value = "cloud-object-storage"
  }
  resource_attributes {
    name  = "serviceInstance"
    value = var.target_cos_instance_guid
  }
  resource_attributes {
    name  = "resource"
    value = var.target_bucket_name
  }
  resource_attributes {
    name  = "resourceType"
    value = "bucket"
  }
}

##############################################################################
# Configure replication rule
##############################################################################

resource "ibm_cos_bucket_replication_rule" "cos_replication_rule" {
  depends_on = [
    ibm_iam_authorization_policy.policy
  ]
  bucket_crn      = var.source_bucket_crn
  bucket_location = var.source_bucket_location
  replication_rule {
    rule_id                         = var.replication_rule_id
    enable                          = var.replication_enabled
    priority                        = var.replication_priority
    deletemarker_replication_status = var.deletemarker_replication_status
    destination_bucket_crn          = var.target_bucket_crn
  }
}
