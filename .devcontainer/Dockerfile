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
    postgresql-client \
    sqlite3 \
    pandoc \
    texlive \
    texlive-latex-extra \
    wkhtmltopdf \
    htop

## Install latest vim
RUN add-apt-repository ppa:jonathonf/vim && \
	apt-get update && \
	apt-get -yq install vim

## Install latest python
RUN add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && \
    apt-get -yq install python3 python3-dev python3-venv python3-pip && \
    ln -s /usr/bin/python3 /usr/bin/python

## Install latest go
RUN GO_VERSION="$(git ls-remote https://github.com/golang/go | grep -oE "refs/tags/go[0-9]+\.[0-9]+(\.[0-9])?$" | sed 's|refs/tags/go||g' | sort --version-sort | tail -n 1)" && \
    ARCH=$(basename "${TARGETPLATFORM}") && \
    curl -fsSL "https://dl.google.com/go/go${GO_VERSION}.linux-${ARCH}.tar.gz" | tar -xz -C /usr/local

## Install latest docker
RUN curl -fsSL https://get.docker.com | bash

## Install latest Azure CLI
RUN curl -fsSL https://aka.ms/InstallAzureCLIDeb | bash

## Install latest doctl
RUN DOCTL_VERSION="$(git ls-remote https://github.com/digitalocean/doctl | grep refs/tags | grep -oE "[0-9]+\.[0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1)" && \
    ARCH=$(basename "${TARGETPLATFORM}") && \
    curl -fsSL "https://github.com/digitalocean/doctl/releases/download/v${DOCTL_VERSION}/doctl-${DOCTL_VERSION}-linux-${ARCH}.tar.gz" | tar -xz -C /usr/local/bin && \
    chmod +x /usr/local/bin/doctl

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
ENV HOME=/home/nonroot
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd --gid "${USER_GID}" "${USERNAME}" && \
    useradd --uid "${USER_UID}" --gid "${USER_GID}" --create-home "${USERNAME}" && \
    apt-get update && \
    apt-get -yq install sudo && \
    echo "${USERNAME}" ALL=\(root\) NOPASSWD:ALL > "/etc/sudoers.d/${USERNAME}" && \
    chmod 0440 "/etc/sudoers.d/${USERNAME}" && \
    usermod -aG docker "${USERNAME}"
USER "${USERNAME}:${USERNAME}"

## Delete default configs
RUN rm "${HOME}/.profile" "${HOME}/.bashrc" && \
    touch "${HOME}/.bashrc"

## Install latest docker-lock
RUN mkdir -p "${HOME}/.docker/cli-plugins" && \
    DOCKER_LOCK_VERSION="$(git ls-remote https://github.com/safe-waters/docker-lock | grep refs/tags | grep -oE "[0-9]+\.[0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1)" && \
    ARCH=$(basename "${TARGETPLATFORM}") && \
    [[ "${ARCH}" == "amd64" ]] && ARCH="x86_64"; \
    curl -fsSL "https://github.com/safe-waters/docker-lock/releases/download/v${DOCKER_LOCK_VERSION}/docker-lock_${DOCKER_LOCK_VERSION}_Linux_${ARCH}.tar.gz" | tar -xz -C "${HOME}/.docker/cli-plugins" && \
    chmod +x "${HOME}/.docker/cli-plugins/docker-lock"

## Install compose-cli
RUN COMPOSE_VERSION="$(git ls-remote https://github.com/docker/compose-cli | grep refs/tags | cut -f2 | sed 's@refs/tags/@@' | sort --version-sort | tail -n 1)" && \
   ARCH=$(basename "${TARGETPLATFORM}") && \
   curl -fsSL "https://github.com/docker/compose-cli/releases/download/${COMPOSE_VERSION}/docker-compose-linux-${ARCH}" -o "${HOME}/.docker/cli-plugins/docker-compose" && \
   chmod +x "${HOME}/.docker/cli-plugins/docker-compose"

## Install latest node
RUN curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh" | PROFILE="${HOME}/.bashrc" bash && \
    source "${HOME}/.bashrc" && \
    nvm install node && \
    nvm use node

## Install vim plugins
RUN mkdir -p "${HOME}/.vim"
COPY --chown="${USERNAME}:${USERNAME}" .vim-plug "${HOME}/.vim-plug"
COPY --chown="${USERNAME}:${USERNAME}" .vim-custom "${HOME}/.vim-custom"
COPY --chown="${USERNAME}:${USERNAME}" coc-settings.json "${HOME}/.vim/coc-settings.json"
RUN source "${HOME}/.bashrc" && \
    cp "${HOME}/.vim-plug" "${HOME}/.vimrc" && \
    curl -fLo "${HOME}/.vim/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && \
    vim +'PlugInstall --sync' +qa && \
    mkdir -p "${HOME}/.config/coc" && \
    vim +'CocInstall -sync coc-prettier coc-html coc-json coc-yaml coc-pyright coc-tsserver' +qa

## Create .vimrc from plugins & custom overrides
RUN cat "${HOME}/.vim-plug" "${HOME}/.vim-custom" > "${HOME}/.vimrc"

## Install python libraries
ENV PATH="${HOME}/.local/bin:${PATH}"
RUN pip3 install black pandas numpy matplotlib jupyterlab

## Install go packages
### Note: coc-go installs gopls when using vim - instead of coc-go, just install gopls so it is ready on container startup.
### Other coc-* extensions behave much better.
ENV GOROOT="/usr/local/go"
ENV GOPATH="${HOME}/go"
ENV PATH="${GOROOT}/bin:${GOPATH}/bin:${PATH}"
RUN go install golang.org/x/tools/gopls@latest && \
    go install github.com/go-delve/delve/cmd/dlv@latest

## Customize tmux
RUN echo "set-option -g default-command /bin/bash" > "${HOME}/.tmux.conf" && \
    echo "set-option -g mouse on" >> "${HOME}/.tmux.conf"

## Customize bashrc
RUN echo "export TERM=xterm-color" >> "${HOME}/.bashrc" && \
    sudo cat /root/.bashrc >> "${HOME}/.bashrc" && \
    echo "set -o vi" >> "${HOME}/.bashrc" && \
    echo "alias tmux='tmux -u'" >> "${HOME}/.bashrc" && \
    echo "export PATH=${PATH}" >> "${HOME}/.bashrc" && \
    echo "nvm use node > /dev/null 2>&1" >> "${HOME}/.bashrc"

## Customize .profile
RUN sudo cat /root/.profile >> "${HOME}/.profile"

## Cleanup
RUN sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

# Mimic VSCode's workspace
RUN mkdir -p "${HOME}/workspaces/dev-container"
WORKDIR "${HOME}/workspaces/dev-container"
