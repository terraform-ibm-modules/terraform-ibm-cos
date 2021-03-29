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
  
  source  = "terraform-ibm-modules/cos/ibm//modules/instance"
  
  service_name       = var.service_name
  resource_group_id  = data.ibm_resource_group.cos_group.id
  plan               = var.plan
  region             = var.region
}