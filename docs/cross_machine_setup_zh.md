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

### 4.3 激活虚拟环境

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
python tools/api_server.py
```

默认会启用：

- `--llama-checkpoint-path checkpoints/s2-pro`
- `--decoder-checkpoint-path checkpoints/s2-pro/codec.pth`
- `--decoder-config-name modded_dac_vq`

如果你需要指定监听地址：

```powershell
python tools/api_server.py --listen 0.0.0.0:8080
```

### 5.2 运行 Web UI

直接运行：

```powershell
python tools/run_webui.py
```

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

### 6.2 检查入口脚本语法

```powershell
python -m py_compile tools/api_server.py tools/run_webui.py
```

### 6.3 检查依赖是否安装

如果脚本执行失败，重新运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\setup_dev.ps1
```

## 7. 常见问题

- 如果报 `FileNotFoundError`：请确认 `checkpoints/s2-pro` 目录已完整复制。
- 如果报依赖缺失：请重装依赖并激活虚拟环境。
- 如果想换模型路径：可在启动时使用 `--llama-checkpoint-path` 和 `--decoder-checkpoint-path` 指定。

## 8. 注意事项

- 模型文件可以跨机器复制，下载时不需要重新下载即可直接拷贝。
- 只要目标电脑上有完整的 `checkpoints/s2-pro` 目录，项目就能按默认路径运行。
- 本手册侧重的是跨机器拷贝与本地运行步骤，不依赖原始 `README.md` 的修改。
