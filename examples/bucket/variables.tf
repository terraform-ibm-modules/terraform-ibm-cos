#####################################################
# COS Bucket
# Copyright 2020 IBM
#####################################################

// Bucket congigurations

variable "bucket_name" {
    description = "Enter Bucket name"
    type        = string
}

variable "location" {
    description = "Bucket cross region location for provision"
    type        = string
}

variable "storage_class" {
    description = " Bucket storage class."
    type        = string
}

// cos-instance

variable "resource_group" {
    description = "Enter Name of the resource group"
    type        = string
}

variable "service_name" {
    description = "Enter service name "
    type        = string
}

variable "plan" {
    description = "Enter plan type"
    type        = string
}

variable "region" {
    description = "Enter Region for provisioning"
    type        = string
}

variable "provision_cos_instance" {
    description = "Create new cos instance(true/false)"
    type        = bool
    default = true
}

variable "cos_instance_id" {
    description = "Create new cos instance(true/false)"
    type        = string
    default = null
}



