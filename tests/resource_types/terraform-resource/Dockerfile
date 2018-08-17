FROM gcr.io/cloud-solutions-group/terraform-resource:beta-backend

ARG HELM_PROVIDER_VERSION=v0.5.0
ARG HELM_VERSION=v2.9.0

RUN apk --no-cache add \
        jq \
        openssl && \
    wget https://github.com/mcuadros/terraform-provider-helm/releases/download/${HELM_PROVIDER_VERSION}/terraform-provider-helm_${HELM_PROVIDER_VERSION}_linux_amd64.tar.gz && \
        tar -xvf terraform-provider-helm*.tar.gz && \
        mkdir -p ~/.terraform.d/plugins/ && \
        mv terraform-provider-helm*/terraform-provider-helm ~/.terraform.d/plugins/ && rm -rf /terraform-provider-helm* && \
    wget https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz && \
        tar -xvf helm-*.tar.gz && mv linux-amd64/helm /usr/local/bin/helm && rm -Rf linux-amd64 && rm -f /helm-*.tar.gz && \
        helm init -c

ENV CLOUD_SDK_VERSION 198.0.0

ENV PATH /google-cloud-sdk/bin:$PATH
RUN apk --no-cache add \
        curl \
        python \
        py-crcmod \
        bash \
        libc6-compat \
        openssh-client \
        git \
    && curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    tar xzf google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    rm google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    ln -s /lib /lib64 && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image && \
    gcloud --version && \
    echo "Y" | gcloud components install beta kubectl
