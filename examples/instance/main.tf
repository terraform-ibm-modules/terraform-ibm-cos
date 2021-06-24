#####################################################
# COS Instance
# Copyright 2020 IBM
#####################################################

provider "ibm" {
}

data "ibm_resource_group" "cos_group" {
  name = var.resource_group
}

module "cos" {
  // Uncommnet the following line to point the source to registry level
  //source = "terraform-ibm-modules/cos/ibm//modules/instance"

  source            = "../../modules/instance"
  bind_resource_key = var.bind_resource_key
  service_name      = var.service_name
  resource_group_id = data.ibm_resource_group.cos_group.id
  plan              = var.plan
  region            = var.region
  service_endpoints = var.service_endpoints
  parameters        = var.parameters
  tags              = var.tags
  create_timeout    = var.create_timeout
  update_timeout    = var.update_timeout
  delete_timeout    = var.delete_timeout
  resource_key_name = var.resource_key_name
  role              = var.role
  key_tags          = var.key_tags
  key_parameters    = var.key_parameters
}