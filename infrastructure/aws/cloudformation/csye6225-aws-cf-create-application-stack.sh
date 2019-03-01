#!/bin/bash

var1="$1"
var2="$(aws route53 list-hosted-zones | jq -r '.HostedZones[0].Name')"
var3="$(aws ec2 describe-key-pairs  --query KeyPairs[0].KeyName)"
DOMAINNAME="${var2::-1}"
echo $DOMAINNAME
echo $var2
aws cloudformation create-stack --stack-name $var1 --parameters ParameterKey=S3BucketName,ParameterValue=${var2}csye6225.com ParameterKey=KeyName,ParameterValue=${var3} ParameterKey=ACCESSKEY,ParameterValue=$ACCESSKEY ParameterKey=SECRETKEY,ParameterValue=$SECRETKEY ParameterKey=REGION,ParameterValue=$REGION ParameterKey=DOMAINNAME,ParameterValue=$DOMAINNAME  ParameterKey=PWDRESETARN,ParameterValue=$PWDRESETARN --template-body file://csye6225-cf-application.json --capabilities CAPABILITY_NAMED_IAM
aws cloudformation wait stack-create-complete --stack-name $var1
aws cloudformation describe-stacks --stack-name $var1 --query "Stacks[*].StackStatus" --output text
exit 0