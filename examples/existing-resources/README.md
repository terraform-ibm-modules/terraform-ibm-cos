# Create Cloud Object Storage instance and a bucket

An end-to-end example that will create the following infrastructure:
- A new resource group, if one is not passed in.
- A Key Protect instance, key ring, and key in a resource group and region.
- An IAM access policy to allow Cloud Object Storage to access Key Protect for the encryption key.
- A Cloud Object Storage instance with no buckets in a resource group and region.
    This example uses the code in the main `terraform-ibm-cos` module.
- Cloud Object Storage buckets with encryption, versioning and archiving respectively.
