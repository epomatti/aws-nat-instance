.PHONY: build

AWS_ACCOUNT_ID := $(aws sts get-caller-identity --query Account --output text)
AWS_REGION := $(aws configure get region)

build:
		sam build

update-function-code:
		rm -rf dist && mkdir -p dist
		sam build
		(cd .aws-sam/build/HelloWorldFunction && zip -rq "../../../dist/lambda.zip" .)
		aws lambda update-function-code --function-name corp --zip-file fileb://dist/lambda.zip
