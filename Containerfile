# POC GH Runner + Docker in Docker
# Consider enhancing from:
# - https://github.com/actions-runner-controller/actions-runner-controller/blob/master/runner/Dockerfile.dindrunner

FROM docker.io/library/fedora AS builder

ARG DNF_FLAGS="\
  -y \
  --nodocs \
  --releasever 35 \
  --setopt install_weak_deps=false \
  --installroot \
"

ARG DNF_PACKAGES="\
  jq \
  ftp \
  git \
  tar \
  dnf \
  upx \
  zip \
  zstd \
  wget \
  curl \
  sudo \
  time \
  rsync \
  unzip \
  telnet \
  openssl \
  parallel \
  dnsutils \
  docker-ce \
  net-tools \
  ShellCheck \
  supervisor \
  cloud-utils \
  python3-pip \
  containerd.io \
  docker-ce-cli \
  coreutils-single \
  glibc-minimal-langpack \
"

################################################################################
# Build Container from scratch
ENV PATH='/home/runner/.local/bin:/home/runner/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/var/lib/snapd/snap/bin'
ARG ROOTFS="/rootfs"
RUN set -ex \
     && mkdir -p ${ROOTFS} \
     && dnf install -y dnf-plugins-core \
     && dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo \
     && dnf install ${DNF_FLAGS} ${ROOTFS} ${DNF_PACKAGES} \
     && echo "PATH=${PATH}" > ${ROOTFS}/etc/environment \
     && ln -sf /usr/bin/python3 /usr/bin/python \
     && ln -sf /usr/bin/pip3 /usr/bin/pip \
     && dnf clean all ${DNF_FLAGS} ${ROOTFS} \
     && rm -rf ${ROOTFS}/var/cache/* \
    && echo
FROM scratch
COPY --from=builder /rootfs/ /

################################################################################
# Create User & Group
ARG UID=1001
ARG USR=runner
ARG GRP=docker
RUN set -ex \
     && useradd --user-group --uid $UID --groups ${GRP} ${USR} \
     && echo "$USR ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
     && usermod -aG docker runner \
    && echo

################################################################################
# Install GH Runner
USER runner
WORKDIR /home/runner
ENV HOME='/home/runner'
RUN set -ex \
     && export urlGHActionsRelease="https://api.github.com/repos/actions/runner/releases/latest"               \
     && export urlGHActionsVersion="$(curl -s ${urlGHActionsRelease} | awk -F '["v,]' '/tag_name/{print $5}')" \
     && export urlGHActionsBase="https://github.com/actions/runner/releases/download"                          \
     && export urlGHActionsBin="actions-runner-linux-x64-${urlGHActionsVersion}.tar.gz"                        \
     && export urlGHActions="${urlGHActionsBase}/v${urlGHActionsVersion}/${urlGHActionsBin}"                   \
     && curl -L ${urlGHActions}                                                                                \
        | tar xzvf - --directory /home/runner                                                                  \
     && sudo /home/runner/bin/installdependencies.sh                                                           \
    && echo

ADD /rootfs /
ENTRYPOINT /entrypoint.sh
CMD /bin/bash
