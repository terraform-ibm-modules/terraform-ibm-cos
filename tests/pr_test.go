// Tests in this file are run in the PR pipeline
package test

import (
	"log"
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

const completeExampleTerraformDir = "examples/complete"
const fsCloudTerraformDir = "examples/fscloud"
const completeExistingTerraformDir = "examples/existing-resources"
const replicateExampleTerraformDir = "examples/replication"
const oneRateExampleTerraformDir = "examples/one-rate-plan"
const basicExampleTerraformDir = "examples/basic"

// Use existing group for tests
const resourceGroup = "geretain-test-cos-base"

// Not all regions provide cross region support so value must be hardcoded https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-service-availability.
const region = "us-south"

// Define a struct with fields that match the structure of the YAML data
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

var permanentResources map[string]interface{}

// TestMain will be run before any parallel tests, used to read data from yaml for use with tests
func TestMain(m *testing.M) {

	var err error
	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}

	os.Exit(m.Run())
}

func setupOptions(t *testing.T, prefix string, dir string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  dir,
		Prefix:        prefix,
		ResourceGroup: resourceGroup,
		Region:        region,
		TerraformVars: map[string]interface{}{
			"existing_at_instance_crn": permanentResources["activityTrackerFrankfurtCrn"],
			"access_tags":              permanentResources["accessTags"],
		},
	})
	// below dirs do not implement Activity Tracker functionality
	if dir == completeExistingTerraformDir || dir == replicateExampleTerraformDir || dir == oneRateExampleTerraformDir {
		options = testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
			Testing:       t,
			TerraformDir:  dir,
			Prefix:        prefix,
			ResourceGroup: resourceGroup,
			Region:        region,
			TerraformVars: map[string]interface{}{
				"access_tags": permanentResources["accessTags"],
			},
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

func TestRunOneRateExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "one-rate-plan", oneRateExampleTerraformDir)
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunFSCloudExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "cos-fscloud", fsCloudTerraformDir)
	options.TerraformVars["primary_existing_hpcs_instance_guid"] = permanentResources["hpcs_south"]
	options.TerraformVars["primary_hpcs_key_crn"] = permanentResources["hpcs_south_root_key_crn"]
	options.TerraformVars["secondary_existing_hpcs_instance_guid"] = permanentResources["hpcs_east"]
	options.TerraformVars["secondary_hpcs_key_crn"] = permanentResources["hpcs_east_root_key_crn"]
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

func TestRunReplicateExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "cos-replicate", replicateExampleTerraformDir)
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
