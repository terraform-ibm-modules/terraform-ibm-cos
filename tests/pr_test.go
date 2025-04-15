// Tests in this file are run in the PR pipeline
package test

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/IBM/ibm-cos-sdk-go/aws"
	"github.com/IBM/ibm-cos-sdk-go/aws/awserr"
	"github.com/IBM/ibm-cos-sdk-go/aws/credentials/ibmiam"
	"github.com/IBM/ibm-cos-sdk-go/aws/session"
	"github.com/IBM/ibm-cos-sdk-go/service/s3"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

const advancedExampleTerraformDir = "examples/advanced"
const fsCloudTerraformDir = "examples/fscloud"
const replicateExampleTerraformDir = "examples/replication"
const basicExampleTerraformDir = "examples/basic"
const oneRateExampleTerraformDir = "examples/one-rate-plan"
const solutionInstanceDir = "solutions/instance"
const solutionRegionalDir = "solutions/secure-regional-bucket"
const solutionCrossRegionDir = "solutions/secure-cross-regional-bucket"

// Use existing group for tests
const resourceGroup = "geretain-test-cos-base"

// Not all regions provide cross region support so value must be hardcoded https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-service-availability.
const region = "us-south"

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
	// below dirs do not implement Activity Tracker functionality
	if dir == replicateExampleTerraformDir || dir == oneRateExampleTerraformDir {
		options = testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
			Testing:       t,
			TerraformDir:  dir,
			Prefix:        prefix,
			ResourceGroup: resourceGroup,
			Region:        region,
			TerraformVars: map[string]interface{}{
				"access_tags": permanentResources["accessTags"],
			},
		})
	}
	return options
}

func TestRunAdvancedExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "cos-advanced", advancedExampleTerraformDir)
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunFSCloudExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "cos-fscloud", fsCloudTerraformDir)
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

func TestRunReplicateExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "cos-replicate", replicateExampleTerraformDir)
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "cos-upgrade", advancedExampleTerraformDir)

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
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

// A single function to test all DA solutions.
func TestRunSolutions(t *testing.T) {
	t.Parallel()

	prefix := fmt.Sprintf("cos-sol-%s", strings.ToLower(random.UniqueId()))

	instanceOptions := setupOptions(t, prefix, solutionInstanceDir)
	instanceOptions.TerraformVars = map[string]interface{}{
		"cos_instance_name":                      prefix,
		"resource_group_name":                    fmt.Sprintf("%s-resource-group", prefix),
		"existing_secrets_manager_instance_crn":  permanentResources["secretsManagerCRN"],
		"existing_secrets_manager_endpoint_type": "public",
		"provider_visibility":                    "public",
		"service_credential_secrets": []map[string]interface{}{
			{
				"secret_group_name": fmt.Sprintf("%s-secret-group", prefix),
				"service_credentials": []map[string]string{
					{
						"secret_name": fmt.Sprintf("%s-cred-manager", prefix),
						"service_credentials_source_service_role_crn": "crn:v1:bluemix:public:iam::::serviceRole:Manager",
					},
					{
						"secret_name": fmt.Sprintf("%s-cred-writer", prefix),
						"service_credentials_source_service_role_crn": "crn:v1:bluemix:public:iam::::serviceRole:Writer",
					},
					{
						"secret_name": fmt.Sprintf("%s-cred-object-writer", prefix),
						"service_credentials_source_service_role_crn": "crn:v1:bluemix:public:cloud-object-storage::::serviceRole:ObjectWriter",
					},
				},
			},
		},
	}
	instanceOptions.SkipTestTearDown = true
	output, err := instanceOptions.RunTestConsistency()

	if assert.Nil(t, err, "This should not have errored") &&
		assert.NotNil(t, output, "Expected some output") &&
		assert.NotNil(t, instanceOptions.LastTestTerraformOutputs, "Expected some Terraform outputs") {

		regionalOptions := testhelper.TestOptionsDefault(&testhelper.TestOptions{
			Testing:      t,
			TerraformDir: solutionRegionalDir,
			// Do not hard fail the test if the implicit destroy steps fail to allow a full destroy of resource to occur
			ImplicitRequired: false,
			TerraformVars: map[string]interface{}{
				"bucket_name":                         fmt.Sprintf("%s-regional-bucket", prefix),
				"region":                              region,
				"existing_kms_instance_crn":           permanentResources["hpcs_south_crn"],
				"kms_endpoint_type":                   "public",
				"provider_visibility":                 "public",
				"management_endpoint_type_for_bucket": "public",
				"existing_cos_instance_crn":           instanceOptions.LastTestTerraformOutputs["cos_instance_id"],
			},
		})

		regionalOutput, err := regionalOptions.RunTestConsistency()
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, regionalOutput, "Expected some output")

		crossRegionalOptions := testhelper.TestOptionsDefault(&testhelper.TestOptions{
			Testing:      t,
			TerraformDir: solutionCrossRegionDir,
			// Do not hard fail the test if the implicit destroy steps fail to allow a full destroy of resource to occur
			ImplicitRequired: false,
			TerraformVars: map[string]interface{}{
				"bucket_name":                         fmt.Sprintf("%s-cross-region-bucket", prefix),
				"cross_region_location":               "us",
				"existing_kms_key_crn":                permanentResources["hpcs_south_root_key_crn"],
				"existing_kms_instance_crn":           permanentResources["hpcs_south_crn"],
				"management_endpoint_type_for_bucket": "public",
				"provider_visibility":                 "public",
				"existing_cos_instance_crn":           instanceOptions.LastTestTerraformOutputs["cos_instance_id"],
			},
		})

		crossRegionalOutput, err := crossRegionalOptions.RunTestConsistency()
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, crossRegionalOutput, "Expected some output")

	}
	instanceOptions.TestTearDown()
}
