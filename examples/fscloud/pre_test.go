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

	// Validate the Cloud Object Storage instance creation.
	bucketModuleID := terraform.Output(t, terraformOptions, "cos_instance_id")
	assert.NotEmpty(t, bucketModuleID, "COS instance ID should not be empty")
}
