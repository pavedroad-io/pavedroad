#!/bin/bash
# Build context is set to parent directory that contains bootstrap script
# Options may be passed to the bootstrap script by setting ARGS
# ARGS="--build-arg OPTS=-s"
docker build --tag opensuse15.0:pavedroad --file Dockerfile-opensuse15.0 .. ${ARGS}
