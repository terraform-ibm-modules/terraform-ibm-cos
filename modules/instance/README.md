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
  // Uncommnet the following line to point the source to registry level
  //source = "terraform-ibm-modules/cos/ibm//modules/instance"

  source = "../../modules/instance"
  bind_resource_key = var.bind_resource_key
  service_name      = var.service_name
  resource_group_id = data.ibm_resource_group.cos_group.id
  plan              = var.plan
  region            = var.region
  service_endpoints = var.service_endpoints
  parameters        = var.parameters
  tags              = var.tags
  create_timeout    = var.create_timeout
  update_timeout    = var.update_timeout
  delete_timeout    = var.delete_timeout
  resource_key_name = var.resource_key_name
  role              = var.role
  key_tags          = var.key_tags
  key_parameters    = var.key_parameters
}

```

## NOTE: If we want to make use of a particular version of module, then set the argument "version" to respective module version.


## Inputs

| Name             | Description                                                      | Type        | Default | Required |
|------------------|------------------------------------------------------------------|:------------|:------- |:---------|
| service_name     | A descriptive name used to identify the resource instance        | string      | n/a     | yes      |
| plan             | The name of the plan type supported by service.                  | string      | n/a     | yes      |
| region           | Target location or environment to create the resource instance.  | string      | n/a     | yes      |
| resource\_group  | Name of the resource group                                       | string      | n/a     | yes      |
| bind_resource_key| Set this to true to latch a key to cos instance                  | boolean     | n/a     | no       |
| service_endpoints| Types of the service endpoints                                   | string      | n/a     | no       |
| parameters       | Arbitrary parameters to create instance                          | map(string) | n/a     | no       |
| tags             | Tags associated with the instance                                | list(string)| n/a     | no       |
| key_parameters   | Arbitrary parameters to create key                               | map(string) | n/a     | no       |
| key_tags         | Tags associated with the key                                     | list(string)| n/a     | no       |
| resource_key_name| Descriptive name used to identify a resource key.                | string      | n/a     | yes      |
| role             | Name of the user role                                            | string      | n/a     | yes      |
| create_timeout   | Timeout duration for creation                                    | string      | n/a     | no       |
| update_timeout   | Timeout duration for updation                                    | string      | n/a     | no       |
| delete_timeout   | Timeout duration for deletion                                    | string      | n/a     | no       |

## Outputs

| Name             | Description                     |
|------------------|---------------------------------|
| cos_instance_id  | The ID of the cos instance      |
| cos_key_id       | The ID of the key               |