# Module cos_instance

This module is used to create a cloud object storage instance.

## Example Usage
```
data "ibm_resource_group" "cos_group" {
  name = var.resource_group
}

module "cos" {
  source = "../../modules/cos_instance"

  name              = var.name
  resource_group_id = data.ibm_resource_group.cos_group.id
  plan              = var.plan
  location          = var.location
}

```

## Inputs

| Name            | Description                                                      | Type   | Default | Required |
|-----------------|------------------------------------------------------------------|:-------|:------- |:---------|
| name            | A descriptive name used to identify the resource instance        | string | n/a     | yes      |
| plan            | The name of the plan type supported by service.                  | string | n/a     | yes      |
| location        | Target location or environment to create the resource instance.  | string | n/a     | yes      |
| resource\_group | Name of the resource group                                       | string | n/a     | yes      |
