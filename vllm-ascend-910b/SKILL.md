---
name: vllm-ascend-910b
description: |
  在华为 Ascend 910B NPU 服务器上安装和部署 vllm-ascend，用于大模型推理服务。
  
  使用场景:
  1. 在 Atlas 800I A2/Atlas A2 等搭载 910B 芯片的服务器上部署 vLLM
  2. 安装 CANN 8.5.1 及配套软件栈
  3. 编译安装 vllm-ascend 插件
  4. 启动和配置 Qwen3-VL、LLaMA 等模型的推理服务
  
  覆盖全流程: CANN安装 → PyTorch/torch-npu安装 → vllm-ascend编译 → 模型部署 → 服务启动
---

# vllm-ascend 910B 部署指南

在华为 Ascend 910B NPU 上部署 vLLM 推理服务。

## 前置要求

- 硬件: Atlas 800I A2 / Atlas A2 / Atlas 800T A2 (搭载 910B 芯片)
- OS: Linux (Ubuntu/CentOS/openEuler)
- Python: 3.10 - 3.12
- 网络: 可访问华为云镜像站

## 快速开始

### 1. 安装 CANN 8.5.1

运行安装脚本:
```bash
bash ~/.kimi/skills/vllm-ascend-910b/scripts/install_cann.sh
source ~/.bashrc
```

或手动安装:
```bash
# 下载并安装 CANN Toolkit
wget --header="Referer: https://www.hiascend.com/" \
    https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/CANN/CANN%208.5.1/Ascend-cann-toolkit_8.5.1_linux-aarch64.run
chmod +x Ascend-cann-toolkit_8.5.1_linux-aarch64.run
./Ascend-cann-toolkit_8.5.1_linux-aarch64.run --full

# 安装 910b ops 和 NNAL
source /usr/local/Ascend/ascend-toolkit/set_env.sh
wget --header="Referer: https://www.hiascend.com/" \
    https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/CANN/CANN%208.5.1/Ascend-cann-910b-ops_8.5.1_linux-aarch64.run
./Ascend-cann-910b-ops_8.5.1_linux-aarch64.run --install

wget --header="Referer: https://www.hiascend.com/" \
    https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/CANN/CANN%208.5.1/Ascend-cann-nnal_8.5.1_linux-aarch64.run
./Ascend-cann-nnal_8.5.1_linux-aarch64.run --install

# 添加环境变量到 ~/.bashrc
echo 'source /usr/local/Ascend/cann-8.5.1/set_env.sh' >> ~/.bashrc
echo 'source /usr/local/Ascend/nnal/atb/set_env.sh' >> ~/.bashrc
```

### 2. 安装 vllm-ascend

运行安装脚本:
```bash
bash ~/.kimi/skills/vllm-ascend-910b/scripts/install_vllm_ascend.sh
```

或手动安装:
```bash
# 基础依赖
pip install attrs decorator sympy cffi pyyaml pathlib2 psutil protobuf scipy requests absl-py wheel typing_extensions setuptools-scm pybind11 cmake -i https://pypi.tuna.tsinghua.edu.cn/simple

# PyTorch 2.8.0 + torch-npu 2.8.0.post2
pip install torch==2.8.0 --index-url https://download.pytorch.org/whl/cpu
pip install torch-npu==2.8.0.post2 --extra-index-url https://mirrors.huaweicloud.com/ascend/repos/pypi/simple

# vllm 0.13.0
pip install vllm==0.13.0

# 从源码安装 vllm-ascend
cd /root/autodl-tmp
git clone https://github.com/vllm-project/vllm-ascend.git
cd vllm-ascend
git checkout v0.13.0

# 修改 requirements.txt 跳过 problematic 依赖
sed -i 's/triton-ascend==3.2.0/# triton-ascend==3.2.0/' requirements.txt
sed -i 's/arctic-inference==0.1.1/# arctic-inference==0.1.1/' requirements.txt

# 编译安装
export CMAKE_PREFIX_PATH=$(python3 -m pybind11 --cmakedir)
pip install --no-build-isolation -e .
```

### 3. 下载模型

```bash
export VLLM_USE_MODELSCOPE=true
pip install modelscope

python3 -c "
from modelscope import snapshot_download
model_path = snapshot_download('Qwen/Qwen3-VL-8B-Instruct', cache_dir='/root/autodl-tmp/models')
print(f'Model downloaded to: {model_path}')
"
```

### 4. 启动服务

使用脚本启动:
```bash
bash ~/.kimi/skills/vllm-ascend-910b/scripts/start_server.sh \
    /root/autodl-tmp/models/Qwen/Qwen3-VL-8B-Instruct \
    8000 \
    8192
```

或手动启动:
```bash
source /usr/local/Ascend/cann-8.5.1/set_env.sh
source /usr/local/Ascend/nnal/atb/set_env.sh
export VLLM_USE_MODELSCOPE=true
export ASCEND_RT_VISIBLE_DEVICES=0

vllm serve /root/autodl-tmp/models/Qwen/Qwen3-VL-8B-Instruct \
    --tensor-parallel-size 1 \
    --dtype bfloat16 \
    --max-model-len 8192 \
    --port 8000
```

## API 使用

服务启动后，访问 http://localhost:8000:

```bash
# 查看模型列表
curl http://localhost:8000/v1/models

# 文本生成
curl http://localhost:8000/v1/completions \
    -H "Content-Type: application/json" \
    -d '{
        "model": "/root/autodl-tmp/models/Qwen/Qwen3-VL-8B-Instruct",
        "prompt": "你好",
        "max_completion_tokens": 100
    }'

# 聊天完成
curl http://localhost:8000/v1/chat/completions \
    -H "Content-Type: application/json" \
    -d '{
        "model": "/root/autodl-tmp/models/Qwen/Qwen3-VL-8B-Instruct",
        "messages": [{"role": "user", "content": "你好"}]
    }'
```

## 版本兼容性

| 组件 | 版本 |
|------|------|
| CANN | 8.5.1 |
| PyTorch | 2.8.0 |
| torch-npu | 2.8.0.post2 |
| vLLM | 0.13.0 |
| vllm-ascend | v0.13.0 |

**注意**: 版本必须严格匹配，否则会导致 CMake 编译失败或运行时错误。

## 故障排除

遇到问题时参考 [troubleshooting.md](references/troubleshooting.md)，包含以下常见问题:

- triton-ascend 找不到
- arctic-inference 编译失败
- PyTorch 版本不匹配
- pybind11/setuptools-scm 缺失
- NPU 内存不足
- 模型加载失败

## 常用命令

```bash
# 检查 NPU 状态
npu-smi info

# 检查环境变量
echo $ASCEND_HOME_PATH

# 验证 PyTorch + NPU
python3 -c "import torch; import torch_npu; print(torch_npu.npu.is_available())"

# 查看服务日志
tail -f /root/autodl-tmp/vllm_server.log

# 停止服务
pkill -f "vllm serve"
```

## 资源占用参考

Qwen3-VL-8B-Instruct on 910B:
- NPU 内存: ~57GB / 64GB
- 加载时间: ~10-15秒
- 编译时间: ~50-60秒（首次启动）
- KV Cache: 251,904 tokens
- 最大并发: ~30 个 8K 序列
