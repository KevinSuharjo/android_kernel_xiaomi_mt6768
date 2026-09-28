#!/bin/bash
set -e

export KBUILD_BUILD_USER="kepin"
export KBUILD_BUILD_HOST="lol"

# setup clang path (clang di-clone ke folder ./clang)
export PATH="$PWD/clang/bin:$PATH"

# mt6768-dev/android_kernel_xiaomi_mt6768 (lineage-20): defconfig-nya merlin_defconfig
DEFCONFIG="arch/arm64/configs/merlin_defconfig"

# optional: fragment tambahan (mis. ksu.config) lewat env EXTRA_CFG
EXTRA_CFG="${EXTRA_CFG:-}"

mkdir -p out
ARCH=arm64 scripts/kconfig/merge_config.sh -O out "$DEFCONFIG" $EXTRA_CFG

# PENTING: setiap baris di bawah harus diakhiri "\" kecuali baris terakhir
make -j"$(nproc --all)" ARCH=arm64 SUBARCH=arm64 O=out \
	LLVM=1 LLVM_IAS=1 \
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
	CROSS_COMPILE_COMPAT="arm-linux-gnueabi-"
