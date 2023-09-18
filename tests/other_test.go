package test

import (
	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

import (
	"testing"
)

const basicExampleTerraformDir = "examples/basic"
const oneRateExampleTerraformDir = "examples/one-rate-plan"

func TestRunBasicExample(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  basicExampleTerraformDir,
		Prefix:        "cos-basic",
		ResourceGroup: resourceGroup,
		Region:        region,
	})

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
