# 跨机器部署与运行手册

## 1. 目标

本手册为你在多台机器之间部署 Fish Speech 项目提供一步步指导。包括：

- 代码仓库如何迁移到另一台电脑
- 模型文件如何复制回原电脑
- 新电脑如何快速配置环境
- 如何启动后端服务和 Web UI

## 2. 前提条件

确保你已经具备以下条件：

- 本地已下载代码仓库 `fish-speech`
- 本地已有模型目录 `checkpoints/s2-pro`
- 目标电脑可访问该仓库并执行 Python
- 你已经登录 Hugging Face（如果需要重新下载模型）

## 3. 如果要把模型拷贝回去

### 3.1 拷贝哪些文件

请完整复制整个模型目录：

- `checkpoints/s2-pro/codec.pth`
- `checkpoints/s2-pro/model-00001-of-00002.safetensors`
- `checkpoints/s2-pro/model-00002-of-00002.safetensors`
- `checkpoints/s2-pro/tokenizer_config.json`
- `checkpoints/s2-pro/special_tokens_map.json`

如果你已经下载了这一目录，直接复制整个 `checkpoints/s2-pro` 即可。

### 3.2 拷贝到目标电脑的位置

目标电脑上也应放在项目根目录下：

- `D:\fish-speech\checkpoints\s2-pro`

项目运行时将默认读取该路径。

## 4. 新电脑环境配置

### 4.1 先准备仓库代码

如果你是拷贝仓库文件：

- 复制完整的 `fish-speech` 项目目录到新电脑

如果你在新电脑上重新拉取仓库：

```powershell
git clone https://github.com/junjunhemaomao/fish-speech.git d:\fish-speech
```

然后进入项目根目录：

```powershell
Set-Location d:\fish-speech
```

### 4.2 安装依赖

运行我们已添加的开发环境脚本：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\setup_dev.ps1
```

该脚本会：

- 创建 Python 虚拟环境 `\.venv`
- 安装项目依赖
- 安装 docs 相关依赖
- 如果检测到 Node.js，则进入 `awesome_webui` 安装前端依赖

如果你不希望执行前端安装，可以在命令后加上 `-skipFrontend`：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\setup_dev.ps1 -skipFrontend
```

如果你想手动执行每一步，可以用下面命令：

```powershell
Set-Location d:\fish-speech
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip setuptools wheel
pip install -r requirements.txt
pip install -r docs\requirements.txt
```

> [!WARNING]
> **`requirements.txt` 默认安装 CPU 版 PyTorch！**  
> `pip install -r requirements.txt` 会安装 `torch==2.8.0`（CPU 版），推理速度极慢。  
> **如果你有 NVIDIA 显卡（nvidia-smi 可见），必须手动替换为 CUDA 版本**（见下方 4.3）。

### 4.3 安装 CUDA 版 PyTorch（有 NVIDIA 显卡的必做）

先检查显卡和 CUDA：

```powershell
nvidia-smi
```

如果有输出，说明有 NVIDIA 显卡，执行：

```powershell
# 激活虚拟环境后
pip uninstall torch torchaudio -y
pip install torch==2.8.0 torchaudio==2.8.0 --index-url https://download.pytorch.org/whl/cu129
```

验证 CUDA 可用：

```powershell
python -c "import torch; print('CUDA available:', torch.cuda.is_available())"
```

如果没有 NVIDIA 显卡，跳过此步，使用 CPU 模式运行（较慢）。

### 4.4 创建 .env 配置文件

从模板创建：

```powershell
copy .env.sample .env
```

编辑 `.env`，关键配置：

| 变量 | 有 GPU (CUDA) | 无 GPU (CPU) |
|------|---------------|--------------|
| `DEVICE` | `cuda` | `cpu` |
| `HALF` | `true` | `false` |
| `LLAMA_CHECKPOINT_PATH` | `checkpoints/s2-pro` | `checkpoints/s2-pro` |
| `DECODER_CHECKPOINT_PATH` | `checkpoints/s2-pro/codec.pth` | 同上 |
| `LISTEN` | `127.0.0.1:8080` | 同上 |

> **注意**：如果显存 ≤ 8GB，`HALF=true` 必须开启，否则会 OOM。

### 4.5 激活虚拟环境

完成后在新终端中执行：

