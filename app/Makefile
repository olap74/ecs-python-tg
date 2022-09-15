TAG ?= latest
REGISTRY_ID ?= 943714287015
REPOSITORY_REGION ?= eu-central-1
APP_NAME ?= flaskapp
ENV_NAME ?= dev
REPO_NAME = $(REGISTRY_ID).dkr.ecr.$(REPOSITORY_REGION).amazonaws.com/${APP_NAME}-${ENV_NAME}

.PHONY: build
build:
	$(MAKE) docker-login
	docker build -t $(REPO_NAME):$(TAG) -f ./Dockerfile .
	docker push $(REPO_NAME):$(TAG)
	$(MAKE) push-cache

.PHONY: build-ci
build-ci:
	$(MAKE) docker-login
	$(MAKE) pull-cache
	docker build -t $(REPO_NAME):$(TAG) --cache-from $(REPO_NAME):cache -f ./Dockerfile .
	docker push $(REPO_NAME):$(TAG)
	$(MAKE) push-cache

.PHONY: docker-login
docker-login:
	aws ecr get-login-password --region $(REPOSITORY_REGION) | docker login --username AWS --password-stdin $(REGISTRY_ID).dkr.ecr.$(REPOSITORY_REGION).amazonaws.com

.PHONY: pull-cache
pull-cache:
	docker pull $(REPO_NAME):cache

.PHONY: push-cache
push-cache:
	docker tag $(REPO_NAME):$(TAG) $(REPO_NAME):cache
	docker push $(REPO_NAME):cache
