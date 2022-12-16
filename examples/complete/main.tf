module "resource_group" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.4"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Observability Instances (LogDNA + Sysdig)
##############################################################################

# Create Sysdig and Activity Tracker instance
module "observability_instances" {
  source                         = "git::https://github.com/terraform-ibm-modules/terraform-ibm-observability-instances?ref=v1.1.0"
  region                         = var.region
  resource_group_id              = module.resource_group.resource_group_id
  activity_tracker_instance_name = "${var.prefix}-at"
  logdna_instance_name           = "${var.prefix}-logdna"
  sysdig_instance_name           = "${var.prefix}-sysdig"
  activity_tracker_plan          = "7-day"
  logdna_plan                    = "7-day"
  sysdig_plan                    = "graduated-tier"
  enable_platform_logs           = false
  enable_platform_metrics        = false
  activity_tracker_tags          = var.resource_tags
  logdna_tags                    = var.resource_tags
  sysdig_tags                    = var.resource_tags
}

# Create COS bucket with:
# - Retention
# - Encryption
# - Monitoring
# - Activity Tracking
module "complete" {
  source               = "../../"
  environment_name     = var.prefix
  resource_group_id    = module.resource_group.resource_group_id
  region               = var.region
  cos_key_ring_name    = "cos-key-ring"
  cos_key_name         = ["cos-key"]
  sysdig_crn           = module.observability_instances.sysdig_crn
  activity_tracker_crn = module.observability_instances.activity_tracker_crn
  retention_enabled    = true
}
