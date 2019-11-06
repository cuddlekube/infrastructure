# Keeping an eye on your serverless containers demo

Repo for the demo from the Container Camp Australia 2019 talk "Keeping an eye on your serverless containers"

## Quick tips

Turn off (set desired to 0) services with `make disable-services`. You can reenable them with a regular `make enable-services`.

If you wish to build the entire project from scratch:
Start with the `make build-s3-artefacts` target, this will create an S3 bucket. Then update the value for **ARTEFACTS_BUCKET** in the Makefile and run the remaining targets until you've deployed the ECR repositories.

Once you have the ECR repositories, use the application repository to build and deploy the applications to ECR before proceeding with the remaining infrastructure.

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
* alb: The public facing ALB
* appmesh: The app mesh itself
* mesh-structure: The structure and configuration for the actual mesh
* servicediscovery: The servicediscovery (Cloud Map) configuration
* dynamodb: the dynamodb
* ecs-task: Template for all ECS tasks
* ecs-serice: Template for all ECS services
* iam: The IAM role for the ECS tasks (slightly overpowered)

## CloudFormation Macros

* NACLExpander: Expands NACLs, see its own README for more details
* ECRExpander: Allows for many ECR repos in a concise syntax
