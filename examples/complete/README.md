# Complete Example (multiple COS Buckets with retention, encryption, tracking and monitoring enabled)

An end-to-end example that will:
- Create a new resource group (if existing one is not passed in).
- Create Sysdig and Activity Tracker instances in the given resource group and region.
- Create a new Key Protect instance (with metrics enabled), Key Ring, and Key in the given resource group and region.
- Create a new Cloud Object Storage instance in the given resource group and region.
- Create an IAM Access Policy to allow Key Protect to access COS instance.
- Create COS bucket-1 with:
  - Encryption
  - Monitoring
  - Activity Tracking
- Create COS bucket-2 with:
  - Cross Region Location
  - Encryption
  - Monitoring
  - Activity Tracking
- Create a Sample VPC.
- Create Context Based Restriction(CBR) to only allow buckets to be accessible from the VPC.
