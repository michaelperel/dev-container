FROM golang:latest

# Set shell to fail on error
SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

# Supports linux/amd64 or linux/arm64
ARG TARGETPLATFORM

# Ensure installations do not prompt for input
ARG DEBIAN_FRONTEND=noninteractive

# Create non-root user and add to sudoers and docker group
ARG USERNAME=nonroot
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd --gid "${USER_GID}" "${USERNAME}" && \
    useradd --uid "${USER_UID}" --gid "${USER_GID}" --create-home "${USERNAME}" && \
    apt-get update && \
    apt-get install -yq sudo && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    curl -fsSL https://get.docker.com | sh && \
    usermod -aG docker "${USERNAME}"

# Install basic packages
RUN apt-get update && \
    apt-get install -yq \
    git vim tmux curl wget build-essential cmake gcc \
    shellcheck unzip tree jq postgresql-client sqlite3 htop \
    python3 python3-dev python3-venv python3-pip \
    nodejs npm && \
    ln -s /usr/bin/python3 /usr/bin/python

# Install latest doctl
RUN DOCTL_VERSION="$(git ls-remote https://github.com/digitalocean/doctl | grep refs/tags | grep -oE "[0-9]+\.[0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1)" && \
    ARCH=$(basename "${TARGETPLATFORM}") && \
    curl -fsSL "https://github.com/digitalocean/doctl/releases/download/v${DOCTL_VERSION}/doctl-${DOCTL_VERSION}-linux-${ARCH}.tar.gz" | tar -xz -C /usr/local/bin && \
    chmod +x /usr/local/bin/doctl

# Set environment variables
ENV HOME="/home/${USERNAME}"

# Switch to non-root user
USER "${USERNAME}:${USERNAME}"
WORKDIR "${HOME}"

# Install go tools
RUN go install golang.org/x/tools/gopls@latest && \
    go install github.com/go-delve/delve/cmd/dlv@latest

# Setup vim configurations
COPY --chown="${USERNAME}:${USERNAME}" .config.vimrc "${HOME}/.config.vimrc"
COPY --chown="${USERNAME}:${USERNAME}" .plug.vimrc "${HOME}/.vimrc"
COPY --chown="${USERNAME}:${USERNAME}" coc-settings.json "${HOME}/.vim/coc-settings.json"

# Install vim plugins
RUN curl -fLo "${HOME}/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && \
    vim +'PlugInstall --sync' +qa

# Add configurations, once all plugins are already installed
RUN cat "${HOME}/.config.vimrc" >> "${HOME}/.vimrc"

# Configure colored shell prompt
RUN echo 'PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "' >> "${HOME}/.bashrc"

# Configure tmux to source .bashrc for interactive shells
RUN echo 'set-option -g default-command "bash -i"' >> "${HOME}/.tmux.conf"

# Cleanup installations
RUN sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Setup workspace
RUN mkdir -p "${HOME}/workspaces/dev-container"
WORKDIR "${HOME}/workspaces/dev-container"
