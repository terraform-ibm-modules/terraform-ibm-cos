moved {
  from = module.secrets_manager_service_credentials
  to   = module.secrets_manager_service_credentials[0]
}

moved {
  from = ibm_iam_authorization_policy.policy
  to   = ibm_iam_authorization_policy.secrets_manager_key_manager
}
