variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Token"
  sensitive   = true
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

variable "prefix" {
  type        = string
  description = "Prefix for name of all resource created by this example"
  default     = "test-bucket-wo-mon"
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}

# tflint-ignore: terraform_unused_declarations
variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}
