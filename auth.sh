 #!/bin/sh

# 通用配置
LOGIN_URL="http://172.21.255.105:801/eportal/?c=Portal&a=login"
USER_ACCOUNT="2024210288@telecom"  # 账号 @后为运营商 telecom电信 unicom联通 cmcc移动
USER_PASSWORD="really123.."       # 密码
JS_VERSION="3.3.3"

# 对接口进行认证的函数
authenticate() {
    INTERFACE=$1
    echo "Authenticating interface: $INTERFACE"

    # 获取接口IP和MAC
    WLAN_USER_IP=$(ip addr show dev $INTERFACE | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
    WLAN_USER_MAC=$(cat /sys/class/net/$INTERFACE/address)

    # 检查是否成功获取IP和MAC
    if [ -z "$WLAN_USER_IP" ] || [ -z "$WLAN_USER_MAC" ]; then
        echo "Failed to retrieve IP or MAC for $INTERFACE"
        return 1
    fi

    # 随机生成callback和v参数
    CALLBACK="dr$((RANDOM % 10000))"
    V_PARAM=$((RANDOM % 10000))

    # 发送认证请求
    curl -G "${LOGIN_URL}" \
    --data-urlencode "login_method=1" \
    --data-urlencode "user_account=${USER_ACCOUNT}" \
    --data-urlencode "user_password=${USER_PASSWORD}" \
    --data-urlencode "wlan_user_ip=${WLAN_USER_IP}" \
    --data-urlencode "wlan_user_mac=${WLAN_USER_MAC}" \
    --data-urlencode "wlan_user_ipv6=" \
    --data-urlencode "wlan_ac_ip=" \
    --data-urlencode "wlan_ac_name=" \
    --data-urlencode "jsVersion=${JS_VERSION}" \
    --data-urlencode "callback=${CALLBACK}" \
    --data-urlencode "v=${V_PARAM}"

    echo "Authentication request sent for $INTERFACE at $(date)!"
}

# 针对两个接口分别进行认证
authenticate "wan"
authenticate "lan3" 