# Cloud Object Storage for IBM Cloud - Financial Services Cloud solution

This architecture creates an Cloud Object Storage(COS) and bucket on IBM Cloud® and supports provisioning the following resources:

- A resource group, if one is not passed in.
- A Cloud Object Storage(COS) for IBM Cloud, set up with
    - KMS encryption to encrypt data
    - Monitoring and Activity Tracking to capture information regarding the events in the COS.
- Context Based Restriction rules for the instance and buckets

![da-fscloud](https://github.com/terraform-ibm-modules/terraform-ibm-cos/tree/main/reference-architecture/secure-cloud-object-storage.svg)
