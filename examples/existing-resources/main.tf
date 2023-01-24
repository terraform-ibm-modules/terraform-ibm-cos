##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.5"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Create Key Protect resources
##############################################################################

locals {
  key_ring_name = "cos-key-ring"
  key_name      = "cos-key"
}

module "key_protect_all_inclusive" {
  source                    = "git::https://github.com/terraform-ibm-modules/terraform-ibm-key-protect-all-inclusive.git?ref=v3.0.2"
  key_protect_instance_name = "${var.prefix}-kp"
  resource_group_id         = module.resource_group.resource_group_id
  enable_metrics            = false
  region                    = var.region
  key_map = {
    (local.key_ring_name) = [local.key_name]
  }
  resource_tags = var.resource_tags
}


# ##############################################################################
# # Get Cloud Account ID
# ##############################################################################

# data "ibm_iam_account_settings" "iam_account_settings" {
# }

# ##############################################################################
# # CBR zone & rule creation
# ##############################################################################

# locals {
#   ip_addresses = [
#     for address in var.ip_address :
#     {
#       type  = "ipAddress"
#       value = address
#     }
#   ]

#   cos_address = [{
#     type = "serviceRef" # to bind a service reference type should be 'serviceRef'
#     ref = {
#       account_id   = data.ibm_iam_account_settings.iam_account_settings.account_id
#       service_name = "cloud-object-storage" # secrets manager service reference.
#     }
#   }]

#   addresses = concat(local.ip_addresses, local.cos_address)

#   zone = {
#       name             = "${var.zone_name}"
#       account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
#       zone_description = var.zone_description
#       addresses        = local.addresses
#     }
# }

# module "cbr_zone" {
#   source           = "git::https://github.com/terraform-ibm-modules/terraform-ibm-cbr//cbr-zone-module?ref=v1.0.0"
#   name             = local.zone.name
#   zone_description = local.zone.zone_description
#   account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
#   addresses        = local.zone.addresses
# }

# locals {
#   rule_contexts = [{
#     attributes = [{
#       name  = "networkZoneId"
#       value = module.cbr_zone.zone_id
#     }]
#   }]

#   pg_resource = [{
#     attributes = [
#       {
#         name     = "accountId"
#         value    = data.ibm_iam_account_settings.iam_account_settings.account_id
#         operator = ""
#       },
#       {
#         name     = "serviceName"
#         value    = "cloud-object-storage"
#         operator = ""
#       }
#     ],
#     tags = [
#       {
#         name  = "terraform-rule"
#         value = "allow-cos"
#       }
#     ]
#   }]
# }

# module "cbr_rule" {
#   source           = "git::https://github.com/terraform-ibm-modules/terraform-ibm-cbr//cbr-rule-module?ref=v1.0.0"
#   rule_description = var.rule_description
#   enforcement_mode = var.enforcement_mode
#   rule_contexts    = local.rule_contexts
#   resources        = local.pg_resource
#   operations       = []
# }

##############################################################################
# Create COS instance only
##############################################################################

module "cos_instance" {
  source                             = "../../"
  cos_instance_name                  = "${var.prefix}-cos"
  create_cos_bucket                  = false
  resource_group_id                  = module.resource_group.resource_group_id
  existing_key_protect_instance_guid = module.key_protect_all_inclusive.key_protect_guid
  region                             = var.region
  cross_region_location              = null
  activity_tracker_crn               = null
}

##############################################################################
# Create COS bucket with:
# - Encryption
# Create COS bucket without:
# - Retention
# - Monitoring
# - Activity Tracking
##############################################################################

module "cos" {
  source                   = "../../"
  create_cos_instance      = false
  existing_cos_instance_id = module.cos_instance.cos_instance_id
  key_protect_key_crn      = module.key_protect_all_inclusive.keys["${local.key_ring_name}.${local.key_name}"].crn
  bucket_name              = "${var.prefix}-bucket"
  resource_group_id        = module.resource_group.resource_group_id
  region                   = var.region
  cross_region_location    = null
  encryption_enabled       = true
  retention_enabled        = false
  activity_tracker_crn     = null
}
