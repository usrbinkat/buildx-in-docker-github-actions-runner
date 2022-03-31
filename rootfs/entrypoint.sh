#!/bin/bash -x

# Start Docker Daemon
sudo dockerd &

# Start GH Actions Runner
/home/runner/config.sh --url https://github.com/ContainerCraft --token $TOKEN --unattended 
/home/runner/run.sh
