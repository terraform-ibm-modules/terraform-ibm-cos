output "buckets" {
  description = "Map of buckets created in the Cloud Object Storage Instance"
  value       = local.exisiting_buckets_map
}
