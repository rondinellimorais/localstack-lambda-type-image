.PHONY: build deploy-local-dockerimage

localstack_endpoint := http://localhost:4566

build:
	sam build

deploy-local-dockerimage:
	aws ecr create-repository \
		--repository-name=lambda-type-image/mytestfunction00000000repo \
		--endpoint-url=${localstack_endpoint} \
		--no-cli-pager > /dev/null 2>&1 || true;

	# aws ecr create-repository \
	# 	--repository-name=.........

	samlocal deploy --config-file samconfig.dev.toml
