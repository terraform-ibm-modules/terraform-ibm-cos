##############################################################################
# COS bucket Replication submodule
##############################################################################
module "source_bucket_crn_parser" {
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.9.0"
  crn     = var.source_bucket_crn
}

locals {
  source_cos_instance_guid = module.source_bucket_crn_parser.service_instance
  source_bucket_name       = module.source_bucket_crn_parser.resource
  account_id               = module.source_bucket_crn_parser.account_id

  unique_targets = {
    for rule in var.replication_rules :
    rule.rule_id => {
      target_cos_instance_guid = split(":", rule.destination_bucket_crn)[7]
      target_bucket_name       = split(":", rule.destination_bucket_crn)[9]
    }
    if !rule.skip_iam_authorization_policy
  }
}

##############################################################################
# Configure IAM authorization policies for each unique target bucket
##############################################################################

module "s2s_auth" {
  source  = "terraform-ibm-modules/s2s-auth/ibm"
  version = "2.3.1"

  enable_cbr = false

  service_map = {
    for key, target in local.unique_targets :
    key => {
      description = "Allow COS instance ${local.source_cos_instance_guid} bucket ${local.source_bucket_name} to replicate to bucket ${target.target_bucket_name} in instance ${target.target_cos_instance_guid}"
      roles       = ["Writer"]

      subject_attributes = [
        {
          name  = "accountId"
          value = local.account_id
        },
        {
          name  = "serviceName"
          value = "cloud-object-storage"
        },
        {
          name  = "serviceInstance"
          value = local.source_cos_instance_guid
        },
        {
          name  = "resource"
          value = local.source_bucket_name
        },
        {
          name  = "resourceType"
          value = "bucket"
        }
      ]
      resource_attributes = [
        {
          name  = "accountId"
          value = local.account_id
        },
        {
          name  = "serviceName"
          value = "cloud-object-storage"
        },
        {
          name  = "serviceInstance"
          value = target.target_cos_instance_guid
        },
        {
          name  = "resource"
          value = target.target_bucket_name
        },
        {
          name  = "resourceType"
          value = "bucket"
        },
      ]
    }
  }
}

##############################################################################
# Configure replication rules
##############################################################################

resource "ibm_cos_bucket_replication_rule" "cos_replication_rule" {
  depends_on      = [module.s2s_auth]
  bucket_crn      = var.source_bucket_crn
  bucket_location = var.source_bucket_region
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
