#!/bin/bash
# vllm-ascend 安装脚本 for Ascend 910B

set -e

VLLM_VERSION="0.13.0"
VLLM_ASCEND_VERSION="v0.13.0"
TORCH_VERSION="2.8.0"
TORCH_NPU_VERSION="2.8.0.post2"

echo "=== 开始安装 vllm-ascend ==="
echo "PyTorch版本: ${TORCH_VERSION}"
echo "vLLM版本: ${VLLM_VERSION}"

# 检查 CANN 环境
if [ -z "$ASCEND_HOME_PATH" ]; then
    echo "错误: CANN 环境变量未设置，请先安装 CANN 并 source set_env.sh"
    exit 1
fi

# 安装基础依赖
echo "安装基础依赖..."
pip install attrs decorator sympy cffi pyyaml pathlib2 psutil protobuf scipy requests absl-py wheel typing_extensions setuptools-scm pybind11 cmake -i https://pypi.tuna.tsinghua.edu.cn/simple

# 安装 PyTorch
echo "安装 PyTorch ${TORCH_VERSION}..."
pip install torch==${TORCH_VERSION} --index-url https://download.pytorch.org/whl/cpu -i https://pypi.tuna.tsinghua.edu.cn/simple

# 安装 torch-npu
echo "安装 torch-npu ${TORCH_NPU_VERSION}..."
pip install torch-npu==${TORCH_NPU_VERSION} --extra-index-url https://mirrors.huaweicloud.com/ascend/repos/pypi/simple -i https://pypi.tuna.tsinghua.edu.cn/simple

# 安装 vllm
echo "安装 vllm ${VLLM_VERSION}..."
pip install vllm==${VLLM_VERSION} -i https://pypi.tuna.tsinghua.edu.cn/simple

# 克隆 vllm-ascend
echo "克隆 vllm-ascend 源码..."
cd /root/autodl-tmp
if [ ! -d "vllm-ascend" ]; then
    git clone https://github.com/vllm-project/vllm-ascend.git
fi
cd vllm-ascend
git checkout ${VLLM_ASCEND_VERSION}

# 修改 requirements.txt 移除 problematic 依赖
echo "修改依赖配置..."
sed -i 's/triton-ascend==3.2.0/# triton-ascend==3.2.0/' requirements.txt
sed -i 's/arctic-inference==0.1.1/# arctic-inference==0.1.1/' requirements.txt

# 安装 vllm-ascend
echo "编译安装 vllm-ascend (这可能需要几分钟)..."
export CMAKE_PREFIX_PATH=$(python3 -m pybind11 --cmakedir)
pip install --no-build-isolation -e . -i https://pypi.tuna.tsinghua.edu.cn/simple

echo "=== vllm-ascend 安装完成 ==="
echo "验证安装: python3 -c 'import vllm_ascend; print(\"OK\")'"