```powershell
Set-Location d:\fish-speech
.\.venv\Scripts\Activate.ps1
```

如果你使用 PowerShell 以外的终端，请使用对应环境激活命令。

## 5. 运行项目

### 5.1 运行 API Server

在项目根目录，并已激活虚拟环境后运行：

```powershell
# 有 NVIDIA 显卡（推荐）
python tools/api_server.py --device cuda --half

# 纯 CPU（慢）
python tools/api_server.py --device cpu
```

默认会启用：

- `--llama-checkpoint-path checkpoints/s2-pro`
- `--decoder-checkpoint-path checkpoints/s2-pro/codec.pth`
- `--decoder-config-name modded_dac_vq`

如果你需要指定监听地址：

```powershell
python tools/api_server.py --device cuda --half --listen 0.0.0.0:8080
```

### 5.2 运行 Web UI

直接运行：

```powershell
# 有 NVIDIA 显卡（推荐）
python tools/run_webui.py --device cuda --half

# 纯 CPU（慢）
python tools/run_webui.py --device cpu
```

> [!WARNING]
> **首次启动会很慢**（5-10 分钟）：模型需要加载到显存 + warm-up 推理。启动后访问 http://127.0.0.1:7860。
>
> 8GB 显存跑这个 11GB 模型非常紧张，部分数据会溢出到共享内存，推理速度较慢（约 0.05 tokens/sec）。

如果你只想启动前端开发模式，可单独进入前端目录：

```powershell
Set-Location d:\fish-speech\awesome_webui
npm install
npm run dev
```

## 6. 运行前检查

### 6.1 检查模型目录

确认目标电脑上存在模型目录：

```powershell
Get-ChildItem d:\fish-speech\checkpoints\s2-pro
```

必须包含以下文件：

- `codec.pth`（约 1.8 GB）
- `model-00001-of-00002.safetensors`（约 5 GB）
- `model-00002-of-00002.safetensors`（约 4 GB）
- `tokenizer.json`、`tokenizer_config.json`、`special_tokens_map.json`
- `config.json`

### 6.2 检查 CUDA / GPU（最重要的步骤）

```powershell
python -c "import torch; print('CUDA:', torch.cuda.is_available()); print('Device:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'CPU only')"
```

- 如果输出 `CUDA: True` → 使用 `--device cuda --half`
- 如果输出 `CUDA: False` → 你装了 CPU 版 PyTorch，请回到 4.3 重新安装 CUDA 版
- 如果报错 `ModuleNotFoundError` → 依赖没装好，回到 4.2

### 6.3 检查 .env 文件

```powershell
Get-Content d:\fish-speech\.env
```

确认 `DEVICE=cuda`（有显卡）或 `DEVICE=cpu`（无显卡）。

### 6.4 检查入口脚本语法

```powershell
python -m py_compile tools/api_server.py tools/run_webui.py
```

### 6.5 检查依赖是否安装

如果脚本执行失败，重新运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\setup_dev.ps1
```

## 7. 常见问题

| 现象 | 原因 | 解决方法 |
|------|------|----------|
| `FileNotFoundError` | 模型没复制 | 确认 `checkpoints/s2-pro` 目录已完整复制到项目根目录 |
| 启动后推理极慢（>30s/token） | 装了 CPU 版 PyTorch | 按 4.3 节安装 CUDA 版 PyTorch |
| `CUDA out of memory` | 显存不足且没开 half | 启动时加 `--half` 参数 |
| 端口被占用 | 之前有残留进程 | `taskkill /PID <PID> /F` 杀掉再启动 |
| 依赖缺失 | venv 没装全 | `pip install -r requirements.txt` |
| `torch.cuda.is_available()` 返回 False | PyTorch 是 CPU 版 | 卸载后从 CUDA index 重装 |
| 模型路径不对 | 默认路径假设在项目根目录 | 用 `--llama-checkpoint-path` 和 `--decoder-checkpoint-path` 指定 |

## 8. 注意事项

- 模型文件可以跨机器复制，下载时不需要重新下载即可直接拷贝。
- 只要目标电脑上有完整的 `checkpoints/s2-pro` 目录，项目就能按默认路径运行。
- 本手册侧重的是跨机器拷贝与本地运行步骤，不依赖原始 `README.md` 的修改。
