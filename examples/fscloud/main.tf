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
# Observability Instances (Sysdig + AT)
##############################################################################

locals {
  existing_at = var.existing_at_instance_crn != null ? true : false
  at_crn      = var.existing_at_instance_crn == null ? module.observability_instances.activity_tracker_crn : var.existing_at_instance_crn
}

# Create Sysdig and Activity Tracker instance
module "observability_instances" {
  source  = "terraform-ibm-modules/observability-instances/ibm"
  version = "2.10.1"
  providers = {
    logdna.at = logdna.at
    logdna.ld = logdna.ld
  }
  region                         = var.region
  resource_group_id              = module.resource_group.resource_group_id
  cloud_monitoring_instance_name = "${var.prefix}-sysdig"
  cloud_monitoring_plan          = "graduated-tier"
  enable_platform_logs           = false
  enable_platform_metrics        = false
  log_analysis_provision         = false
  activity_tracker_instance_name = "${var.prefix}-at"
  activity_tracker_tags          = var.resource_tags
  activity_tracker_plan          = "7-day"
  activity_tracker_provision     = !local.existing_at
  log_analysis_tags              = var.resource_tags
  cloud_monitoring_tags          = var.resource_tags
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
  version          = "1.17.1"
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
  version          = "1.17.1"
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
# Create COS instance and bucket with:
# - Encryption
# - Monitoring
# - Activity Tracking
##############################################################################

module "cos_fscloud" {
  source               = "../../modules/fscloud"
  resource_group_id    = module.resource_group.resource_group_id
  cos_instance_name    = "${var.prefix}-cos"
  cos_tags             = var.resource_tags
  sysdig_crn           = module.observability_instances.cloud_monitoring_crn
  activity_tracker_crn = local.at_crn
  access_tags          = var.access_tags

  # CBR rule only allowing the COS instance to be accessbile over the private endpoint from within the VPC
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
          "value" : "public"
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
    kms_key_crn              = var.bucket_hpcs_key_crn
    kms_guid                 = var.bucket_existing_hpcs_instance_guid
    management_endpoint_type = "public"
    resource_group_id        = module.resource_group.resource_group_id
    region_location          = var.region
    activity_tracking = {
      activity_tracker_crn = local.at_crn
    }

    # CBR rule only allowing the COS bucket to be accessbile over the private endpoint from within the VPC
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
