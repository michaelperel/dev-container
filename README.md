![ci](https://github.com/michaelperel/dev-container/workflows/ci/badge.svg)
![cd](https://github.com/michaelperel/dev-container/workflows/cd/badge.svg)

# What is this?
* A container based on ubuntu with the latest version of common tools for development

# What is included
* docker
* docker-compose
* docker-lock
* az cli
* kubectl
* helm
* terraform
* python 3, pip3
* black
* go
* golangci-lint
* dlv
* node, npm
* vim with a sensible configuration
* tmux
* psql

# Using a Pre-built Container
* The container is a few gigabytes. It prioritizes readability and breadth of tools over size.
* To use a nightly, pre-built container for linux/amd64 or linux/arm64:
```
docker run -it -v ${PWD}:/nonroot/home/workspaces/app mperel/dev-container
```

# Building From Scratch
* By default, the container runs as a nonroot user (as a sudoer) with UID and GID = 1000. This user exists
so that if you map a volume, file permissions will not be root. On MacOS, you do not need
to change these values. On Linux, if you are not using the first user on your
machine, you should change these values to match your current
UID and GID. Either way, the following build command will work (change TARGETPLATFORM):
```
docker build -f .devcontainer/Dockerfile --build-arg TARGETPLATFORM=<either linux/amd64 or linux/arm64> --build-arg USER_UID=$(id -u) --build-arg USER_GID=$(id -g) -t mperel/dev-container .devcontainer
```

* If you would like to build for all platforms, use [docker buildx](https://github.com/docker/buildx)
```
docker buildx build -f .devcontainer/Dockerfile --platform linux/arm64,linux/amd64 -t mperel/dev-buildx-container .devcontainer
```

# Editor
* vim
    * To open a file tree: `CTRL+g`
    * To goto definition: `,+g`
    * To goto docs: `,+d`
    * To cycle forward through autocomplete suggestions: `TAB`
    * To cycle backward through autocomplete suggestions: `SHIFT+TAB`
* vscode
    * Install the [Remote-Container Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
    * Copy the .devcontainer directory into your project
    * In the command palette, type: `Remote-Containers: Reopen in Container`
    * In the command palette, type: `Go: Install/Update Tools` and select all
    * When all tools are finished installing, in the command palette
    type: `Developer: Reload Window`
    * The docker daemon is mapped from the host into the dev container,
    so you can use docker and docker-compose commands (with sudo) from within
    the container as if they were run on the host. 
