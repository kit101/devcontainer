#!/bin/sh

# 定义清理函数
cleanup() {
    echo "脚本被中断，正在执行清理操作..."
    cmd="docker rm -f devcontainer"
    echo "+ $cmd"
    eval "$cmd"
    exit 1
}

# 捕获SIGINT和SIGTERM信号，并执行cleanup函数
trap cleanup SIGINT SIGTERM

image=${1:-kit101z/devcontainer:max}

echo $image

docker run --rm -it --name devcontainer -d -e "DEBUG_MODE=true" -e "BASH_ENV=~/.bashrc" $image '
gvm -v
jabba --version
nvm -V
'

docker exec -it devcontainer bash -c '
gvm -v
jabba --version
nvm -V
'

docker logs -f devcontainer