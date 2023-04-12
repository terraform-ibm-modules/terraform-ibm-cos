##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source                       = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.5"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Get Cloud Account ID
##############################################################################

data "ibm_iam_account_settings" "iam_account_settings" {
}

##############################################################################
# Create CBR Zone
##############################################################################
# Create COS instance and Key protect instance.
# Create COS bucket-1 with:
# - Encryption
# - Monitoring
# - Activity Tracking
# - One Rate Plan & One Rate Active Bucket Storage Class
module "cos_bucket" {
  source                = "../../"
  resource_group_id     = module.resource_group.resource_group_id
  region                = var.region
  cross_region_location = null
  cos_instance_name     = "${var.prefix}-cos"
  cos_tags              = var.resource_tags
  bucket_name           = "${var.prefix}-bucket-1"
  # disable retention for test environments - enable for stage/prod
  retention_enabled     = false
  encryption_enabled    = false
  cos_plan              = "cos-one-rate-plan"
  bucket_storage_class  = "onerate_active"
  bucket_cbr_rules      = [
    {
      description      = "sample rule for bucket 1"
      enforcement_mode = "report"
      account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
      rule_contexts    = [
        {
          attributes = [
            {
              "name" : "endpointType",
              "value" : "private"
            },
          ]
        }
      ]
    }
  ]
  instance_cbr_rules = [
    {
      description      = "sample rule for the instance"
      enforcement_mode = "report"
      account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
      # IAM tags on the rule resources should match to the instance level IAM tags
      tags             = [
        {
          name  = "env"
          value = "test"
        }
      ]
      rule_contexts = [
        {
          attributes = [
            {
              "name" : "endpointType",
              "value" : "private"
            },
          ]
        }
      ]
    }
  ]
}
