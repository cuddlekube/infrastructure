# Keeping an eye on your serverless containers demo

Repo for the demo from the Container Camp Australia 2019 talk "Keeping an eye on your serverless containers"

## Quick tips

Turn off (set desired to 0) services with `make disable-services`. You can reenable them with a regular `make enable-services`.

## Structure

* cfn-lint: Contains an override file for cfn-lint to ensure Macros don't cause issues
* cfn-macros: CloudFormation Macros, separately stored in their own directories
* cfn-parameters: Parameter files for the deployed CloudFormation stacks
* cfn-tags: Tags to be used with the CloudFormation stacks
* cfn-templates: The actual CloudFormation templates

### Other

* build.sh: convenience script for deploying CloudFormation templates
* Makefile: convenience Makefile for running various commands

## CloudFormation templates

* ecr-repos: All ECR repos can be put in here as a simple array due to the ECRExpander Macro
* ecs-cluster: Create a base ECS cluster
* loggroups: Global log groups
* s3: Very basic S3 bucket
* vpc: Basic VPC for 3 AZs with public/private subnets and everything required for that

## CloudFormation Macros

* NACLExpander: Expands NACLs, see its own README for more details
* ECRExpander: Allows for many ECR repos in a concise syntax
