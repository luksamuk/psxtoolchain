# psxtoolchain

PlayStation 1 (PSX) Docker toolchain for building projects and ISO images

## About

This repository contains the Dockerfile and instructions for building your own PlayStation games as ISO files.

This image **also supports PSn00bSDK**.

I created this because I felt like the toolchain was somewhat directed to Windows users. I prefer doing things on Linux, or even, if I were using Windows, I'd still use WSL to develop my games.

Please notice that **I am also not redistributing anything here that may cause copyright infringiment**. This image is composed of opensource software that can be freely installed on a Linux system with no extra effort, plus a few opensource projects that can be compiled from source with no problems. So you might need extra files for building your ISO, for example, which cannot be obtained on this Docker image.

This Docker image definition contains:

- Ubuntu 24.04 LTS Noble Numbat;
- A modern GCC-MIPSEL compiler (`mipsel-linux-gnu-gcc` GCC 12.3.0);
- PSn00bSDK toolchain and libraries (`mipsel-none-elf-gcc` GCC 12.3.0 and everything under `/opt/psn00bsdk`);
- GDB-Multiarch (if needed -- scripts allowed on `/source`);
- CMake, Make;
- Git;
- [armips assembler](https://github.com/Kingcom/armips), compiled from source;
- [mkpsxiso](https://github.com/Lameguy64/mkpsxiso), compiled from source;
- [TIMedit](https://github.com/alex-free/TIMedit), more precisely, a Linux fork (with an extra patch to avoid segfaults), compiled from source;
- [smxtool](https://github.com/Lameguy64/smxtool), a model viewer and material editor;
- [img2tim](https://github.com/Lameguy64/img2tim), a tool to convert images to PlayStation TIM format (The `img2tim.txt` documentation can be found in `/root/img2tim.txt`);
- `psxavenc` from [WonderfulToolchain](https://github.com/WonderfulToolchain/psxavenc)
- `xainterleave` from [CandyK-PSX](https://github.com/ABelliqueux/candyk-psx) SDK;
- [wav2vag](https://github.com/Aikku93/wav2vag), a WAV to VAG (4-bit ADPCM compressed PSX sound format) converter.

This project is also heavily inspired by the [psptoolchain](https://github.com/pspdev/psptoolchain).

## Requirements

If anything, you'll need Docker installed and nothing else.

### If you're using PsyQ + Nugget or similar...

A PsyQ + Nugget project can be compiled with a modern GNU C Compiler for MIPS, most notably, using the toolchain under `mipsel-linux-gnu-*` present on PATH.

You can easily generate a project by using the [PSX.Dev extension for VSCode](https://marketplace.visualstudio.com/items?itemName=Grumpycoders.psx-dev).

### If you're using PSn00bSDK...

This image already exports environment variables that are needed when compiling a project with PSn00bSDK.

Please refer to [PSn00bSDK's Installation Guide](https://github.com/Lameguy64/PSn00bSDK/blob/master/doc/installation.md) for more information.

## How to use

There are many ways to use this.

My first recommendation is that you use this in a bash script such as `buildiso.sh`. Suppose you have a proper `CDLAYOUT.xml` file for building your PSX ISO on your project directory. So you can use the following script:

```bash
#!/bin/bash
exec docker run --rm \
     -v $(pwd):/source \
     -w /source \
     luksamuk/psxtoolchain:latest \
     "make && mkpsxiso -y CDLAYOUT.xml"
```

If you want more direct control over building, you can also mount your project on a directory of your container and then you can do whatever by running an Ubuntu console there:

```bash
docker run -it --rm \
    -v $(pwd):/source \
    -w /source \
    luksamuk/psxtoolchain:latest \
    /bin/bash
```

For more info, please refer to ~mkpsxiso~ above.

### Running graphical tools

Some tools are GUI tools for Linux. So you might need extra configuration to give it access to a running X11 session.

Here is an example running ~timedit~:

```bash
docker run -it --rm \
    -e DISPLAY=${DISPLAY} \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ~/.Xauthority:/root/.Xauthority \
    -v $(pwd):/source \
    -w /source \
    --net=host \
    luksamuk/psxtoolchain:latest \
    timedit
```

Remember that, if you need access to your own filesystem, you'll be able to do that through the `/source` directory in this case, which is expected to be your own project dir, so be mindful of where you're running the script above.

Some graphical binaries you may want to use are:

- `timedit`
- `smxtool`

## Building the image

Here's how I build it using BuildX directly. Of course, you won't be able to push to `luksamuk/psxtoolchain:latest`. :)

```bash
docker buildx build . -t luksamuk/psxtoolchain:latest --push
```

## License

This code is distributed under the MIT License.

