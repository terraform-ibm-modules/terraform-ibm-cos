#####################################################
# COS Instance
# Copyright 2020 IBM
#####################################################

output "cos_instance_id" {
  description = "The ID of the cos instance"
  value = module.cos.cos_instance_id
}
