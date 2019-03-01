#!/bin/bash

var1="$1"
var2="$(aws route53 list-hosted-zones | jq -r '.HostedZones[0].Name')"
var3="$(aws ec2 describe-key-pairs  --query KeyPairs[0].KeyName)"
CERTIFICATEARN="$(aws acm list-certificates | jq -r '.CertificateSummaryList[].CertificateArn')"
PWDRESETARN="$(aws sns list-topics | jq -r '.Topics[0].TopicArn')"
REGION="us-east-1"
DOMAINNAME="${var2::-1}"
echo $DOMAINNAME

echo $var2
aws cloudformation create-stack --stack-name $var1 --parameters ParameterKey=S3BucketName,ParameterValue=${var2}csye6225.com ParameterKey=KeyName,ParameterValue=${var3} ParameterKey=REGION,ParameterValue=$REGION ParameterKey=DOMAINNAME,ParameterValue=$DOMAINNAME  ParameterKey=PWDRESETARN,ParameterValue=$PWDRESETARN ParameterKey=CERTIFICATEARN,ParameterValue=$CERTIFICATEARN ParameterKey=hostedZone,ParameterValue=$var2 --template-body file://csye6225-cf-auto-scaling-application.json --capabilities CAPABILITY_NAMED_IAM
aws cloudformation wait stack-create-complete --stack-name $var1
aws cloudformation describe-stacks --stack-name $var1 --query "Stacks[*].StackStatus" --output text
exit 0