#!/bin/bash
var1="$1"
# validation code
# name=$(aws cloudformation wait stack-exists --stack-name $var1 2>&1)
#
#
# if [[ -z $name ]];then
# 	echo "the stack exists. please enter a different name"
# 	exit 0
# fi
var2="$(aws route53 list-hosted-zones | jq -r '.HostedZones[0].Name')"
echo $var2
aws cloudformation create-stack --stack-name $var1 --parameters ParameterKey=S3BucketName,ParameterValue=code-deploy.${var2}tld ParameterKey=S3BucketLambda,ParameterValue=code-deploy.${var2}lambda --template-body file://csye6225-cf-cicd.json --capabilities CAPABILITY_NAMED_IAM
#aws cloudformation create-stack --stack-name $var1 --template-body file://csye6225-cf-cicd.json --capabilities CAPABILITY_NAMED_IAM

aws cloudformation wait stack-create-complete --stack-name $var1
aws cloudformation describe-stacks --stack-name $var1 --query "Stacks[*].StackStatus" --output text
exit 0