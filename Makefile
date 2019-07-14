CFN_TEMPLATES=$(wildcard *.yml */*.yml */*/*.yml)
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

deploy-cluster-demo:
	@./build.sh -n CCAU-Demo-Cluster -f ecs-cluster -t common-tags -p ccau-ecs-democluster

deploy-cluster-cuddle:
	@./build.sh -n CCAU-CuddleKube-Cluster -f ecs-cluster -t common-tags -p ccau-ecs-cuddle-kube

deploy-ecr-repos:
	@./build.sh -n CCAU-ECR-Repos -f ecr-repos -t common-tags

deploy-iam:
	@./build.sh -n CCAU-IAM -f iam -t common-tags

deploy-route53:
	@./build.sh -n CCAU-Route53 -f route53 -t common-tags -p ccau-route53

deploy-servicediscovery:
	@./build.sh -n CCAU-ServiceDiscovery -f servicediscovery -t common-tags -p ccau-servicediscovery

deploy-tasks:
	@./build.sh -n CCAU-Task-DummyPassthroughAPI -f ecs-task -t common-tags -p ccau-task-dummy-passthrough-api
	@./build.sh -n CCAU-Task-FeedAPI -f ecs-task -t common-tags -p ccau-task-feed-api
	@./build.sh -n CCAU-Task-ListAPI -f ecs-task -t common-tags -p ccau-task-list-api
	@./build.sh -n CCAU-Task-OrderAPI -f ecs-task -t common-tags -p ccau-task-order-api
	@./build.sh -n CCAU-Task-RegisterAPI -f ecs-task -t common-tags -p ccau-task-register-api
	@./build.sh -n CCAU-Task-ValidateAPI -f ecs-task -t common-tags -p ccau-task-validate-api
	@./build.sh -n CCAU-Task-PublicSite -f ecs-task -t common-tags -p ccau-task-public-site

deploy-services:
	# @./build.sh -n CCAU-Service-DummyPassthroughAPI -f ecs-service -t common-tags -p ccau-service-dummy-passthrough-api
	@./build.sh -n CCAU-Service-FeedAPI -f ecs-service -t common-tags -p ccau-service-feed-api
	@./build.sh -n CCAU-Service-ListAPI -f ecs-service -t common-tags -p ccau-service-list-api
	@./build.sh -n CCAU-Service-OrderAPI -f ecs-service -t common-tags -p ccau-service-order-api
	@./build.sh -n CCAU-Service-RegisterAPI -f ecs-service -t common-tags -p ccau-service-register-api
	@./build.sh -n CCAU-Service-ValidateAPI -f ecs-service -t common-tags -p ccau-service-validate-api
	@./build.sh -n CCAU-Service-PublicSite -f ecs-service -t common-tags -p ccau-service-public-site

deploy-mesh:
	@./build.sh -n CCAU-CuddleKubeMesh -f appmesh -t common-tags -p ccau-appmesh
	@./build.sh -n CCAU-CuddleKubeMeshStructure -f mesh-structure -t common-tags -p ccau-appmesh-structure