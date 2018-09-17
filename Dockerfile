#https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux_atomic_host/7/html/getting_started_with_containers/using_red_hat_base_container_images_standard_and_minimal
FROM centos:latest

ARG PACKER
ARG TERRAFORM
ARG VAGRANT
ARG GO
ARG SERVERSPEC
ARG AWSCLI
ARG AWS_ECS_CLI
ARG AWS_EB_CLI

ENV ANSIBLE_BIN='/usr/bin/ansible'
ENV VAGRANT_BIN='/opt/vagrant/bin/vagrant'
ENV TERRAFORM_BIN='/opt/terraform/terraform'
ENV PACKER_BIN='/opt/packer/packer'
ENV AWS_CLI_BIN='/usr/bin/aws'
ENV PIP_CMD_ARGS='--trusted-host pypi.org --trusted-host files.pythonhosted.org'
ENV LANG=en_US.utf8

ENV HOME_DIR='/home/cloud'
ENV SYS_USER='cloud'

ENV http_proxy http://172.17.0.1:3128
ENV https_proxy http://172.17.0.1:3128

COPY data/crt /etc/pki/ca-trust/source/anchors
RUN update-ca-trust

RUN yum -y install unzip \
	gcc-c++ \
	qemu-kvm \
	patch \
	readline \
	readline-devel \
	zlib zlib-devel \
	qemu-kvm-tools \
	qemu-utils \
	ansible \
	gcc \
	libvirt \
	libvirt-devel \
	ruby-devel \
	openssh-clients \
	libyaml-devel \
	libffi-devel \
	openssl-devel \
	make \
	bzip2 \
	autoconf \
	automake \
	libtool \
	bison \
	iconv-devel \
	sqlite-devel \
	which \
	git \
	sudo

# JQ
RUN curl -L -o /usr/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 \
	&& chmod +x /usr/bin/jq

# AWS_ECS_CLI
RUN curl -L -o /usr/local/bin/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-v${AWS_ECS_CLI} \
	&& chmod +x /usr/local/bin/ecs-cli

# PACKER
RUN curl -L -o /tmp/packer.zip https://releases.hashicorp.com/packer/${PACKER}/packer_${PACKER}_linux_amd64.zip \
	&& unzip /tmp/packer.zip -d /opt/packer/ \
	&& rm -f /tmp/packer.zip

# TERRAFORM
RUN curl -L -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM}/terraform_${TERRAFORM}_linux_amd64.zip \
	&& unzip /tmp/terraform.zip -d /opt/terraform \
	&& rm -f /tmp/terraform.zip

# VAGRANT
RUN rpm -i https://releases.hashicorp.com/vagrant/${VAGRANT}/vagrant_${VAGRANT}_x86_64.rpm

# PIP
RUN curl -L -o /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py \
	&& python /tmp/get-pip.py ${PIP_CMD_ARGS} \
	&& rm -f /tmp/get-pip.py

# AWSCLI
RUN pip install "awscli==${AWSCLI}" ${PIP_CMD_ARGS}
RUN pip install "awsebcli==${AWS_EB_CLI}" ${PIP_CMD_ARGS}

# Install GO
RUN curl -L -o go.tar.gz https://storage.googleapis.com/golang/go${GO}.linux-amd64.tar.gz \
    && tar xzvf go.tar.gz -C /usr/local >/dev/null \
    && rm -f go.tar.gz

# Ruby stuff
RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import - \
	&& curl -L get.rvm.io | bash -s stable

RUN /bin/bash -c "source /etc/profile.d/rvm.sh \
	&& rvm reload \
	&& rvm requirements run \
	&& rvm install 2.5 \
	&& rvm use 2.5 \
	&& gem install serverspec -v ${SERVERSPEC} \
	&& gem install rake"

# Install kubeadm / kutectl
COPY kubernetes.repo /etc/yum.repos.d/kubernetes.repo
RUN yum install -y kubelet kubeadm kubectl docker

#RUN systemctl enable kubelet && systemctl start kubelet

# add this to bottom
ENV PATH=$PATH:/usr/local/go/bin
ENV GOPATH=${HOME_DIR}/go/dev
ENV PATH=$PATH:$GOPATH/bin:$GOPATH/dev/bin

RUN groupadd -g 20229 docker
RUN useradd -d ${HOME_DIR} -G docker -ms /usr/bin/bash ${SYS_USER}

# Additional packages for AWS ECR setup
RUN cd ${HOME_DIR} && \
	go get -u github.com/awslabs/amazon-ecr-credential-helper/ecr-login/cli/docker-credential-ecr-login && \
	chown ${SYS_USER}:${SYS_USER} ${HOME_DIR} -R

ENV http_proxy ""
ENV https_proxy ""

RUN echo 'cloud ALL=(ALL) NOPASSWD: /usr/bin/dockerd' > /etc/sudoers
RUN mkdir -p /opt/infra \
	&& chown cloud:cloud /opt/infra -R

RUN modprobe kvm_intel

USER ${SYS_USER}

COPY .bashrc ${HOME_DIR}

ENTRYPOINT ["echo", "Image has no entrypoint. Specify --entrypoint argument. Example: docker run -it --rm --entrypoint ls"]
