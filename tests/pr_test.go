// Tests in this file are run in the PR pipeline
package test

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"io/fs"
	"log"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/IBM/ibm-cos-sdk-go/aws"
	"github.com/IBM/ibm-cos-sdk-go/aws/awserr"
	"github.com/IBM/ibm-cos-sdk-go/aws/credentials/ibmiam"
	"github.com/IBM/ibm-cos-sdk-go/aws/session"
	"github.com/IBM/ibm-cos-sdk-go/service/s3"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testaddons"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

/*
Global variables
*/
const terraformVersion = "terraform_v1.10" // This should match the version in the ibm_catalog.json
const advancedExampleTerraformDir = "examples/advanced"
const fsCloudTerraformDir = "examples/fscloud"
const replicateExampleTerraformDir = "examples/replication"
const basicExampleTerraformDir = "examples/basic"
const solutionInstanceDir = "solutions/instance"
const fullyConfigurableCrossRegionalDir = "solutions/cross-regional-bucket/fully-configurable"
const RegionalfullyConfigurableDir = "solutions/regional-bucket/fully-configurable"
const securityEnforcedCrossRegionalDir = "solutions/cross-regional-bucket/security-enforced"
const securityEnforcedRegionalDir = "solutions/regional-bucket/security-enforced"
const resourceGroup = "geretain-test-cos-base"
const region = "us-south"                                                                    // Not all regions provide cross region support so value must be hardcoded https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-service-availability.
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml" // Define a struct with fields that match the structure of the YAML data

var excludeDirs = []string{
	".terraform",
	".docs",
	".github",
	".git",
	".idea",
	"common-dev-assets",
	"examples",
	"tests",
	"reference-architectures",
}
var includeFiletypes = []string{
	".tf",
	".yaml",
	".py",
	".tpl",
}
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

func setupExampleOptions(t *testing.T, prefix string, dir string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  dir,
		Prefix:        prefix,
		ResourceGroup: resourceGroup,
		Region:        region,
		TerraformVars: map[string]interface{}{
			"access_tags": permanentResources["accessTags"],
		},
	})

	return options
}

type tarIncludePatterns struct {
	excludeDirs []string

	includeFiletypes []string

	includeDirs []string
}

func getTarIncludePatternsRecursively(dir string, dirsToExclude []string, fileTypesToInclude []string) ([]string, error) {
	r := tarIncludePatterns{dirsToExclude, fileTypesToInclude, nil}
	err := filepath.WalkDir(dir, func(path string, entry fs.DirEntry, err error) error {
		return walk(&r, path, entry, err)
	})
	if err != nil {
		fmt.Println("error")
		return r.includeDirs, err
	}
	return r.includeDirs, nil
}

func walk(r *tarIncludePatterns, s string, d fs.DirEntry, err error) error {
	if err != nil {
		return err
	}
	if d.IsDir() {
		for _, excludeDir := range r.excludeDirs {
			if strings.Contains(s, excludeDir) {
				return nil
			}
		}
		if s == ".." {
			r.includeDirs = append(r.includeDirs, "*.tf")
			return nil
		}
		for _, includeFiletype := range r.includeFiletypes {
			r.includeDirs = append(r.includeDirs, strings.ReplaceAll(s+"/*"+includeFiletype, "../", ""))
		}
	}
	return nil
}

