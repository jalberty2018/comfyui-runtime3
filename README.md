[![Docker Image Version](https://img.shields.io/docker/v/ls250824/comfyui-runtime3)](https://hub.docker.com/r/ls250824/comfyui-runtime3)

# comfyui-runtime3

## Information

- Docker base image for ComfyUI inference with GPU (CUDA) acceleration.
- Includes ComfyUI `0.37.0`.
- CUDA 13.0 support
- Includes native llama.cpp `b10218` for CUDA 13.0 and `llama-cpp-python`
  `0.3.35` as separate installations.
- This image does not start any services; use `ls250824/run-x` for that.

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

## Build

- [Setup](documentation/README_docker.md)

## Available Images

### Base Image

`ls250824/pytorch-cuda-ubuntu-runtime:22092026`

This base image includes the official
`pytorch/pytorch:2.12.1-cuda13.0-cudnn9-runtime` image.

The supplied base-image build log (2026-09-22) reports PyTorch `2.12.1+cu130`,
torchvision `0.27.1+cu130`, torchaudio `2.11.0+cu130`, and Triton `3.7.1`.
See the [setup documentation](documentation/README_docker.md) for build inputs
and GPU verification.

[Docker Hub: ls250824/pytorch-cuda-ubuntu-runtime](https://hub.docker.com/r/ls250824/pytorch-cuda-ubuntu-runtime)

### Custom Build

```bash
docker pull ls250824/comfyui-runtime3:<tag>
```

[Docker Hub: ls250824/comfyui-runtime3](https://hub.docker.com/r/ls250824/comfyui-runtime3)

## Building the Docker Image

The image can be built on a CPU-only Docker host. A GPU, NVIDIA driver, and
NVIDIA Container Toolkit are only required when running GPU workloads. The
pre-built llama.cpp archive targets Linux `amd64`; use the platform explicitly
when the builder is not already `amd64`:

```bash
docker build --platform linux/amd64 -t ls250824/comfyui-runtime3:<tag> ./comfyui-runtime3
```

Run this command from the parent directory of `comfyui-runtime3`.

You can build and push the image to Docker Hub using the `build_docker.py` script.

### `build_docker.py` Script Options

| Option         | Description                                         | Default                |
|----------------|-----------------------------------------------------|------------------------|
| `--username`   | Docker Hub username                                 | `name`                 |
| `--tag`        | Tag to use for the image                            | Today's date           |
| `--latest`     | If specified, also tags and pushes as `latest`      | Not enabled by default |

### Build & Push Command

Run the following command to clone the repository and build the image:

```bash
git clone https://github.com/jalberty2018/comfyui-runtime3.git
cp comfyui-runtime3/build_docker.py .

export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

python3 build_docker.py \
--username=<your_dockerhub_username> \
--tag=<custom_tag> \
comfyui-runtime3
```

Note: If you want to push the image with the latest tag, add the `--latest` flag at the end.
