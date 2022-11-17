// Tests in this file are run in the PR pipeline
package test

import (
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

const resourceGroup = "geretain-test-resources"
const multipleBucketsExampleTerraformDir = "examples/complete-multiple-buckets"
const bucketWithoutTrackingExampleTerraformDir = "examples/bucket-without-tracking-monitoring"

// TestMain will be run before any parallel tests, used to set up a shared InfoService object to track region usage
// for multiple tests
func TestMain(m *testing.M) {
	sharedInfoSvc, _ = cloudinfo.NewCloudInfoServiceFromEnv("TF_VAR_ibmcloud_api_key", cloudinfo.CloudInfoServiceOptions{})

	os.Exit(m.Run())
}

func TestRunMultipleBucketsExample(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:                       t,
		TerraformDir:                  multipleBucketsExampleTerraformDir,
		ResourceGroup:                 resourceGroup,
		Prefix:                        "cos-module-buckets",
		CloudInfoService:              sharedInfoSvc,
		ExcludeActivityTrackerRegions: true,
	})

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunBucketWithoutTrackingExample(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:                       t,
		TerraformDir:                  bucketWithoutTrackingExampleTerraformDir,
		ResourceGroup:                 resourceGroup,
		Prefix:                        "cos-module-wo-tracking",
		CloudInfoService:              sharedInfoSvc,
		ExcludeActivityTrackerRegions: true,
	})

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}
