#!/bin/bash

enable_dockerd=${DOCKERD_ENABLE:-false}
enable_sshd=${SSHD_ENABLE:-true}
dockerd_args=${DOCKERD_ARGS:-""}

# 检查是否启用 dockerd 并且 dockerd 可执行
if [[ "$enable_dockerd" == "true" && -x "$(command -v dockerd)" ]]; then
    # 启动 dockerd
    dockerd $dockerd_args &
    
    # 等待 dockerd 启动
    max_attempts=150
    for ((attempt = 1; attempt <= max_attempts; attempt++)); do
        docker info
        exit_status=$?
        if [ $exit_status -eq 0 ]; then
            break
        else
            sleep 1
        fi
    done
fi

# 启动 sshd
/usr/sbin/sshd -D &

# 若没有传递参数，则执行 sleep infinity，否则执行传递的命令
if [ $# -eq 0 ]; then
    sleep infinity
else
    exec "$@"
fi