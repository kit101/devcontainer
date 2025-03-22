FROM debian:12 AS base

RUN sed -i 's|http://deb.debian.org/debian|http://mirrors.aliyun.com/debian|g' /etc/apt/sources.list.d/debian.sources && \
    sed -i 's|http://deb.debian.org/debian-security|http://mirrors.aliyun.com/debian-security|g' /etc/apt/sources.list.d/debian.sources && \
    apt update
RUN apt install -y apt-transport-https ca-certificates curl gnupg lsb-release openssh-server rsync cmake git sudo

# 创建 devcontainer 用户并赋予 sudo 权限
RUN useradd -m -s /bin/bash devcontainer && \
    echo "devcontainer:devcontainer" | chpasswd && \
    usermod -aG sudo devcontainer && \
    echo "devcontainer ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/devcontainer
RUN mkdir -p /var/run/sshd
COPY sshd_config /etc/ssh/sshd_config
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] http://mirrors.aliyun.com/docker-ce/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli
ENV DOCKER_HOST=unix:///var/run/docker.sock
ENV SHELL=/bin/bash
ENTRYPOINT ["sudo", "/usr/local/bin/entrypoint.sh"]
USER devcontainer
WORKDIR /home/devcontainer
RUN chown -R devcontainer:devcontainer /home/devcontainer


#
# programming language environment
#

# node version manager: https://github.com/tj/n  . But move command 'n' to 'nvm'
FROM base AS node
ARG DEFAULT_NODE_VERSION=20.19.0
ENV N_NODE_MIRROR=https://npmmirror.com/mirrors/node/
RUN export N_PREFIX=/home/devcontainer/.nvm && \
    curl -L https://bit.ly/n-install | bash -s -- -y $DEFAULT_NODE_VERSION && \
    export PATH=$PATH:$N_PREFIX/bin && \
    mv $N_PREFIX/bin/n $N_PREFIX/bin/nvm && \
    node -v && npm -v

# golang version manager: https://github.com/voidint/g  . But move command 'g' to 'gvm'
FROM base AS golang
ARG DEFAULT_GO_VERSION=1.20.5
ENV G_MIRROR=https://go.dev/dl/
RUN mkdir -p "$HOME/.g/downloads" && \
    curl -sSL https://raw.githubusercontent.com/voidint/g/master/install.sh | bash && \
    . "$HOME/.g/env" && \
    mv "$HOME/.g/bin/g" "$HOME/.g/bin/gvm" && \
    gvm install $DEFAULT_GO_VERSION && gvm clean && \
    go version
ENV G_HOME=/home/devcontainer/.g

# java version manager: https://github.com/shyiko/jabba
FROM base AS java
ARG DEFAULT_JAVA_VERSION=amazon-corretto@1.8.292-10.1
RUN JABBA_VERSION=0.11.2 curl -sL https://github.com/shyiko/jabba/raw/master/install.sh | bash && . ~/.jabba/jabba.sh && \
    jabba install $DEFAULT_JAVA_VERSION && \
    jabba alias default $DEFAULT_JAVA_VERSION && \
    jabba current && \
    . ~/.jabba/jabba.sh && java -version

# contain all programming language environment
FROM base AS max
COPY --from=node    /home/devcontainer/.nvm     /home/devcontainer/.nvm
COPY --from=golang  /home/devcontainer/.g       /home/devcontainer/.g
COPY --from=java    /home/devcontainer/.jabba   /home/devcontainer/.jabba
COPY .bashrc /home/devcontainer/.bashrc
RUN sudo apt install busybox -y && sudo busybox --install /usr/local/bin