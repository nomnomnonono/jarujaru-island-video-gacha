.PHONY: lint format upload_html push_api_image push_batch_image

UV ?= uv

AWS_REGION = ap-northeast-1
AWS_PROFILE = developer
ACCOUNT_ID = $(shell aws sts get-caller-identity --profile $(AWS_PROFILE) --query Account --output text)
ECR_REPO = $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
BUCKET_NAME = $(shell terraform -chdir=terraform output -raw bucket_name)
API_REP_NAME = $(shell terraform -chdir=terraform output -raw api_repository_name)
BATCH_REP_NAME = $(shell terraform -chdir=terraform output -raw batch_repository_name)


lint:
	$(UV) run ruff check .
	$(UV) run mypy backend

format:
	$(UV) run ruff format .
	$(UV) run ruff check . --fix

upload_html:
	aws s3 cp ./frontend/index.html s3://$(BUCKET_NAME) --profile $(AWS_PROFILE)

push_api_image:
	aws ecr get-login-password --region ap-northeast-1 --profile $(AWS_PROFILE) | docker login --username AWS --password-stdin $(ECR_REPO)
	docker build -t $(API_REP_NAME) -f ./backend/api/Dockerfile .
	docker tag $(API_REP_NAME):latest $(ECR_REPO)/$(API_REP_NAME):latest
	docker push $(ECR_REPO)/$(API_REP_NAME):latest

push_batch_image:
	aws ecr get-login-password --region ap-northeast-1 --profile $(AWS_PROFILE) | docker login --username AWS --password-stdin $(ECR_REPO)
	docker build -t $(BATCH_REP_NAME) -f ./backend/batch/Dockerfile .
	docker tag $(BATCH_REP_NAME):latest $(ECR_REPO)/$(BATCH_REP_NAME):latest
	docker push $(ECR_REPO)/$(BATCH_REP_NAME):latest
