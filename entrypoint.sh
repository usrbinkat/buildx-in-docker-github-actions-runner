#!/bin/bash -x

# Start Docker Daemon
dockerd &

# Start GH Actions Runner
/home/runner/config.sh --url https://github.com/ContainerCraft --unattended --token $GHA_TOKEN
/home/runner/run.sh
