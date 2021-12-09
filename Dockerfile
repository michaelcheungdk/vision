FROM debian:stable-slim as fetcher
COPY build/fetch_binaries.sh /tmp/fetch_binaries.sh

RUN apt-get update && apt-get install -y \
  curl \
  wget

ENV GRPCURL_VERSION 1.6.0
RUN wget https://github.com/fullstorydev/grpcurl/releases/download/v${GRPCURL_VERSION}/grpcurl_${GRPCURL_VERSION}_linux_x86_64.tar.gz -O /tmp/grpcurl_${GRPCURL_VERSION}_linux_x86_64.tar.gz && \
    mkdir ./grpcurl_${GRPCURL_VERSION}_linux_x86_64 && \
    tar -zxvf /tmp/grpcurl_${GRPCURL_VERSION}_linux_x86_64.tar.gz -C grpcurl_${GRPCURL_VERSION}_linux_x86_64/ && \
    mv grpcurl_${GRPCURL_VERSION}_linux_x86_64/grpcurl /usr/local/bin/grpcurl && \
    chmod +x /usr/local/bin/grpcurl

ENV ETCD_VERSION 3.5.1
RUN wget https://github.com/etcd-io/etcd/releases/download/v${ETCD_VERSION}/etcd-v${ETCD_VERSION}-linux-amd64.tar.gz -O /tmp/etcd-v${ETCD_VERSION}-linux-amd64.tar.gz && \
    mkdir ./etcd-v${ETCD_VERSION}-linux-amd64 && \
    tar -zxvf /tmp/etcd-v${ETCD_VERSION}-linux-amd64.tar.gz && \
    mv etcd-v${ETCD_VERSION}-linux-amd64/etcdctl /usr/local/bin/etcdctl && \
    chmod +x /usr/local/bin/etcdctl

RUN /tmp/fetch_binaries.sh

FROM alpine:3.14

RUN set -ex \
    && echo "http://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && echo "http://nl.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && apk update \
    && apk upgrade \
    && apk add --no-cache \
    bash \
    bind-tools \
    bridge-utils \
    busybox-extras \
    curl \
    drill \
    ethtool \
    file\
    fping \
    iftop \
    iproute2 \
    ipset \
    iputils \
    ipvsadm \
    jq \
    mtr \
    openssl \
    strace \
    tcpdump \
    tcptraceroute \
    git \
    websocat \
    zsh

# Installing calicoctl
COPY --from=fetcher /tmp/calicoctl /usr/local/bin/calicoctl

# Installing grpcurl
COPY --from=fetcher /usr/local/bin/grpcurl /usr/local/bin/grpcurl

# Installing etcdctl
COPY --from=fetcher /usr/local/bin/etcdctl /usr/local/bin/etcdctl

# Setting User and Home
USER root
WORKDIR /root
ENV HOSTNAME vision

# ZSH Themes
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
COPY zshrc .zshrc
COPY motd motd

# Fix permissions for OpenShift
RUN chmod -R g=u /root

# Running ZSH
CMD ["zsh"]
