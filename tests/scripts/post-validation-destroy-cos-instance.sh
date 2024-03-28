#! /bin/bash

########################################################################################################################
## This script is used by the catalog pipeline to destroy the COS Instance, which was provisioned as a                ##
## prerequisite for the cross-region and regional bucket solutions that is published to the catalog                   ##
########################################################################################################################

set -e

TERRAFORM_SOURCE_DIR="solutions/instance"
TF_VARS_FILE="terraform.tfvars"

(
  cd ${TERRAFORM_SOURCE_DIR}
  echo "Destroying prerequisite COS Instance .."
  terraform destroy -input=false -auto-approve -var-file=${TF_VARS_FILE} || exit 1

  echo "Post-validation complete successfully"
)
