#!/bin/bash
set -e

export KBUILD_BUILD_USER="kepin"
export KBUILD_BUILD_HOST="lol"

# setup clang path (clang/ ada di root source kernel)
export PATH=$PWD/clang/bin:$PATH
export LD_LIBRARY_PATH=$PWD/clang/lib64:$LD_LIBRARY_PATH

CFG=arch/arm64/configs/vendor

# Fragment config yang digabung, urutan penting (yang belakang menimpa yang depan)
FRAGMENTS="$CFG/mt6768_defconfig $CFG/merlin.config"
[ -f "$CFG/erofs.config" ] && FRAGMENTS="$FRAGMENTS $CFG/erofs.config"
[ -f "$CFG/ksu.config" ]   && FRAGMENTS="$FRAGMENTS $CFG/ksu.config"
echo "Fragment yang dipakai: $FRAGMENTS"

# NOTE: langkah merge ini sengaja TANPA LLVM=1 (sama seperti script aslimu), jadi
# CONFIG_LTO_CLANG / CONFIG_CFI_CLANG (butuh CC_IS_CLANG) ikut terbuang dari .config.
# Itu bikin build lebih ringan dan sama dengan perilaku kernelmu yang sudah boot sebelumnya.
ARCH=arm64 scripts/kconfig/merge_config.sh -O "out" $FRAGMENTS

# Bagian ini yang dulu rusak: baris pertama make TIDAK ada backslash di akhir,
# jadi CC/CROSS_COMPILE dst. tidak pernah sampai ke make.
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
