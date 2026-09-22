# Third-party software notices

Build-input inventory based on the repository Dockerfile, constraints and
documentation, updated on 2026-09-22. This is not a new license audit.
Third-party copyrights belong to their respective holders.
These projects retain their own terms; the repository MIT license does not
override them. This is an inventory and source index, not a replacement for
upstream license texts or a complete image SBOM.

## Build inputs

| Component | How it enters the image | License/source reference and verification scope |
| --- | --- | --- |
| Ubuntu, Python, PyTorch, torchvision, torchaudio, Triton and NVIDIA CUDA/cuDNN/NCCL libraries | Inherited from ls250824/pytorch-cuda-ubuntu-runtime:22092026; repository documentation describes pytorch/pytorch:2.12.1-cuda13.0-cudnn9-runtime underneath | Mixed licenses. Inspect the exact base image, OS package copyright files and Python distribution notices. [Base image](https://hub.docker.com/r/ls250824/pytorch-cuda-ubuntu-runtime), [PyTorch](https://github.com/pytorch/pytorch), [NVIDIA CUDA terms](https://docs.nvidia.com/cuda/eula/index.html). The parent image has not been audited here. |
| ComfyUI | Git clone with default COMFYUI_VERSION=v0.37.0 into /ComfyUI | [Upstream GPL v3 text](https://github.com/Comfy-Org/ComfyUI/blob/master/LICENSE). Verify /ComfyUI/LICENSE for the actual resolved tag; the exact tag license was not retrievable during this review. Retain its source and any modifications. |
| ComfyUI Python requirements, including frontend distributions | pip install -r /ComfyUI/requirements.txt | Each distribution has its own terms; ComfyUI's license does not automatically cover these dependencies. Resolve the exact installed versions and their license/NOTICE files. |
| FlashAttention 2.8.4 | Prebuilt flash_attn wheel from LS110824/attentions-llama-cuda130 | [Upstream source and license files](https://github.com/Dao-AILab/flash-attention). Check the exact wheel and embedded dependencies. |
| Native llama.cpp b10218 | CUDA 13.0 archive from LS110824/attentions-llama-cuda130, extracted into /opt/llama.cpp | [Upstream source](https://github.com/ggml-org/llama.cpp). Verify release sources, build modifications, license files and bundled libraries against the downloaded archive. |
| llama-cpp-python 0.3.35 | Prebuilt wheel from LS110824/attentions-llama-cuda130 | [Upstream source](https://github.com/abetlen/llama-cpp-python). Review its bundled llama.cpp and native libraries separately from /opt/llama.cpp. |
| SageAttention 2.2.0 | Prebuilt wheel from LS110824/attentions-llama-cuda130 | [Upstream Apache-2.0 license](https://github.com/thu-ml/SageAttention/blob/main/LICENSE). Confirm terms and any required notices in the exact wheel. |
| torch_generic_nms 0.1 | Prebuilt wheel from LS110824/attentions-llama-cuda130 | [Repository linked by this project](https://github.com/ronghanghu/torch_generic_nms). License and exact wheel provenance remain unverified; do not infer MIT from availability or the hosting repository. |
| ONNX Runtime GPU 1.22.*, ONNX | pip install | [ONNX Runtime](https://github.com/microsoft/onnxruntime), [ONNX](https://github.com/onnx/onnx). Preserve package licenses and bundled third-party notices. |
| Hugging Face Hub / hf | pip install, then hf update | [Upstream source](https://github.com/huggingface/huggingface_hub). Final version is build-dependent; inspect installed distribution notices and dependencies. |
| Typer 0.21.1, Click 8.*, NumPy and other Python dependencies | Direct installation, constraints and dependency resolution | [Typer](https://github.com/fastapi/typer), [Click](https://github.com/pallets/click), [NumPy](https://github.com/numpy/numpy). Constraints are not a complete installed-package inventory. The Civitai scripts also import [Requests](https://github.com/psf/requests). |
| code-server | Unpinned code-server.dev/install.sh | [Upstream MIT license](https://github.com/coder/code-server/blob/main/LICENSE). Bundled VS Code, Node.js and other dependencies retain separate notices; review the actual installed release. |

## Binary artifacts and inherited components

The wheel/archive download source is [LS110824/attentions-llama-cuda130 on Hugging Face](https://huggingface.co/LS110824/attentions-llama-cuda130).
Hosting metadata or a repository-level license is not proof of the terms for
every uploaded binary. Exact source revisions, patches, build inputs and
embedded license files have not been verified here. Resolve these details,
especially torch_generic_nms provenance, before redistributing those artifacts.

The native archive and wheels may contain software beyond their named project.
Inspect `/opt/llama.cpp`, Python `.dist-info` license directories, the code-server
installation and `/usr/share/doc/*/copyright` in the built image. Preserve
notices already present in inherited layers; add missing required notices from
the matching upstream distribution rather than assigning a blanket license.

The code-server installer, hf update, version ranges and transitive dependencies
can change between builds. An image-specific inventory must use the final built
image, not just this table. Optional ComfyUI-Manager setup in the documentation
adds further dependencies and requires its own review if enabled.

See [LICENSE](LICENSE) for this repository's MIT terms and
[MODEL_USAGE.md](MODEL_USAGE.md) for separately supplied model assets.
Third-party software retains the upstream terms referenced above.
