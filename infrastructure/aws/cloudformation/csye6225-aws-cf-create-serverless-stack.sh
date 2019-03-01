#!/bin/bash
var1="$1"
lambdaArn="lambdaFn"
var2="$(aws route53 list-hosted-zones | jq -r '.HostedZones[].Name')"
aws cloudformation create-stack --stack-name $var1 --parameters  ParameterKey=lambdaArn1,ParameterValue=$lambdaArn ParameterKey=S3BucketLambda,ParameterValue=code-deploy.${var2}lambda --template-body file://csye6225-cf-serverless.json --capabilities CAPABILITY_NAMED_IAM
aws cloudformation wait stack-create-complete --stack-name $var1
aws cloudformation describe-stacks --stack-name $var1 --query "Stacks[*].StackStatus" --output text
exit 0