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
			"resource_group":              "Default",
			"configure_activity_tracker":  true,
			"is_new_activity_tracker":     true,
			"activity_tracker_name":       "at-19",
			"activity_tracker_plan":       "7-day",
			"activity_tracker_region":     "us-south",
			"configure_sysdig_monitoring": true,
			"is_new_sysdig_monitoring":    true,
			"sysdig_monitoring_name":      "sm-19",
			"sysdig_monitoring_plan":      "graduated-tier",
			"sysdig_monitoring_region":    "us-south",
			"cos_instance_name":           "cosInstance",
			"plan":                        "standard",
			"is_bind_resource_key":        false,
			"resource_key_name":           "resourcekey",
			"role":                        "Manager",
			"bucket_names":                []string{"atb", "logdnab"},
			"location":                    "jp-osa",
			"storage_class":               "standard",
			"force_delete":                true,
			"endpoint_type":               "public",
			"archive_rule_enabled":        false,
			"read_data_events":            true,
			"write_data_events":           true,
		},
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)
}
