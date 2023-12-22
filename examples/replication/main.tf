##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.4"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

locals {
  source_bucket_config = {
    bucket_name          = "${var.prefix}-bucket-source"
    region_location      = "us-south"
    resource_group_id    = module.resource_group.resource_group_id
    resource_instance_id = module.cos.cos_instance_id
  }
  source_replication_rules = [
    {
      rule_id                         = "replicate-everything"
      enable                          = true
      priority                        = 50
      deletemarker_replication_status = false
    }
  ]
  target_bucket_config = {
    bucket_name          = "${var.prefix}-bucket-target"
    region_location      = "us-east"
    resource_group_id    = module.resource_group.resource_group_id
    resource_instance_id = module.cos.cos_instance_id
  }
}

##############################################################################
# Create COS source bucket
##############################################################################

module "cos" {
  source                 = "../../"
  resource_group_id      = module.resource_group.resource_group_id
  region                 = var.region
  cos_instance_name      = "${var.prefix}-cos"
  cos_tags               = var.resource_tags
  retention_enabled      = false # disable retention for test environments - enable for stage/prod
  kms_encryption_enabled = false
}

##############################################################################
# Create COS source bucket
##############################################################################

module "replica_set" {
  source                    = "../../modules/replication"
  origin_bucket_config      = local.source_bucket_config
  replication_rules         = local.source_replication_rules
  destination_bucket_config = local.target_bucket_config
}

##############################################################################
# Retrieve account ID
##############################################################################
#data "ibm_iam_account_settings" "iam_account_settings" {
#}

##############################################################################
# Configure IAM authorization policy
##############################################################################

#resource "ibm_iam_authorization_policy" "policy" {
#  roles = [
#    "Writer",
#  ]
#  subject_attributes {
#    name  = "accountId"
#    value = data.ibm_iam_account_settings.iam_account_settings.account_id
#  }
#  subject_attributes {
#    name  = "serviceName"
#    value = "cloud-object-storage"
#  }
#  subject_attributes {
#    name  = "serviceInstance"
#    value = module.cos_source_bucket.cos_instance_guid
#  }
#  subject_attributes {
#    name  = "resource"
#    value = module.cos_source_bucket.bucket_name
#  }
#  subject_attributes {
#    name  = "resourceType"
#    value = "bucket"
#  }
#  resource_attributes {
#    name  = "accountId"
#    value = data.ibm_iam_account_settings.iam_account_settings.account_id
#  }
#  resource_attributes {
#    name  = "serviceName"
#    value = "cloud-object-storage"
#  }
#  resource_attributes {
#    name  = "serviceInstance"
#    value = module.cos_target_bucket.cos_instance_guid
#  }
#  resource_attributes {
#    name  = "resource"
#    value = module.cos_target_bucket.bucket_name
#  }
#  resource_attributes {
#    name  = "resourceType"
#    value = "bucket"
#  }
#}
