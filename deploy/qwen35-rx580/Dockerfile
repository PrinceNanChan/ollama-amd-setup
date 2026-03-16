FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    git build-essential cmake ninja-build pkg-config \
    libvulkan-dev vulkan-tools ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*

ARG LLAMA_REPO=https://github.com/ggml-org/llama.cpp.git
ARG LLAMA_COMMIT=9e2e2198b

WORKDIR /opt
RUN git clone ${LLAMA_REPO} llama.cpp
WORKDIR /opt/llama.cpp
RUN git checkout ${LLAMA_COMMIT}

RUN cmake -S . -B build -G Ninja -DGGML_VULKAN=ON -DGGML_CUDA=OFF && \
    cmake --build build -j

WORKDIR /srv
COPY start.sh /srv/start.sh
RUN chmod +x /srv/start.sh

EXPOSE 11440
ENTRYPOINT ["/srv/start.sh"]
