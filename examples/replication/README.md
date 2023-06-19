# Cloud Object Storage replication example

An end-to-end example that will the following infrastructure:
- A new resource group (if existing one is not passed in).
- A new Cloud Object Storage instances in the given resource group and region.
- A COS source bucket with versioning
- A COS target bucket with versioning
- An IAM authorization policy to let the source instance write to the target bucket
- A rule to copy everything from the source bucket to the target bucket

This is a basic example with the COS instances and buckets in the same account, same resource group and same region. Most use cases for replication will dictate different regions and/or accounts. This example uses a single rule to a single destination; other options are multiple rules, multiple destinations, selective replication, replication of deletes and bi-directional replication (add a rule to the target destination to write to the source).
