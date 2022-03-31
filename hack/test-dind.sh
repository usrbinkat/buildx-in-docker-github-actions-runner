#!/bin/bash -x
sudo docker run -it --rm --privileged --volume $(pwd):/build \
  docker.io/usrbinkat/gha-runner:buildx \
    --tag docker.io/usrbinkat/gha-runner:buildx \
    --file ./Containerfile \
    --pull --load
