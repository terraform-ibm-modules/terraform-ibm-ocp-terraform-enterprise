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
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"

// Ensure every example directory has a corresponding test
const completeExampleDir = "examples/complete"

// Define a struct with fields that match the structure of the YAML data
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

// due to postgres usage, limiting to icd regions
const regionSelectionPath = "../common-dev-assets/common-go-assets/icd-region-prefs.yaml"

var permanentResources map[string]interface{}

// TestMain will be run before any parallel tests, used to read data from yaml for use with tests
func TestMain(m *testing.M) {

	var err error
	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}

	// get the license from a secrets manager, fail test if error
	license, licenseErr := getLicenseString()
	if licenseErr != nil {
		log.Fatal(licenseErr)
	}

	// generate a random password, fail if error
	pass, passErr := getRandomAdminPassword()
	if passErr != nil {
		log.Fatal(passErr)
	}

	// ADD SENSITIVE VALS TO ENV
	// not adding to regular vars so not to leak the values
	setLicenseEnvErr := os.Setenv("TF_VAR_tfe_license", *license)
	if setLicenseEnvErr != nil {
		log.Fatal(setLicenseEnvErr)
	}
	setPassEnvErr := os.Setenv("TF_VAR_admin_password", *pass)
	if setPassEnvErr != nil {
		log.Fatal(setPassEnvErr)
	}

	// NOTE: SHOULD REMOVE THIS WHEN PROJECT IS MORE STABLE
	// While in Alpha phase we want to debug failures
	setDoNotDestroyErr := os.Setenv("DO_NOT_DESTROY_ON_FAILURE", "true")
	if setDoNotDestroyErr != nil {
		log.Fatal(setDoNotDestroyErr)
	}

	os.Exit(m.Run())
}

func setupOptions(t *testing.T, prefix string, dir string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:            t,
		TerraformDir:       dir,
		Prefix:             prefix,
		ResourceGroup:      resourceGroup,
		BestRegionYAMLPath: regionSelectionPath,
		TerraformVars: map[string]interface{}{
			"add_to_catalog":               false,
			"postgres_deletion_protection": false,
			"postgres_vpe_enabled":         true,
		},
		IgnoreUpdates: testhelper.Exemptions{ // Ignore for consistency check
			List: []string{
				"module.tfe.module.tfe_install.helm_release.tfe_install",
				"module.tfe.module.tfe_install.kubernetes_namespace.tfe",
				"module.tfe.module.tfe_install.kubernetes_secret.tfe_admin_token",
			},
		},
	})

	// NOTE ON INPUT VARS:
	// the inputs for license and password are added in TestMain in the ENV.

	// NOTE ON IGNORE UPDATES:
	// In early Alpha state the helm chart and other kubernetes resources are going to
	// report update-in-place on each run. Ignoring for now, should investigate before an
	// official GA release.

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
	t.Skip("Skip upgrade test while in Alpha release stage - resume upon official release")

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
