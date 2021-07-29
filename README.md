# IBM COS Bucket Terraform Module

This is a collection of modules that make it easier to provision a cloud object stoarge on IBM Cloud Platform:

* instance
* bucket

## Compatibility

This module is meant for use with Terraform 0.13 (and higher).

## Usage

Full examples are in the [examples](./examples/) folder, but basic usage is as follows for creation of COS instance:


```hcl
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

Creation of cloud object storage bucket:

```hcl
provider "ibm" {
  region = var.location
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
  // Uncommnet the following line to point the source to registry level
  //source                 = "terraform-ibm-modules/cos/ibm//modules/instance"

  source                 = "../../modules/instance"
  provision_cos_instance = true
  service_name           = var.cos_instance_name
  resource_group_id      = data.ibm_resource_group.group.id
  plan                   = var.cos_plan
  region                 = var.cos_location
}


module "cos_bucket" {

  // Uncommnet the following line to point the source to registry level
  //source               = "terraform-ibm-modules/cos/ibm//modules/bucket"

  source               = "../../modules/bucket"
  count                = length(local.bucket_list)
  bucket_name          = local.bucket_list[count.index]
  cos_instance_id      = module.cos.cos_instance_id
  location             = var.location
  storage_class        = var.storage_class
  force_delete         = var.force_delete
  endpoint_type        = var.endpoint_type
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

## Requirements

### Terraform plugins

- [Terraform](https://www.terraform.io/downloads.html) 0.13 (or later)
- [terraform-provider-ibm](https://github.com/IBM-Cloud/terraform-provider-ibm)

## Install

### Terraform

Be sure you have the correct Terraform version (0.13), you can choose the binary here:
- https://releases.hashicorp.com/terraform/

### Terraform plugins

Be sure you have the compiled plugins on $HOME/.terraform.d/plugins/

- [terraform-provider-ibm](https://github.com/IBM-Cloud/terraform-provider-ibm)

### Pre-commit hooks

Run the following command to execute the pre-commit hooks defined in .pre-commit-config.yaml file
```
pre-commit run -a
```
You can install pre-coomit tool using

```
pip install pre-commit
```
or
```
pip3 install pre-commit
```
## How to input varaible values through a file

To review the plan for the configuration defined (no resources actually provisioned)
```
terraform plan -var-file=./input.tfvars
```
To execute and start building the configuration defined in the plan (provisions resources)
```
terraform apply -var-file=./input.tfvars
```

To destroy the VPC and all related resources
```
terraform destroy -var-file=./input.tfvars
```

## Note

All optional parameters, by default, will be set to `null` in respective example's varaible.tf file. You can also override these optional parameters.
