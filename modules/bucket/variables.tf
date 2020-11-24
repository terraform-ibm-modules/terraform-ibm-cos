#####################################################
# COS Bucket
# Copyright 2020 IBM
#####################################################

variable "bucket_name" {
    description = "Name of the bucket"
    type        = string
}

variable "location" {
    description = "Location to provision"
    type        = string
}

variable "storage_class" {
    description = " storage class to use for the bucket."
    type        = string
}

variable "cos_instance_id"{
    description = "resource instance id"
    type        = string
}