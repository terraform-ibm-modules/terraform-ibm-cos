# COS Bucket without encryption using an existing COS instance and Key Protect instance + Keys

An end-to-end example that will:
- Create a new resource group (if existing one is not passed in).
- Create a new Key Protect instance, Key Ring, and Key in the given resource group and region outside of the terraform-ibm-cos module.
- Create a new Cloud Object Storage instance in the given resource group and region outside of the terraform-ibm-cos module.
- Create an IAM Access Policy to allow Key Protect to access COS instance (outside of the terraform-ibm-cos module).
- Using the terraform-ibm-cos module, create a COS Bucket without encryption using the existing COS instance, Key Protect instance + Keys created at the start of this example.
