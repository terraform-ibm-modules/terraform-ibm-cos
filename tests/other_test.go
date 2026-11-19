package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testaddons"
)

func TestRunBasicExample(t *testing.T) {
	t.Parallel()

	options := setupExampleOptions(t, "cos-basic", basicExampleTerraformDir)
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunReplicateExample(t *testing.T) {
	t.Parallel()

	options := setupExampleOptions(t, "cos-replicate", replicateExampleTerraformDir)
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

// Test regional bucket variation deployment with all "on-by-default" dependant DAs
func TestRegionalBucketAddonDefault(t *testing.T) {
	t.Parallel()

	options := testaddons.TestAddonsOptionsDefault(&testaddons.TestAddonOptions{
		Testing:       t,
		Prefix:        "reg-addon",
		ResourceGroup: resourceGroup,
		QuietMode:     true, // Suppress logs except on failure
	})
	options.AddonConfig = cloudinfo.NewAddonConfigTerraform(
		options.Prefix,
		"deploy-arch-ibm-cos",
		"regional-bucket-fully-configurable",
		map[string]interface{}{
			"bucket_name":                  "test",
			"existing_resource_group_name": resourceGroup,
		},
	)

	err := options.RunAddonTest()
	require.NoError(t, err)
}

// Test cross-regional bucket variation deployment with all "on-by-default" dependant DAs
func TestCrossRegionalBucketAddonDefault(t *testing.T) {
	t.Parallel()

	options := testaddons.TestAddonsOptionsDefault(&testaddons.TestAddonOptions{
		Testing:       t,
		Prefix:        "cr-addon",
		ResourceGroup: resourceGroup,
		QuietMode:     true, // Suppress logs except on failure
	})
	options.AddonConfig = cloudinfo.NewAddonConfigTerraform(
		options.Prefix,
		"deploy-arch-ibm-cos",
		"cross-regional-bucket-fully-configurable",
		map[string]interface{}{
			"bucket_name":                  "test",
			"existing_resource_group_name": resourceGroup,
		},
	)

	err := options.RunAddonTest()
	require.NoError(t, err)
}
