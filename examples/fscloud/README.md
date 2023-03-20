# Financial Services Cloud Profile example

## *Note:* This example is only deploying COS in a compliant manner the other infrastructure is not necessarily compliant.
### Keyprotect is being used in the example but for FS Cloud compliance Hyper Protect Crypto Service should be used

An end-to-end example that will:
- Create a new resource group
- Create Sysdig and Activity Tracker instances in the given resource group and region.
- Create a new Key Protect instance (with metrics enabled), Key Ring, and Key in the given resource group and region.
- Create a new Cloud Object Storage instance in the given resource group and region.
- Create an IAM Access Policy to allow Key Protect to access COS instance.
- Create COS bucket with:
  - Retention
  - Cross Region Location
  - Encryption
  - Monitoring
  - Activity Tracking
- Create a Sample VPC.
- Create Context Based Restriction(CBR) to only allow buckets to be accessible from the VPC.
