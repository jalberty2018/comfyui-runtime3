# syntax=docker/dockerfile:1.7

FROM ls250824/pytorch-cuda-ubuntu-runtime:22092026

ENV PIP_BREAK_SYSTEM_PACKAGES=1

# Set working directory
WORKDIR /

# Pin
COPY constraints.txt /constraints.txt

# Pre-built native llama.cpp CUDA release from Hugging Face
ARG LLAMA_CPP_TAG=b10218

# Install Hugging Face CLI before downloading the wheels
RUN --mount=type=cache,target=/root/.cache/pip \
    python -m pip install --no-cache-dir --root-user-action ignore -c /constraints.txt \
        huggingface_hub

# Download and install the GPU artifacts. Native llama.cpp remains separate
# from llama-cpp-python so their shared libraries cannot override each other.
RUN --mount=type=cache,target=/root/.cache/pip \
    hf download LS110824/attentions-llama-cuda130 \
        flash_attn-2.8.4-cp312-cp312-linux_x86_64.whl \
        llama-cpp-${LLAMA_CPP_TAG}-cu130-linux-x86_64.tar.gz \
        llama_cpp_python-0.3.35-py3-none-linux_x86_64.whl \
        sageattention-2.2.0-cp312-cp312-linux_x86_64.whl \
        torch_generic_nms-0.1-cp312-cp312-linux_x86_64.whl \
        --local-dir / \
    && python -m pip install \
        --no-cache-dir \
        --root-user-action ignore \
        -c /constraints.txt \
        \
        ./flash_attn-2.8.4-cp312-cp312-linux_x86_64.whl \
        ./llama_cpp_python-0.3.35-py3-none-linux_x86_64.whl \
        ./sageattention-2.2.0-cp312-cp312-linux_x86_64.whl \
        ./torch_generic_nms-0.1-cp312-cp312-linux_x86_64.whl \
        \
        "onnxruntime-gpu==1.22.*" \
        onnx \
        "typer==0.21.1" \
        "click==8.*" \
    && rm -f \
        flash_attn-2.8.4-cp312-cp312-linux_x86_64.whl \
        llama_cpp_python-0.3.35-py3-none-linux_x86_64.whl \
        sageattention-2.2.0-cp312-cp312-linux_x86_64.whl \
        torch_generic_nms-0.1-cp312-cp312-linux_x86_64.whl \
    && mkdir -p /opt/llama.cpp \
    && tar -xzf /llama-cpp-${LLAMA_CPP_TAG}-cu130-linux-x86_64.tar.gz \
        -C /opt/llama.cpp \
    && rm /llama-cpp-${LLAMA_CPP_TAG}-cu130-linux-x86_64.tar.gz \
    && test -x /opt/llama.cpp/bin/llama-cli \
    && find /opt/llama.cpp -type f -name 'libggml-cuda.so*' -print -quit \
        | grep -q .

ENV PATH="/opt/llama.cpp/bin:${PATH}" \
    MINIMAX_H3_LLAMA_SERVER="/opt/llama.cpp/bin/llama-server"

# Make the CUDA libraries installed as Python packages available to native wheels.
RUN python - <<'PY'
from pathlib import Path
import site
import sys

required_packages = ("cuda_runtime", "cublas", "nccl")
site_packages = {
    Path(path)
    for path in (*site.getsitepackages(), *sys.path)
    if path
}
library_dirs = {
    library_dir
    for root in site_packages
    for library_dir in (root / "nvidia").glob("*/lib")
    if library_dir.is_dir()
}

missing = [
    package
    for package in required_packages
    if not any(path.parts[-3:-1] == ("nvidia", package) for path in library_dirs)
]
if missing:
    raise RuntimeError(f"Missing NVIDIA library directories: {', '.join(missing)}")

config = "\n".join(str(path) for path in sorted(library_dirs)) + "\n"
Path("/etc/ld.so.conf.d/python-nvidia.conf").write_text(config)
PY
RUN ldconfig

# ComfyUI release version
ARG COMFYUI_VERSION=v0.37.0

# Clone ComfyUI
RUN --mount=type=cache,target=/root/.cache/git \
    git clone --depth=1 --branch "${COMFYUI_VERSION}" https://github.com/Comfy-Org/ComfyUI.git /ComfyUI

# ComfyUI
WORKDIR /ComfyUI

# Install ComfyUI requirements
RUN --mount=type=cache,target=/root/.cache/pip \
    python -m pip install --no-cache-dir --root-user-action ignore -c /constraints.txt \
        -r requirements.txt

# Set working directory
WORKDIR /

# Install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Copy and set up Civitai downloader with appropriate permissions
COPY --chmod=755 civitai_com_environment.py /usr/local/bin/civitai_com
COPY --chmod=755 civitai_red_environment.py /usr/local/bin/civitai_red

# Project licensing documents; upstream components retain their own notices.
COPY THIRD_PARTY_NOTICES.md MODEL_USAGE.md /usr/share/doc/comfyui-runtime3/

# Labels
LABEL org.opencontainers.image.title="Base image ComfyUI 0.37.0 + code-server + downloaders" \
      org.opencontainers.image.description="ComfyUI + flash-attn + native llama.cpp + llama-cpp-python + sageattention + onnxruntime-gpu + torch_generic_nms + code-server + civitai downloader + huggingface_hub" \
      org.opencontainers.image.source="https://hub.docker.com/r/ls250824/comfyui-runtime3" \
      org.opencontainers.image.licenses=""

# Check
# Update Hugging Face CLI and verify the hf command is available
RUN hf update && hf version

# CPU-safe package and artifact verification. Docker builds have no GPU/driver,
# so do not import CUDA-backed modules or execute native llama.cpp binaries here.
# Runtime CUDA checks are performed by run-comfyui-minimax/start.sh on the pod.
RUN python - <<'PY'
import importlib.metadata as metadata
import os
from pathlib import Path

packages = (
    "torch",
    "torchvision",
    "torchaudio",
    "triton",
    "llama-cpp-python",
    "onnxruntime-gpu",
)
for package in packages:
    print(f"{package}: {metadata.version(package)}")

executables = (
    Path("/opt/llama.cpp/bin/llama-cli"),
    Path(os.environ["MINIMAX_H3_LLAMA_SERVER"]),
)
for executable in executables:
    if not executable.is_file() or not os.access(executable, os.X_OK):
        raise RuntimeError(f"Missing or non-executable llama.cpp artifact: {executable}")
    print(f"llama.cpp artifact: {executable}")
PY

# ComfyUI
RUN cat ComfyUI/comfyui_version.py
