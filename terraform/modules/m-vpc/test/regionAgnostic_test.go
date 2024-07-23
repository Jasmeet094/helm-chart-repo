package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestRegionAgnostic(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/regionAgnostic",
		NoColor:      true,
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// There are no assertions in this test as merely the ability to successfully terraform-apply suffices
}
