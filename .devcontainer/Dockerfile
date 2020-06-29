FROM ubuntu:bionic

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV HOME=/root

# Install environment

## Install basic tools
RUN apt-get update && \
    apt-get -y install vim tmux curl wget build-essential python3-dev cmake gcc shellcheck unzip tree software-properties-common jq gettext-base uuid-runtime

## Install latest git
RUN add-apt-repository ppa:git-core/ppa -y && \
    apt-get update && \
	apt-get install git -y

## Install latest docker
RUN curl -fsSL https://get.docker.com | bash

## Install latest docker-compose
RUN DOCKER_COMPOSE_VERSION="$(git ls-remote https://github.com/docker/compose | grep refs/tags | grep -oE "[0-9]+\.[0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1)" && \
    curl -fsSL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

## Install latest docker-lock
RUN DOCKER_LOCK_VERSION="$(git ls-remote https://github.com/michaelperel/docker-lock | grep refs/tags | grep -oE "[0-9]+\.[0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1)" && \
    mkdir -p "${HOME}/.docker/cli-plugins" && \
    curl -fsSL "https://github.com/michaelperel/docker-lock/releases/download/v${DOCKER_LOCK_VERSION}/docker-lock-linux" -o "${HOME}/.docker/cli-plugins/docker-lock" && \
    chmod +x "${HOME}/.docker/cli-plugins/docker-lock"

## Install latest Azure CLI
RUN curl -fsSL https://aka.ms/InstallAzureCLIDeb | bash

## Install Azure Functions Core Tools
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
    mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg && \
    sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-$(lsb_release -cs)-prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/dotnetdev.list' && \
    apt-get update && \
    apt-get install azure-functions-core-tools

## Install latest kubectl
RUN KUBECTL_VERSION="$(curl -fsSL https://storage.googleapis.com/kubernetes-release/release/stable.txt)" && \
    curl -fsSL "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

## Install latest helm
RUN curl -fsSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

## Install latest fluxctl
RUN FLUXCTL_VERSION="$(git ls-remote https://github.com/fluxcd/flux | grep refs/tags | grep -oE "[0-9]+\.[0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1)" && \
    curl -fsSL "https://github.com/fluxcd/flux/releases/download/${FLUXCTL_VERSION}/fluxctl_linux_amd64" -o /usr/local/bin/fluxctl && \
    chmod +x /usr/local/bin/fluxctl

## Install latest kubeseal
RUN KUBESEAL_VERSION="$(git ls-remote https://github.com/bitnami-labs/sealed-secrets | grep refs/tags | grep -oE "[0-9]+\.[0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1)" && \
    curl -fsSL "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-linux-amd64" -o /usr/local/bin/kubeseal && \
    chmod +x /usr/local/bin/kubeseal

## Install latest terraform
RUN TERRAFORM_VERSION="$(curl -fsSL https://releases.hashicorp.com/terraform/ | grep -oE "[0-9]+\.[0-9]+\.[0-9]+<" | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" | head -n 1)" && \
    curl -fsSLO "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    unzip "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    mv terraform /usr/local/bin && \
    chmod +x /usr/local/bin/terraform

## Install latest Anaconda Python
RUN ANACONDA_VERSION="$(curl https://repo.anaconda.com/archive/ | grep -oE "[0-9]{4}\.[0-9]{2}" | head -n 1)" && \
    ANACONDA_SCRIPT="Anaconda3-${ANACONDA_VERSION}-$(uname -s)-$(uname -m).sh" && \
    curl -fsSLO "https://repo.anaconda.com/archive/${ANACONDA_SCRIPT}" && \
    bash "${ANACONDA_SCRIPT}" -b -p "/usr/local/anaconda3" && \
    rm "${ANACONDA_SCRIPT}"
ENV PATH="/usr/local/anaconda3/bin:${PATH}"

## Install latest go
RUN GO_VERSION="$(git ls-remote https://github.com/golang/go | grep refs/tags | grep -oE "[0-9]+\.[0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1)" && \
    curl -fsSL "https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz" | tar -xz -C /usr/local
ENV PATH="/usr/local/go/bin:${HOME}/go/bin:${PATH}"

# Customize environment

## Install vim-awesome basic edition
RUN curl -fsSL https://raw.githubusercontent.com/amix/vimrc/master/vimrcs/basic.vim > "${HOME}/.vimrc"

## Install vim-plug
RUN curl -fsSLo "${HOME}/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

## Install vim plugins
COPY vim/plugins .
RUN cat plugins >> "${HOME}/.vimrc" && \
    vim +'PlugInstall --sync' +qa > /dev/null && \
    rm plugins

## Customize vim-awesome's vimrc
COPY vim/customrc .
RUN cat customrc >> "${HOME}/.vimrc" && \
    rm customrc

## Set vim color support for tmux
RUN echo "export TERM=xterm-256color" >> "${HOME}/.bashrc"

## Install python libraries
COPY python/requirements.txt .
RUN pip install -r requirements.txt && \
    rm requirements.txt

## Install go libraries
RUN GOLANGCI_LINT_VERSION="$(git ls-remote https://github.com/golangci/golangci-lint | grep refs/tags | grep -oE "[0-9]+\.[0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1)" && \
    curl -fsSL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | bash -s -- -b "${HOME}/go/bin" "v${GOLANGCI_LINT_VERSION}"

# Cleanup
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set PATH
RUN echo "export PATH=${PATH}" >> "${HOME}/.bashrc"

# Start script to manage ssh permissions
COPY cmd/start.sh .

# Mimic VSCode's workspaces
WORKDIR /workspaces/app

CMD /start.sh && bash
