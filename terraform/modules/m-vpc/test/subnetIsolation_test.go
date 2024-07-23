package test

import (
	"bytes"
	"strings"
	"testing"

	"golang.org/x/crypto/ssh"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestSubnetIsolation(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/subnetIsolation",
		NoColor:      true,
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	outputs := terraform.OutputMap(t, terraformOptions, "main")

	sshKey := outputs["ssh_key"]
	ipPublic := outputs["ip_public"]
	ipPrivate := outputs["ip_private"]
	ipNatGw := outputs["ip_natgw"]
	ipIsolated := outputs["ip_isolated"]

	sshKey = strings.ReplaceAll(sshKey, `\n`, "\n")

	config, client, err := publicConnection(sshKey, ipPublic)
	assert.Nil(t, err)
	defer client.Close()

	// If the result of `curl ifconfig.co` matches the elastic-ip address
	// addressed to the instance, then success!
	publicIpFromCommand, err := publicCommand(client, "/usr/bin/curl ifconfig.co")
	assert.Nil(t, err)
	assert.Equal(t, ipPublic, publicIpFromCommand)

	// If the address of `curl ifconfig.co` matches the elastic-ip address
	// of the NAT Gateway, then our private-subnet's route to the internet
	// is correct.
	privateIpFromCommand, err := bastionedCommand(client, config, ipPrivate, "/usr/bin/curl ifconfig.co")
	assert.Nil(t, err)
	assert.Equal(t, ipNatGw, privateIpFromCommand)

	// Use /dev/tcp to start a connection to a google nameserver that should never go down.
	// If (as we hope) we get a '124' error code, then we can't reach this server.
	// Not reaching this server means we have no route to the internet.
	responseIsolatedFromCommand, err := bastionedCommand(client, config, ipIsolated, "/usr/bin/timeout 2 bash -c '</dev/tcp/8.8.8.8/53'; echo $?")
	assert.Nil(t, err)
	assert.Equal(t, "124", responseIsolatedFromCommand)

}

// This will run a command on a host directly (not using a bastion) and return the
// stdout from that command stripping the last \n(ewline)
func publicCommand(client *ssh.Client, command string) (string, error) {
	session, err := client.NewSession()
	if err != nil {
		return "", err
	}
	defer session.Close()

	var b bytes.Buffer
	session.Stdout = &b
	err = session.Run(command)
	return strings.TrimSuffix(b.String(), "\n"), err
}

// This will create a client connection over ssh from which commands can be run and
// the config that created it.
func publicConnection(sshKey string, ip string) (*ssh.ClientConfig, *ssh.Client, error) {

	signer, err := ssh.ParsePrivateKey([]byte(sshKey))
	if err != nil {
		return &ssh.ClientConfig{}, &ssh.Client{}, err
	}
	config := &ssh.ClientConfig{
		User: "ec2-user",
		Auth: []ssh.AuthMethod{
			ssh.PublicKeys(signer),
		},
		HostKeyCallback: ssh.InsecureIgnoreHostKey(),
	}

	conn, err := ssh.Dial("tcp", ip+":22", config)
	return config, conn, err
}

// This function will run commands on a target machine over a bastion connection and return the stdout stripping the last \n(ewline)
func bastionedCommand(bastion *ssh.Client, config *ssh.ClientConfig, targetAddress string, command string) (string, error) {
	// Build the ip:port address, Dial() it over the bastion's connection, and close the dail at the end of this function
	serviceAddress := targetAddress + ":22"
	clientConn, err := bastion.Dial("tcp", serviceAddress)
	if err != nil {
		return "", err
	}
	defer clientConn.Close()

	// Take the connection over the bastion, and the client to the target, and build a new Client over which we can start sessions
	ncc, chans, reqs, err := ssh.NewClientConn(clientConn, serviceAddress, config)
	if err != nil {
		return "", err
	}
	defer ncc.Close()
	targetClient := ssh.NewClient(ncc, chans, reqs)

	// Okay, finally, we've got a session on the target, over the bastion. Whew.
	targetSession, err := targetClient.NewSession()
	defer targetSession.Close()

	// Run the input comamnd and return whatever standard out had.
	var b bytes.Buffer
	targetSession.Stdout = &b
	err = targetSession.Run(command)
	return strings.TrimSuffix(b.String(), "\n"), err
}
