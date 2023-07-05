# Financial Services Cloud Profile example

An end-to-end example that uses the [Profile for IBM Cloud Framework for Financial Services](../../modules/fscloud/) to deploy an instance of IBM Cloud Storage.

An end-to-end example that uses the IBM Cloud Terraform provider to create the following infrastructure:

- A resource group, if one is not passed in.
- A Sysdig instance and Activity Tracker instance (unless an Activity Tracker instance CRN is passed in) in the resource group and region.
- A IBM Cloud Object Storage instance in the resource group and region.
- An IAM access policy to allow Hyper Protect Crypto Services to access the Cloud Object Storage instance.
- Two buckets, primary and secondary, in separate regions, with replication enabled.
    - Primary Cloud Object Storage bucket configuration:
        - Retention
        - Encryption (KYOK Hyper Protect Crypto Service)
        - Monitoring
        - Activity tracking
    - Secondary Cloud Object Storage bucket configuration:
        - Retention
        - Encryption (KYOK Hyper Protect Crypto Service)
        - Monitoring
        - Activity tracking
- A sample virtual private cloude (VPC).
- A context-based restriction (CBR) rule to prevent access from the VPC except to the database buckets.

:exclamation: **Important:** In this example, only the IBM Cloud Object Storage instance complies with the IBM Cloud Framework for Financial Services. Other parts of the infrastructure do not necessarily comply.

## Before you begin

Before you run the example, make sure that you set up the following prerequisites.

- You need Hyper Protect Crypto Service instances available in the two regions that you want to deploy your primary and secondary buckets.
- You need a root key that is available to use for bucket encryption in each region.
