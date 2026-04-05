# vllm-ascend 故障排除指南

## 常见错误及解决方案

### 1. triton-ascend 找不到

**错误信息:**
```
ERROR: Could not find a version that satisfies the requirement triton-ascend==3.2.0
```

**解决方案:**
这是预期行为，triton-ascend 在 pip 源中不可用。需要从源码安装 vllm-ascend，并修改 requirements.txt 注释掉该依赖：
```bash
sed -i 's/triton-ascend==3.2.0/# triton-ascend==3.2.0/' requirements.txt
```

### 2. arctic-inference 编译失败

**错误信息:**
```
ERROR: Failed building wheel for arctic-inference
```

**解决方案:**
arctic-inference 需要编译 C++ 扩展，容易失败。修改 requirements.txt 注释掉该依赖：
```bash
sed -i 's/arctic-inference==0.1.1/# arctic-inference==0.1.1/' requirements.txt
```

### 3. PyTorch 版本不匹配

**错误信息:**
```
RuntimeError: CMake configuration failed: Expected PyTorch version 2.8.0, but found 2.9.0+cpu
```

**解决方案:**
vllm-ascend v0.13.0 需要 PyTorch 2.8.0，降级 PyTorch：
```bash
pip install torch==2.8.0 --index-url https://download.pytorch.org/whl/cpu
pip install torch-npu==2.8.0.post2 --extra-index-url https://mirrors.huaweicloud.com/ascend/repos/pypi/simple
```

### 4. pybind11 找不到

**错误信息:**
```
ModuleNotFoundError: No module named 'setuptools_scm'
```
或
```
RuntimeError: CMake configuration failed: pybind11
```

**解决方案:**
```bash
pip install setuptools-scm pybind11
```

### 5. vllm 版本不兼容

**错误信息:**
```
ModuleNotFoundError: No module named 'vllm.model_executor.layers.fused_moe.routed_experts_capturer'
```

**解决方案:**
这是因为 vllm-ascend main 分支与 vllm 0.13.0 不兼容。切换到 v0.13.0 标签：
```bash
cd vllm-ascend
git checkout v0.13.0
```

### 6. NPU 内存不足

**错误信息:**
```
RuntimeError: NPU out of memory
```

**解决方案:**
- 减小 `--max-model-len` 参数
- 使用较小的模型
- 启用量化（如果支持）

### 7. 模型加载失败

**错误信息:**
```
We couldn't connect to 'https://huggingface.co' to load the files
```

**解决方案:**
设置 ModelScope 镜像：
```bash
export VLLM_USE_MODELSCOPE=true
pip install modelscope
```

## 验证安装

```bash
# 检查 CANN
npu-smi info

# 检查 PyTorch + NPU
python3 -c "import torch; import torch_npu; print(f'PyTorch: {torch.__version__}'); print(f'torch-npu: {torch_npu.__version__}')"

# 检查 vllm-ascend
python3 -c "import vllm_ascend; print('vllm-ascend OK')"
```

## 日志位置

- vllm 服务日志: `/root/autodl-tmp/vllm_server.log`
- CANN 日志: `/var/log/npu/`

## 环境变量检查清单

```bash
echo $ASCEND_HOME_PATH
echo $ASCEND_VERSION
echo $CANN_HOME
```

如果为空，执行:
```bash
source /usr/local/Ascend/cann-8.5.1/set_env.sh
source /usr/local/Ascend/nnal/atb/set_env.sh
```
