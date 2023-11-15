# Bucket replication example

An example showing how to configure replication between two buckets.

Resources provisioned by this example:
- A new resource group, if existing one is not passed in.
- One target and one source Cloud Object Storage instance in the given resource group and region.
- One target and one source COS bucket.
- An IAM authorization policy to let the source instance write to the target bucket.
- A replication rule to copy everything from the source bucket to the target bucket.

- A Sysdig and Activity Tracker instance (if existing one is not passed in) in the given resource group and region.
- A Cloud Object Storage instance in the given resource group and region.
- An IAM auth policy to allow the COS instance read access to the given HPCS instance.
- A regional bucket with KYOK HPCS encryption, monitoring and activity tracking enabled
- A basic VPC and subnet.
- A Context Based Restriction (CBR) network zone containing the VPC.
- Context Based Restriction (CBR) rules to only allow the COS instance and bucket to be accessible from within VPC over the private endpoint.

This is a basic example with the COS instances and buckets in the same account, same resource group, and same region. Most use cases for replication will dictate different regions and/or accounts. This example uses a single rule to a single destination; other options are multiple rules, multiple destinations, selective replication, replication of deletes and bi-directional replication (add a rule to the target destination to write to the source).
