##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.4.7"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Create Cloud Object Storage instance and a bucket
##############################################################################

module "cos" {
  source                    = "../../"
  resource_group_id         = module.resource_group.resource_group_id
  region                    = var.region
  cos_instance_name         = "${var.prefix}-cos"
  cos_tags                  = var.resource_tags
  bucket_name               = "${var.prefix}-bucket"
  retention_enabled         = false # disable retention for test environments - enable for stage/prod
  kms_encryption_enabled    = false
  cos_plan                  = "standard"
  bucket_storage_class      = "smart"
  object_versioning_enabled = true
  access_tags               = var.access_tags
  add_vault_name_suffix     = true
  create_backup_vault       = true
  backup_vault_instances    = [
    {
      name = "vault-s"
      region = var.region
      bucket_backup_policy = {
        "retention-policy-1" = {
          name                      = "${var.prefix}-retention-policy-1"
          initial_delete_after_days = 1
          type                      = "continuous"
        }
      }
    },
    {
      name = "vault-p"
      cos_service_instance_id = "crn:v1:bluemix:public:cloud-object-storage:global:a/abac0df06b644a9cabc6e44f55b3880e:a15c44f5-0aa4-475e-b77b-73518f3adc38::"
      region = var.region
      bucket_backup_policy = {
      "retention-policy-2" = {
          name                      = "retention-policy-2"
          initial_delete_after_days = 1
          type                      = "continuous"
        }
      }
    },
    {
      name = "vault-m"
      cos_service_instance_id = "crn:v1:bluemix:public:cloud-object-storage:global:a/abac0df06b644a9cabc6e44f55b3880e:a15c44f5-0aa4-475e-b77b-73518f3adc38::"
      region = var.region
      bucket_backup_policy = {
      "retention-policy-3" = {
          name                      = "retention-policy-3"
          initial_delete_after_days = 1
          type                      = "continuous"
        }
      }
    }
  ] 
}

##############################################################################
# Create Cloud Object Storage bucket using buckets submodule
##############################################################################

module "buckets" {
  source = "../../modules/buckets"
  bucket_configs = [
    {
      bucket_name            = "${var.prefix}-bucket-module"
      kms_encryption_enabled = false
      region_location        = var.region
      resource_instance_id   = module.cos.cos_instance_id
      storage_class          = "smart"
    }
  ]
}

##############################################################################
# Create Multiple Lifecycle Rules using lifecycle_rules submodule
##############################################################################

module "advance_lifecycle_rules" {
  source     = "../../modules/lifecycle_rules"
  cos_region = var.region
  bucket_crn = module.cos.bucket_crn
  expiry_rules = [
    {
      rule_id = "expiry-info-7d"
      days    = 7
      prefix  = "info-"
    },
    {
      rule_id = "expiry-error-30d"
      days    = 30
      prefix  = "error-"
    }
  ]

  noncurrent_expiry_rules = [
    {
      rule_id         = "ncv-expire-45d"
      noncurrent_days = 45
      prefix          = "data/"
    },
    {
      rule_id         = "ncv-expire-90d"
      noncurrent_days = 90
      prefix          = "archive/"
    }
  ]

  abort_multipart_rules = [
    {
      rule_id               = "abort-stale-7d"
      days_after_initiation = 7
      prefix                = ""
    },
    {
      rule_id               = "abort-temp-3d"
      days_after_initiation = 3
      prefix                = "tmp/"
    }
  ]

}
