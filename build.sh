#!/bin/bash
set -e

mkdir -p out

export KBUILD_BUILD_USER="kepin"
export KBUILD_BUILD_HOST="lol"

# Setup Clang path (folder clang ada di root kernel source saat di runner)
if [ -d "$PWD/clang" ]; then
    export PATH=$PWD/clang/bin:$PATH
    export LD_LIBRARY_PATH=$PWD/clang/lib64:$LD_LIBRARY_PATH
fi

CFG=arch/arm64/configs/vendor

# Fragment config yang digabung, urutan penting (yang belakang menimpa yang depan)
FRAGMENTS=""
[ -f "$CFG/mt6768_defconfig" ] && FRAGMENTS="$FRAGMENTS $CFG/mt6768_defconfig"
[ -f "$CFG/merlin.config" ]     && FRAGMENTS="$FRAGMENTS $CFG/merlin.config"
[ -f "$CFG/erofs.config" ]      && FRAGMENTS="$FRAGMENTS $CFG/erofs.config"
[ -f "$CFG/ksu.config" ]        && FRAGMENTS="$FRAGMENTS $CFG/ksu.config"

# Kalau vendor/mt6768_defconfig ga ada, fallback ke merlin_defconfig biasa
if [ -z "$FRAGMENTS" ]; then
    FRAGMENTS="arch/arm64/configs/merlin_defconfig"
fi

echo ">> Fragment config yang dipakai: $FRAGMENTS"

ARCH=arm64 scripts/kconfig/merge_config.sh -O "out" $FRAGMENTS

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
