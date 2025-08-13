##############################################################################
# Input Variables for Secure COS Bucket Demo DA
##############################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key to deploy resources."
  sensitive   = true
}

variable "bucket_name" {
  type        = string
  description = "The name for the secure COS bucket. A random suffix will be added automatically."
}

variable "existing_cos_instance_crn" {
  type        = string
  description = "The CRN of the existing COS instance where the bucket will be created."
}

variable "existing_kms_key_crn" {
  type        = string
  description = "The CRN of the existing KMS key for bucket encryption."
}
