FROM docker.io/library/fedora:35 AS builder

ARG DNF_FLAGS="\
  -y \
  --nodocs \
  --releasever 35 \
  --setopt install_weak_deps=false \
  --installroot \
"
ARG DNF_PACKAGES="\
  tar \
  dnf \
  curl \
  sudo \
  openssl \
  dnf-plugins-core \
  coreutils-single \
  glibc-minimal-langpack \
"

################################################################################
# Build Centos Stream 9 Container from scratch
ARG ROOTFS="/rootfs"
RUN set -ex \
     && mkdir -p ${ROOTFS} \
     && dnf install ${DNF_FLAGS} ${ROOTFS} ${DNF_PACKAGES} \
     && dnf clean all ${DNF_FLAGS} ${ROOTFS} \
     && rm -rf ${ROOTFS}/var/cache/* \
    && echo
FROM scratch
COPY --from=builder /rootfs/ /

################################################################################
# Install Docker
RUN set -ex \
     && dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo \
     && dnf install -y docker-ce docker-ce-cli containerd.io \
    && echo

# Create User & Group
ENV UID=1001
ENV USR=runner
ENV GRP=docker
RUN set -ex \
  && useradd --user-group --uid $UID --groups ${GRP} ${USR} \
  && echo "$USR ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
  && echo

# Install GH Runner
ARG RUNNER_PATH="/home/runner"
USER runner

RUN set -ex \
     && mkdir -p ${RUNNER_PATH} \
    && echo
WORKDIR /home/runner

RUN set -ex \
     && export urlGHActionsRelease="https://api.github.com/repos/actions/runner/releases/latest"               \
     && export urlGHActionsVersion="$(curl -s ${urlGHActionsRelease} | awk -F '["v,]' '/tag_name/{print $5}')" \
     && export urlGHActionsBase="https://github.com/actions/runner/releases/download"                          \
     && export urlGHActionsBin="actions-runner-linux-x64-${urlGHActionsVersion}.tar.gz"                        \
     && export urlGHActions="${urlGHActionsBase}/v${urlGHActionsVersion}/${urlGHActionsBin}"                   \
     && curl -L ${urlGHActions}                                                                                \
        | tar xzvf - --directory ${RUNNER_PATH}                                                                \
     && sudo /home/runner/bin/installdependencies.sh                                                           \
    && echo

ADD /rootfs /
ENTRYPOINT /entrypoint.sh
CMD /bin/bash
