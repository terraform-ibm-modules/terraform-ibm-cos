output "replicated_bucket" {
  description = "Replicated buckets, the origin bucket, the destination bucket and all replication rules"
  value = {
    origin_bucket      = module.cos_origin_bucket
    destination_bucket = module.cos_destination_bucket
    replication_rules  = merge(module.origin_rules, module.reverse_rules)
  }
}
