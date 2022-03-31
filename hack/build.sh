#!/bin/bash -x
docker buildx build --tag docker.io/usrbinkat/gha-runner:buildx --platform linux/amd64 --file ./Containerfile --pull --load ./
