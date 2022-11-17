module "resource_group" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.2"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Observability Instances (LogDNA + Sysdig)
##############################################################################

module "observability_instances" {
  source                         = "git::https://github.com/terraform-ibm-modules/terraform-ibm-observability-instances?ref=v1.0.0"
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

# Create COS instance and Key protect instance.
# Create COS bucket-1 with:
# - Retention
# - Encryption
# - Monitoring
# - Activity Tracking
module "cos_bucket1" {
  source               = "../../"
  environment_name     = var.prefix
  resource_group_id    = module.resource_group.resource_group_id
  region               = var.region
  cos_key_ring_name    = "cos-key-ring"
  cos_key_name         = ["cos-key"]
  sysdig_crn           = module.observability_instances.sysdig_crn
  activity_tracker_crn = module.observability_instances.activity_tracker_crn
  bucket_infix         = "bucket1"
}

# We will reuse the COS instance and Key Protect that were created in cos_bucket1 module.
# Pass the cos instance name and key protect name for creating second bucket
# Create COS bucket-2 with:
# - Retention
# - Encryption
# - Monitoring
# - Activity Tracking
module "cos_bucket2" {
  source                      = "../../"
  environment_name            = var.prefix
  resource_group_id           = module.resource_group.resource_group_id
  region                      = var.region
  bucket_infix                = "bucket2"
  cos_key_ring_name           = "cos-key-ring"
  cos_key_name                = ["cos-key"]
  sysdig_crn                  = module.observability_instances.sysdig_crn
  activity_tracker_crn        = module.observability_instances.activity_tracker_crn
  create_cos_instance         = false
  create_key_protect_instance = false
  cos_instance_name           = "${var.prefix}-cos"
  key_protect_instance_name   = "${var.prefix}-kms"
  depends_on                  = [module.cos_bucket1]
}
