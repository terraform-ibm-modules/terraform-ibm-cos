#####################################################
# COS Instance
# Copyright 2020 IBM
#####################################################

resource "ibm_resource_instance" "cos_instance" {
  count             = (var.provision_cos_instance ? 1 : 0)
  name              = var.service_name
  resource_group_id = var.resource_group_id
  service           = var.service_type
  plan              = var.plan
  location          = var.region
}
