// test.go
package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformModule(t *testing.T) {
	terraformOptions := &terraform.Options{
		// Set the path to the Terraform code that will be tested.
		TerraformDir: "./",
	}

	// Terraform init and apply. The t.Parallel() allows multiple tests to run in parallel.
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate the Cloud Object Storage source bucket creation
	sourceBucketModuleID := terraform.Output(t, terraformOptions, "source_bucket_name")
	assert.NotEmpty(t, sourceBucketModuleID, "Source bucket should not be empty")

	// Validate the Cloud Object Storage source bucket creation
	targetBucketModuleID := terraform.Output(t, terraformOptions, "target_bucket_name")
	assert.NotEmpty(t, targetBucketModuleID, "Target bucket should not be empty")

}
