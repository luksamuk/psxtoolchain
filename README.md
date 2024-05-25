# psxtoolchain

PlayStation 1 (PSX) Docker toolchain for building projects and ISO images

## About

This repository contains the Dockerfile and instructions for building your own PlayStation games as ISO files.

I created this because I felt like the toolchain was somewhat directed to Windows users. I prefer doing things on Linux, or even, if I were using Windows, I'd still use WSL to develop my games.

Please notice that **I am also not redistributing anything here that may cause copyright infringiment**. This image is composed of opensource software that can be freely installed on a Linux system with no extra effort, plus a few opensource projects that can be compiled from source with no problems. So you might need extra files for building your ISO, for example, which cannot be obtained on this Docker image.

This Docker image definition contains:

- Ubuntu 24.04 LTS Noble Numbat;
- A modern GCC-MIPSEL compiler;
- GDB-Multiarch (if needed);
- CMake, Make;
- Git;
- [armips assembler](https://github.com/Kingcom/armips), compiled from source;
- [mkpsxiso](https://github.com/Lameguy64/mkpsxiso), compiled from source;
<!-- - [TIMedit](https://github.com/alex-free/TIMedit), more precisely, a Linux fork, compiled from source; -->
- [smxtool](https://github.com/Lameguy64/smxtool), a model viewer and material editor;
- [img2tim](https://github.com/Lameguy64/img2tim), a tool to convert images to PlayStation TIM format (The `img2tim.txt` documentation can be found in `/root/img2tim.txt`).

This project is also heavily inspired by the [psptoolchain](https://github.com/pspdev/psptoolchain).

## Requirements

If anything, you'll need Docker installed and nothing else.
I also expect you to be using the PsyQ + Nugget toolchain or something similar, as long as it can be compiled with a modern GNU C Compiler for MIPS.

You can easily generate a project by using the [PSX.Dev extension for VSCode](https://marketplace.visualstudio.com/items?itemName=Grumpycoders.psx-dev).

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

### Running TIMedit

Some tools are GUI tools for Linux. So you might need extra configuration to give it access to a running X11 session.

Here is an example running ~smxtool~:

```bash
docker run -it --rm \
    -e DISPLAY=${DISPLAY} \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ~/.Xauthority:/root/.Xauthority \
    -v $(pwd):/source \
    -w /source \
    --net=host \
    luksamuk/psxtoolchain:latest \
    smxtool
```

## Building the image

Here's how I build it using BuildX directly. Of course, you won't be able to push to `luksamuk/psxtoolchain:latest`. :)

```bash
docker buildx build . -t luksamuk/psxtoolchain:latest --push
```

## License

This code is distributed under the MIT License.

