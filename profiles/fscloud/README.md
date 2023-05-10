# Profile for IBM Cloud Framework for Financial Services

This code is a version of the [parent root module](../../) that includes a default configuration that complies with the relevant controls from the [IBM Cloud Framework for Financial Services](https://cloud.ibm.com/docs/framework-financial-services?topic=framework-financial-services-about). See the [Example for IBM Cloud Framework for Financial Services](/examples/fscloud/) for logic that uses this module. The profile assumes you are deploying into an account that is in compliance with the framework.

The default values in this profile were scanned by [IBM Code Risk Analyzer (CRA)](https://cloud.ibm.com/docs/code-risk-analyzer-cli-plugin?topic=code-risk-analyzer-cli-plugin-cra-cli-plugin#terraform-command) for compliance with the IBM Cloud Framework for Financial Services profile that is specified by the IBM Security and Compliance Center. The scan passed for all applicable goals with the following exceptions:

> 3000107 - Check whether Cloud Object Storage network access is restricted to a specific IP range

The rule is ignored because it is covered by the context-based restriction rule. CRA does not check the rule.

> 3000116 - Check whether Cloud Object Storage bucket resiliency is set to cross region

This is ignored because cross-regional buckets and keep-your-own-key (KYOK) encryption (HPCS) are not compatible. The solution is to provision two buckets with replication in separate regions. This solution gives you cross-region support and KYOK encryption. CRA does not validate the rule.

The IBM Cloud Framework for Financial Services mandates the application of an inbound network-based allowlist in front of the IBM Cloud Object Storage instance. You can comply with this requirement in the following ways:

- Use the `allowlist` variable in the module (legacy method).
- Use the `cbr_rules` variable in the module, which creates a narrow context-based restriction rule that is scoped to the ICD PostgreSQL instance.
- Create a context-based restriction rule through the [https://github.com/terraform-ibm-modules/terraform-ibm-cbr](terraform-ibm-cbr) module. For example, create a rule to cover all IBM Cloud Databases for PostgreSQL instances in the account. For more information, see [What are context-based restrictions?](https://cloud.ibm.com/docs/account?topic=account-context-restrictions-whatis) in the IBM Cloud Docs.
