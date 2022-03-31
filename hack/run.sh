#!/bin/bash -x
sudo docker run \
    --entrypoint bash \
    -it --rm --privileged \
    --volume $(pwd):/build \
  docker.io/usrbinkat/gha-runner:buildx
