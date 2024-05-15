##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.5"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Create Cloud Object Storage instance and a bucket
##############################################################################

module "cos" {
  source                 = "../../"
  resource_group_id      = module.resource_group.resource_group_id
  region                 = var.region
  cos_instance_name      = "${var.prefix}-cos"
  cos_tags               = var.resource_tags
  bucket_name            = "${var.prefix}-bucket"
  retention_enabled      = false # disable retention for test environments - enable for stage/prod
  kms_encryption_enabled = false
}

##############################################################################
# Create Cloud Object Storage bucket using buckets submodule
##############################################################################

module "buckets" {
  source = "../../modules/buckets"
  bucket_configs = [
    {
      bucket_name                   = "${var.prefix}-bucket-0"
      kms_encryption_enabled        = true
      region_location               = var.region
      resource_instance_id          = module.cos.cos_instance_id
      skip_iam_authorization_policy = false
      kms_guid                      = "68c81d30-48dd-41fd-ba7e-494038b35bdc"
      kms_key_crn                   = "crn:v1:bluemix:public:kms:us-south:a/abac0df06b644a9cabc6e44f55b3880e:68c81d30-48dd-41fd-ba7e-494038b35bdc:key:fc1d321b-6b59-4c62-a7fe-e40b6ab0809d"
    },
    {
      bucket_name                   = "${var.prefix}-bucket-1"
      kms_encryption_enabled        = true
      region_location               = var.region
      resource_instance_id          = module.cos.cos_instance_id
      skip_iam_authorization_policy = false
      kms_guid                      = "68c81d30-48dd-41fd-ba7e-494038b35bdc"
      kms_key_crn                   = "crn:v1:bluemix:public:kms:us-south:a/abac0df06b644a9cabc6e44f55b3880e:68c81d30-48dd-41fd-ba7e-494038b35bdc:key:fc1d321b-6b59-4c62-a7fe-e40b6ab0809d"
    }
  ]
}
