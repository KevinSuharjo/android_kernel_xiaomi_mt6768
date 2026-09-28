# Taruh di: .github/workflows/build-kernel.yml di repo kernel_action_merlin
# Repo ini cuma berisi build.sh + workflow; source kernel di-checkout terpisah ke ./kernel
name: Build kernel merlin

on:
  workflow_dispatch:
    inputs:
      kernel_repo:
        description: "Repo source kernel"
        default: "mt6768-dev/android_kernel_xiaomi_mt6768"
      kernel_ref:
        description: "Branch / tag / commit"
        default: "lineage-20"
      ksu:
        description: "Integrasi KernelSU (butuh manual hook sudah ter-patch di source!)"
        type: boolean
        default: false

jobs:
  build:
    runs-on: ubuntu-22.04
    steps:
      - name: Checkout scripts (build.sh)
        uses: actions/checkout@v4

      - name: Checkout kernel source
        uses: actions/checkout@v4
        with:
          repository: ${{ inputs.kernel_repo }}
          ref: ${{ inputs.kernel_ref }}
          path: kernel
          fetch-depth: 1

      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y --no-install-recommends \
            bc bison flex libssl-dev libelf-dev cpio lz4 zstd zip \
            gcc-aarch64-linux-gnu gcc-arm-linux-gnueabi

      - name: Get AOSP clang r416183b
        working-directory: kernel
        run: |
          git clone --depth=1 \
            https://github.com/LineageOS/android_prebuilts_clang_kernel_linux-x86_clang-r416183b.git clang
          clang/bin/clang --version

      - name: Integrate KernelSU (optional)
        if: ${{ inputs.ksu }}
        working-directory: kernel
        run: |
          # sebaiknya pin ke tag/commit, bukan master
          curl -LSs "https://raw.githubusercontent.com/backslashxx/KernelSU/refs/heads/master/kernel/setup.sh" | bash -s master
          printf 'CONFIG_KSU=y\nCONFIG_KSU_HACK_ARM64_BRANCH_LINK=y\n' > ksu.config

      - name: Build
        working-directory: kernel
        run: |
          if [ -f ksu.config ]; then export EXTRA_CFG=ksu.config; fi
          bash ../build.sh 2>&1 | tee ../build.log
          test "${PIPESTATUS[0]}" -eq 0

      - name: Upload kernel image
        uses: actions/upload-artifact@v4
        with:
          name: kernel-merlin
          if-no-files-found: error
          path: |
            kernel/out/arch/arm64/boot/Image*
            kernel/out/arch/arm64/boot/dts/mediatek/*.dtb

      - name: Upload log
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: build-log
          if-no-files-found: ignore
          path: build.log
