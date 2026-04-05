#!/bin/bash
# CANN 8.5.1 安装脚本 for Ascend 910B

set -e

CANN_VERSION="8.5.1"
INSTALL_DIR="/root/autodl-tmp/cann_install"

echo "=== 开始安装 CANN ${CANN_VERSION} ==="

# 创建安装目录
mkdir -p ${INSTALL_DIR}
cd ${INSTALL_DIR}

# 下载 CANN Toolkit
if [ ! -f "Ascend-cann-toolkit_${CANN_VERSION}_linux-aarch64.run" ]; then
    echo "下载 CANN Toolkit..."
    wget --header="Referer: https://www.hiascend.com/" \
        "https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/CANN/CANN%20${CANN_VERSION}/Ascend-cann-toolkit_${CANN_VERSION}_linux-aarch64.run"
fi

# 下载 CANN 910b Ops
if [ ! -f "Ascend-cann-910b-ops_${CANN_VERSION}_linux-aarch64.run" ]; then
    echo "下载 CANN 910b Ops..."
    wget --header="Referer: https://www.hiascend.com/" \
        "https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/CANN/CANN%20${CANN_VERSION}/Ascend-cann-910b-ops_${CANN_VERSION}_linux-aarch64.run"
fi

# 下载 CANN NNAL
if [ ! -f "Ascend-cann-nnal_${CANN_VERSION}_linux-aarch64.run" ]; then
    echo "下载 CANN NNAL..."
    wget --header="Referer: https://www.hiascend.com/" \
        "https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/CANN/CANN%20${CANN_VERSION}/Ascend-cann-nnal_${CANN_VERSION}_linux-aarch64.run"
fi

# 安装 Toolkit
echo "安装 CANN Toolkit..."
chmod +x Ascend-cann-toolkit_${CANN_VERSION}_linux-aarch64.run
./Ascend-cann-toolkit_${CANN_VERSION}_linux-aarch64.run --full --quiet

# 设置环境变量
source /usr/local/Ascend/cann-${CANN_VERSION}/set_env.sh

# 安装 910b Ops
echo "安装 CANN 910b Ops..."
chmod +x Ascend-cann-910b-ops_${CANN_VERSION}_linux-aarch64.run
./Ascend-cann-910b-ops_${CANN_VERSION}_linux-aarch64.run --install --quiet

# 安装 NNAL
echo "安装 CANN NNAL..."
chmod +x Ascend-cann-nnal_${CANN_VERSION}_linux-aarch64.run
./Ascend-cann-nnal_${CANN_VERSION}_linux-aarch64.run --install --quiet

# 添加到 bashrc
echo "source /usr/local/Ascend/cann-${CANN_VERSION}/set_env.sh" >> ~/.bashrc
echo "source /usr/local/Ascend/nnal/atb/set_env.sh" >> ~/.bashrc

echo "=== CANN ${CANN_VERSION} 安装完成 ==="
echo "请重新登录或执行 'source ~/.bashrc' 使环境变量生效"
