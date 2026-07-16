#!/bin/sh

# Many parts of this script were taken from @REIGNZ, @idkwhoiam322 and @raphielscape . Huge thanks to them.

# KernelSu
curl -LSs "https://raw.githubusercontent.com/backslashxx/KernelSU/kernel/setup.sh" | bash -s master
#Cleaning
rm -rf out
make clean
make mrproper
# Some general variables
PHONE="lave"
ARCH="arm64"
SUBARCH="arm64"
DEFCONFIG=lavender-perf_defconfig 
COMPILER=clang
LINKER=""
KERNEL_DIR=$(pwd)
PATH="${KERNEL_DIR}/clang/bin:${KERNEL_DIR}/gcc/bin:${KERNEL_DIR}/gcc32/bin:${PATH}"

git clone --depth=1 https://github.com/sohamxda7/llvm-stable  clang
git clone https://github.com/sohamxda7/llvm-stable -b gcc64 --depth=1 gcc
git clone https://github.com/sohamxda7/llvm-stable -b gcc32  --depth=1 gcc32

# Outputs
mkdir -p zone_lave
mkdir -p out/outputs
mkdir -p out/outputs/${PHONE}
mkdir -p out/outputs/${PHONE}/NSE

# Export shits
export KBUILD_BUILD_USER=Zone
export KBUILD_BUILD_HOST=D543

# Speed up build process
MAKE="./makeparallel"

# Basic build function
BUILD_START=$(date +"%s")
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'

Build () {
make -j$(nproc --all) O=out \
ARCH=${ARCH} \
CC=clang \
CLANG_TRIPLE=aarch64-linux-gnu- \
CROSS_COMPILE=aarch64-linux-android- \
CROSS_COMPILE_ARM32=arm-linux-androideabi-
}

# Make defconfig

make O=out ARCH=${ARCH} ${DEFCONFIG}
if [ $? -ne 0 ]
then
    echo "Build failed"
else
    echo "Made ${DEFCONFIG}"
fi

# Build starts here
    #NSE
    Build
    if [ $? -ne 0 ]
    then
        echo "Build failed"
        rm -rf out/outputs/${PHONE}/NSE/*
    else
        echo "Build succesful"
        cp out/arch/arm64/boot/Image.gz-dtb out/outputs/${PHONE}/NSE/Image.gz-dtb
    fi

#Anykernel 
if [ ! -d "AnyKernel3" ]; then
            git clone -q https://github.com/diyantika/AnyKernel3.git -b Dipper-SE AnyKernel3
        fi
        
Zipping () {
       ZIPNAME="${PHONE}.zip"
       cd AnyKernel3
        git checkout Dipper-SE &> /dev/null
        zip -r9 "../$ZIPNAME" * -x .git README.md *placeholder
        cd ..
        #Pindah Zip
        mv "$ZIPNAME" zone_lave/
       }

#NSE
cp out/outputs/${PHONE}/NSE/Image.gz-dtb AnyKernel3/
Zipping "NSE"

rm -rf AnyKernel3/

BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
