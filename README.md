# psxtoolchain

PlayStation 1 (PSX) Docker toolchain for building projects and ISO images

## About

This repository contains the Dockerfile and instructions for building your own PlayStation games as ISO files.

I created this because I felt like the toolchain was somewhat directed to Windows users. I prefer doing things on Linux, or even, if I were using Windows, I'd still use WSL to develop my games.

This Docker image definition contains:

- The latest Ubuntu (currently 24.04 LTS Noble Numbat)
- A modern GCC-MIPSEL compiler;
- [mkpsxiso](https://github.com/Lameguy64/mkpsxiso), compiled from source;
- CMake, Make;
- Git;
- Bchunk (if needed).

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

## Building the image

Here's how I build it using BuildX directly. Of course, you won't be able to push to ~luksamuk/psxtoolchain:latest~. :)

```bash
docker buildx build . -t luksamuk/psxtoolchain:latest --push
```

## License

This code is distributed under the MIT License.

