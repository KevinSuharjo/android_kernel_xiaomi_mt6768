#!/bin/bash

export KBUILD_BUILD_USER="kepin"  
export KBUILD_BUILD_HOST="lol"	

# setup clang path
export PATH=$PWD/clang/bin:$PATH

# Buat folder out
mkdir -p out

# Clone atau pastikan gcc 32-bit tersedia jika belum ada (biasanya butuh gcc arm untuk cross compile 32-bit vdso)
if [ ! -d "gcc-arm" ]; then
    git clone --depth=1 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9 gcc-arm
fi

export PATH=$PWD/gcc-arm/bin:$PATH

# Generate config merlin_defconfig
make -j$(nproc --all) ARCH=arm64 SUBARCH=arm64 O=out merlin_defconfig

# Proses kompilasi kernel dengan tambahan path cross compile arm32
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
	CROSS_COMPILE_ARM32="arm-linux-androideabi-" \
	CROSS_COMPILE_COMPAT="arm-linux-androideabi-" \
	CONFIG_DEBUG_SECTION_MISMATCH=y
