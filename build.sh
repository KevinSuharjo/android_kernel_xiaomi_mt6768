#!/bin/bash

export KBUILD_BUILD_USER="kepin"  
export KBUILD_BUILD_HOST="lol"	

# setup clang & gcc-arm path
export PATH=$PWD/clang/bin:$PWD/gcc-arm/bin:$PATH

# Buat folder out
mkdir -p out

# Generate config merlin_defconfig
make -j$(nproc --all) ARCH=arm64 SUBARCH=arm64 O=out merlin_defconfig

# Proses kompilasi kernel dengan tambahan AS=llvm-as agar tidak lari ke /usr/bin/as
make -j$(nproc --all) ARCH=arm64 SUBARCH=arm64 O=out LLVM=1 LLVM_IAS=1 \
	CC="clang" \
	AS="llvm-as" \
	AR="llvm-ar" \
	NM="llvm-nm" \
	LD="ld.lld -S" \
	OBJCOPY="llvm-objcopy" \
	OBJDUMP="llvm-objdump" \
	STRIP="llvm-strip" \
	CLANG_TRIPLE="aarch64-linux-gnu-" \
	CROSS_COMPILE="aarch64-linux-gnu-" \
	CROSS_COMPILE_ARM32="arm-linux-androideabi-" \
	CROSS_COMPILE_COMPAT="arm-linux-androideabi-" \
	CONFIG_DEBUG_SECTION_MISMATCH=y