func TestRunAdvancedExample(t *testing.T) {
	t.Parallel()

	options := setupExampleOptions(t, "cos-advanced", advancedExampleTerraformDir)
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunFSCloudExample(t *testing.T) {
	t.Parallel()

	options := setupExampleOptions(t, "cos-fscloud", fsCloudTerraformDir)
	options.TerraformVars["bucket_existing_hpcs_instance_guid"] = permanentResources["hpcs_south"]
	options.TerraformVars["bucket_hpcs_key_crn"] = permanentResources["hpcs_south_root_key_crn"]
	options.TerraformVars["management_endpoint_type_for_bucket"] = "public"

	// Setting this will allow the destroy to run without error by using the list of rule ids from the outputs
	// to disable the rules before destroy. Without it, the destroy will fail on the refresh.
	options.CBRRuleListOutputVariable = "cbr_rule_ids"
	options.TestSetup()
	defer func() {
		options.TestTearDown()
	}()

	terraform.InitAndApply(t, options.TerraformOptions)
	outputs, err := terraform.OutputAllE(t, options.TerraformOptions)

	// Delay before running tests to allow CBRs to be picked up
	delayDuration := 10 * time.Minute
	delayMinutes := delayDuration.Minutes()
	logger.Log(t, fmt.Sprintf("Waiting %.f minutes for CBRs to be picked up...", delayMinutes))
	time.Sleep(delayDuration)

	expectedOutputs := []string{"cos_instance_id", "cos_instance_guid", "cos_instance_crn", "buckets", "bucket_cbr_rules", "instance_cbr_rules"}
	_, tfOutputsErr := testhelper.ValidateTerraformOutputs(outputs, expectedOutputs...)
	if assert.Nil(t, tfOutputsErr, tfOutputsErr) {
		// Retrieve the API key from the environment variable
		apiKey := os.Getenv("TF_VAR_ibmcloud_api_key")

		require.NotEmpty(t, apiKey, "TF_VAR_ibmcloud_api_key environment variable is not set")

		// Set up COS connection
		authEndpoint := "https://iam.cloud.ibm.com/identity/token"
		serviceEndpoint := "s3.us.cloud-object-storage.appdomain.cloud" // Instance can be read from any region

		cosClient := getCOSInstanceClient(apiKey, outputs["cos_instance_id"].(string), authEndpoint, serviceEndpoint)

		// Test CBRs by attempting to list buckets or access a bucket
		bucketList, listErr := cosClient.ListBuckets(&s3.ListBucketsInput{})

		// Check if CBRs are working as expected
		if assert.NotNilf(t, listErr, "CBRs are not working as expected. Instance exposed Buckets can be listed: %s", bucketList) {
			var awsErr awserr.Error
			_ = errors.As(listErr, &awsErr)
			if assert.Equal(t, "AccessDenied", awsErr.Code(), "CBRs are not working as expected. Expected 403 error access denied when blocked by CBR") {
				fmt.Println("CBRs are working as expected. Instance is not exposed Buckets cannot be listed.")
			}
		}

		bearerToken := getIAMBearerToken(apiKey)
		for bucket := range outputs["buckets"].(map[string]interface{}) {

			publicEndpoint := outputs["buckets"].(map[string]interface{})[bucket].(map[string]interface{})["s3_endpoint_public"].(string)
			privateEndpoint := outputs["buckets"].(map[string]interface{})[bucket].(map[string]interface{})["s3_endpoint_private"].(string)
			directEndpoint := outputs["buckets"].(map[string]interface{})[bucket].(map[string]interface{})["s3_endpoint_direct"].(string)
			endpoints := []string{publicEndpoint, privateEndpoint, directEndpoint}
			for _, endpoint := range endpoints {
				// Create a GET request to list objects in the bucket
				buckReq, buckErr := http.NewRequest("GET", fmt.Sprintf("https://%s.%s", bucket, endpoint), nil)
				if buckErr != nil {
					fmt.Println("Error creating request:", err)
					continue
				}

				buckReq.Header.Set("Authorization", "bearer "+bearerToken)
				buckReq.Header.Set("ibm-service-instance-id", outputs["cos_instance_id"].(string))

				client := &http.Client{}
				resp, objErr := client.Do(buckReq)
				cbrWorkingAsExpected := false
				reason := ""
				if resp != nil {
					// Close the response body when done
					defer func() {
						if resp != nil {
							err := resp.Body.Close()
							if err != nil {
								// Handle or log the error
								log.Printf("Error closing response body: %v", err)
							}
						} else {
							log.Print("no response, defer close not needed")
						}
					}()

					// Read the response body into a string
					bodyBytes, readErr := io.ReadAll(resp.Body)
					if readErr != nil {
						reason = fmt.Sprintf("CBRs are Not working as expected. Bucket %s can be accessed at https://%s.%s with response code: %d and Error reading response body: %v", bucket, bucket, endpoint, resp.StatusCode, readErr)
					} else {
						// Create a readable message
						reason = fmt.Sprintf("CBRs are Not working as expected. Bucket %s can be accessed at https://%s.%s with response code: %d and body: %s", bucket, bucket, endpoint, resp.StatusCode, string(bodyBytes))
					}

				}
				if resp != nil && resp.StatusCode == 403 {
					cbrWorkingAsExpected = true
					reason = fmt.Sprintf("CBRs are working as expected, blocked at https://%s.%s with 403 response. Bucket %s is not exposed. Bucket cannot be accessed.", bucket, endpoint, bucket)
				} else if objErr != nil {
					cbrWorkingAsExpected = true
					reason = fmt.Sprintf("CBRs are working as expected, blocked at https://%s.%s with error. Bucket %s is not exposed. Bucket cannot be accessed. error: %s", bucket, endpoint, bucket, objErr.Error())
				}

				if assert.True(t, cbrWorkingAsExpected, reason) {
					fmt.Println(reason)
				}

			}
		}
	}
}

func getIAMBearerToken(apikey string) string {
	authEndpoint := "https://iam.cloud.ibm.com/identity/token"
	data := url.Values{}
	data.Set("grant_type", "urn:ibm:params:oauth:grant-type:apikey")
	data.Set("apikey", apikey)

	client := &http.Client{}
	req, err := http.NewRequest("POST", authEndpoint, strings.NewReader(data.Encode()))
	if err != nil {
		fmt.Println("Error creating request:", err)
		return ""
	}

	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")

	resp, err := client.Do(req)
	if err != nil {
		fmt.Println("Error sending request:", err)
		return ""
	}
	defer func() {
		if resp != nil {
			err := resp.Body.Close()
			if err != nil {
				// Handle or log the error
				log.Printf("Error closing response body: %v", err)
			}
		} else {
			log.Print("no response, defer close not needed")
		}
	}()

	var responseJSON map[string]interface{}
	err = json.NewDecoder(resp.Body).Decode(&responseJSON)
	if err != nil {
		fmt.Println("Error decoding response:", err)
		return ""
	}

	return responseJSON["access_token"].(string)
}

func getCOSInstanceClient(apiKey, serviceInstanceID, authEndpoint, serviceEndpoint string) *s3.S3 {
	sess := session.Must(session.NewSession())
	creds := ibmiam.NewStaticCredentials(aws.NewConfig(), authEndpoint, apiKey, serviceInstanceID)
	conf := aws.NewConfig().
		WithEndpoint(serviceEndpoint).
		WithCredentials(creds).
		WithS3ForcePathStyle(true)
	return s3.New(sess, conf)
}
func TestRunInstancesSchematics(t *testing.T) {
	t.Parallel()

	prefix := "cos-sol"

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		Region:  region,
		Prefix:  prefix,
		TarIncludePatterns: []string{
			"*.tf",
			"modules/buckets/*.tf",
			"modules/fscloud/*.tf",
			solutionInstanceDir + "/*.tf",
		},
		TemplateFolder:         solutionInstanceDir,
		Tags:                   []string{"cos-instance-da-test"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 30,
		TerraformVersion:       terraformVersion,
	})

	service_credential_secrets := []map[string]interface{}{
		{
			"secret_group_name": fmt.Sprintf("%s-secret-group", options.Prefix),
			"service_credentials": []map[string]string{
				{
					"secret_name": fmt.Sprintf("%s-cred-manager", options.Prefix),
					"service_credentials_source_service_role_crn": "crn:v1:bluemix:public:iam::::serviceRole:Manager",
				},
				{
					"secret_name": fmt.Sprintf("%s-cred-writer", options.Prefix),
					"service_credentials_source_service_role_crn": "crn:v1:bluemix:public:iam::::serviceRole:Writer",
				},
				{
					"secret_name": fmt.Sprintf("%s-cred-object-writer", options.Prefix),
					"service_credentials_source_service_role_crn": "crn:v1:bluemix:public:cloud-object-storage::::serviceRole:ObjectWriter",
				},
			},
		},
	}

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "existing_resource_group_name", Value: resourceGroup, DataType: "string"},
		{Name: "existing_secrets_manager_instance_crn", Value: permanentResources["secretsManagerCRN"], DataType: "string"},
		{Name: "service_credential_secrets", Value: service_credential_secrets, DataType: "list(object{})"},
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")

}

