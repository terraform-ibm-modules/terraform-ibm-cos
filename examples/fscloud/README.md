# Financial Services Cloud Profile example

## *Note:* This example is only deploying COS in a compliant manner the other infrastructure is not necessarily compliant. The account deployed onto would also need to be compliant for a fully compliant solution.

### Requirements
This example expects you have Hyper Protect Crypto Service instances in the two regions you wish to deploy your primary and secondary buckets.
And a root key available to use for bucket encryption in each.

### Deploys
An end-to-end example:
- Create a new resource group
- Create Sysdig and Activity Tracker instances in the given resource group and region.
- Create a new Cloud Object Storage instance in the given resource group and region.
- Create an IAM Access Policy to allow Hyper protect to access COS instance.
- Two Buckets Primary and Secondary in separate regions with replication enabled
  - Create Primary COS bucket with:
    - Retention
    - Encryption (KYOK Hyper Protect Crypto Service)
    - Monitoring
    - Activity Tracking
  - Create Secondary COS bucket with:
    - Retention
    - Encryption (KYOK Hyper Protect Crypto Service)
    - Monitoring
    - Activity Tracking
- Create a Sample VPC.
- Create Context Based Restriction(CBR) to only allow buckets to be accessible from the VPC.
