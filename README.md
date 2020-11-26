# IBM COS Bucket Terraform Module

This is a collection of modules that make it easier to provision a cloud object stoarge on IBM Cloud Platform:
* [COS Instance](modules/cos_instance)
* [COS Bucket](modules/cos_bucket)

## Compatibility

This module is meant for use with Terraform 0.12. If you haven't
[upgraded][terraform-0.12-upgrade] and need a Terraform 0.11.x-compatible
version of this module, the last released version intended for Terraform 0.11.x
is [1.1.1][v1.1.1].

## Usage

Full examples are in the [examples](./examples/) folder, but basic usage is as follows for creation of COS instance:

```hcl
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

Creation of cloud object storage bucket:

```hcl
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

## Requirements

### Terraform plugins

- [Terraform](https://www.terraform.io/downloads.html) 0.12
- [terraform-provider-ibm](https://github.com/IBM-Cloud/terraform-provider-ibm) 

## Install

### Terraform

Be sure you have the correct Terraform version (0.12), you can choose the binary here:
- https://releases.hashicorp.com/terraform/

### Terraform plugins

Be sure you have the compiled plugins on $HOME/.terraform.d/plugins/

- [terraform-provider-ibm](https://github.com/IBM-Cloud/terraform-provider-ibm) 
