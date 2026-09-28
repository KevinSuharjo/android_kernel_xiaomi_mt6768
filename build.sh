#!/bin/bash

export KBUILD_BUILD_USER="kepin"  
export KBUILD_BUILD_HOST="lol"	

# setup clang path
export PATH=$PWD/clang/bin:$PATH

# Buat folder out
mkdir -p out

# Langsung panggil defconfig vendor mt6768 (karena biasanya merlin.config udah di-include di dalamnya)
make -j$(nproc --all) ARCH=arm64 SUBARCH=arm64 O=out mt6768_defconfig

# Proses kompilasi kernel
make -j$(nproc --all) ARCH=arm64 SUBARCH=arm64 O=out LLVM=1 LLVM_IAS=1 \
	CC="clang" \
	AR="llvm-ar" \
	NM="llvm-nm" \
	LD="ld.lld -S" \
	OBJCOPY="llvm-objcopy" \
	OBJDUMP="llvm-objdump" \
	STRIP="llvm-strip" \
	CLANG_TRIPLE="aarch64-linux-gnu-" \
	CROSS_COMPILE="aarch64-linux-gnu-" \
	CROSS_COMPILE_ARM32="arm-linux-gnueabi-" \
	CROSS_COMPILE_COMPAT="arm-linux-gnueabi-" \
	CONFIG_DEBUG_SECTION_MISMATCH=y
