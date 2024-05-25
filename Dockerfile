FROM ubuntu:noble AS base
RUN apt update && apt upgrade -y

FROM base AS builder
WORKDIR /
RUN apt install -y \
    git \
    build-essential \
    cmake \
    libfltk1.3-dev \
    libfreeimage-dev \
    libtinyxml2-dev \
    libglew-dev \
    xorg-dev

FROM builder AS armips
RUN git clone --depth=1 --recursive https://github.com/Kingcom/armips.git &&\
    cd armips &&\
    mkdir build && cd build &&\
    cmake -DCMAKE_BUILD_TYPE=Release .. &&\
    cmake --build .

FROM builder AS mkpsxiso
RUN git clone --depth=1 https://github.com/Lameguy64/mkpsxiso &&\
    cd mkpsxiso &&\
    git submodule update --init --recursive &&\
    cmake -S . -B ./build -DCMAKE_BUILD_TYPE=Release &&\
    cmake --build ./build

# FROM builder AS timedit
# RUN git clone --depth=1 https://github.com/alex-free/TIMedit &&\
#     cd TIMedit &&\
#     make

FROM builder AS smxtool
RUN git clone --depth=1 https://github.com/Lameguy64/smxtool &&\
    cd smxtool &&\
    make -f Makefile CONF=Release-linux

FROM builder AS img2tim
RUN git clone https://github.com/Lameguy64/img2tim &&\
    cd img2tim &&\
    g++ -o img2tim -O2 -Wall main.cpp tim.cpp -lfreeimage


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
    libtinyxml2-10 \
    libfltk-gl1.3 \
    libglu1-mesa \
    libglew2.2
RUN apt clean &&\
    rm -rf /var/lib/apt/lists/*
COPY --from=mkpsxiso /mkpsxiso/build/mkpsxiso /usr/local/bin/mkpsxiso
COPY --from=mkpsxiso /mkpsxiso/build/dumpsxiso /usr/local/bin/dumpsxiso
COPY --from=armips /armips/build/armips /usr/local/bin/armips
#COPY --from=timedit /TIMedit/timedit /usr/local/bin/timedit
COPY --from=smxtool /smxtool/dist/Release-linux/* /usr/local/bin/
COPY --from=img2tim /img2tim/img2tim /usr/local/bin/img2tim
COPY --from=img2tim /img2tim/img2tim.txt /root/img2tim.txt


ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
