##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.5"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

# Create COS source bucket
module "cos_source_bucket" {
  source = "../../"
  # bucket_name               = "${var.prefix}-bucket-source" # temporary override to match ibm_cos_bucket_replication_rule regex
  bucket_name               = "cos-replicate-bucket-source"
  resource_group_id         = module.resource_group.resource_group_id
  region                    = var.region
  cos_instance_name         = "${var.prefix}-source-cos"
  cos_tags                  = var.resource_tags
  object_versioning_enabled = true
  encryption_enabled        = false
  retention_enabled         = false
  archive_days              = null
  expire_days               = null
}

# Create COS target bucket
module "cos_target_bucket" {
  source = "../../"
  # bucket_name               = "${var.prefix}-bucket-target" # temporary override to match ibm_cos_bucket_replication_rule regex
  bucket_name               = "cos-replicate-bucket-target"
  resource_group_id         = module.resource_group.resource_group_id
  region                    = var.region
  cos_instance_name         = "${var.prefix}-target-cos"
  cos_tags                  = var.resource_tags
  object_versioning_enabled = true
  encryption_enabled        = false
  retention_enabled         = false
  archive_days              = null
  expire_days               = null
}

### Configure replication rule

resource "ibm_cos_bucket_replication_rule" "cos_replication_rule" {
  depends_on = [
    ibm_iam_authorization_policy.policy
  ]
  bucket_crn      = module.cos_source_bucket.bucket_crn[0]
  bucket_location = var.region
  replication_rule {
    rule_id = "replicate-everything"
    enable  = true
    # prefix = "prefix"
    priority                        = 50
    deletemarker_replication_status = false
    destination_bucket_crn          = module.cos_target_bucket.bucket_crn[0]
  }
}

### Configure IAM authorization policy

# Data source to retrieve account ID
data "ibm_iam_account_settings" "iam_account_settings" {
}

resource "ibm_iam_authorization_policy" "policy" {
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
    value = module.cos_source_bucket.cos_instance_guid
  }
  subject_attributes {
    name  = "resource"
    value = module.cos_source_bucket.bucket_name[0]
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
    value = module.cos_target_bucket.cos_instance_guid
  }
  resource_attributes {
    name  = "resource"
    value = module.cos_target_bucket.bucket_name[0]
  }
  resource_attributes {
    name  = "resourceType"
    value = "bucket"
  }
}
