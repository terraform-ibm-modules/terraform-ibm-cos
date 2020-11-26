# Module cos_instance

This module is used to create a cloud object storage instance.

## Example Usage
```
provider "ibm" {
}

data "ibm_resource_group" "cos_group" {
  name = var.resource_group
}

module "cos" {
  
  source  = "terraform-ibm-modules/cos/ibm//modules/instance"
  
  service_name       = var.service_name
  resource_group_id  = data.ibm_resource_group.cos_group.id
  plan               = var.plan
  region             = var.region
}

```

## NOTE: If we want to make use of a particular version of module, then set the argument "version" to respective module version.


## Inputs

| Name            | Description                                                      | Type   | Default | Required |
|-----------------|------------------------------------------------------------------|:-------|:------- |:---------|
| name            | A descriptive name used to identify the resource instance        | string | n/a     | yes      |
| plan            | The name of the plan type supported by service.                  | string | n/a     | yes      |
| location        | Target location or environment to create the resource instance.  | string | n/a     | yes      |
| resource\_group | Name of the resource group                                       | string | n/a     | yes      |
