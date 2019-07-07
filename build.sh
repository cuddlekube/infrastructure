#!/bin/bash

while getopts "n:f:t:p:h?" opt; do
  case $opt in
    n)
      NAME=$OPTARG
      ;;
    f)
      TEMPLATE_FILE=$OPTARG
      ;;
    t)
      TAG_FILE=$OPTARG
      ;;
    p)
      PARAMETER_FILE="--parameters file://cfn-parameters/${OPTARG}.json"
      ;;
    h)
      full_help
      exit 2
      ;;
    \?)
      full_help
      exit 2
      ;;
  esac
done

CHANGESETNAME=$(date "+A%Y-%m-%d-%H-%M-%S")
if ! aws cloudformation describe-stacks --stack-name "${NAME}" >/dev/null 2>&1 ; then
    echo "Creating new stack: ${NAME}"
    aws cloudformation create-stack  --template-body "file://cfn-templates/${TEMPLATE_FILE}.yml" --stack-name "${NAME}" ${PARAMETER_FILE} --tags "file://cfn-tags/${TAG_FILE}.json" --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND
    if [[ $? == 0 ]]; then
      echo "Waiting for create stack to finish"
      aws cloudformation wait stack-create-complete --stack-name ${NAME}
      exit $?
    else
      exit $?
    fi
fi
echo "Updating ${NAME}"
aws cloudformation create-change-set --template-body "file://cfn-templates/${TEMPLATE_FILE}.yml" --stack-name "${NAME}" --change-set-name "${CHANGESETNAME}" ${PARAMETER_FILE} --tags "file://cfn-tags/${TAG_FILE}.json" --capabilities CAPABILITY_IAM >/dev/null 2>&1
# Add a 10 second sleep to prevent the 30 second delay from the wait function
sleep 10
aws cloudformation wait change-set-create-complete --change-set-name "${CHANGESETNAME}" --stack-name "${NAME}" >/dev/null 2>&1
status=$(aws cloudformation describe-change-set --change-set-name "${CHANGESETNAME}" --stack-name "${NAME}" --query StatusReason --output text)
# Check if there are no updates in which case, clean up and move on
if [[ "$status" == "No updates are to be performed." || "$status" == "The submitted information didn't contain changes. Submit different information to create a change set." ]]; then
    echo "No updates are to be performed on ${NAME}"
    aws cloudformation delete-change-set --change-set-name "${CHANGESETNAME}" --stack-name "${NAME}" >/dev/null 2>&1
    exit 0;
fi
aws cloudformation execute-change-set --change-set-name "${CHANGESETNAME}" --stack-name "${NAME}"
aws cloudformation wait stack-update-complete --stack-name "${NAME}"
echo "Finished updating ${NAME}"