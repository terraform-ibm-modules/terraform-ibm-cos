module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.4"
  resource_group_name          = var.existing_resource_group == false ? var.resource_group_name : null
  existing_resource_group_name = var.existing_resource_group == true ? var.resource_group_name : null
}

module "cos_fscloud_da" {
  source                    = "../../modules/fscloud"
  resource_group_id         = module.resource_group.resource_group_id
  create_cos_instance       = var.create_cos_instance
  existing_cos_instance_id  = var.existing_cos_instance_id
  cos_instance_name         = var.cos_instance_name
  create_resource_key       = var.create_resource_key
  resource_key_name         = var.resource_key_name
  resource_key_role         = var.resource_key_role
  generate_hmac_credentials = var.generate_hmac_credentials
  cos_plan                  = var.cos_plan
  cos_tags                  = var.cos_tags
  access_tags               = var.access_tags
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
  bucket_configs = [{
    access_tags              = var.access_tags
    bucket_name              = "${var.prefix}-bucket"
    kms_key_crn              = "crn:v1:bluemix:public:hs-crypto:us-south:a/abac0df06b644a9cabc6e44f55b3880e:e6dce284-e80f-46e1-a3c1-830f7adff7a9:key:76170fae-4e0c-48c3-8ebe-326059ebb533"
    kms_guid                 = "e6dce284-e80f-46e1-a3c1-830f7adff7a9"
    management_endpoint_type = "public"
    region_location          = "us-south"
    # activity_tracking = {
    #   activity_tracker_crn = local.at_crn
    # }
    # metrics_monitoring = {
    #   metrics_monitoring_crn = module.observability_instances.cloud_monitoring_crn
    # }

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

# locals {
#   at_crn      = module.observability_instances.activity_tracker_crn
# }

# Create Sysdig and Activity Tracker instance
# module "observability_instances" {
#   source  = "terraform-ibm-modules/observability-instances/ibm"
#   version = "2.11.0"
#   providers = {
#     logdna.at = logdna.at
#     logdna.ld = logdna.ld
#   }
#   region                         = var.region
#   resource_group_id              = module.resource_group.resource_group_id
#   cloud_monitoring_instance_name = "sysdig-1"
#   cloud_monitoring_plan          = "graduated-tier"
#   enable_platform_logs           = false
#   enable_platform_metrics        = false
#   log_analysis_provision         = false
#   activity_tracker_instance_name = "at-1"
#   activity_tracker_tags          = ["at_tags"]
#   activity_tracker_plan          = "7-day"
#   activity_tracker_provision     = true
#   log_analysis_tags              = ["log_an_tags"]
#   cloud_monitoring_tags          = ["monitoring_tags"]
# }

##############################################################################
# Get Cloud Account ID
##############################################################################

data "ibm_iam_account_settings" "iam_account_settings" {
}

##############################################################################
# VPC
##############################################################################

resource "ibm_is_vpc" "example_vpc" {
  name           = "${var.prefix}-vpc"
  resource_group = module.resource_group.resource_group_id
  tags           = ["tag-1"]
}

resource "ibm_is_subnet" "testacc_subnet" {
  name                     = "${var.prefix}-subnet"
  vpc                      = ibm_is_vpc.example_vpc.id
  zone                     = "us-south-1"
  total_ipv4_address_count = 256
  resource_group           = module.resource_group.resource_group_id
}

##############################################################################
# Create CBR Zone
##############################################################################

module "cbr_zone" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "1.18.1"
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
  version          = "1.18.1"
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
