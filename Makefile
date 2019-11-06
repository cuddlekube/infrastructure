CFN_TEMPLATES=$(wildcard *.yml */*.yml */*/*.yml)
# Update the below with the bucket created in the deploy-s3-artefacts target
ARTEFACTS_BUCKET="ccau-artefacts-bucket-5dm2b0kss7fd"
.PHONY: cfn-lint deploy-logs-global deploy-vpc-demo

cfn-lint:
	@$(foreach template,$(CFN_TEMPLATES),(echo "Running cfn-lint on $(template)" && cfn-lint  --ignore-checks W3002  --override-spec cfn-lint/override-file.json $(template))  || exit $$?;)

deploy-s3-artefacts:
	@./build.sh -n CCAU-Artefacts -f s3 -t common-tags

build-macro-naclexpander:
	@aws cloudformation package --template-file cfn-macros/NaclExpander/macro-template.yml --s3-bucket $(ARTEFACTS_BUCKET) --output-template-file cfn-macros/NaclExpander/packaged-macro.yml

deploy-macro-naclexpander:
	@aws cloudformation deploy --template-file cfn-macros/NaclExpander/packaged-macro.yml --stack-name Macro-NaclExpander --capabilities CAPABILITY_IAM

build-macro-ecrexpander:
	@aws cloudformation package --template-file cfn-macros/ECRExpander/macro-template.yml --s3-bucket $(ARTEFACTS_BUCKET) --output-template-file cfn-macros/ECRExpander/packaged-macro.yml

deploy-macro-ecrexpander:
	@aws cloudformation deploy --template-file cfn-macros/ECRExpander/packaged-macro.yml --stack-name Macro-ECRExpander --capabilities CAPABILITY_IAM

deploy-logs-global:
	@./build.sh -n CCAU-Logs -f loggroups -t common-tags -p ccau-logs-global

deploy-vpc-demo:
	@./build.sh -n CCAU-Demo-VPC -f vpc -t common-tags -p ccau-vpc-demo

deploy-cluster-cuddle:
	@./build.sh -n CCAU-CuddleKube-Cluster -f ecs-cluster -t common-tags -p ccau-ecs-cuddle-kube

deploy-mesh:
	@./build.sh -n CCAU-CuddleKubeMesh -f appmesh -t common-tags -p ccau-appmesh
	@./build.sh -n CCAU-CuddleKubeMeshStructure -f mesh-structure -t common-tags -p ccau-appmesh-structure

deploy-dynamodb:
	@./build.sh -n CCAU-Dynamo-CuddlyKube -f dynamodb -t common-tags -p ccau-ddb-cuddlykube

deploy-ecr-repos:
	@./build.sh -n CCAU-ECR-Repos -f ecr-repos -t common-tags

deploy-iam:
	@./build.sh -n CCAU-IAM -f iam -t common-tags

deploy-servicediscovery:
	@./build.sh -n CCAU-ServiceDiscovery -f servicediscovery -t common-tags -p ccau-servicediscovery

deploy-alb:
	@./build.sh -n CCAU-ALB -f alb -t common-tags -p ccau-alb

deploy-tasks:
	@./build.sh -n CCAU-Task-FeedAPI -f ecs-task -t common-tags -p ccau-task-feed-api
	@./build.sh -n CCAU-Task-ListAPI -f ecs-task -t common-tags -p ccau-task-list-api
	@./build.sh -n CCAU-Task-OrderAPI -f ecs-task -t common-tags -p ccau-task-order-api
	@./build.sh -n CCAU-Task-RegisterAPI -f ecs-task -t common-tags -p ccau-task-register-api
	@./build.sh -n CCAU-Task-ValidateAPI -f ecs-task -t common-tags -p ccau-task-validate-api
	@./build.sh -n CCAU-Task-PublicSite -f ecs-task -t common-tags -p ccau-task-public-site
	@./build.sh -n CCAU-Task-HappinessAPI -f ecs-task -t common-tags -p ccau-task-happiness-api

deploy-services:
	@./build.sh -n CCAU-Service-FeedAPI -f ecs-service -t common-tags -p ccau-service-feed-api
	@./build.sh -n CCAU-Service-ListAPI -f ecs-service -t common-tags -p ccau-service-list-api
	@./build.sh -n CCAU-Service-OrderAPI -f ecs-service -t common-tags -p ccau-service-order-api
	@./build.sh -n CCAU-Service-RegisterAPI -f ecs-service -t common-tags -p ccau-service-register-api
	@./build.sh -n CCAU-Service-ValidateAPI -f ecs-service -t common-tags -p ccau-service-validate-api
	@./build.sh -n CCAU-Service-PublicSite -f ecs-service -t common-tags -p ccau-service-public-site
	@./build.sh -n CCAU-Service-HappinessAPI -f ecs-service -t common-tags -p ccau-service-happiness-api

disable-services:
	@aws cloudformation update-stack --stack-name CCAU-Service-FeedAPI --use-previous-template --parameters ParameterKey=DesiredCount,ParameterValue=0 ParameterKey=ServiceName,UsePreviousValue=true ParameterKey=TaskDefinitionStack,UsePreviousValue=true ParameterKey=Cluster,UsePreviousValue=true ParameterKey=SubnetIDs,UsePreviousValue=true ParameterKey=SecurityGroups,UsePreviousValue=true ParameterKey=RegistryStack,UsePreviousValue=true
	@aws cloudformation update-stack --stack-name CCAU-Service-ListAPI --use-previous-template --parameters ParameterKey=DesiredCount,ParameterValue=0 ParameterKey=ServiceName,UsePreviousValue=true ParameterKey=TaskDefinitionStack,UsePreviousValue=true ParameterKey=Cluster,UsePreviousValue=true ParameterKey=SubnetIDs,UsePreviousValue=true ParameterKey=SecurityGroups,UsePreviousValue=true ParameterKey=RegistryStack,UsePreviousValue=true
	@aws cloudformation update-stack --stack-name CCAU-Service-OrderAPI --use-previous-template --parameters ParameterKey=DesiredCount,ParameterValue=0 ParameterKey=ServiceName,UsePreviousValue=true ParameterKey=TaskDefinitionStack,UsePreviousValue=true ParameterKey=Cluster,UsePreviousValue=true ParameterKey=SubnetIDs,UsePreviousValue=true ParameterKey=SecurityGroups,UsePreviousValue=true ParameterKey=RegistryStack,UsePreviousValue=true
	@aws cloudformation update-stack --stack-name CCAU-Service-RegisterAPI --use-previous-template --parameters ParameterKey=DesiredCount,ParameterValue=0 ParameterKey=ServiceName,UsePreviousValue=true ParameterKey=TaskDefinitionStack,UsePreviousValue=true ParameterKey=Cluster,UsePreviousValue=true ParameterKey=SubnetIDs,UsePreviousValue=true ParameterKey=SecurityGroups,UsePreviousValue=true ParameterKey=RegistryStack,UsePreviousValue=true
	@aws cloudformation update-stack --stack-name CCAU-Service-ValidateAPI --use-previous-template --parameters ParameterKey=DesiredCount,ParameterValue=0 ParameterKey=ServiceName,UsePreviousValue=true ParameterKey=TaskDefinitionStack,UsePreviousValue=true ParameterKey=Cluster,UsePreviousValue=true ParameterKey=SubnetIDs,UsePreviousValue=true ParameterKey=SecurityGroups,UsePreviousValue=true ParameterKey=RegistryStack,UsePreviousValue=true
	@aws cloudformation update-stack --stack-name CCAU-Service-PublicSite --use-previous-template --parameters ParameterKey=DesiredCount,ParameterValue=0 ParameterKey=ServiceName,UsePreviousValue=true ParameterKey=TaskDefinitionStack,UsePreviousValue=true ParameterKey=Cluster,UsePreviousValue=true ParameterKey=SubnetIDs,UsePreviousValue=true ParameterKey=SecurityGroups,UsePreviousValue=true ParameterKey=RegistryStack,UsePreviousValue=true
	@aws cloudformation update-stack --stack-name CCAU-Service-HappinessAPI --use-previous-template --parameters ParameterKey=DesiredCount,ParameterValue=0 ParameterKey=ServiceName,UsePreviousValue=true ParameterKey=TaskDefinitionStack,UsePreviousValue=true ParameterKey=Cluster,UsePreviousValue=true ParameterKey=SubnetIDs,UsePreviousValue=true ParameterKey=SecurityGroups,UsePreviousValue=true ParameterKey=RegistryStack,UsePreviousValue=true

enable-services:
	@aws cloudformation update-stack --stack-name CCAU-Service-FeedAPI --use-previous-template --parameters ParameterKey=DesiredCount,ParameterValue=1 ParameterKey=ServiceName,UsePreviousValue=true ParameterKey=TaskDefinitionStack,UsePreviousValue=true ParameterKey=Cluster,UsePreviousValue=true ParameterKey=SubnetIDs,UsePreviousValue=true ParameterKey=SecurityGroups,UsePreviousValue=true ParameterKey=RegistryStack,UsePreviousValue=true
	@aws cloudformation update-stack --stack-name CCAU-Service-ListAPI --use-previous-template --parameters ParameterKey=DesiredCount,ParameterValue=1 ParameterKey=ServiceName,UsePreviousValue=true ParameterKey=TaskDefinitionStack,UsePreviousValue=true ParameterKey=Cluster,UsePreviousValue=true ParameterKey=SubnetIDs,UsePreviousValue=true ParameterKey=SecurityGroups,UsePreviousValue=true ParameterKey=RegistryStack,UsePreviousValue=true
	@aws cloudformation update-stack --stack-name CCAU-Service-OrderAPI --use-previous-template --parameters ParameterKey=DesiredCount,ParameterValue=1 ParameterKey=ServiceName,UsePreviousValue=true ParameterKey=TaskDefinitionStack,UsePreviousValue=true ParameterKey=Cluster,UsePreviousValue=true ParameterKey=SubnetIDs,UsePreviousValue=true ParameterKey=SecurityGroups,UsePreviousValue=true ParameterKey=RegistryStack,UsePreviousValue=true
	@aws cloudformation update-stack --stack-name CCAU-Service-RegisterAPI --use-previous-template --parameters ParameterKey=DesiredCount,ParameterValue=1 ParameterKey=ServiceName,UsePreviousValue=true ParameterKey=TaskDefinitionStack,UsePreviousValue=true ParameterKey=Cluster,UsePreviousValue=true ParameterKey=SubnetIDs,UsePreviousValue=true ParameterKey=SecurityGroups,UsePreviousValue=true ParameterKey=RegistryStack,UsePreviousValue=true
	@aws cloudformation update-stack --stack-name CCAU-Service-ValidateAPI --use-previous-template --parameters ParameterKey=DesiredCount,ParameterValue=1 ParameterKey=ServiceName,UsePreviousValue=true ParameterKey=TaskDefinitionStack,UsePreviousValue=true ParameterKey=Cluster,UsePreviousValue=true ParameterKey=SubnetIDs,UsePreviousValue=true ParameterKey=SecurityGroups,UsePreviousValue=true ParameterKey=RegistryStack,UsePreviousValue=true
	@aws cloudformation update-stack --stack-name CCAU-Service-PublicSite --use-previous-template --parameters ParameterKey=DesiredCount,ParameterValue=1 ParameterKey=ServiceName,UsePreviousValue=true ParameterKey=TaskDefinitionStack,UsePreviousValue=true ParameterKey=Cluster,UsePreviousValue=true ParameterKey=SubnetIDs,UsePreviousValue=true ParameterKey=SecurityGroups,UsePreviousValue=true ParameterKey=RegistryStack,UsePreviousValue=true
	@aws cloudformation update-stack --stack-name CCAU-Service-HappinessAPI --use-previous-template --parameters ParameterKey=DesiredCount,ParameterValue=1` ParameterKey=ServiceName,UsePreviousValue=true ParameterKey=TaskDefinitionStack,UsePreviousValue=true ParameterKey=Cluster,UsePreviousValue=true ParameterKey=SubnetIDs,UsePreviousValue=true ParameterKey=SecurityGroups,UsePreviousValue=true ParameterKey=RegistryStack,UsePreviousValue=true
