// Tests in this file are run in the PR pipeline
package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

const resourceGroup = "geretain-test-resources"
const multipleBucketsExampleTerraformDir = "examples/complete-multiple-buckets"
const bucketWithoutTrackingExampleTerraformDir = "examples/bucket-without-tracking-monitoring"

func TestRunMultipleBucketsExample(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  multipleBucketsExampleTerraformDir,
		ResourceGroup: resourceGroup,
		Prefix:        "cos-module-buckets",
	})

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunBucketWithoutTrackingExample(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  bucketWithoutTrackingExampleTerraformDir,
		ResourceGroup: resourceGroup,
		Prefix:        "cos-module-wo-tracking",
	})

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}
