#!/bin/bash

IMAGE_NAME=""
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/image-config.sh

function make() 
(
	docker run --net=host --privileged -it -v $(pwd):$(pwd) --rm --entrypoint /bin/bash "${IMAGE_NAME}" -c "cd $(pwd); pwd; make $@"
)

function packer() 
{
	docker run -it -v $(pwd):/home/vlad/git/ --rm --entrypoint /bin/bash "${IMAGE_NAME}" -c "/opt/packer/packer $@"
}

function terraform() 
{
	docker run -it -v $(pwd):/home/vlad/git/ --rm --entrypoint /bin/bash "${IMAGE_NAME}" -c "/opt/terraform/terraform $@"
}