func TestRunInstancesUpgradeInSchematics(t *testing.T) {
	t.Parallel()

	prefix := "cos-upg"

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		Region:  region,
		Prefix:  prefix,
		TarIncludePatterns: []string{
			"*.tf",
			"modules/buckets/*.tf",
			"modules/fscloud/*.tf",
			solutionInstanceDir + "/*.tf",
		},
		TemplateFolder:             solutionInstanceDir,
		Tags:                       []string{"cos-da-instance-upg"},
		DeleteWorkspaceOnFail:      false,
		WaitJobCompleteMinutes:     120,
		CheckApplyResultForUpgrade: true, // Set to true to test the actual terraform apply upgrade
		TerraformVersion:           terraformVersion,
	})

	service_credential_secrets := []map[string]interface{}{
		{
			"secret_group_name": fmt.Sprintf("%s-secret-group", options.Prefix),
			"service_credentials": []map[string]string{
				{
					"secret_name": fmt.Sprintf("%s-cred-manager", options.Prefix),
					"service_credentials_source_service_role_crn": "crn:v1:bluemix:public:iam::::serviceRole:Manager",
				},
				{
					"secret_name": fmt.Sprintf("%s-cred-writer", options.Prefix),
					"service_credentials_source_service_role_crn": "crn:v1:bluemix:public:iam::::serviceRole:Writer",
				},
				{
					"secret_name": fmt.Sprintf("%s-cred-object-writer", options.Prefix),
					"service_credentials_source_service_role_crn": "crn:v1:bluemix:public:cloud-object-storage::::serviceRole:ObjectWriter",
				},
			},
		},
	}

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "existing_resource_group_name", Value: resourceGroup, DataType: "string"},
		{Name: "existing_secrets_manager_instance_crn", Value: permanentResources["secretsManagerCRN"], DataType: "string"},
		{Name: "service_credential_secrets", Value: service_credential_secrets, DataType: "list(object{})"},
	}

	err := options.RunSchematicUpgradeTest()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
	}
}

