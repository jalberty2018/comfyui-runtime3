# comfyui-runtime3

## Information

- Docker base image for ComfyUI inference with GPU (CUDA) acceleration.
- This image does not start any services; use `ls250824/run-x` for that.
- Based on [`ls250824/pytorch-cuda-ubuntu-runtime:22092026`](https://hub.docker.com/r/ls250824/pytorch-cuda-ubuntu-runtime/tags?name=22092026).
- That base image already integrates the official `pytorch/pytorch:2.12.1-cuda13.0-cudnn9-runtime` image; do not install PyTorch or CUDA again in this image.
- Includes native llama.cpp `b10218` and `llama-cpp-python` `0.3.35` as
  separate installations so their shared libraries cannot override each other.

## Websites

- [ComfyUI](https://github.com/Comfy-Org/ComfyUI)
- [Code server](https://github.com/coder/code-server)
- [HuggingFace cli](https://huggingface.co/docs/huggingface_hub/guides/cli)
- [Flash attention](https://github.com/Dao-AILab/flash-attention)
- [Sage attention](https://github.com/thu-ml/SageAttention)
- [Onnxruntime-gpu](https://pypi.org/project/onnxruntime-gpu/)
- [Triton](https://triton-lang.org/main/index.html)
- [torch_generic_nms](https://github.com/ronghanghu/torch_generic_nms)
- [llama.cpp](https://github.com/ggml-org/llama.cpp)
- [llama-cpp-python](https://github.com/abetlen/llama-cpp-python)

## Images on Docker

- If the image is **less than one day old**, it might not be tested yet or might still be updated.

## Latest Image Setup

### Image

| Component | Version              |
|-----------|----------------------|
| OS        | `Ubuntu 24.04 x86_64` |
| Python    | `3.12.x`             |
| PyTorch   | `2.12.1+cu130`             |
| Torchvision | `0.27.1+cu130`           |
| Torchaudio | `2.11.0+cu130`            |
| CUDA      | `13.0`               |
| cuDNN     | `9`                  |
| Triton    | `3.7.1`              |
| onnxruntime-gpu | `1.22.*`     |
| ComfyUI | `0.37.0` |
| Native llama.cpp | `b10218` |
| CodeServer | `latest`          |

The PyTorch, torchvision, torchaudio, Triton and CUDA versions above match the
supplied base-image build log from 2026-09-22. ONNX Runtime is constrained to
`1.22.*`; its exact patch version is resolved during the build.

`CUDA available: False` in a Docker build without GPU access is expected.
It does not establish whether GPU execution works in the deployed container.
With the NVIDIA driver and NVIDIA Container Toolkit installed on the host,
check the built image at runtime:

```bash
docker run --rm --gpus all ls250824/comfyui-runtime3:<tag> \
  python -c "import torch; print(torch.__version__, torch.version.cuda); assert torch.cuda.is_available(), 'CUDA is unavailable'; print(torch.cuda.get_device_name(0))"
```

### Wheels

| Package        | Version  |
|----------------|----------|
| flash_attn     | `2.8.4`    |
| llama-cpp-python | `0.3.35` |
| sageattention  |  `2.2.0`   |
| torch_generic_nms | `0.1` |

### Native llama.cpp

The wheels and native archive are downloaded from
[LS110824/attentions-llama-cuda130](https://huggingface.co/LS110824/attentions-llama-cuda130).
The native archive is `llama-cpp-b10218-cu130-linux-x86_64.tar.gz`.
The image installs it under `/opt/llama.cpp`. The included commands, such as `llama-cli`, `llama-server`, and `llama-bench`, are available through `PATH`.

The archive is built for CUDA 13.0 on Linux `x86_64`. Its binaries use an
embedded relative RPATH for the libraries in `/opt/llama.cpp/lib`.
`llama-cpp-python` continues to use its package-local libraries. Do not set
`LD_LIBRARY_PATH=/opt/llama.cpp/lib` or `LLAMA_CPP_LIB_PATH` globally and do
not add this directory to `ld.so.conf`.

### Optimised

| Architecture | Compute Capability | Native Build Target | Examples |
|---|---:|---:|---|
| Ampere | 8.6 | `sm_86` | RTX 3090, RTX A5000, RTX A6000, A40 |
| Ada Lovelace | 8.9 | `sm_89` | RTX 4090, RTX 6000 Ada, L40, L40S |
| Blackwell | 12.0 | `sm_120` | RTX 5090, RTX PRO 6000 |

## Build Constraints (`/constraints.txt`)

```txt
numpy<2
onnxruntime-gpu==1.22.*
onnxruntime==0
flash-attn==2.8.4
llama-cpp-python==0.3.35
sageattention==2.2.0
typer==0.21.1
click==8.*
huggingface_hub>=1.24.0
```

## Adding ComfyUI-Manager Internal Version Instead of Legacy

```bash
WORKDIR /ComfyUI
RUN --mount=type=cache,target=/root/.cache/pip \
    python -m pip install --no-cache-dir --root-user-action ignore -c /constraints.txt \
    matrix-nio \
    -r manager_requirements.txt
```

## Docker Speedup

```bash
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
```
