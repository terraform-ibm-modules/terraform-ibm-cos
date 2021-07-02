package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

// An example of how to test the Terraform module to create cos instance in examples/instance using Terratest.
func TestAccIBMCosBucket(t *testing.T) {
	t.Parallel()

	// Construct the terraform options with default retryable errors to handle the most common retryable errors in
	// terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples/configure-bucket",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"location":                "jp-osa",
			"resource_group":          "default",
			"activity_tracker_name":   "atInstance",
			"activity_tracker_plan":   "7-day",
			"activity_tracker_region": "us-south",
			"archive_rule_enabled":    false,
			"cos_instance_name":       "cosInstance",
			"cos_plan":                "standard",

			"cos_location":      "global",
			"storage_class":     "standard",
			"force_delete":      true,
			"endpoint_type":     "public",
			"role":              "Manager",
			"resource_key_name": "resourcekey",
			"bucket_names":      []string{"atb", "logdnab"},
		},
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	/*instanceID := terraform.Output(t, terraformOptions, "cos_instance_id")
	if len(instanceID) <= 0 {
		t.Fatal("Wrong output")
	}
	fmt.Println("COS INstance iD", instanceID)*/
}
