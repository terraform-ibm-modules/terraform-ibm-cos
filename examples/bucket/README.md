# Module cos_bucket 

This module is used to create a cloud object storage bucket

## Example Usage
```
provider "ibm" {
}

data "ibm_resource_group" "group" {
  name = var.resource_group
}

data "ibm_resource_instance" "logdna_instance" {
  name              = var.logdna_instance_name
  location          = var.location
  resource_group_id = data.ibm_resource_group.group.id
  service           = "logdna"
}

data "ibm_resource_instance" "at_instance" {
  name              = var.at_instance_name
  location          = var.location
  resource_group_id = data.ibm_resource_group.group.id
  service           = "logdnaat"
}

locals {

  logdna-bucket   = "${data.ibm_resource_instance.logdna_instance.name}-cos-bucket"
  at-bucket       = "${data.ibm_resource_instance.at_instance.name}-cos-bucket"
  logdna_crn      = var.logdna_crn == "" ? data.ibm_resource_instance.logdna_instance.id : var.logdna_crn
  at_crn          = var.activity_tracker_crn == "" ? data.ibm_resource_instance.at_instance.id : var.activity_tracker_crn
  archive_rule_id = "bucket-archive-rule-${data.ibm_resource_instance.logdna_instance.name}"
  expire_rule_id  = "bucket-expire-rule-${data.ibm_resource_instance.at_instance.name}"
  bucket_list     = [local.logdna-bucket, local.at-bucket]
  crn_list        = [local.logdna_crn, local.at_crn]
}

module "cos" {
  
 source  = "terraform-ibm-modules/cos/ibm//modules/instance"
 provision_cos_instance = true
 service_name           = var.cos_instance_name
 resource_group_id      = data.ibm_resource_group.group.id
 plan                   = var.cos_plan
 region                 = var.cos_location
}


module "cos_bucket" {

  source           = "terraform-ibm-modules/cos/ibm//modules/bucket"
  count            = length(local.bucket_list)
  bucket_name      = local.bucket_list[count.index]
  cos_instance_id  = module.cos.cos_instance_id
  location         = var.location
  storage_class    = var.storage_class
  force_delete     = var.force_delete
  endpoint_type    = var.endpoint_type
  activity_tracker_crn = local.crn_list[count.index]
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
| logdna\_instance\_name | Name of the logdna instance name  with bucket to be configured for event              | string | n/a     | yes      |
| at\_instance\_name     | Name of the actvity tracker instance name  with bucket to be configured for event     | string | n/a     | yes      |
| cos\_instance\_name    | Name of the cos instance with bucket to be attached                                   | string | n/a     | yes      |
| endpoint\_type         | endpoint for the COS bucket                                                           | string | `public`| no       |
| force\_delete          | COS buckets need to be empty before they can be deleted                               | bool   | `true`  | no       |
| activity\_tracker\_crn | instance crn of Activity Tracker that will receive object event data                  | string | n/a     | no       |
| logdna\_crn            | instance crn of logdna that will receive object event data                            | string | n/a     | no       |
| read\_data\_events     | If set to true, all object write events will be sent to Activity Tracke/logdna        | bool   | `true`  | no       |
| write\_data\_events    | If set to true, all object write events will be sent to Activity Tracke/logdna        | bool   | `true`  | no       |


## NOTE: If we want to make use of a particular version of module, then set the argument "version" to respective module version.