func TestRunCrossRegionalFullyConfigurableSchematics(t *testing.T) {
	t.Parallel()

	tarIncludePatterns, recurseErr := getTarIncludePatternsRecursively("..", excludeDirs, includeFiletypes)

	// if error producing tar patterns (very unexpected) fail test immediately
	require.NoError(t, recurseErr, "Schematic Test had unexpected error traversing directory tree")

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:                t,
		Prefix:                 "f-sb",
		TarIncludePatterns:     tarIncludePatterns,
		ResourceGroup:          resourceGroup,
		TemplateFolder:         fullyConfigurableCrossRegionalDir,
		Tags:                   []string{"cos-cr-fc-test"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 80,
		TerraformVersion:       terraformVersion,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "cross_region_location", Value: "us", DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "existing_cos_instance_crn", Value: permanentResources["general_test_storage_cos_instance_crn"], DataType: "string"},
		{Name: "bucket_name", Value: "cr-bucket", DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}

func TestRunCrossRegionalFullyConfigurableUpgradeSchematics(t *testing.T) {
	t.Parallel()

	tarIncludePatterns, recurseErr := getTarIncludePatternsRecursively("..", excludeDirs, includeFiletypes)

	// if error producing tar patterns (very unexpected) fail test immediately
	require.NoError(t, recurseErr, "Schematic Test had unexpected error traversing directory tree")

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:                    t,
		Prefix:                     "f-sb-up",
		TarIncludePatterns:         tarIncludePatterns,
		ResourceGroup:              resourceGroup,
		TemplateFolder:             fullyConfigurableCrossRegionalDir,
		Tags:                       []string{"cos-cr-fg-upg"},
		DeleteWorkspaceOnFail:      false,
		WaitJobCompleteMinutes:     80,
		CheckApplyResultForUpgrade: true, // Set to true to test the actual terraform apply upgrade
		TerraformVersion:           terraformVersion,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "cross_region_location", Value: "us", DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "existing_cos_instance_crn", Value: permanentResources["general_test_storage_cos_instance_crn"], DataType: "string"},
		{Name: "existing_kms_instance_crn", Value: permanentResources["hpcs_south_crn"], DataType: "string"},
		{Name: "kms_encryption_enabled", Value: true, DataType: "bool"},
		{Name: "bucket_name", Value: "cr-bucket", DataType: "string"},
	}

	err := options.RunSchematicUpgradeTest()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
	}
}

