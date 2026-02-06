# Configuring the `backup_policies` input

The `backup_policies` input variable allows you to configure backup policies for your Cloud Object Storage bucket. Backup policies automatically copy objects from the source bucket to a backup vault for data protection and disaster recovery.

- Variable name: `backup_policies`.
- Type: A list of objects representing backup policies.
- Default value: An empty list (`[]`).
- Maximum: 3 backup policies per bucket.

### Prerequisites

- **Object Versioning**: The source bucket must have object versioning enabled (The `enable_object_versioning` input must be set to true).
- **Backup Vault**: You must have an existing backup vault with its CRN available.

### Options for backup_policies

Each backup policy object in the list requires the following attributes:

- `policy_name` (required): A unique name for the backup policy. Must be unique across all policies for this bucket.
  - Type: String
  - Example: `"daily-backup"`, `"weekly-backup"`

- `target_backup_vault_crn` (required): The CRN of the target backup vault where objects will be backed up. Must be unique across all policies for this bucket.
  - Type: String (CRN format)
  - Example: `"crn:v1:bluemix:public:cloud-object-storage:us-south:a/abcd1234:instance-id::backup-vault:vault-id"`

- `initial_delete_after_days` (required): The number of days after which backed-up objects will be automatically deleted from the backup vault.
  - Type: Number
  - Must be greater than 0
  - Example: `30`, `90`, `365`

### Validation Rules

1. **Maximum Policies**: A maximum of 3 backup policies can be configured per bucket.
2. **Unique Names**: Each backup policy must have a unique `policy_name`.
3. **Unique Vaults**: Each backup policy must target a unique `target_backup_vault_crn`.
4. **Positive Retention**: The `initial_delete_after_days` must be greater than 0.
5. **Versioning Required**: Object versioning must be enabled on the source bucket.

### Example Backup Policies Configuration

#### Single Backup Policy

```hcl
[
  {
    policy_name               = "daily-backup"
    target_backup_vault_crn   = "crn:v1:bluemix:public:cloud-object-storage:us-south:a/abcd1234abcd1234abcd1234abcd1234:1234abcd-1234-abcd-1234-abcd1234abcd::backup-vault:abcd1234-abcd-1234-abcd-1234abcd1234"
    initial_delete_after_days = 30
  }
]
```

This creates a single backup policy that retains backups for 30 days.

#### Multiple Backup Policies (Tiered Retention)

```hcl
[
  {
    policy_name               = "short-term-backup"
    target_backup_vault_crn   = "crn:v1:bluemix:public:cloud-object-storage:us-south:a/abcd1234abcd1234abcd1234abcd1234:1234abcd-1234-abcd-1234-abcd1234abcd::backup-vault:vault1-id"
    initial_delete_after_days = 30
  },
  {
    policy_name               = "medium-term-backup"
    target_backup_vault_crn   = "crn:v1:bluemix:public:cloud-object-storage:us-east:a/abcd1234abcd1234abcd1234abcd1234:5678efgh-5678-efgh-5678-efgh5678efgh::backup-vault:vault2-id"
    initial_delete_after_days = 90
  },
  {
    policy_name               = "long-term-backup"
    target_backup_vault_crn   = "crn:v1:bluemix:public:cloud-object-storage:eu-de:a/abcd1234abcd1234abcd1234abcd1234:9012ijkl-9012-ijkl-9012-ijkl9012ijkl::backup-vault:vault3-id"
    initial_delete_after_days = 365
  }
]
```

This creates a tiered backup strategy with three different retention periods across different backup vaults.
