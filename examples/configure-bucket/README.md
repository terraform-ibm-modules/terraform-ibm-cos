# Module cos_bucket

This module is used to create a cloud object storage bucket

## Example Usage
```
provider "ibm" {
  region = var.location
}

data "ibm_resource_group" "group" {
  name = var.resource_group
}

resource "ibm_resource_instance" "at_instance" {

  name              = var.activity_tracker_name
  service           = "logdnaat"
  plan              = var.activity_tracker_plan
  location          = var.activity_tracker_region
  resource_group_id = data.ibm_resource_group.group.id
}

locals {
  archive_rule_id = var.archive_rule_enabled ? "bucket-archive-rule-${ibm_resource_instance.at_instance.name}" : null
  expire_rule_id  = "bucket-expire-rule-${ibm_resource_instance.at_instance.name}"
}

module "cos" {
  // Uncommnet the following line to point the source to registry level
  //source                 = "terraform-ibm-modules/cos/ibm//modules/instance"

  source                 = "../../modules/instance"
  provision_cos_instance = true
  service_name           = var.cos_instance_name
  resource_group_id      = data.ibm_resource_group.group.id
  plan                   = var.cos_plan
  region                 = var.cos_location
  resource_key_name      = var.resource_key_name
  role                   = var.role
}


module "cos_bucket" {

  // Uncommnet the following line to point the source to registry level
  //source               = "terraform-ibm-modules/cos/ibm//modules/bucket"

  source               = "../../modules/bucket"
  count                = length(var.bucket_names)
  bucket_name          = var.bucket_names[count.index]
  cos_instance_id      = module.cos.cos_instance_id
  location             = var.location
  storage_class        = var.storage_class
  force_delete         = var.force_delete
  endpoint_type        = var.endpoint_type
  activity_tracker_crn = ibm_resource_instance.at_instance.id
  archive_rule = {
    rule_id = local.archive_rule_id
    enable  = true
    days    = 0
    type    = "GLACIER"
  }
  expire_rules = [{
    rule_id = local.expire_rule_id
    enable  = true
    days    = 365
    prefix  = "logs/"
  }]
}



```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs


| Name                   | Description                                                                           | Type   | Default | Required |
|------------------------|---------------------------------------------------------------------------------------|--------|---------|----------|
| cos\_location          | cos location info                                                                     | string | n/a     | yes      |
| storage\_class         | Storage class to use for the bucket                                                   | string | n/a     | yes      |
| location               | single site or region or cross region location info for bucket                        | string | n/a     | yes      |
| cos\_plan              | The name of the plan type supported by COS service.                                   | string | n/a     | yes      |
| region                 | Target location or environment to create the resource instance.                       | string | n/a     | yes      |
| resource\_group        | Name of the resource group                                                            | string | n/a     | yes      |
| at\_instance\_name     | Name of the actvity tracker instance name  with bucket to be configured for event     | string | n/a     | yes      |
| cos\_instance\_name    | Name of the cos instance with bucket to be attached                                   | string | n/a     | yes      |
| endpoint\_type         | endpoint for the COS bucket                                                           | string | `public`| no       |
| force\_delete          | COS buckets need to be empty before they can be deleted                               | bool   | `true`  | no       |
| read\_data\_events     | If set to true, all object write events will be sent to Activity Tracke/logdna        | bool   | `true`  | no       |
| write\_data\_events    | If set to true, all object write events will be sent to Activity Tracke/logdna        | bool   | `true`  | no       |


## NOTE :

* If we want to make use of a particular version of module, then set the argument "version" to respective module version.

* Set the `archive_rule_enabled` argument to true only for regional cos bucket creation. For cross region and singleSite location set to false.

* To attach a key to cos instance, enbale it by setting `bind_resource_key` argument to true (which is by default false). And set the `resource_key_name` and `role` parameters accordingly (which are by deafult empty) in variables.tf file.