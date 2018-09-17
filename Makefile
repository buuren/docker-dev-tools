.DEFAULT_GOAL := help

REGISTRY := docker.io
NAME := cloud-dev-tools
TAG := latest

DOCKER := /usr/bin/docker
PROXY := http://172.17.0.1:3128
NOPROXY := localhost

run: ## Start container
	${DOCKER} run \
		--name ${NAME} \
		--hostname=${NAME} \
		--entrypoint /usr/bin/bash \
		--net=host \
		--privileged \
		-it \
		-e USER=root \
		-e HTTP_PROXY=${PROXY} \
		-e HTTPS_PROXY=${PROXY} \
		-e NOPROXY=${NOPROXY} \
		-e http_proxy=${PROXY} \
		-e https_proxy=${PROXY} \
		-e noproxy=${NOPROXY} \
		-v ${HOME}:/home/cloud/home:ro \
		-v /var/run/docker.sock:/var/run/docker.sock:ro \
		--rm \
		${REGISTRY}/${NAME}:${TAG}

build: ## Build image
	${DOCKER} build \
		--tag=${REGISTRY}/${NAME}:${TAG} \
		--build-arg PACKER=1.2.5 \
		--build-arg TERRAFORM=0.11.7 \
		--build-arg VAGRANT=2.1.2 \
		--build-arg AWSCLI=1.15.73 \
		--build-arg AWS_ECS_CLI=1.8.0 \
		--build-arg AWS_EB_CLI=3.14.5 \
		--build-arg GO=1.10 \
		--build-arg SERVERSPEC=2.41.3 \
		.

push: ## Push image
	${DOCKER} tag ${NAME}:${TAG} ${REGISTRY}/${NAME}:${TAG} 
	${DOCKER} push ${REGISTRY}/${NAME}:${TAG}

pull: ## Pull image
	${DOCKER} pull ${REGISTRY}/${NAME}:${TAG}

.PHONY: help
help:  ## Show this message
	@echo -e "\nUsage: \n"
	@ grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\t\033[36mmake %-15s\033[0m %s\n", $$1, $$2}'
