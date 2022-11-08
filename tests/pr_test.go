// Tests in this file are run in the PR pipeline
package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

// const completeExampleTerraformDir = "examples/complete"
// TODO: Move back to complete example once observability and keyprotect modules are available
const bucketWOMonitoringExampleTerraformDir = "examples/bucket-without-tracking-monitoring"

const resourceGroup = "geretain-test-resources"

func TestRunDefaultExample(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  bucketWOMonitoringExampleTerraformDir,
		ResourceGroup: resourceGroup,
		Prefix:        "cos-base-module",
	})

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeExample(t *testing.T) {
	t.Parallel()

	// TODO: Remove this line after the first merge to master branch is complete to enable upgrade test
	t.Skip("Skipping upgrade test until initial code is in master branch")

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  bucketWOMonitoringExampleTerraformDir,
		ResourceGroup: resourceGroup,
		Prefix:        "cos-base-module-upg",
	})

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}
