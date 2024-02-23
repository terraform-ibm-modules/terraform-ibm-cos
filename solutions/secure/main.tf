module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.4"
  resource_group_name          = var.existing_resource_group == false ? var.resource_group_name : null
  existing_resource_group_name = var.existing_resource_group == true ? var.resource_group_name : null
}

module "cos_da" {
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
  instance_cbr_rules        = var.instance_cbr_rules
  bucket_configs            = var.bucket_configs
}
