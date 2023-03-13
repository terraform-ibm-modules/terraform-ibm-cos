output "buckets" {
  description = "Buckets"
  value       = module.cos_bucket1.buckets
}

output "cross_region_buckets" {
  description = "Cross regional buckets"
  value       = module.cos_bucket2.buckets
}
