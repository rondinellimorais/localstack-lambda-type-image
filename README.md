# Lambda + Cloudformation + ECR local

Just contributing a little, in my project I have some lambdas that are of type Image. Here's what I did to get around this issue:

### Localstack version

```bash
# docker-compose.yml
image: localstack/localstack-pro:2.3.2
```

My list of services has `ecr`, `ecs` and `eks`

### template.yaml
```yaml
Resources:
  MyTestFunction:
    Type: AWS::Serverless::Function
    Properties:
      PackageType: Image
      FunctionName: !Sub "${AWS::StackName}-MyTest"
    Metadata:
      Dockerfile: Dockerfile
      DockerContext: .
      DockerBuildArgs:
        FUNCTION_DIR: src/functions/my_test
        SOURCE_DIR: src
```

### samconfig.dev.toml

```
capabilities = "CAPABILITY_IAM CAPABILITY_AUTO_EXPAND CAPABILITY_NAMED_IAM"
image_repositories = ["MyTestFunction=localhost.localstack.cloud:4510/dev-stackname/mytestfunction00000000repo"]
```

If you have multiple lambdas you can separate them with commas in the `toml`, something like this:

```
image_repositories = ["MyFn001=repo","MyFn002=repo","MyFn003=repo"]
```

So I built a make function to create the repository every time I do a local deploy:

### MakeFile

```make
deploy-local-dockerimage:
	aws ecr create-repository \
		--repository-name=dev-stackname/mytestfunction00000000repo \
		--endpoint-url=http://localhost:4566 \
		--no-cli-pager > /dev/null 2>&1 || true;

         # other function
	# aws ecr create-repository \
        #     --repository-name=dev-stackname/otherfunction00000000repo .....

	samlocal deploy --config-file samconfig.dev.toml
```

Finally here is the command I use to deploy:

```bash
sam build && make deploy-local-dockerimage
```

### Result

```
....
CREATE_COMPLETE             AWS::ApiGateway::Stage      RestApiGatewayStage         -                         
CREATE_COMPLETE             AWS::CloudFormation::Stac   dev-stackname             -                         
                            k                                                                                 
-------------------------------------------------------------------------------------------------------------

CloudFormation outputs from deployed stack
---------------------------------------------------------------------------------------------------------------
Outputs                                                                                                       
---------------------------------------------------------------------------------------------------------------
Key                 ApiURL                                                                             
Description         API endpoint URL                                                                  
Value               http://2yd3fnnboe.execute-api.localhost.localstack.cloud:4566/dev                                       
---------------------------------------------------------------------------------------------------------------


Successfully created/updated stack - dev-stackname in us-east-1
```

### Testing

```bash
curl http://{{restapiId}}.execute-api.localhost.localstack.cloud:4566/dev/api/v1/mytest
# {"message": "Hello from lambda!!"}
```

https://github.com/localstack/localstack/issues/7196
