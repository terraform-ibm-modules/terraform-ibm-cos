#####################################################
# COS Instance
# Copyright 2020 IBM
#####################################################

variable "resource_group" {
    description = "Enter Name of the resource group"
    type        = string
}

variable "service_name" {
    description = "Enter Name of the cos instance"
    type        = string
}

variable "plan" {
    description = "Enter plan type"
    type        = string
}

variable "region" {
    description = " Enter Region for provisioning"
    type        = string
}

variable "ibmcloud_api_key" {
    description = " Enter IBM Cloud API KEY"
    type        = string
}