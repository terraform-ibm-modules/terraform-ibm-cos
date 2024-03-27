module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.5"
  resource_group_name          = var.existing_resource_group == false ? var.resource_group_name : null
  existing_resource_group_name = var.existing_resource_group == true ? var.resource_group_name : null
}

module "cos" {
  source              = "../../modules/fscloud"
  resource_group_id   = module.resource_group.resource_group_id
  create_cos_instance = true
  cos_instance_name   = var.cos_instance_name
  resource_keys       = var.resource_keys
  cos_plan            = var.cos_plan
  cos_tags            = var.cos_tags
  access_tags         = var.access_tags
}
