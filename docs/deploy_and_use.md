# 本地部署与使用手册

## 1. 概览

本项目是 Fish Speech 本地部署仓库，包含：

- Python 后端服务（API Server）
- Web UI 前端入口
- 模型权重路径配置
- 本地开发环境设置脚本

此手册适用于在本机执行本项目，并启动服务或 Web UI 进行推理。

## 2. 环境准备

### 2.1 代码仓库

在本机的任意目录下，准备仓库文件：

- `d:\fish-speech` 目录为项目根目录
- 保留项目原有目录结构，不要删除 `tools/`、`fish_speech/`、`awesome_webui/` 等文件夹

### 2.2 Python 依赖

进入项目根目录后运行：

```powershell
Set-Location d:\fish-speech
powershell -ExecutionPolicy Bypass -File .\scripts\setup_dev.ps1
```

此脚本会：

- 创建虚拟环境 `\.venv`
- 安装 Python 依赖
- 安装 docs 所需的额外依赖
- 如果存在 Node.js，会进入 `awesome_webui` 并安装前端依赖

### 2.3 激活虚拟环境

安装完成后，在新终端中运行：

```powershell
Set-Location d:\fish-speech
.\.venv\Scripts\Activate.ps1
```

如果你仅希望手动安装依赖，也可以使用：

```powershell
pip install -r requirements.txt
```

## 3. 模型文件准备

本项目默认使用模型目录：

- `checkpoints/s2-pro`

该目录下应包含：

- `checkpoints/s2-pro/codec.pth`
- `checkpoints/s2-pro/model-00001-of-00002.safetensors`
- `checkpoints/s2-pro/model-00002-of-00002.safetensors`
- `checkpoints/s2-pro/tokenizer_config.json`
- `checkpoints/s2-pro/special_tokens_map.json`

如果你已经在另一台电脑上下载完成，可以直接完整复制 `checkpoints/s2-pro` 目录到本机项目根目录下。

## 4. 运行后端服务

启动 API Server：

```powershell
python tools/api_server.py
```

默认监听地址：

- `127.0.0.1:8080`

如果需要自定义参数：

```powershell
python tools/api_server.py --listen 0.0.0.0:8080 --api-key your_token
```

主要参数：

- `--llama-checkpoint-path checkpoints/s2-pro`
- `--decoder-checkpoint-path checkpoints/s2-pro/codec.pth`
- `--decoder-config-name modded_dac_vq`
- `--device cuda`
- `--half`
- `--compile`

## 5. 运行本地 Web UI

启动 Web UI：

```powershell
python tools/run_webui.py
```

默认配置会：

- 加载 `checkpoints/s2-pro`
- 加载 `checkpoints/s2-pro/codec.pth`
- 启动浏览器界面

如果你只需要前端代码本地开发：

```powershell
Set-Location d:\fish-speech\awesome_webui
npm install
npm run dev
```

## 6. 使用方式

### 6.1 API 调用

后端启动后，可访问：

- `GET /v1/health`
- `POST /v1/tts`
- `POST /v1/vqgan/encode`
- `POST /v1/vqgan/decode`

常见调用示例：

```powershell
python tools/api_client.py --url http://127.0.0.1:8080/v1/tts --text "Hello from Fish Speech" --output demo.wav
```

### 6.2 Web UI

执行 `python tools/run_webui.py` 后，浏览器会打开本地 Web 界面，直接输入文本即可进行推理。

## 7. 运行检查

如果要检查代码是否能正常解析：

```powershell
python -m py_compile tools/api_server.py tools/run_webui.py
```

如果要检查模型目录是否存在：

```powershell
Get-ChildItem checkpoints\s2-pro
```

## 8. 快速故障排查

- 如果报 `FileNotFoundError`，请确认 `checkpoints/s2-pro` 目录是否完整。
- 如果报 `ModuleNotFoundError` 或依赖缺失，重复执行 `setup_dev.ps1`。
- 如果需要其它模型路径，运行时可通过 `--llama-checkpoint-path` 和 `--decoder-checkpoint-path` 指定。

## 9. 备注

本手册主要说明工程的本地部署与使用流程，硬件要求属于运行时资源层面，具体可根据你当前机器情况再做判断。