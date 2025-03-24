#!/bin/bash

# 从环境变量获取配置，设置默认值
enable_sshd=${SSHD_ENABLE:-true}
debug_mode=${DEBUG_MODE:-false}
devcontainer_password=${DEVCONTAINER_USER_PASSWORD:-""}

# 日志函数，支持 debug、info、warn、error 级别
log() {
    local log_level="$1"
    local message="$2"
    local valid_levels=("debug" "info" "warn" "error")
    local is_valid=false
    # 检查日志级别是否有效
    for level in "${valid_levels[@]}"; do
        if [ "$log_level" = "$level" ]; then
            is_valid=true
            break
        fi
    done
    # 若日志级别无效，输出错误信息并返回非零状态码
    if [ "$is_valid" = false ]; then
        echo "[error]: Invalid log level '$log_level'"
        return 1
    fi
    # 处理调试级别日志，仅在调试模式开启时输出
    if [ "$log_level" = "debug" ]; then
        if [ "$debug_mode" = "true" ]; then
            echo -e "[$log_level] $message"
        fi
    else
        echo -e "[$log_level] $message"
    fi
}

# 初始化用户密码
if [ -n "$devcontainer_password" ]; then
    echo "devcontainer:$devcontainer_password" | sudo chpasswd
    log "debug" "The password of user 'devcontainer' has been changed."
fi

# 启动 SSH 服务
if [ "$enable_sshd" = "true" ]; then
    sudo /usr/sbin/sshd -D &
    log "info" "SSH service has been started."
fi

# 若传入参数，将第一个参数作为脚本执行
if [ $# -gt 0 ]; then
    log "info" "The first argument will be executed as a shell script."
    if [ "$debug_mode" = "true" ]; then
        echo ""
        echo -e "$1"
        echo ""
    fi
    log "info" "Executing the script..."
    echo -e "$1" | bash
    log "info" "Script execution completed."
else
    log "debug" "No script provided as an argument. You can pass a script to execute, example:\n        docker run kit101z/devcontainer:max 'echo \"Hello, World!\"'"
fi

# 输出欢迎信息和登录指导
echo -e "\n👏 Welcome to the devcontainer! The environment has been initialized successfully. 👌"
echo -e "To log in, use the following command:"
echo -e "  ssh devcontainer@<your_external_ip> -p <your_external_port>"
echo -e "To retrieve the login password, run:"
echo -e "  export CONTAINER_NAME=<your_container_name>"
echo -e "  docker exec -it \$CONTAINER_NAME bash -c 'echo \${DEVCONTAINER_USER_PASSWORD:-devcontainer}'\n"
echo -e "For more information, visit https://github.com/kit101/devcontainer"
echo -e "-------------------------------------------------"

sleep infinity