#! /bin/bash

########################################################################################################################
## This script is used by the catalog pipeline to deploy the COS Instance, which is a prerequisite for the Cross      ##
## Region bucket extension, after catalog validation has completed.                                                   ##
########################################################################################################################

set -e

DA_DIR="solutions/secure-cross-regional-bucket"
TERRAFORM_SOURCE_DIR="solutions/instance"
JSON_FILE="${DA_DIR}/catalogValidationValues.json"
PREFIX="cos-$(openssl rand -hex 2)"
TF_VARS_FILE="terraform-cross-regional.tfvars"

(
  cwd=$(pwd)
  cd ${TERRAFORM_SOURCE_DIR}
  echo "Provisioning prerequisite COS Instance .."
  terraform init || exit 1
  # $VALIDATION_APIKEY is available in the catalog runtime
  {
    echo "ibmcloud_api_key=\"${VALIDATION_APIKEY}\""
    echo "cos_instance_name=\"${PREFIX}\""
    echo "resource_group_name=\"${PREFIX}\""
  } >>${TF_VARS_FILE}
  terraform apply -input=false -auto-approve -var-file=${TF_VARS_FILE} || exit 1

  cos_instance_crn_var_name="existing_cos_instance_crn"
  cos_instance_crn_value=$(terraform output -state=terraform.tfstate -raw cos_instance_id) # TODO: Replace with crn when https://github.com/terraform-ibm-modules/terraform-ibm-cos/issues/839 is done

  echo "Appending '${cos_instance_crn_var_name}' input variable values to ${JSON_FILE}.."

  cd "${cwd}"
  jq -r --arg cos_instance_crn_var_name "${cos_instance_crn_var_name}" \
    --arg cos_instance_crn_value "${cos_instance_crn_value}" \
    '. + {($cos_instance_crn_var_name): $cos_instance_crn_value}' "${JSON_FILE}" >tmpfile && mv tmpfile "${JSON_FILE}" || exit 1

  echo "Pre-validation complete successfully"
)
