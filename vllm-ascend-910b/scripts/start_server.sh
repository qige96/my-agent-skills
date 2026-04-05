#!/bin/bash
# 启动 vllm 服务

# 默认配置
MODEL_PATH="${1:-/root/autodl-tmp/models/Qwen/Qwen3-VL-8B-Instruct}"
PORT="${2:-8000}"
MAX_MODEL_LEN="${3:-8192}"

# 检查环境
if [ -z "$ASCEND_HOME_PATH" ]; then
    echo "加载 CANN 环境变量..."
    source /usr/local/Ascend/cann-8.5.1/set_env.sh 2>/dev/null || source /usr/local/Ascend/ascend-toolkit/set_env.sh
fi

if [ -f "/usr/local/Ascend/nnal/atb/set_env.sh" ]; then
    source /usr/local/Ascend/nnal/atb/set_env.sh
fi

# 设置环境变量
export VLLM_USE_MODELSCOPE=true
export ASCEND_RT_VISIBLE_DEVICES=0

# 检查模型路径
if [ ! -d "$MODEL_PATH" ]; then
    echo "错误: 模型路径不存在: $MODEL_PATH"
    echo "使用方法: $0 <模型路径> [端口] [max_model_len]"
    exit 1
fi

echo "=== 启动 vLLM 服务 ==="
echo "模型: $MODEL_PATH"
echo "端口: $PORT"
echo "Max model len: $MAX_MODEL_LEN"

# 启动服务
vllm serve "$MODEL_PATH" \
    --tensor-parallel-size 1 \
    --dtype bfloat16 \
    --max-model-len $MAX_MODEL_LEN \
    --port $PORT \
    "$@"
