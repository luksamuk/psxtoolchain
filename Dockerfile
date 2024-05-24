FROM ubuntu:noble AS base
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
RUN git clone --depth=1 https://github.com/alex-free/TIMedit &&\
    apt install -y libfltk1.3-dev libfreeimage-dev libtinyxml2-dev &&\
    cd TIMedit &&\
    make

FROM base
RUN apt install -y \
    git \
    cmake \
    gdb-multiarch \
    gcc-mipsel-linux-gnu \
    g++-mipsel-linux-gnu \
    binutils-mipsel-linux-gnu
RUN apt install -y \
    libfltk1.3t64 \
    libfltk-images1.3 \
    libfreeimage3 \
    libtinyxml2-10
RUN apt clean &&\
    rm -rf /var/lib/apt/lists/*
COPY --from=builder /mkpsxiso/build/mkpsxiso /usr/local/bin/mkpsxiso
COPY --from=builder /mkpsxiso/build/dumpsxiso /usr/local/bin/dumpsxiso
COPY --from=builder /armips/build/armips /usr/local/bin/armips
COPY --from=builder /TIMedit/timedit /usr/local/bin/timedit

ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
