FROM ubuntu:latest AS base
RUN apt update && apt upgrade -y

FROM base AS builder
RUN apt install -y git build-essential cmake
WORKDIR /
RUN git clone --depth=1 --recursive https://github.com/Kingcom/armips.git &&\
    git clone --depth=1 https://github.com/Lameguy64/mkpsxiso
RUN cd armips &&\
    mkdir build && cd build &&\
    cmake -DCMAKE_BUILD_TYPE=Release .. &&\
    cmake --build .
RUN cd mkpsxiso &&\
    git submodule update --init --recursive &&\
    cmake -S . -B ./build -DCMAKE_BUILD_TYPE=Release &&\
    cmake --build ./build

FROM base
RUN apt install -y \
    git \
    cmake \
    gdb-multiarch \
    gcc-mipsel-linux-gnu \
    g++-mipsel-linux-gnu \
    binutils-mipsel-linux-gnu
RUN apt clean &&\
    rm -rf /var/lib/apt/lists/*
COPY --from=builder /mkpsxiso/build/mkpsxiso /usr/local/bin/mkpsxiso
COPY --from=builder /mkpsxiso/build/dumpsxiso /usr/local/bin/dumpsxiso
COPY --from=builder /armips/build/armips /usr/local/bin/armips

ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
