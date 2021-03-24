#####################################################
# COS Instance
# Copyright 2020 IBM
#####################################################

output "cos_instance_id" {
  description = "The ID of the cos instance"
  value = length(ibm_resource_instance.cos_instance) > 0 ? ibm_resource_instance.cos_instance[0].id : ""
}