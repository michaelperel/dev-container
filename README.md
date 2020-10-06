[![Build Status](https://dev.azure.com/michaelsethperel/dev-container/_apis/build/status/michaelperel.dev-container?branchName=master)](https://dev.azure.com/michaelsethperel/dev-container/_build/latest?definitionId=5&branchName=master)

# What is this?
* A container based on ubuntu with the latest version of common tools for development

# What is included
* docker
* docker-compose
* az cli
* kubectl
* helm
* fluxctl
* terraform
* python 3
* go
* vim with a sensible configuration

# Usage
* The container is a few gigabytes. It prioritizes readability and breadth of tools over size.
* By default, the container runs as a nonroot user with UID and GID = 1000. This user exists
so that if you map a volume, file permissions will not be root. On MacOS, you do not need
to change these values. On Linux, you should change these values to match your current
UID and GID on the host. Either way, the following build command will work:
```
docker build -f .devcontainer/Dockerfile --build-arg USER_UID=$(id -u) --build-arg USER_GID=$(id -g) -t mperel/dev-container .devcontainer
```

* To build for arm64 (raspberry pi 4, for instance):
```
docker build -f .devcontainer/Dockerfile --build-arg ARCH=arm64 --build-arg USER_UID=$(id -u) --build-arg USER_GID=$(id -g) -t mperel/dev-container .devcontainer
```

* To run:
```
docker run -it -v ${PWD}:/home/nonroot/workspaces/app -v /var/run/docker.sock:/var/run/docker.sock mperel/dev-container
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
    so you can use docker and docker-compose commands from within
    the container as if they were run on the host
