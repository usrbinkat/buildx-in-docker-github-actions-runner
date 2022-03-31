#!/bin/bash -x
sudo docker run \
    -it --rm --privileged \
    -e TOKEN=$1 \
  docker.io/usrbinkat/gha-runner:buildx \
    
