#!/bin/bash

IMAGE_NAME=""
DOCKER_BIN="sudo docker"
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/image-config.sh

function vte-bash()
{
    echo "Running vte-bash command with args: $@"
	${DOCKER_BIN} run --net=host -it --rm --entrypoint /bin/bash "${IMAGE_NAME}" -c "bash"
}

function vte-make()
{
    echo "Running vte-make command with args: $@"
	${DOCKER_BIN} run --net=host --privileged -it -v $(pwd):$(pwd) --rm --entrypoint /bin/bash "${IMAGE_NAME}" -c "cd $(pwd); make $@"
}

function vte-packer()
{
    echo "Running vte-packer command with args: $@"
	${DOCKER_BIN} run --net=host --privileged -it -v $(pwd):$(pwd) --rm --entrypoint /bin/bash "${IMAGE_NAME}" -c "cd $(pwd); /opt/packer/packer $@"
}

function vte-terraform()
{
    echo "Running vte-terraform command with args: $@"
	${DOCKER_BIN} run --net=host --privileged -it -v $(pwd):$(pwd) --rm --entrypoint /bin/bash "${IMAGE_NAME}" -c "cd $(pwd); /opt/terraform/terraform $@"
}

function vte-terraform-wrapper()
{
    echo "Running vte-terraform-wrapper command with args: $@"
	${DOCKER_BIN} run --net=host --privileged -it -v $(pwd):$(pwd) --rm --entrypoint /bin/bash "${IMAGE_NAME}" -c "cd $(pwd); ./terraform-wrapper.sh $*"
}

function vte-aws()
{
    echo "Running vte-aws command with args: $@"
	${DOCKER_BIN} run --net=host -it --rm --entrypoint /bin/bash "${IMAGE_NAME}" -c "aws $@"
}