package test

import "github.com/stretchr/testify/assert"

import (
	"testing"
)

func TestRunBasicExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "cos-basic", basicExampleTerraformDir)
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}
