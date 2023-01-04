// Tests in this file are run in the PR pipeline
package test

import (
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

const completeExampleTerraformDir = "examples/complete"
const completeExistingTerraformDir = "examples/existing-resources"

// Use existing group for tests
const resourceGroup = "geretain-test-cos-base"

var sharedInfoSvc *cloudinfo.CloudInfoService

// TestMain will be run before any parallel tests, used to set up a shared InfoService object to track region usage
// for multiple tests
func TestMain(m *testing.M) {
	sharedInfoSvc, _ = cloudinfo.NewCloudInfoServiceFromEnv("TF_VAR_ibmcloud_api_key", cloudinfo.CloudInfoServiceOptions{})

	os.Exit(m.Run())
}

func setupOptions(t *testing.T, prefix string, dir string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:                       t,
		TerraformDir:                  dir,
		Prefix:                        prefix,
		ResourceGroup:                 resourceGroup,
		CloudInfoService:              sharedInfoSvc,
		ExcludeActivityTrackerRegions: true,
	})

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
