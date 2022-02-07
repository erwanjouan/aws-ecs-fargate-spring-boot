init:
	PROJECT_NAME=$$(./infra/utils/get_mvn_project_name.sh) && \
	PROJECT_VERSION=$$(./infra/utils/get_mvn_project_version.sh) && \
	TEMPLATE_BUCKET=$${PROJECT_NAME}-cf-templates && \
	aws cloudformation deploy \
		--capabilities CAPABILITY_NAMED_IAM \
		--template-file ./infra/pipeline/init.yml \
		--stack-name $${PROJECT_NAME}-init \
		--parameter-overrides \
			ProjectName=$${PROJECT_NAME} \
			ProjectVersion=$${PROJECT_VERSION} \
			TemplateBucketName=$${TEMPLATE_BUCKET} && \
	aws s3 sync ./infra/pipeline/ s3://$${TEMPLATE_BUCKET}/

push:
	PROJECT_NAME=$$(./infra/utils/get_mvn_project_name.sh) && \
	PROJECT_VERSION=$$(./infra/utils/get_mvn_project_version.sh) && \
	mvn spring-boot:build-image && \
	aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 467420073914.dkr.ecr.eu-west-1.amazonaws.com && \
	docker tag $${PROJECT_NAME}:$${PROJECT_VERSION} 467420073914.dkr.ecr.eu-west-1.amazonaws.com/$${PROJECT_NAME}:$${PROJECT_VERSION} && \
	docker tag $${PROJECT_NAME}:$${PROJECT_VERSION} 467420073914.dkr.ecr.eu-west-1.amazonaws.com/$${PROJECT_NAME}:latest && \
	docker push 467420073914.dkr.ecr.eu-west-1.amazonaws.com/$${PROJECT_NAME}:latest && \
	docker push 467420073914.dkr.ecr.eu-west-1.amazonaws.com/$${PROJECT_NAME}:$${PROJECT_VERSION}

deploy:
	make init && \
	PROJECT_NAME=$$(./infra/utils/get_mvn_project_name.sh) && \
	PROJECT_VERSION=$$(date '+%Y%m%d%H%M%S') && \
	TEMPLATE_BUCKET=$${PROJECT_NAME}-cf-templates && \
	aws cloudformation deploy \
		--capabilities CAPABILITY_NAMED_IAM \
		--template-file ./infra/pipeline/_global.yml \
		--stack-name $${PROJECT_NAME}-global \
		--parameter-overrides \
			ProjectName=$${PROJECT_NAME} \
			ProjectVersion=$${PROJECT_VERSION} \
			TemplateBucketName=$${TEMPLATE_BUCKET}

run:
	@PROJECT_NAME=$$(./infra/utils/get_mvn_project_name.sh) && \
	PROJECT_VERSION=$$(./infra/utils/get_mvn_project_version.sh) && \
	docker run -it -p 8080:8080 $${PROJECT_NAME}:$${PROJECT_VERSION}

destroy:
	@PROJECT_NAME=$$(./infra/utils/get_mvn_project_name.sh) && \
	aws ecr batch-delete-image --
	aws cloudformation delete-stack --stack-name $${PROJECT_NAME}-global; \
	aws cloudformation delete-stack --stack-name $${PROJECT_NAME}-init
