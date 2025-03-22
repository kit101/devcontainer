#!/bin/bash

enable_dockerd=${DOCKERD_ENABLE:-false}
enable_sshd=${SSHD_ENABLE:-true}
dockerd_args=${DOCKERD_ARGS:-""}
debug_mode=${DEBUG_MODE:-false}

# 检查是否启用 dockerd 并且 dockerd 可执行
if [[ "$enable_dockerd" == "true" && -x "$(command -v dockerd)" ]]; then
    # 启动 dockerd
    sudo dockerd $dockerd_args &
    
    # 等待 dockerd 启动
    max_attempts=150
    for ((attempt = 1; attempt <= max_attempts; attempt++)); do
        sudo docker info
        exit_status=$?
        if [ $exit_status -eq 0 ]; then
            break
        else
            sleep 1
        fi
    done
fi

# 启动 sshd
sudo /usr/sbin/sshd -D &

# 将第一个参数作为脚本执行
if [ $# -ne 0 ]; then
    echo '-------------------------------------------------' 
    echo 'The first parameter will be executed as a script'
    if [ "$debug_mode" == "true" ]; then
        echo ''
        echo -e "$1" 
        echo ''
    fi
    echo '-------------------------------------------------' 
    echo ''
    echo -e "$1" | bash
fi

sleep infinity
