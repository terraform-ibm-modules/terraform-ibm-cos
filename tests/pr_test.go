// Tests in this file are run in the PR pipeline
package test

import (
	"log"
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"gopkg.in/yaml.v3"
)

const completeExampleTerraformDir = "examples/complete"
const fsCloudTerraformDir = "examples/fscloud"
const completeExistingTerraformDir = "examples/existing-resources"
const replicateExampleTerraformDir = "examples/replication"

// Use existing group for tests
const resourceGroup = "geretain-test-cos-base"

// Not all regions provide cross region support so value must be hardcoded https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-service-availability.
const region = "us-south"

// Define a struct with fields that match the structure of the YAML data
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

type Config struct {
	ExistingAccessTags []string `yaml:"accessTags"`
}

var permanentResources map[string]interface{}
var existingAccessTags []string

// TestMain will be run before any parallel tests, used to read data from yaml for use with tests
func TestMain(m *testing.M) {
	permanentResources, err := os.ReadFile(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}
	// Create a struct to hold the YAML data
	var config Config
	// Unmarshal the YAML data into the struct
	err = yaml.Unmarshal(permanentResources, &config)
	if err != nil {
		log.Fatal(err)
	}
	// Parse the existing access tags from data
	existingAccessTags = config.ExistingAccessTags

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
			"access_tags":              existingAccessTags,
		},
	})
	// completeExistingTerraformDir does not implement any activity tracker functionality
	if dir == completeExistingTerraformDir || dir == replicateExampleTerraformDir {
		options = testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
			Testing:       t,
			TerraformDir:  dir,
			Prefix:        prefix,
			ResourceGroup: resourceGroup,
			Region:        region,
			TerraformVars: map[string]interface{}{
				"access_tags": existingAccessTags,
			},
		})
	} else if dir == fsCloudTerraformDir {
		options = testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
			Testing:       t,
			TerraformDir:  dir,
			Prefix:        prefix,
			ResourceGroup: resourceGroup,
			Region:        region,
			TerraformVars: map[string]interface{}{
				"existing_at_instance_crn": permanentResources["activityTrackerFrankfurtCrn"],
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

func TestRunFSCloudExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "cos-fscloud", fsCloudTerraformDir)
	options.TerraformVars["primary_existing_hpcs_instance_guid"] = permanentResources["hpcs_south"]
	options.TerraformVars["primary_hpcs_key_crn"] = permanentResources["hpcs_south_root_key_crn"]
	options.TerraformVars["secondary_existing_hpcs_instance_guid"] = permanentResources["hpcs_east"]
	options.TerraformVars["secondary_hpcs_key_crn"] = permanentResources["hpcs_east_root_key_crn"]
	options.TerraformVars["existing_at_instance_crn"] = permanentResources["activityTrackerFrankfurtCrn"]
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
