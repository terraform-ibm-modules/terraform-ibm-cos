output "replicated_bucket" {
  description = "Replicated bucket, source bucket, target bucket and replication rules"
  value       = {
    source_bucket = module.cos_source_bucket
    target_bucket = module.cos_target_bucket
    replication_rules = [
      ibm_cos_bucket_replication_rule.cos_replication_rule
    ]
  }
}
