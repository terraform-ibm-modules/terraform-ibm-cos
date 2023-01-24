// Tests in this file are run in the PR pipeline
package test

import (
	"testing"

	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

const completeExampleTerraformDir = "examples/complete"
const completeExistingTerraformDir = "examples/existing-resources"

// Use existing group for tests
const resourceGroup = "geretain-test-cos-base"

const region = "us-south"

const activityTrackerCrn = "crn:v1:bluemix:public:logdnaat:eu-de:a/abac0df06b644a9cabc6e44f55b3880e:b1ef3365-dfbf-4d8f-8ac8-75f4f84d6f4a::"

var sharedInfoSvc *cloudinfo.CloudInfoService

func setupOptions(t *testing.T, prefix string, dir string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:          t,
		TerraformDir:     dir,
		Prefix:           prefix,
		ResourceGroup:    resourceGroup,
		Region:           region, // Not all regions provide cross region support so value must be hardcoded https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-service-availability.
		CloudInfoService: sharedInfoSvc,
		TerraformVars: map[string]interface{}{
			"existing_at_instance_crn": activityTrackerCrn,
		},
	})
	// completeExistingTerraformDir does not implement any activity tracker functionality
	if dir == completeExistingTerraformDir {
		options = testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
			Testing:          t,
			TerraformDir:     dir,
			Prefix:           prefix,
			ResourceGroup:    resourceGroup,
			Region:           region, // Not all regions provide cross region support so value must be hardcoded https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-service-availability.
			CloudInfoService: sharedInfoSvc,
		})
	}
	return options
}

func TestRunCompleteExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "cos-complete", completeExampleTerraformDir)
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunExistingResourcesExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "cos-existing", completeExistingTerraformDir)
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "cos-upgrade", completeExampleTerraformDir)

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}
