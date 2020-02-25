#!/bin/bash
# Build context is set to parent directory that contains bootstrap script
# Options may be passed to the bootstrap script by setting ARGS
# ARGS="--build-arg OPTS=-s"
docker build --tag ubuntu16.04:pavedroad --file Dockerfile-ubuntu16.04 .. ${ARGS}
