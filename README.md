![ci](https://github.com/michaelperel/dev-container/workflows/ci/badge.svg)
![cd](https://github.com/michaelperel/dev-container/workflows/cd/badge.svg)

# What is this?
* A container based on ubuntu for developing applications in go

# Using a Pre-built Container
* To use a nightly, pre-built container for linux/amd64 or linux/arm64:
```
docker run --rm -it -v ${PWD}:/nonroot/home/workspaces/app mperel/dev-container
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
