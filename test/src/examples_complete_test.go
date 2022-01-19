package test

import (
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Test the Terraform module in examples/complete using Terratest.
func TestExamplesComplete(t *testing.T) {
	randID := strings.ToLower(random.UniqueId())
	attributes := []string{randID}

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../examples/complete",
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: []string{"fixtures.us-east-2.tfvars"},
		// We always include a random attribute so that parallel tests
		// and AWS resources do not interfere with each other
		Vars: map[string]interface{}{
			"attributes": attributes,
		},
	}
	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	id := "eg-ue2-test-budgets-" + randID + "-budgets"

	// verify Name of SNS topic contains randID
	// see https://github.com/cloudposse/terraform-aws-sns-lambda-notify-slack/blob/master/main.tf#L13
	snsTopicName := terraform.Output(t, terraformOptions, "sns_topic_name")
	assert.Equal(t, id, snsTopicName)

	// verify Name of lambda contains randID
	// underlying lambda has `default` appended to attributes
	lambdaFunctionName := terraform.Output(t, terraformOptions, "lambda_function_name")
	assert.Equal(t, id+"-default", lambdaFunctionName)

	// verify ARN of KMS key is not empty
	kmsKeyArn := terraform.Output(t, terraformOptions, "kms_key_arn")
	assert.NotEmpty(t, kmsKeyArn)

	// verify ARN of KMS key is not empty
	kmsKeyId := terraform.Output(t, terraformOptions, "kms_key_id")
	assert.NotEmpty(t, kmsKeyId)
}

// Test the Terraform module in examples/complete doesn't attempt to create resources with enabled=false
func TestExamplesCompleteDisabled(t *testing.T) {
	testExamplesCompleteDisabled(t)
}
