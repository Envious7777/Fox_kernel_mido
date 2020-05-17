#!/usr/bin/env bash
#
# Copyright (C) 2020 Shashank's build script.
#
# Licensed under the General Public License.
# This program is free software; you can redistribute it and/or modify
# in the hope that it will be useful, but WITHOUT ANY WARRANTY;
#
#
# kernel building script.

export TERM=xterm

    red=$(tput setaf 1)             #  red
    grn=$(tput setaf 2)             #  green
    blu=$(tput setaf 4)             #  blue
    cya=$(tput setaf 6)             #  cyan
    txtrst=$(tput sgr0)             #  Reset

# clean up zip
echo -e ${blu}"clean up bish"${txtrst}
cd zip && rm -rf *.zip zImage && cd ..

# update repo of toolchain & anykernel 
cd zip && git pull && cd .. && cd toolchain_32 && git pull && cd .. && cd toolchain_64 && git pull && cd ..

# Environment
export KBUILD_BUILD_HOST="shashank's buildbot"
export KBUILD_BUILD_USER="shashank"
TOOLCHAIN=/home/shashank/fox/toolchain_64/bin/aarch64-linux-android-                   
export CROSS_COMPILE_ARM32=/home/shashank/fox/toolchain_32/bin/arm-linux-androideabi-
export CROSS_COMPILE="${CCACHE} ${TOOLCHAIN}"
export ARCH=arm64

# Run it
echo "Running ${RUN}"
eval ${RUN}
         
# Clean out folder
if [ "$CLEAN" == "yes" ]
then
echo -e ${blu}"Removing existing images"${txtrst}
  rm -rf out
fi

# cache
if [ "$use_ccache" = "yes" ]; 
then echo -e ${blu}"CCACHE is enabled for this build"${txtrst} 
export CCACHE_EXEC=$(which ccache) 
export USE_CCACHE=1 
export CCACHE_DIR=/home/shashank/.jenkins/ccache/ 
ccache -M 50G
fi

if [ "$use_ccache" = "clean" ]; 
then export CCACHE_EXEC=$(which ccache) 
export CCACHE_DIR=/home/shashank/.jenkins/ccache/ 
ccache -C
export USE_CCACHE=1 
ccache -M 50G 
wait 
echo -e ${grn}"CCACHE Cleared"${txtrst};
fi

# Start compilation
echo -e ${blu}"Starting compilation...."${txtrst}
make clean O=out/
make mido_defconfig O=out/
make -j"$jobs" O=out
wait
echo -e ${blu}"Build completed plox"${txtrst}

#make kernel zip
echo -e ${blu}"making flashable zip"${txtrst}
cp -r out/arch/arm64/boot/Image.gz-dtb zip/
cd zip
mv Image.gz-dtb zImage
zip -r Fox_kernel_4.9-mido.zip *
wait 
echo -e ${blu}"zip completed test it plox"${txtrst}