func TestRunRegionalFullyConfigurableSchematics(t *testing.T) {
	t.Parallel()

	tarIncludePatterns, recurseErr := getTarIncludePatternsRecursively("..", excludeDirs, includeFiletypes)

	// if error producing tar patterns (very unexpected) fail test immediately
	require.NoError(t, recurseErr, "Schematic Test had unexpected error traversing directory tree")

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:                t,
		Prefix:                 "reg-fc",
		Region:                 region,
		TarIncludePatterns:     tarIncludePatterns,
		ResourceGroup:          resourceGroup,
		TemplateFolder:         RegionalfullyConfigurableDir,
		Tags:                   []string{"cos-reg-fc-test"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 80,
		TerraformVersion:       terraformVersion,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "existing_cos_instance_crn", Value: permanentResources["general_test_storage_cos_instance_crn"], DataType: "string"},
		{Name: "bucket_name", Value: "reg-bucket", DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}

func TestRunRegionalFullyConfigurableUpgradeSchematics(t *testing.T) {
	t.Parallel()

	tarIncludePatterns, recurseErr := getTarIncludePatternsRecursively("..", excludeDirs, includeFiletypes)

	// if error producing tar patterns (very unexpected) fail test immediately
	require.NoError(t, recurseErr, "Schematic Test had unexpected error traversing directory tree")

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:                    t,
		Prefix:                     "reg-fc-up",
		Region:                     region,
		TarIncludePatterns:         tarIncludePatterns,
		ResourceGroup:              resourceGroup,
		TemplateFolder:             RegionalfullyConfigurableDir,
		Tags:                       []string{"cos-reg-fc-upg"},
		DeleteWorkspaceOnFail:      false,
		WaitJobCompleteMinutes:     80,
		CheckApplyResultForUpgrade: true, // Set to true to test the actual terraform apply upgrade
		TerraformVersion:           terraformVersion,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "existing_cos_instance_crn", Value: permanentResources["general_test_storage_cos_instance_crn"], DataType: "string"},
		{Name: "existing_kms_instance_crn", Value: permanentResources["hpcs_south_crn"], DataType: "string"},
		{Name: "kms_encryption_enabled", Value: true, DataType: "bool"},
		{Name: "bucket_name", Value: "reg-bucket", DataType: "string"},
	}

	err := options.RunSchematicUpgradeTest()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
	}
}

func TestRunCrossRegionalSecurityEnforcedSchematics(t *testing.T) {
	t.Parallel()

	tarIncludePatterns, recurseErr := getTarIncludePatternsRecursively("..", excludeDirs, includeFiletypes)

	// if error producing tar patterns (very unexpected) fail test immediately
	require.NoError(t, recurseErr, "Schematic Test had unexpected error traversing directory tree")

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:                t,
		Prefix:                 "cr-sec",
		TarIncludePatterns:     tarIncludePatterns,
		ResourceGroup:          resourceGroup,
		TemplateFolder:         securityEnforcedCrossRegionalDir,
		Tags:                   []string{"cos-cr-se-test"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 80,
		TerraformVersion:       terraformVersion,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "cross_region_location", Value: "us", DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "existing_kms_key_crn", Value: permanentResources["hpcs_south_root_key_crn"], DataType: "string"},
		{Name: "existing_cos_instance_crn", Value: permanentResources["general_test_storage_cos_instance_crn"], DataType: "string"},
		{Name: "skip_cos_kms_iam_auth_policy", Value: true, DataType: "bool"},
		{Name: "bucket_name", Value: "cr-sec-bucket", DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}
func TestRunRegionalSecurityEnforcedSchematics(t *testing.T) {
	t.Parallel()

	tarIncludePatterns, recurseErr := getTarIncludePatternsRecursively("..", excludeDirs, includeFiletypes)

	// if error producing tar patterns (very unexpected) fail test immediately
	require.NoError(t, recurseErr, "Schematic Test had unexpected error traversing directory tree")

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:                t,
		Prefix:                 "rg-sec",
		Region:                 region,
		TarIncludePatterns:     tarIncludePatterns,
		ResourceGroup:          resourceGroup,
		TemplateFolder:         securityEnforcedRegionalDir,
		Tags:                   []string{"cos-reg-se-test"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 80,
		TerraformVersion:       terraformVersion,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "existing_kms_key_crn", Value: permanentResources["hpcs_south_root_key_crn"], DataType: "string"},
		{Name: "existing_cos_instance_crn", Value: permanentResources["general_test_storage_cos_instance_crn"], DataType: "string"},
		{Name: "skip_cos_kms_iam_auth_policy", Value: true, DataType: "bool"},
		{Name: "bucket_name", Value: "reg-sec-bucket", DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
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
