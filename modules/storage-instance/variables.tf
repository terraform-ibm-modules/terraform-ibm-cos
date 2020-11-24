#####################################################
# COS Instance
# Copyright 2020 IBM
#####################################################

######## configured by user ########################

variable "resource_group_id" {
    description = "ID of the resource group"
    type        = string
}

variable "service_name" {
    description = "Name of the instance"
    type        = string
}

variable "plan" {
    description = "plan type"
    type        = string
}

variable "region" {
    description = "Provisioning Region"
    type        = string
}

########### Having Default Values ############

variable "service_type" {
    description = "Type of the service"
    default     = "cloud-object-storage"
    type        = string
}



