FROM ubuntu:noble AS base
RUN apt update && apt upgrade -y

FROM base AS builder
WORKDIR /
RUN apt install -y \
    git \
    curl \
    7zip \
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

FROM builder AS timedit
COPY ./timedit.patch /timedit.patch
RUN git clone --depth=1 https://github.com/alex-free/TIMedit &&\
    cd TIMedit &&\
    git apply /timedit.patch &&\
    make

FROM builder AS smxtool
RUN git clone --depth=1 https://github.com/Lameguy64/smxtool &&\
    cd smxtool &&\
    make -f Makefile CONF=Release-linux

FROM builder AS img2tim
RUN git clone https://github.com/Lameguy64/img2tim &&\
    cd img2tim &&\
    g++ -o img2tim -O2 -Wall main.cpp tim.cpp -lfreeimage

FROM builder AS candyk
RUN apt install -y \
    meson ninja-build \
    libavformat-dev \
    libavcodec-dev \
    libavutil-dev \
    libswresample-dev \
    libswscale-dev

FROM candyk as psxavenc
RUN git clone --depth=1 https://github.com/WonderfulToolchain/psxavenc &&\
    cd psxavenc &&\
    meson setup build &&\
    cd build &&\
    ninja install

FROM candyk as xainterleave
RUN git clone --depth=1 https://github.com/ABelliqueux/candyk-psx &&\
    cd candyk-psx &&\
    make bin/xainterleave

FROM builder AS wav2vag
COPY ./wav2vag.patch /wav2vag.patch
RUN git clone --depth=1 https://github.com/Aikku93/wav2vag &&\
    cd wav2vag &&\
    git apply /wav2vag.patch &&\
    make

FROM builder AS psn00bsdk
ARG PSN00BSDK_URL=https://github.com/Lameguy64/PSn00bSDK/releases/download/v0.24/PSn00bSDK-0.24-Linux.zip
RUN curl -L ${PSN00BSDK_URL} -o "psn00bsdk.zip" &&\
    7z x "psn00bsdk.zip" &&\
    rm "psn00bsdk.zip" &&\
    find . -name "PSn00bSDK-*-Linux" | xargs -I {} mv {} "/psn00bsdk"

FROM builder AS tochd
RUN git clone --depth=1 https://github.com/thingsiplay/tochd &&\
    chmod +x tochd/tochd.py
    

FROM base AS final
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
RUN apt install -y \
    libavformat60 \
    libavcodec60 \
    libavutil58 \
    libswresample4 \
    libswscale7
RUN apt install -y \
    ffmpeg \
    mencoder
RUN apt install -y \
    7zip \
    mame-tools \
    python3

RUN apt clean &&\
    rm -rf /var/lib/apt/lists/*
COPY --from=mkpsxiso /mkpsxiso/build/mkpsxiso /usr/local/bin/mkpsxiso
COPY --from=mkpsxiso /mkpsxiso/build/dumpsxiso /usr/local/bin/dumpsxiso
COPY --from=armips /armips/build/armips /usr/local/bin/armips
COPY --from=timedit /TIMedit/timedit /usr/local/bin/timedit
COPY --from=smxtool /smxtool/dist/Release-linux/* /usr/local/bin/
COPY --from=img2tim /img2tim/img2tim /usr/local/bin/img2tim
COPY --from=img2tim /img2tim/img2tim.txt /root/img2tim.txt
COPY --from=psxavenc /psxavenc/build/psxavenc /usr/local/bin/psxavenc
COPY --from=xainterleave /candyk-psx/bin/xainterleave /usr/local/bin/xainterleave
COPY --from=wav2vag /wav2vag/release/wav2vag /usr/local/bin/wav2vag
COPY --from=psn00bsdk /psn00bsdk/ /opt/psn00bsdk/
COPY --from=tochd /tochd/tochd.py /usr/local/bin/tochd
COPY ./gdbinit /root/.config/gdb/gdbinit

ENV PATH           /opt/psn00bsdk/bin:${PATH}
ENV PSN00BSDK_LIBS /opt/psn00bsdk/lib/libpsn00b


ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
