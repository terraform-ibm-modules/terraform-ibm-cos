# Configuring complex inputs in IBM Cloud Object Storage in IBM Cloud projects
Several optional input variables in the IBM Cloud Object Storage [deployable architecture](https://cloud.ibm.com/catalog#deployable_architecture) use complex object types. You specify these inputs when you configure your deployable architecture.

- [Resource keys](#resource-keys) (`resource_keys`)
- [Service credential secrets](#service-credential-secrets) (`service_credential_secrets`)

## Resource keys <a name="resource-keys"></a>
When you add an IBM Cloud Object Storage service from the IBM Cloud catalog to an IBM Cloud Projects service, you can configure resource keys. In the edit mode for the projects configuration, select the Configure panel and then click the optional tab.

In the configuration, specify the name of the resource key, whether HMAC credentials should be included, the Role of the key and an optional Service ID CRN to create with a Service ID.

To enter a custom value, use the edit action to open the "Edit Array" panel. Add the resource key configurations to the array here.

 [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_key) about resource keys.

- Variable name: `resource_keys`.
- Type: A list of objects that represent a resource key
- Default value: An empty list (`[]`)

### Options for resource_key

- `name` (required): A unique human-readable name that identifies this resource key.
- `generate_hmac_credentials` (optional, default = `false`): Set to true to include COS HMAC keys in the resource key. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_key#example-to-create-by-using-hmac).
- `role` (optional, default = `Reader`): The name of the user role.
- `service_id_crn` (optional, default = `null`): Pass a Service ID CRN to create credentials for a resource with a Service ID. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_key#example-to-create-by-using-serviceid).

The following example includes all the configuration options for two resource keys. One is a key with a `Reader` role, the other with a `Writer` role.
```hcl
    [
      {
        "name": "da-reader-resource-key",
        "generate_hmac_credentials": "false",
        "role": "Reader",
        "service_id_crn": null
      },
      {
        "name": "da-writer-resource-key",
        "role": "Writer"
      }
    ]
```

## Service credential secrets <a name="service-credential-secrets"></a>
When you add an IBM Cloud Object Storage service from the IBM Cloud catalog to an IBM Cloud Projects service, you can configure service credentials. In the edit mode for the projects configuration, select the Configure panel and then click the optional tab.

In the configuration, specify the secret group name, whether it already exists or will be created and include all the necessary service credential secrets that need to be created within that secret group.

To enter a custom value, use the edit action to open the "Edit Array" panel. Add the service credential secrets configurations to the array here.

 [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/sm_service_credentials_secret) about service credential secrets.

- Variable name: `service_credential_secrets`.
- Type: A list of objects that represent a service credential secret groups and secrets
- Default value: An empty list (`[]`)

### Options for service_credential_secrets

- `secret_group_name` (required): A unique human-readable name that identifies this service credential secret group.
- `secret_group_description` (optional, default = `null`): A human-readable description for this secret group.
- `existing_secret_group`: (optional, default = `false`): Set to true, if secret group name provided in the variable `secret_group_name` already exists.
- `service_credentials`: (optional, default = `[]`): A list of object that represents a service credential secret.

### Options for service_credentials

- `secret_name`: (required): A unique human-readable name of the secret to create.
- `service_credentials_source_service_role_crn`: (required): The CRN of the role to give the service credential in the COS service. Service credentials role CRNs can be found at https://cloud.ibm.com/iam/roles, select Cloud Object Storage and select the role.
- `secret_labels`: (optional, default = `[]`): Labels of the secret to create. Up to 30 labels can be created. Labels can be 2 - 30 characters, including spaces. Special characters that are not permitted include the angled brackets (<>), comma (,), colon (:), ampersand (&), and vertical pipe character (|).
- `secret_auto_rotation`: (optional, default = `true`): Whether to configure automatic rotation of service credential.
- `secret_auto_rotation_unit`: (optional, default = `day`): Specifies the unit of time for rotation of a secret. Acceptable values are `day` or `month`.
- `secret_auto_rotation_interval`: (optional, default = `89`): Specifies the rotation interval for the rotation unit.
- `service_credentials_ttl`: (optional, default = `7776000`): The time-to-live (TTL) to assign to generated service credentials (in seconds).
- `service_credential_secret_description`: (optional, default = `null`): Description of the secret to create.

The following example includes all the configuration options for four service credentials and two secret groups.
```hcl
[
  {
    "secret_group_name": "sg-1"
    "existing_secret_group": true
    "service_credentials": [
      {
        "secret_name": "cred-1"
        "service_credentials_source_service_role_crn": "crn:v1:bluemix:public:iam::::serviceRole:Reader"
        "secret_labels": ["test-reader-1", "test-reader-2"]
        "secret_auto_rotation": true
        "secret_auto_rotation_unit": "day"
        "secret_auto_rotation_interval": 89
        "service_credentials_ttl": 7776000
        "service_credential_secret_description": "sample description"
      },
      {
        "secret_name": "cred-2"
        "service_credentials_source_service_role_crn": "crn:v1:bluemix:public:iam::::serviceRole:Writer"
      }
    ]
  },
  {
    "secret_group_name": "sg-2"
    "service_credentials": [
      {
        "secret_name": "cred-3"
        "service_credentials_source_service_role_crn": "crn:v1:bluemix:public:iam::::serviceRole:Manager"
      },
      {
        "secret_name": "cred-4"
        "service_credentials_source_service_role_crn": "crn:v1:bluemix:public:cloud-object-storage::::serviceRole:ContentReader"
      }
    ]
  }
]
```
