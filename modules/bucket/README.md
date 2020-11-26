# Module cos_bucket 

This module is used to create a cloud object storage bucket

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

module "cos_bucket" {
  source  = "terraform-ibm-modules/cos/ibm//modules/bucket"

  bucket_name         = var.bucket_name
  cos_instance_id     = module.cos.cos_instance_id  
  location            = var.location
  storage_class       = var.storage_class

}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs


| Name            | Description                                                      | Type   | Default | Required |
|-----------------|------------------------------------------------------------------|:-------|---------|----------|
| bucket\_name    | Name of the bucket                                               | string | n/a     | yes      |
| storage\_class  | Storage class to use for the bucket                              | string | n/a     | yes      |
| location        | The location of a regional bucket                                | string | n/a     | no       |
| name            | A descriptive name used to identify the resource instance        | string | n/a     | yes      |
| plan            | The name of the plan type supported by service.                  | string | n/a     | yes      |
| region          | Target location or environment to create the resource instance.  | string | n/a     | yes      |
| resource\_group | Name of the resource group                                       | string | n/a     | yes      |

## NOTE: If we want to make use of a particular version of module, then set the argument "version" to respective module version.