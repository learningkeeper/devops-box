FROM alpine:latest


ARG TERRAFORM_AWS_PROVIDER_VERSION="2.70.0"
ARG TERRAFORM_VERSION="0.12.25"
ARG KUBECTL_CLI_VERSION="v1.17.0"
ENV KUBECTL_DOWNLOAD_URL="https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_CLI_VERSION/bin/linux/amd64/kubectl"
ENV TERRAFORM_PLUGIN_DIR="/devops/.terraform.d/plugins"
ENV TERRAFORM_ZIP_FILE="terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
ENV TERRAFORM_DOWNLOAD_LINK="https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/$TERRAFORM_ZIP_FILE"
ENV TERRAFORM_AWS_PROVIDER_ZIP_FILE="terraform-provider-aws_${TERRAFORM_AWS_PROVIDER_VERSION}_linux_amd64.zip"
ENV TERRAFORM_AWS_PROVIDER_DOWNLOAD_LINK="https://releases.hashicorp.com/terraform-provider-aws/${TERRAFORM_AWS_PROVIDER_VERSION}/${TERRAFORM_AWS_PROVIDER_ZIP_FILE}"



RUN apk update \
  && apk add --no-cache tini \
  && apk add --no-cache wget curl jq git bash shadow 

# install python3 and upgrade pip3
RUN apk add --no-cache --virtual .build-deps g++ python3-dev libffi-dev openssl-dev && \
  apk add --no-cache --update python3  && \
  apk add cmd:pip3 && \
  pip3 install --upgrade pip setuptools #&& pip3 install awscli==1.18.40

# gcloud cli
RUN curl https://sdk.cloud.google.com | bash 
ENV PATH $PATH:/root/google-cloud-sdk/bin

# get and mv terraform bin to /usr/local/bin
RUN wget --quiet --directory-prefix="/tmp" "${TERRAFORM_DOWNLOAD_LINK}" && \
  unzip "/tmp/${TERRAFORM_ZIP_FILE}" -d /usr/local/bin/ && \
  rm "/tmp/${TERRAFORM_ZIP_FILE}"

#RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl

RUN curl -LO $KUBECTL_DOWNLOAD_URL \
  && chmod +x ./kubectl \
  && mv ./kubectl /usr/local/bin/kubectl \
  && curl -LO https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

CMD ["/sbin/tini", "--", "/bin/bash"]

