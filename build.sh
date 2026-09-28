#!/bin/bash

export KBUILD_BUILD_USER="kepin"  
export KBUILD_BUILD_HOST="lol"	

# setup clang path
export PATH=$PWD/clang/bin:$PATH

# Wajib buat folder out dulu biar gak error "directory does not exist"
mkdir -p out

# Jalankan merge_config dengan path file yang sesuai (masuk ke folder vendor/)
ARCH=arm64 scripts/kconfig/merge_config.sh -O "out" arch/arm64/configs/vendor/mt6768_defconfig arch/arm64/configs/vendor/merlin.config

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
