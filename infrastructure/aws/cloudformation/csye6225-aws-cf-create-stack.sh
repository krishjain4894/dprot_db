#!/bin/bash

var1="$1"
aws cloudformation create-stack --stack-name $var1 --parameters ParameterKey=privateroutetableName,ParameterValue=${var1}csye6225-privateRoute ParameterKey=vpcName,ParameterValue=${var1}-csye6225-vpc ParameterKey=gatewayName,ParameterValue=${var1}-csye6225-InternetGateway ParameterKey=publicroutetableName,ParameterValue=${var1}-csye6225-public-route-table --template-body file://csye6225-cf-networking.json

aws cloudformation wait stack-create-complete --stack-name $var1

aws cloudformation describe-stacks --stack-name $var1 --query "Stacks[*].StackStatus" --output text

exit 0
