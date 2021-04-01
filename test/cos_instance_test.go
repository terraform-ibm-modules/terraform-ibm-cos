package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

// An example of how to test the Terraform module to create cos instance in examples/instance using Terratest.
func TestAccIBMCosInstance(t *testing.T) {
	t.Parallel()

	// Unique name for an isnatnce so we can distinguish it from any other cos instances provisioned in your IBM account
	expectedInstanceName := fmt.Sprintf("terratest-%s", strings.ToLower(random.UniqueId()))

	// Plan value
	expectedPlan := "standard"

	// resource group
	expectedResourceGroup := "Default"

	// Region
	expectedRegion := "global"

	// Construct the terraform options with default retryable errors to handle the most common retryable errors in
	// terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples/instance",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"service_name":   expectedInstanceName,
			"plan":           expectedPlan,
			"region":         expectedRegion,
			"resource_group": expectedResourceGroup,
		},
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	instanceID := terraform.Output(t, terraformOptions, "cos_instance_id")
	if len(instanceID) <= 0 {
		t.Fatal("Wrong output")
	}
	fmt.Println("COS INstance iD", instanceID)
}
