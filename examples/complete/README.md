# Complete Example (multiple COS Buckets with retention, encryption, tracking and monitoring enabled)

This example creates the following infrastructure:
- A new resource group, if one is not passed in.
- A Sysdig and Activity Tracker instances in a resource group and region.
- A new Key Protect instance (with metrics enabled), Key Ring, and Key in a resource group and region.
- A new Cloud Object Storage instance in a resource group and region.
- An IAM Access Policy to allow Key Protect to access COS instance.
- COS bucket-1 with:
  - Encryption
  - Monitoring
  - Activity Tracking
- COS bucket-2 with:
  - Cross Region Location
  - Encryption
  - Monitoring
  - Activity Tracking
- A sample VPC.
- A Context Based Restriction(CBR) to only allow buckets to be accessible from the VPC.
