# One Rate plan example

A simple example that shows how to provision an IBM Cloud Object Storage One Rate plan instance and an Object Storage bucket with One Rate Active storage.

:exclamation: **Important:** The Active storage class is available only with One Rate plans. You can't use it with Standard or Lite plans.

The following resources are provisioned by this example:

- A new resource group, if an existing one is not passed in.
- A One Rate plan Object Storage instance in the given resource group and region.
- A One Rate Active storage plan regional bucket.

## Note:

To run this example, you have to set the values for the environment variables being used in variables.tf or can pass them at the time of running the example.