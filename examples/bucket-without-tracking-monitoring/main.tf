module "resource_group" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.2"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-${var.environment_name}-rg" : null
  existing_resource_group_name = var.resource_group
}

# Create COS bucket with:
# - Retention
# - Encryption
# Create COS bucket without:
# - Monitoring
# - Activity Tracking

module "cos" {
  source             = "../../"
  environment_name   = "${var.prefix}-${var.environment_name}-cos"
  resource_group_id  = module.resource_group.resource_group_id
  region             = var.region
  encryption_enabled = true
}
