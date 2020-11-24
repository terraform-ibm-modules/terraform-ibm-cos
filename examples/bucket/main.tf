#####################################################
# COS Bucket
# Copyright 2020 IBM
#####################################################

provider "ibm" {
}

data "ibm_resource_group" "cos_group" {
  name = var.resource_group
}

module "cos" {
  
  source  = "terraform-ibm-modules/cos/ibm//modules/cos_instance"
  
  service_name       = var.service_name
  resource_group_id  = data.ibm_resource_group.cos_group.id
  plan               = var.plan
  region             = var.region
}

module "cos_bucket" {
  source  = "terraform-ibm-modules/cos/ibm//modules/cos_bucket"

  bucket_name         = var.bucket_name
  cos_instance_id     = module.cos.cos_instance_id  
  location            = var.location
  storage_class       = var.storage_class

}