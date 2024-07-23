package test

import (
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestScalableNatGateways(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/scalableNatGateways",
		NoColor:      true,
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	outputs := terraform.OutputMap(t, terraformOptions, "main")

	sshKey := outputs["ssh_key"]
	ipPublic := outputs["ip_public"]
	ipPrivate0 := outputs["ip_private0"]
	ipPrivate1 := outputs["ip_private1"]
	ipPrivate2 := outputs["ip_private2"]
	ipNatGw := outputs["ip_natgw"]

	sshKey = strings.ReplaceAll(sshKey, `\n`, "\n")

	config, client, err := publicConnection(sshKey, ipPublic)
	assert.Nil(t, err)
	defer client.Close()

	// If the address of `curl ifconfig.co` matches the elastic-ip address
	// of the NAT Gateway, then our private-subnet's route to the internet
	// is correct.
	for _, ip := range []string{ipPrivate0, ipPrivate1, ipPrivate2} {
		ipResponse, err := bastionedCommand(client, config, ip, "/usr/bin/curl ifconfig.co")
		assert.Nil(t, err)
		assert.Equal(t, ipNatGw, ipResponse)
	}

}
