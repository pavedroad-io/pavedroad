#!/bin/bash
# Build context is set to parent directory that contains bootstrap script
# Options for the bootstrap script are passed in the BOOT_OPTS environment variable
# export BOOT_OPTS="-s"
# export BOOT_OPTS="-b <branch-name>"
# export BOOT_OPTS="-s -b <branch-name>"
BOOT_ARGS="--build-arg BOOT_OPTS"
docker build --tag fedora32:pavedroad --file Dockerfile-fedora32 ${BOOT_ARGS} ..
