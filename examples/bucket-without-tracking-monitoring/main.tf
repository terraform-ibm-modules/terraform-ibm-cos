module "resource_group" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.1"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name = "${var.environment_name}-resource-group"
}

# Create COS bucket with:
# - Retention
# Create COS bucket without:
# - Monitoring
# - Activity Tracking
# - Encryption
module "cos" {
  source             = "../../"
  environment_name   = var.environment_name
  resource_group_id  = module.resource_group.resource_group_id
  region             = var.region
  encryption_enabled = false
}
