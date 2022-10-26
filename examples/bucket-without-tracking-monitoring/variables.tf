variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Token"
}

variable "environment_name" {
  type        = string
  default     = "test-cos"
  description = "Prefix name for all related resources"
}

variable "region" {
  type        = string
  default     = "us-south"
  description = "Name of the Region to deploy in to"
}
