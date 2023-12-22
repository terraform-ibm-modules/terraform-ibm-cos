##############################################################################
# Configure replication rule
##############################################################################

resource "ibm_cos_bucket_replication_rule" "replication_rule" {
  depends_on = [
    ibm_iam_authorization_policy.policy
  ]
  bucket_crn      = var.origin_bucket_crn
  bucket_location = var.origin_bucket_location
  replication_rule {
    rule_id                         = var.replication_rule.rule_id
    enable                          = var.replication_rule.enable
    prefix                          = var.replication_rule.prefix
    priority                        = var.replication_rule.priority
    deletemarker_replication_status = var.replication_rule.deletemarker_replication_status
    destination_bucket_crn          = var.destination_bucket_crn
  }
}


# The IAM policy will only work when there is one rule, otherwise this module will be called
# repeatedly... so maybe it should be created in the replication (sub)module rather than
# the replication rule (sub)module.


##############################################################################
# Retrieve account ID
##############################################################################
data "ibm_iam_account_settings" "iam_account_settings" {
}

##############################################################################
# Configure IAM authorization policy
##############################################################################

resource "ibm_iam_authorization_policy" "policy" {
  count = var.skip_iam_authorization_policy == true ? 0 : 1
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
    value = var.origin_bucket_instance_guid
  }
  subject_attributes {
    name  = "resource"
    value = var.origin_bucket_name
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
    value = var.destination_bucket_instance_guid
  }
  resource_attributes {
    name  = "resource"
    value = var.destination_bucket_name
  }
  resource_attributes {
    name  = "resourceType"
    value = "bucket"
  }
}
