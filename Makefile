INFRA_DIR := /home/vlad/infra

enter: dev-tools-image/build ## Spawns a local dev environment in a docker image #docker system prune -a --volumes
	/usr/bin/docker run \
		--name dev-tools \
		--hostname=dev-tools \
		--entrypoint /bin/bash \
		--net=host \
		--privileged \
		-it \
		-v $(INFRA_DIR):$(INFRA_DIR) \
		-e USER=root \
		--rm \
		dev-tools:latest -c "bash"\


dev-tools-image/build: ## Spawns a local dev environment in a docker image
	cd $(INFRA_DIR)/dev-tools && /usr/bin/docker build \
		--tag=dev-tools:latest \
		--build-arg PACKER=1.2.0 \
		--build-arg TERRAFORM=0.11.3 \
		--build-arg VAGRANT=2.0.2 \
		--build-arg AWSCLI=1.14.57 \
		--build-arg GO=1.10 \
		--build-arg SERVERSPEC=2.41.3 \
		.
