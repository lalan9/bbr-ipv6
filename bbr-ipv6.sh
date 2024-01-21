#!/bin/bash  
  
# 自动获取网络接口名称  
IFACE=$(ip route get 8.8.8.8 | awk -- '{print $5}')  
  
# 函数定义：输出状态信息  
function show_status() {
    if [ $? -eq 0 ]; then
        echo "[OK] $1"
    else
        echo "[Error] Failed to $1"
        exit 1
    fi
}

# 1. 启用 IPv6  
echo "Enabling IPv6 on $IFACE"  
sysctl net.ipv6.conf.$IFACE.disable_ipv6=0
show_status "enable IPv6"

# 2. 启用 BBR (需要内核支持)  
echo "Enabling BBR on $IFACE"  
sysctl net.core.default_qdisc=bbr  
show_status "enable BBR (congestion control)"

# 3. 启用 UDP 优化 (需要内核支持)  
echo "Enabling UDP optimization on $IFACE"  
sysctl net.core.default_qdisc=fq_codel  
show_status "enable UDP optimization (fq_codel)"

sysctl net.ipv4.udp_rmem_min=8192  
show_status "adjust UDP receive buffer minimum size"

sysctl net.ipv4.udp_wmem_min=8192  
show_status "adjust UDP send buffer minimum size"

sysctl net.core.rmem_default=8192  
show_status "adjust default receive buffer size"

sysctl net.core.wmem_default=8192  
show_status "adjust default send buffer size"

sysctl net.core.rmem_max=8388608  
show_status "adjust maximum receive buffer size"

sysctl net.core.wmem_max=8388608  
show_status "adjust maximum send buffer size"

# 4. 重启网络服务 (可选)  
echo "Restarting network service"  
service networking restart  # 根据您的系统替换为正确的命令  
show_status "restart network service"

echo "Optimization complete."
