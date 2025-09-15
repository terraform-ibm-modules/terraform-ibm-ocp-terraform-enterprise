// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"crypto/rand"
	"encoding/base64"
	"fmt"
	"log"
	"os"
	"testing"

	"github.com/IBM/go-sdk-core/v5/core"
	"github.com/IBM/secrets-manager-go-sdk/v2/secretsmanagerv2"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"

// Ensure every example directory has a corresponding test
const completeExampleDir = "examples/complete"

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

	// get the license from a secrets manager, fail test if error
	license, licenseErr := getLicenseString()
	require.NoError(t, licenseErr)

	// generate a random password, fail if error
	pass, passErr := getRandomAdminPassword()
	require.NoError(t, passErr)

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  dir,
		Prefix:        prefix,
		ResourceGroup: resourceGroup,
		TerraformVars: map[string]interface{}{
			"tfe_license":    *license,
			"admin_password": *pass,
			"add_to_catalog": false,
		},
	})
	return options
}

// Consistency test for the complete example
func TestRunCompleteExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "tfe-complete", completeExampleDir)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

// Upgrade test (using complete example)
func TestRunUpgradeExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "tfe-complete-upg", completeExampleDir)

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func getLicenseString() (*string, error) {
	secMgrId := permanentResources["secretsManagerGuid"].(string)
	secMgrRegion := permanentResources["secretsManagerRegion"].(string)
	licenseSecretId := permanentResources["terraform_enterprise_license_secret_id"].(string)

	secretSvc, secretSvcErr := secretsmanagerv2.NewSecretsManagerV2(&secretsmanagerv2.SecretsManagerV2Options{
		URL: fmt.Sprintf("https://%s.%s.secrets-manager.appdomain.cloud", secMgrId, secMgrRegion),
		Authenticator: &core.IamAuthenticator{
			ApiKey: os.Getenv("TF_VAR_ibmcloud_api_key"),
		},
	})

	if secretSvcErr != nil {
		return nil, secretSvcErr
	}

	licenseSecret, _, getLicenseErr := secretSvc.GetSecret(&secretsmanagerv2.GetSecretOptions{
		ID: core.StringPtr(licenseSecretId),
	})

	if getLicenseErr != nil {
		return nil, getLicenseErr
	}

	license := licenseSecret.(*secretsmanagerv2.ArbitrarySecret).Payload

	return license, nil
}

func getRandomAdminPassword() (*string, error) {
	// Generate a 15 char long random string for the admin_pass
	randomBytes := make([]byte, 13)
	_, randErr := rand.Read(randomBytes)
	if randErr != nil {
		return nil, randErr
	} // do not proceed if we can't gen a random password

	randomPass := "A1" + base64.URLEncoding.EncodeToString(randomBytes)[:13]
	return core.StringPtr(randomPass), nil
}
