

#!/bin/bash
var1="$1"
aws cloudformation create-stack --stack-name $var1 --template-body file://csye6225-cf-WAFResource.json --capabilities CAPABILITY_NAMED_IAM
aws cloudformation wait stack-create-complete --stack-name $var1
aws cloudformation describe-stacks --stack-name $var1 --query "Stacks[*].StackStatus" --output text
exit 0