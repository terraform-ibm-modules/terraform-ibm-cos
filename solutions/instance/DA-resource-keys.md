# Configuring resource keys in IBM Cloud Object Storage in IBM Cloud projects

When you add an IBM Cloud Object Storage service from the IBM Cloud catalog to an IBM Cloud Projects service, you can configure resource keys. In the edit mode for the projects configuration, select the Configure panel and then click the optional tab.

In the configuration, specify the name of the resource key, whether HMAC credentials should be included, the Role of the key and an optional Service ID CRN to create with a Service ID.

To enter a custom value, use the edit action to open the "Edit Array" panel. Add the resource key configurations to the array here.

 [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_key) about resource keys.


## Options
### Resource key options

- `name` (required): A unique human-readable name that identifies this resource key.
- `generate_hmac_credentials` (optional, default = `false`): Set to true to include COS HMAC keys in the resource key. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_key#example-to-create-by-using-hmac).
- `role` (optional, default = `Reader`): The name of the user role.
- `service_id_crn` (optional, default = `null`): Pass a Service ID CRN to create credentials for a resource with a Service ID. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_key#example-to-create-by-using-serviceid).

The following example includes all the configuration options for two resource keys. One is a key with a `Reader` role, the other with a `Writer` role.

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
