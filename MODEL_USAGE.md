# Models in derived images and user environments

comfyui-runtime3 is a ComfyUI base image. This repository provides no start.sh
and defines no service startup or automatic model-download workflow. Its
Dockerfile installs runtime software; the Hugging Face artifacts downloaded
during the build are software wheels and a native binary archive, not models.

The image includes Civitai helper commands and the Hugging Face CLI as tools
available to derived images or manually invoked commands. Merely including
these tools does not execute them or download models. Service startup and
model provisioning belong to the consuming image or user environment.

## Separately supplied models

If a derived image or user environment adds model weights or other assets,
those assets retain their publishers' licenses and conditions. The MIT license
for this repository does not grant rights to those models. The party adding
or using them must check the terms for the exact model version and intended
use, and preserve any required license and attribution information.

This distinction does not change the distribution obligations for third-party
software already included in the base image; see
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md). The repository's own terms
are in [LICENSE](LICENSE).
