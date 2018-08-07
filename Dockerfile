#https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux_atomic_host/7/html/getting_started_with_containers/using_red_hat_base_container_images_standard_and_minimal
FROM centos:latest

ARG PACKER
ARG TERRAFORM
ARG VAGRANT
ARG AWSCLI
ARG GO
ARG SERVERSPEC

ENV ANSIBLE_BIN='/usr/bin/ansible'
ENV VAGRANT_BIN='/opt/vagrant/bin/vagrant'
ENV TERRAFORM_BIN='/opt/terraform/terraform'
ENV PACKER_BIN='/opt/packer/packer'
ENV AWS_CLI_BIN='/usr/bin/aws'

RUN yum -y install unzip \
	make \
	qemu-kvm \
	qemu-kvm-tools \
	qemu-utils \
	ansible \
	gcc \
	libvirt \
	libvirt-devel \
	ruby-devel \
	openssh-clients

RUN curl -L -o /usr/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
RUN chmod +x /usr/bin/jq

# PACKER
RUN curl -L -o /tmp/packer.zip https://releases.hashicorp.com/packer/${PACKER}/packer_${PACKER}_linux_amd64.zip
RUN unzip /tmp/packer.zip -d /opt/packer/

# TERRAFORM
RUN curl -L -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM}/terraform_${TERRAFORM}_linux_amd64.zip
RUN unzip /tmp/terraform.zip -d /opt/terraform/

# VAGRANT
RUN rpm -i https://releases.hashicorp.com/vagrant/${VAGRANT}/vagrant_${VAGRANT}_x86_64.rpm

# PIP
RUN curl -L -o /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py
RUN python /tmp/get-pip.py
RUN rm -f /tmp/get-pip.py

# AWSCLI
RUN pip install "awscli==${AWSCLI}"

# CLEANUP
RUN rm -f /tmp/packer.zip /tmp/terraform.zip

# Install GO
RUN curl -L -o go.tar.gz https://storage.googleapis.com/golang/go${GO}.linux-amd64.tar.gz \
    && tar xzvf go.tar.gz -C /usr/local >/dev/null \
    && rm -f go.tar.gz

RUN gem install serverspec -v ${SERVERSPEC}
RUN gem install rake

# Install kubeadm / kutectl

COPY kubernetes.repo /etc/yum.repos.d/kubernetes.repo
RUN yum update -y
RUN yum install -y kubelet kubeadm kubectl docker
#RUN systemctl enable kubelet && systemctl start kubelet

# add this to bottom
ENV PATH=$PATH:/usr/local/go/bin
ENV GOPATH=/usr/local/go/dev
ENV PATH=$PATH:$GOPATH/bin

#COPY resources/ansible.cfg /etc/ansible/ansible.cfg
#RUN cd /root/metadata-server \
#    && go build


ENTRYPOINT ["echo", "Image has no entrypoint. Specify --entrypoint argument. Example: docker run -it --rm --entrypoint ls"]