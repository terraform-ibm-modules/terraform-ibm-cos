#####################################################
# COS Instance
# Copyright 2020 IBM
#####################################################

locals {
  bind = var.bind_resource_key
}

resource "ibm_resource_instance" "cos_instance" {
  count             = (var.provision_cos_instance ? 1 : 0)
  name              = var.service_name
  resource_group_id = var.resource_group_id
  service           = var.service_type
  plan              = var.plan
  location          = var.region
  tags              = (var.tags != null ? var.tags : null)
  parameters        = (var.parameters != null ? var.parameters : null)
  service_endpoints = (var.service_endpoints != null ? var.service_endpoints : null)

  timeouts {
    create = (var.create_timeout != null ? var.create_timeout : null)
    update = (var.update_timeout != null ? var.update_timeout : null)
    delete = (var.delete_timeout != null ? var.delete_timeout : null)
  }
}

resource "ibm_resource_key" "key" {
  count                = local.bind ? 1 : 0
  name                 = var.resource_key_name
  role                 = var.role
  parameters           = (var.key_parameters != null ? var.key_parameters : null)
  resource_instance_id = (var.provision_cos_instance ? ibm_resource_instance.cos_instance[0].id : null)
  tags                 = (var.key_tags != null ? var.key_tags : null)

  timeouts {
    create = (var.create_timeout != null ? var.create_timeout : null)
    delete = (var.delete_timeout != null ? var.delete_timeout : null)
  }
}
