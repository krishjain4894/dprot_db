#!/bin/bash

var1="$1"
id=$(aws cloudformation describe-stacks --stack-name $var1 --query "Stacks[*].StackId" --output text 2>&1)

bucket_id=$(aws cloudformation describe-stack-resources --stack-name $var1 --logical-resource-id S3Bucket --query "StackResources[0].PhysicalResourceId" --output text)
aws s3 rm 's3://'$bucket_id --recursive

aws cloudformation delete-stack --stack-name $var1

aws cloudformation wait stack-delete-complete --stack-name $var1
aws cloudformation describe-stacks --stack-name $id --query "Stacks[*].StackStatus" --output text

exit 0
