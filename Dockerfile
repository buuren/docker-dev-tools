#https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux_atomic_host/7/html/getting_started_with_containers/using_red_hat_base_container_images_standard_and_minimal

FROM centos:latest

ARG PACKER_VERSION="1.1.2"
ARG TERRAFORM_VERSION="0.11.0"
ARG VAGRANT_VERSION="2.0.1"

RUN yum -y install unzip \
	make \
	qemu-kvm \
	qemu-kvm-tools

RUN rpm -i https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/vagrant_${VAGRANT_VERSION}_x86_64.rpm

RUN mkdir /opt/tools

RUN curl -L -o /tmp/packer.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip
RUN curl -L -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
RUN curl -L -o /usr/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
RUN chmod +x /usr/bin/jq

RUN unzip /tmp/packer.zip -d /opt/packer/
RUN unzip /tmp/terraform.zip -d /opt/terraform/
RUN rm -f /tmp/packer.zip /tmp/terraform.zip

ENTRYPOINT ["echo", "Specify --entrypoint. Example: docker run -it --rm --entrypoint packer IMAGE_ID"]