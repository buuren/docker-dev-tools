#!/bin/bash
set -e

IMAGE_NAME=""
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/image-config.sh

function vte-bash()
{
    echo "Running vte-bash command with args: $@"
    #[ -f ~/.aws/credentials ] && docker cp -f ~/.aws/credentials
	docker run --net=host -it --rm --entrypoint /bin/bash "${IMAGE_NAME}" -c "bash"
}

function vte-make()
{
    echo "Running vte-make command with args: $@"
	docker run --net=host --privileged -it -v $(pwd):$(pwd) --rm --entrypoint /bin/bash "${IMAGE_NAME}" -c "cd $(pwd); make $@"
}

function vte-packer()
{
    echo "Running vte-packer command with args: $@"
	docker run --net=host --privileged -it -v $(pwd):$(pwd) --rm --entrypoint /bin/bash "${IMAGE_NAME}" -c "cd $(pwd); /opt/packer/packer $@"
}

function vte-terraform()
{
    echo "Running vte-terraform command with args: $@"
	docker run --net=host --privileged -it -v $(pwd):$(pwd) --rm --entrypoint /bin/bash "${IMAGE_NAME}" -c "cd $(pwd); /opt/terraform/terraform $@"
}

function vte-terraform-wrapper()
{
    echo "Running vte-terraform-wrapper command with args: $@"
	docker run --net=host --privileged -it -v $(pwd):$(pwd) --rm --entrypoint /bin/bash "${IMAGE_NAME}" -c "cd $(pwd); ./terraform-wrapper.sh $*"
}

function vte-aws()
{
    echo "Running vte-aws command with args: $@"
    #export AWS_CREDENTIAL_PROFILES_FILE=path/to/credentials_file
    #~/.aws/credentials
    # AWS_DEFAULT_REGION
    # AWS_ACCESS_KEY_ID
    # AWS_SECRET_ACCESS_KEY
    # [default]
    # aws_access_key_id={YOUR_ACCESS_KEY_ID}
    # aws_secret_access_key={YOUR_SECRET_ACCESS_KEY}

	docker run --net=host -it --rm --entrypoint /bin/bash "${IMAGE_NAME}" -c "aws $@"
}