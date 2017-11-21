#!/bin/bash
IMAGE_NAME=""
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/image-config.sh

sudo docker build -t="${IMAGE_NAME}" .
