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
echo + env
env
echo + golang
gvm -v && go version
echo + java
jabba --version && java -version
echo + node
nvm -V && node -v && npm -v
'

docker exec -it devcontainer bash -c '
echo + ssh devcontainer@127.0.0.1
sudo apt install -y sshpass  -qq
sshpass -p devcontainer ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -v devcontainer@127.0.0.1 pwd > /dev/null 2>&1
# 检查退出状态码
if [ $? -eq 0 ]; then
    echo "SSH connection succeeded."
else
    echo "SSH connection failed."
    exit 1
fi

echo + env
env
echo + golang
gvm -v && go version
echo + java
jabba --version && java -version
echo + node
nvm -V && node -v && npm -v
'

echo '------'

docker logs -f devcontainer