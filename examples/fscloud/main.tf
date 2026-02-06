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
# VPC
##############################################################################

resource "ibm_is_vpc" "example_vpc" {
  name           = "${var.prefix}-vpc"
  resource_group = module.resource_group.resource_group_id
  tags           = var.resource_tags
}

resource "ibm_is_subnet" "testacc_subnet" {
  name                     = "${var.prefix}-subnet"
  vpc                      = ibm_is_vpc.example_vpc.id
  zone                     = "${var.region}-1"
  total_ipv4_address_count = 256
  resource_group           = module.resource_group.resource_group_id
}

##############################################################################
# Get Cloud Account ID
##############################################################################

data "ibm_iam_account_settings" "iam_account_settings" {
}

##############################################################################
# Create CBR Zone
##############################################################################

module "cbr_zone" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "1.35.13"
  name             = "${var.prefix}-VPC-fscloud-nz"
  zone_description = "CBR Network zone containing VPC"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses = [{
    type  = "vpc", # to bind a specific vpc to the zone
    value = ibm_is_vpc.example_vpc.crn,
  }]
}

# Allow schematics, from outside VPC, to manage resources
module "cbr_zone_schematics" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "1.35.13"
  name             = "${var.prefix}-schematics-fscloud-nz"
  zone_description = "CBR Network zone containing Schematics"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses = [{
    type = "serviceRef", # to bind a schematics to the zone
    ref = {
      # Allow all schematics instances from all geographies
      account_id   = data.ibm_iam_account_settings.iam_account_settings.account_id
      service_name = "schematics"
    }
  }]
}

##############################################################################
# HPCS root keys
##############################################################################

locals {
  key_ring_name   = "${var.prefix}-cos-key-ring"
  bucket_key_name = "${var.prefix}-bucket-key"
  vault_key_name  = "${var.prefix}-vault-key"
}

module "hpcs_keys" {
  source                      = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version                     = "5.5.27"
  region                      = var.region
  create_key_protect_instance = false
  existing_kms_instance_crn   = var.hpcs_instance_crn
  keys = [
    {
      key_ring_name = local.key_ring_name
      keys = [
        {
          key_name     = local.bucket_key_name
          force_delete = true
        },
        {
          key_name     = local.vault_key_name
          force_delete = true
        }
      ]
    }
  ]
}

##############################################################################
# Create COS instance and bucket with:
# - Encryption
##############################################################################

module "cos_fscloud" {
  source            = "../../modules/fscloud"
  resource_group_id = module.resource_group.resource_group_id
  cos_instance_name = "${var.prefix}-cos"
  cos_tags          = var.resource_tags
  access_tags       = var.access_tags

  # CBR rule only allowing the COS instance to be accessible over the private endpoint from within the VPC
  # or from schematics
  instance_cbr_rules = [{
    description      = "sample rule for the instance"
    enforcement_mode = "enabled"
    account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
    rule_contexts = [{
      attributes = [
        {
          "name" : "endpointType",
          "value" : "private"
        },
        {
          name  = "networkZoneId"
          value = module.cbr_zone.zone_id
      }]
      }, {
      attributes = [
        {
          "name" : "endpointType",
          "value" : "private"
        },
        {
          name  = "networkZoneId"
          value = module.cbr_zone_schematics.zone_id
      }]
    }]
    operations = [{
      api_types = [{
        api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::api-type:"
      }]
    }]
  }]

  # Create one regional bucket, encrypted with the HPCS root key
  bucket_configs = [{
    access_tags              = var.access_tags
    bucket_name              = "${var.prefix}-bucket"
    kms_key_crn              = module.hpcs_keys.keys["${local.key_ring_name}.${local.bucket_key_name}"].crn
    management_endpoint_type = var.management_endpoint_type_for_bucket
    region_location          = var.region

    # To create a backup policy, uncomment the below code and update to your requirements.
    # Be aware that terraform destroy will fail on the backup vault once a policy exists and will only work after all buckets using the vault have been destroyed and the initial_delete_after_days has been met.

    # backup_policies = [{ policy_name               = "default-backup-policy"
    #   target_backup_vault_crn   = module.backup_vault.backup_vault_crn
    #   initial_delete_after_days = 1
    # }]

    # CBR rule only allowing the COS bucket to be accessible over the private endpoint from within the VPC
    cbr_rules = [{
      description      = "sample rule for ${var.prefix}-bucket"
      enforcement_mode = "enabled"
      account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
      rule_contexts = [{
        attributes = [
          {
            "name" : "endpointType",
            "value" : "private"
          },
          {
            name  = "networkZoneId"
            value = module.cbr_zone.zone_id
          }
        ] }, {
        attributes = [
          {
            "name" : "endpointType",
            "value" : "private"
          },
          {
            name  = "networkZoneId"
            value = module.cbr_zone_schematics.zone_id
        }]
      }]
      operations = [{
        api_types = [{
          api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::api-type:"
        }]
      }]
    }]
  }, ]
}

module "backup_vault" {
  source                   = "../../modules/backup_vault"
  name                     = "${var.prefix}-vault"
  existing_cos_instance_id = module.cos_fscloud.cos_instance_id
  region                   = var.region
  kms_encryption_enabled   = true
  kms_key_crn              = module.hpcs_keys.keys["${local.key_ring_name}.${local.vault_key_name}"].crn
}
