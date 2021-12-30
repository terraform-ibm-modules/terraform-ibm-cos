# Module Cloud Object Storage

This module is used to create a cloud object storage instance with multuple buckets attached to it. Cloud object storage bucket can be configured with activity tracker and monitoring instances.

## Example Usage
```
provider "ibm" {
  region = var.location
}

locals {
  archive_rule_id = var.archive_rule_enabled && var.configure_activity_tracker ? (var.is_new_activity_tracker ? "bucket-archive-rule-${ibm_resource_instance.activity_tracker[0].name}" : "bucket-archive-rule-${data.ibm_resource_instance.data_activity_tracker[0].name}"): null
  expire_rule_id  = var.configure_activity_tracker ? (var.is_new_activity_tracker ? "bucket-expire-rule-${ibm_resource_instance.activity_tracker[0].name}" : "bucket-expire-rule-${data.ibm_resource_instance.data_activity_tracker[0].name}") : null
}

/***************************************************
Read resource group
***************************************************/
data "ibm_resource_group" "group" {
  name = var.resource_group
}

/*****************************************************
Read existing activity_tracker or create a new instance
*****************************************************/
data "ibm_resource_instance" "data_activity_tracker" {
  count = var.configure_activity_tracker && var.is_new_activity_tracker ? 0 : 1

  name              = var.activity_tracker_name
  location          = var.activity_tracker_region
  resource_group_id = data.ibm_resource_group.group.id
  service           = "logdnaat"
}

resource "ibm_resource_instance" "activity_tracker" {
  count             = var.configure_activity_tracker && var.is_new_activity_tracker ? 1 : 0
  name              = var.activity_tracker_name
  service           = "logdnaat"
  plan              = var.activity_tracker_plan
  location          = var.activity_tracker_region
  resource_group_id = data.ibm_resource_group.group.id
}

/*****************************************************
Read existing sysdig monitoring or create a new instance
*****************************************************/
data "ibm_resource_instance" "data_sysdig_instance" {
  count = var.configure_sysdig_monitoring && var.is_new_sysdig_monitoring ? 0 : 1

  name              = var.sysdig_monitoring_name
  location          = var.sysdig_monitoring_region
  resource_group_id = data.ibm_resource_group.group.id
  service           = "sysdig-monitor"
}

resource "ibm_resource_instance" "sysdig_instance" {

  count = var.configure_sysdig_monitoring && var.is_new_sysdig_monitoring ? 1 : 0

  name              = var.sysdig_monitoring_name
  service           = "sysdig-monitor"
  plan              = var.sysdig_monitoring_plan
  location          = var.sysdig_monitoring_region
  resource_group_id = data.ibm_resource_group.group.id
}

/*****************************************************
COS Instance Creation
*****************************************************/
module "cos" {
  // Uncommnet the following line to point the source to registry level
  //source                 = "terraform-ibm-modules/cos/ibm//modules/instance"

  source                 = "../../modules/instance"
  provision_cos_instance = true
  service_name           = var.cos_instance_name
  resource_group_id      = data.ibm_resource_group.group.id
  plan                   = var.cos_plan
  region                 = var.cos_location
  bind_resource_key      = var.bind_resource_key
  resource_key_name      = var.resource_key_name
  role                   = var.role
}


/*****************************************************
COS Bucket Creation
*****************************************************/
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
  activity_tracker_crn = var.configure_activity_tracker ? (var.is_new_activity_tracker ? ibm_resource_instance.activity_tracker[0].id : data.ibm_resource_instance.data_activity_tracker[0].id) : null
  read_data_events     = var.configure_activity_tracker ? var.read_data_events : null
  write_data_events    = var.configure_activity_tracker ? var.write_data_events : null
  metrics_monitoring_crn = var.configure_sysdig_monitoring ? (var.is_new_sysdig_monitoring ? ibm_resource_instance.sysdig_instance[0].id : data.ibm_resource_instance.data_sysdig_instance[0].id) : null
  usage_metrics_enabled = var.configure_sysdig_monitoring ? var.usage_metrics_enabled : null
  allowed_ip           = var.allowed_ip
  kms_key_crn          = var.kms_key_crn
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


| Name                      | Description                                                                  | Type   | Default | Required |
|---------------------------|------------------------------------------------------------------------------|--------|---------|----------|
| bucket_name_prefix        | String used as prefix to user input bucket name                              | string | Empty   |  no|
| resource_group_id         | ID of the resource group                                                   | string | n/a     | yes      |
| is_new_cos_instance       | Enable this to create new COS instance                                       | bool   | true    | no     |
| cos_instance_name         | Name of the COS instance                                                     | string | n/a     | yes      |
| region              | Location to provision COS instance                                           | string | us-south| no       |
| plan                  | Plan type for COS instance                                                   | string | standard| no       |
| is_bind_resource_key      | Enable this to bind key to COS instance                                      | bool   | false   | no       |
| resource_key_name         | Name of the resource key to bind                                             | string | empty   | no       |
| role                      | Type of roleValid roles are Writer, Reader, Manager, Administrator, Operator, Viewer, Editor | string | standard| no      |
| bucket_names              | List of buckets to create                                                    | list(string) | n/a     | yes      |
| location                  | Single site or region or cross region location info                          | string | n/a     | yes      |
| storage_class             | storage class to use for the bucket                                          | string | standard| no       |
| endpoint_type             | Endpoint for the COS bucket                                                  | string | false   | no       |
| resource_key_name         | Name of the resource key to bind                                             | string | public  | no       |
| force_delete              | COS buckets need to be empty before they can be deleted. force_delete option empty the bucket and delete it | bool | true     | no      |
| allowed_ip                | list of IPv4 or IPv6 addresses in CIDR notation that you want to allow access to your IBM Cloud Object Storage bucket | list(string) | n/a | no       |
| kms_key_crn               | CRN of the encryption root key that you want to use to encrypt data          | string | n/a     | no       |
| tags                      | List of tags to attach to COS instance                                       | list(string) | n/a     | no       |
| service_endpoints         | Type of COS servuce end point                     | string | public     | no       |
| key_tags               |  List of tags to attach to resource key               | list(string) | n/a     | no       |
| read_data_events       |  If set to true, all object read events will be sent to Activity Tracker/logdna  | bool | n/a     | no       |
| write_data_events      | If set to true, all object write events will be sent to Activity Tracke/logdna   | bool | n/a     | no       |
| activity_tracker_crn   | The instance of Activity Tracker that will receive object event data             | string | n/a     | no      |
| usage_metrics_enabled  | Usage metrics will be sent to the monitoring service.   | bool | n/a     | no       |
| metrics_monitoring_crn   | Instance of IBM Cloud Monitoring that will receive the bucket metrics        | string | n/a     | no      |


## Outputs

| Name                      | Description             | Type         |
|---------------------------|-------------------------|--------------|
| bucket_ids                | List of bucket ids      | list(string) |

## Requirements

### Terraform plugins

- [Terraform](https://www.terraform.io/downloads.html) 0.13
- [terraform-provider-ibm](https://github.com/IBM-Cloud/terraform-provider-ibm)

## Install

### Terraform

Be sure you have the correct Terraform version (0.13), you can choose the binary here:
- https://releases.hashicorp.com/terraform/

### Terraform plugins

Be sure you have the compiled plugins on $HOME/.terraform.d/plugins/

- [terraform-provider-ibm](https://github.com/IBM-Cloud/terraform-provider-ibm)

### Pre-commit Hooks

Run the following command to execute the pre-commit hooks defined in `.pre-commit-config.yaml` file

  `pre-commit run -a`

We can install pre-coomit tool using

  `pip install pre-commit`

## How to input varaible values through a file

To review the plan for the configuration defined (no resources actually provisioned)

`terraform plan -var-file=./input.tfvars`

To execute and start building the configuration defined in the plan (provisions resources)

`terraform apply -var-file=./input.tfvars`

To destroy the VPC and all related resources

`terraform destroy -var-file=./input.tfvars`

## NOTE :

* All optional fields should be given value `null` in respective resource varaible.tf file. User can configure the same by overwriting
  with appropriate values.

* If we want to make use of a particular version of module, then set the argument "version" to respective module version.

* Set the `archive_rule_enabled` argument to true only for regional cos bucket creation. For cross region and singleSite location set to
  false.

* To attach a key to cos instance, enbale it by setting `bind_resource_key` argument to true (which is by default false). And set the
  `resource_key_name` and `role` parameters accordingly (which are by deafult empty) in variables.tf file.
