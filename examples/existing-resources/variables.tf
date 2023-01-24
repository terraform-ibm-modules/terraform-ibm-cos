variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Token"
  sensitive   = true
}

variable "region" {
  type        = string
  default     = "us-south"
  description = "Name of the Region to deploy in to"
}

variable "prefix" {
  type        = string
  description = "Prefix for name of all resource created by this example"
  default     = "wes2-exist-cos"
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}


##############################################################
# Context-based restriction variables
##############################################################

# variable "rule_description" {
#   type        = string
#   description = "(Optional, String) The description of the rule"
#   default     = null
# }

# variable "enforcement_mode" {
#   type        = string
#   description = "(String) The rule enforcement mode"
#   default     = "enabled"
# }

# variable "zone_name" {
#   type        = string
#   description = "(String) The name of the zone"
#   default     = "zone1-terraform"
# }

# variable "zone_description" {
#   type        = string
#   description = "(Optional, String) The description of the zone"
#   default     = "Zone from automation"
# }

# variable "ip_address" {
#   type        = list(string)
#   description = "(Optional, list(string)) of CBR ipaddresses"
#   default     = []
# }
