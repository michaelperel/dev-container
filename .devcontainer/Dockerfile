FROM --platform="${BUILDPLATFORM}" ubuntu:focal

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

# Install environment

## linux/amd64 or linux/arm64 supported
ARG TARGETPLATFORM

## Create nonroot user with sudo support
ARG USERNAME=nonroot
ENV HOME="/home/${USERNAME}"
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd --non-unique --gid "${USER_GID}" "${USERNAME}" \
    && useradd --non-unique --uid "${USER_UID}" --gid "${USER_GID}" -m "${USERNAME}" \
    && apt-get update \
    && apt-get -yq install sudo \
    && echo "${USERNAME}" ALL=\(root\) NOPASSWD:ALL > "/etc/sudoers.d/${USERNAME}" \
    && chmod 0440 "/etc/sudoers.d/${USERNAME}"

## Use nonroot user
USER "${USERNAME}"

## Install basic tools
RUN sudo ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime && \
    sudo apt-get update && \
    sudo apt-get -yq install \
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
RUN sudo add-apt-repository ppa:deadsnakes/ppa && \
    sudo apt-get update && \
    sudo apt-get -yq install python3 python3-dev python3-venv python3-pip && \
    mkdir -p "${HOME}/.local/bin"
ENV PATH="${HOME}/.local/bin:${PATH}"

## Install latest python libraries
RUN pip3 install --user black

## Install latest go
ENV GOROOT="${HOME}/.local/go"
ENV GOPATH="${HOME}/go"
ENV PATH="${GOPATH}/bin:${GOROOT}/bin:${PATH}"
RUN GO_VERSION="$(git ls-remote https://github.com/golang/go | grep refs/tags | grep -oE "[0-9]+\.[0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1)" && \
    ARCH=$(basename ${TARGETPLATFORM}) && \
    curl -fsSL "https://dl.google.com/go/go${GO_VERSION}.linux-${ARCH}.tar.gz" | tar -xz -C "${HOME}/.local"

## Install latest go libraries
RUN GOLANGCI_LINT_VERSION="$(git ls-remote https://github.com/golangci/golangci-lint | grep refs/tags | grep -oE "[0-9]+\.[0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1)" && \
    curl -fsSL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | bash -s -- -b "${GOPATH}/bin" "v${GOLANGCI_LINT_VERSION}"

## Install latest node, npm
RUN NODE_VERSION=14 && \
    curl -fsSL "https://deb.nodesource.com/setup_${NODE_VERSION}.x" | sudo bash && \
    sudo apt-get -yq install nodejs

## Install latest docker
RUN curl -fsSL https://get.docker.com | sudo bash && \
    sudo usermod -aG docker "${USERNAME}"

## Install latest docker-compose
RUN pip3 install --user docker-compose

## Install latest Azure CLI
RUN curl -fsSL https://aka.ms/InstallAzureCLIDeb | sudo bash

## Install latest kubectl
RUN KUBECTL_VERSION="$(curl -fsSL https://storage.googleapis.com/kubernetes-release/release/stable.txt)" && \
    ARCH=$(basename ${TARGETPLATFORM}) && \
    curl -fsSL "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl" -o "${HOME}/.local/bin/kubectl" && \
    chmod +x "${HOME}/.local/bin/kubectl"

## Install latest helm
RUN curl -fsSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | sudo bash

## Install latest fluxctl
RUN FLUXCTL_VERSION="$(git ls-remote https://github.com/fluxcd/flux | grep refs/tags | grep -oE "[0-9]+\.[0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1)" && \
    ARCH=$(basename ${TARGETPLATFORM}) && \
    curl -fsSL "https://github.com/fluxcd/flux/releases/download/${FLUXCTL_VERSION}/fluxctl_linux_${ARCH}" -o "${HOME}/.local/bin/fluxctl" && \
    chmod +x "${HOME}/.local/bin/fluxctl"

## Install latest terraform
RUN TERRAFORM_VERSION="$(curl -fsSL https://releases.hashicorp.com/terraform/ | grep -oE "[0-9]+\.[0-9]+\.[0-9]+<" | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" | head -n 1)" && \
    ARCH=$(basename ${TARGETPLATFORM}) && \
    [[ "${ARCH}" == "arm64" ]] && ARCH=${ARCH//[0-9]/}; \
    curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip" -o "${HOME}/.local/terraform.zip" && \
    unzip "${HOME}/.local/terraform.zip" -d "${HOME}/.local/bin"

# Customize environment

## Install Vim Awesome
RUN mkdir -p "${HOME}/.vim_runtime" && \
    git clone --depth=1 https://github.com/amix/vimrc.git "${HOME}/.vim_runtime" && \
    "${HOME}/.vim_runtime/install_awesome_vimrc.sh"

## Add custom vimrc
COPY --chown="${USER_UID}":"${USER_GID}" vim/my_configs.vim "${HOME}/.vim_runtime/my_configs.vim"

## Install YouCompleteMe vim plugin
RUN git clone https://github.com/ycm-core/YouCompleteMe.git "${HOME}/.vim_runtime/my_plugins/YouCompleteMe" && \
    cd "${HOME}/.vim_runtime/my_plugins/YouCompleteMe" && \
    git submodule update --init --recursive "${HOME}/.vim_runtime/my_plugins/YouCompleteMe" && \
    PATH="${PATH}" ./install.py --clangd-completer --go-completer

## Set vim color support for tmux
RUN echo "export TERM=xterm-256color" | sudo tee -a "${HOME}/.bashrc"

# Cleanup
RUN sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

# Mimic VSCode's workspace
RUN mkdir -p ${HOME}/workspaces/app
WORKDIR "${HOME}/workspaces/app"