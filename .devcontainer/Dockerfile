FROM ubuntu:focal

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

# Create system wide environment as root

## linux/amd64 or linux/arm64 supported
ARG TARGETPLATFORM

## Install basic tools
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime && \
    apt-get update && \
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
    uuid-runtime

## Install latest python
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get -yq install python3 python3-dev python3-venv python3-pip && \
    ln -s /usr/bin/pip3 /usr/bin/pip && \
    ln -s /usr/bin/python3 /usr/bin/python

## Install latest python libraries
RUN pip3 install black

## Install latest node, npm
RUN NODE_VERSION=14 && \
    curl -fsSL "https://deb.nodesource.com/setup_${NODE_VERSION}.x" | bash && \
    apt-get -yq install nodejs

## Install latest go
RUN GO_VERSION="$(git ls-remote https://github.com/golang/go | grep refs/tags | grep -oE "[0-9]+\.[0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1)" && \
    ARCH=$(basename "${TARGETPLATFORM}") && \
    curl -fsSL "https://dl.google.com/go/go${GO_VERSION}.linux-${ARCH}.tar.gz" | tar -xz -C /usr/local

## Install latest go libraries
RUN GOLANGCI_LINT_VERSION="$(git ls-remote https://github.com/golangci/golangci-lint | grep refs/tags | grep -oE "[0-9]+\.[0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1)" && \
    curl -fsSL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | bash -s -- -b /usr/local/bin "v${GOLANGCI_LINT_VERSION}"

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

## Install latest fluxctl
RUN FLUXCTL_VERSION="$(git ls-remote https://github.com/fluxcd/flux | grep refs/tags | grep -oE "[0-9]+\.[0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1)" && \
    ARCH=$(basename "${TARGETPLATFORM}") && \
    curl -fsSL "https://github.com/fluxcd/flux/releases/download/${FLUXCTL_VERSION}/fluxctl_linux_${ARCH}" -o /usr/local/bin/fluxctl && \
    chmod +x /usr/local/bin/fluxctl

## Install latest terraform
RUN TERRAFORM_VERSION="$(curl -fsSL https://releases.hashicorp.com/terraform/ | grep -oE "[0-9]+\.[0-9]+\.[0-9]+<" | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" | head -n 1)" && \
    ARCH=$(basename "${TARGETPLATFORM}") && \
    [[ "${ARCH}" == "arm64" ]] && ARCH=${ARCH//[0-9]/}; \
    curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip" -o terraform.zip && \
    unzip terraform.zip -d /usr/local/bin

## Cleanup
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

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

## Set Env
ENV GOROOT="/usr/local/go"
ENV GOPATH="${HOME}/go"
ENV PATH="${GOROOT}/bin:${GOPATH}/bin:${PATH}"
RUN echo "export PATH=${PATH}" | tee -a "${HOME}/.bashrc"

## Install latest docker-lock
RUN mkdir -p "${HOME}/.docker/cli-plugins" && \
    DOCKER_LOCK_VERSION="$(git ls-remote https://github.com/safe-waters/docker-lock | grep refs/tags | grep -oE "[0-9]+\.[0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1)" && \
    ARCH=$(basename "${TARGETPLATFORM}") && \
    [[ "${ARCH}" == "amd64" ]] && ARCH="x86_64"; \
    curl -fsSL "https://github.com/safe-waters/docker-lock/releases/download/v${DOCKER_LOCK_VERSION}/docker-lock_${DOCKER_LOCK_VERSION}_Linux_${ARCH}.tar.gz" | tar -xz -C "${HOME}/.docker/cli-plugins" && \
    chmod +x "${HOME}/.docker/cli-plugins/docker-lock"

## Install Vim Awesome
RUN mkdir -p "${HOME}/.vim_runtime" && \
    git clone --depth=1 https://github.com/amix/vimrc.git "${HOME}/.vim_runtime" && \
    "${HOME}/.vim_runtime/install_awesome_vimrc.sh"

## Add custom vimrc
COPY vim/my_configs.vim "${HOME}/.vim_runtime/my_configs.vim"

## Install YouCompleteMe vim plugin
RUN git clone https://github.com/ycm-core/YouCompleteMe.git "${HOME}/.vim_runtime/my_plugins/YouCompleteMe" && \
    cd "${HOME}/.vim_runtime/my_plugins/YouCompleteMe" && \
    git submodule update --init --recursive "${HOME}/.vim_runtime/my_plugins/YouCompleteMe" && \
    PATH="${PATH}" ./install.py --clangd-completer --go-completer

## Set vim color support for tmux
RUN echo "export TERM=xterm-256color" | tee -a "${HOME}/.bashrc"

# Mimic VSCode's workspace
RUN mkdir -p "${HOME}/workspaces/app"
WORKDIR "${HOME}/workspaces/app"
