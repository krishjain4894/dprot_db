
 # Infrastructure as a Code:
 This readme.md contains steps to build your AWS cloud infrastrcture using AWS CLI
 
 ## Getting Started:
 For this, we will be programming VPC i.e Virtual Private Cloud using AWS cloudformation.
 
 ## Prerequisites:
 1. VMware Work Station OR
 2. Oracle Virtual BOx
 3. Fedora
 4. Pip
 5. AWS CLI
 
```
sudo apt-get install python-pip
```
 
 ## For AWS:
 First make sure that you have installed AWS CLI in your fedora
 ```
 $ pip install awscli --upgrade --user
 ```
 
 Now, we will configure our AWS. Make sure you configure your AWS with your Access Key and Secret Key. In order to set-up the AWS infrastrucutre, use 
 the following command
 
```
 $aws configure
```

## Running Scripts:
Before running the scripts, it is important to make a note that all the scripts, template file should be in the same folder.

To create and configure required networking resources using AWS CloudFormation:
```
> ./csye6225-aws-cf-create-stack.sh
```
To delete  Cloudformation Stack:
```
> ./csye6225-aws-cf-terminate-stack.sh
```
 
## Running application stack scripts:

To create application stack:
```
> ./csye6225-aws-cf-create-application-stack.sh  [STACK_NAME]
```

To Delete application stack:
```
> ./csye6225-aws-cf-terminate-application-stack.sh [STACK_NAME]
```
##Running cicd stack script:
To create cicd
```
> ./csye6225-aws-cf-create-cicd.sh [STACK_NAME]
```
To delete cicd
```
> ./csye6225-aws-cf-terminate-cicd-stack.sh [STACK NAME]
```
##Running autoscaling stack scripts:
To create autoscaling
```
> ./csye6225-aws-cf-create-autoscaling-stack.sh [STACK_NAME]
```
To delete cicd
```
> ./csye6225-aws-cf-terminate-autoscaling-stack.sh [STACK NAME]
```
##Running Serverless stack scripts:
To create serverless
```
> ./csye6225-aws-cf-create-serverless-stack.sh [STACK_NAME]
```
To delete cicd
```
> ./csye6225-aws-cf-terminate-serverless-stack.sh [STACK NAME]
```
##Running WAF RESOURCE stack script:
To create waf resource
```
> ./csye6225-aws-cf-create-WAFResource.sh [STACK_NAME]
```
To delete cicd
```
> ./csye6225-aws-cf-terminate-WAFResource.sh [STACK NAME]
```