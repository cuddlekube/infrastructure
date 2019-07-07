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

deploy-logs-global:
	@./build.sh -n CCAU-Logs -f loggroups -t common-tags -p ccau-logs-global

deploy-vpc-demo:
	@./build.sh -n CCAU-Demo-VPC -f vpc -t common-tags -p ccau-vpc-demo

deploy-cluster-demo:
	@./build.sh -n CCAU-Demo-Cluster -f ecs-cluster -t common-tags -p ccau-ecs-democluster