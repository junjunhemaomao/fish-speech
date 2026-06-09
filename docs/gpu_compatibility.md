# GPU 兼容性与模型下载说明

## 1. 模型下载与显卡关系

- `hf download fishaudio/s2-pro --local-dir checkpoints/s2-pro` 下载的是模型文件，和你当前机器上的显卡型号没有关系。
- 无论你在公司电脑（2060）还是家里电脑（3060）上执行下载，得到的模型文件都是相同的。
- 也就是说，模型下载时不会“挑显卡”，显卡只是影响后续运行是否可行。

## 2. 2060 / 3060 与 S2-Pro 运行能力

- 这个仓库默认使用的是 `fishaudio/s2-pro`，该模型非常大。
- 项目文档中建议至少使用 24GB GPU。
- 因此：
  - 公司电脑上的 RTX 2060（6GB/8GB）通常不足以运行完整的 S2-Pro 模型。
  - 家里 RTX 3060（通常 12GB 或 8GB）也很可能不够运行完整模型，尤其是默认配置下。
- 结论：
  - 2060/3060 都不是“下载低配模型”的问题，下载的模型文件一样。
  - 关键是显存是否够用，S2-Pro 的实际运行更依赖显存大小而不是显卡品牌。

## 3. 你需要准备的模型文件

目标目录：`checkpoints/s2-pro`

主要文件包括：

- `checkpoints/s2-pro/codec.pth`
- `checkpoints/s2-pro/model-00001-of-00002.safetensors`
- `checkpoints/s2-pro/model-00002-of-00002.safetensors`
- `checkpoints/s2-pro/tokenizer_config.json`
- `checkpoints/s2-pro/special_tokens_map.json`

## 4. 家里 3060 是否适用？

- 3060 可以用来存放和下载模型文件。
- 如果你要实际运行，本质上需要判断显存是否足够。
- 如果家里是 12GB 版本，仍然可能不足；如果是 8GB，更难以运行。
- 你可以尝试运行，但最好准备好如下方案：
  - 先运行 `python tools/api_server.py`，看是否能成功加载模型
  - 如果报显存不足，可考虑 `--half` 或 `--compile` 选项，但仍没有保证成功
  - 如果失败，说明这台显卡不够大，实际上是显存不够而不是下载的问题

## 5. 如果要在家里运行，推荐流程

1. 复制 `checkpoints/s2-pro` 到新电脑根目录
2. 进入项目根目录
3. 创建并激活 Python 虚拟环境
4. 安装依赖
5. 运行后端或 Web UI：
   - `python tools/api_server.py`
   - `python tools/run_webui.py`

## 6. 额外说明

- 如果你只是想在家里备份模型文件，不必关心显卡型号。
- 只有当你要执行推理时，显卡才是核心限制。
- 如果你希望运行更小的模型版本，当前仓库默认的是 S2-Pro，可能需要额外的轻量模型支持才行。

---

*本说明已记录在 `docs/gpu_compatibility.md`。*