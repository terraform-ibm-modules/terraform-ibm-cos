#####################################################
# COS Bucket
# Copyright 2020 IBM
#####################################################

resource "ibm_cos_bucket" "testBucket" {
  bucket_name             = var.bucket_name
  resource_instance_id    = var.cos_instance_id  
  cross_region_location   = var.location
  storage_class           = var.storage_class
}