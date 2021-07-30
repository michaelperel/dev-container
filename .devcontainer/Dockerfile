FROM ubuntu

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

# Create system wide environment as root

## Supports linux/amd64 or linux/arm64
ARG TARGETPLATFORM

## Ensure installation does not prompt for input
ARG DEBIAN_FRONTEND=noninteractive

## Install basic tools
RUN apt-get -yq update && \
    apt-get -yq upgrade && \
    apt-get -yq install \
    git \
    vim \
    tmux \
    curl \
    wget \
    build-essential \
    cmake \
    gcc \
    shellcheck \
    unzip \
    tree \
    software-properties-common \
    jq \
    gettext-base \
    uuid-runtime \
    postgresql-client

## Install latest python
RUN add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && \
    apt-get -yq install python3 python3-dev python3-venv python3-pip && \
    ln -s /usr/bin/python3 /usr/bin/python

## Install latest go
RUN GO_VERSION="$(git ls-remote https://github.com/golang/go | grep refs/tags | grep -oE "[0-9]+\.[0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1)" && \
    ARCH=$(basename "${TARGETPLATFORM}") && \
    curl -fsSL "https://dl.google.com/go/go${GO_VERSION}.linux-${ARCH}.tar.gz" | tar -xz -C /usr/local

## Install latest docker
RUN curl -fsSL https://get.docker.com | bash

## Install latest docker-compose
RUN pip3 install docker-compose

## Install latest Azure CLI
RUN curl -fsSL https://aka.ms/InstallAzureCLIDeb | bash

## Install latest kubectl
RUN KUBECTL_VERSION="$(curl -fsSL https://storage.googleapis.com/kubernetes-release/release/stable.txt)" && \
    ARCH=$(basename "${TARGETPLATFORM}") && \
    curl -fsSL "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl" -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

## Install latest helm
RUN curl -fsSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

## Install latest terraform
RUN TERRAFORM_VERSION="$(curl -fsSL https://releases.hashicorp.com/terraform/ | grep -oE "[0-9]+\.[0-9]+\.[0-9]+<" | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" | head -n 1)" && \
    ARCH=$(basename "${TARGETPLATFORM}") && \
    [[ "${ARCH}" == "arm64" ]] && ARCH=${ARCH//[0-9]/}; \
    curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip" -o terraform.zip && \
    unzip terraform.zip -d /usr/local/bin

# Customize environment for nonroot user
ARG USERNAME=nonroot
ENV HOME=/nonroot/home
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd --non-unique --gid "${USER_GID}" "${USERNAME}" \
    && useradd --non-unique --uid "${USER_UID}" --gid "${USER_GID}" -m "${USERNAME}" \
    && apt-get update \
    && apt-get -yq install sudo \
    && echo "${USERNAME}" ALL=\(root\) NOPASSWD:ALL > "/etc/sudoers.d/${USERNAME}" \
    && chmod 0440 "/etc/sudoers.d/${USERNAME}" && \
    mkdir -p "${HOME}" && \
    usermod -aG docker "${USERNAME}" && \
    chown -R "${USER_UID}":"${USER_GID}" "${HOME}"

USER "${USERNAME}"

## Copy config files
COPY .tmux.conf "${HOME}/.tmux.conf"
COPY .bashrc "${HOME}/.bashrc"
COPY .vimrc "${HOME}/.vimrc"

## Set go environment variables
ENV GOROOT="/usr/local/go"
ENV GOPATH="${HOME}/go"
ENV PATH="${GOROOT}/bin:${GOPATH}/bin:${HOME}/.local/bin:${PATH}"
RUN echo "export PATH=${PATH}" | sudo tee -a "${HOME}/.bashrc"

## Install latest go libraries
#RUN go install github.com/go-delve/delve/cmd/dlv@latest && \
#    GOLANGCI_LINT_VERSION="$(git ls-remote https://github.com/golangci/golangci-lint | grep refs/tags | grep -oE "[0-9]+\.[0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1)" && \
#    curl -fsSL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sudo bash -s -- -b "${GOPATH}/bin" "v${GOLANGCI_LINT_VERSION}"

## Install latest docker-lock
RUN mkdir -p "${HOME}/.docker/cli-plugins" && \
    DOCKER_LOCK_VERSION="$(git ls-remote https://github.com/safe-waters/docker-lock | grep refs/tags | grep -oE "[0-9]+\.[0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1)" && \
    ARCH=$(basename "${TARGETPLATFORM}") && \
    [[ "${ARCH}" == "amd64" ]] && ARCH="x86_64"; \
    curl -fsSL "https://github.com/safe-waters/docker-lock/releases/download/v${DOCKER_LOCK_VERSION}/docker-lock_${DOCKER_LOCK_VERSION}_Linux_${ARCH}.tar.gz" | tar -xz -C "${HOME}/.docker/cli-plugins" && \
    chmod +x "${HOME}/.docker/cli-plugins/docker-lock"

## Install vim-go
RUN git clone https://github.com/fatih/vim-go.git "${HOME}/.vim/pack/plugins/start/vim-go" && \
    vim +GoInstallBinaries +qall && \
    vim +"helptags ALL" +qall

## Cleanup
RUN sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

# Mimic VSCode's workspace
RUN mkdir -p "${HOME}/workspaces/app"
WORKDIR "${HOME}/workspaces/app"
