#!/usr/bin/env bash

SSH_COPY="${HOME}"/.ssh-copy
if [[ -d "${SSH_COPY}" ]]; then
    mkdir -p "${HOME}"/.ssh
    cp -r "${HOME}"/.ssh-copy/* "${HOME}"/.ssh
    if [[ -f "${HOME}/.ssh/config" ]]; then
        rm -rf "${HOME}"/.ssh/config
    fi
    chmod 700 "${HOME}"/.ssh
    chmod 600 "${HOME}"/.ssh/*
fi
