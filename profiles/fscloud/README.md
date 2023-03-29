# Financial Services Cloud Profile

This is a profile for COS that meets FS Cloud requirements. This profile assumes you are deploying into an already compliant account.
It has been scanned by [IBM Code Risk Analyzer (CRA)](https://cloud.ibm.com/docs/code-risk-analyzer-cli-plugin?topic=code-risk-analyzer-cli-plugin-cra-cli-plugin#terraform-command) and meets all applicable goals with the following exceptions:
- 3000107 - Check whether Cloud Object Storage network access is restricted to a specific IP range
  - This is ignored because the CBR locks this down and CRA does not check this
- 3000116 - Check whether Cloud Object Storage bucket resiliency is set to cross region
  - This is ignored because cross-regional buckets and KYOK encryption (HPCS) are not compatible. The solution is to provision two buckets with replication in separate regions. This gives us
    cross region support and KYOK encryption but CRA does not pick this up.

## Note: If no Context Based Restriction(CBR) rules are passed, you must configure Context Based Restrictions externally to be compliant.
