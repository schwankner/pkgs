#!/bin/bash
# Patch OOT module Makefiles: remove -Werror and add required include paths.
# srctree.nvconftest and srctree.nvidia-oot are passed as make vars at build time.
set -euo pipefail

NVIDIA_OOT=/oot-src/nvidia-oot

# OOT host1x: add conftest + nvidia-oot includes (exports host1x_fence_extract)
printf 'ccflags-y += -I$(srctree.nvconftest)\n' \
  >> ${NVIDIA_OOT}/drivers/gpu/host1x/Makefile
printf 'ccflags-y += -I$(srctree.nvidia-oot)/include\n' \
  >> ${NVIDIA_OOT}/drivers/gpu/host1x/Makefile
printf 'ccflags-y += -I$(srctree.nvidia-oot)/drivers/gpu/host1x/include\n' \
  >> ${NVIDIA_OOT}/drivers/gpu/host1x/Makefile
# Force-include version.h so LINUX_VERSION_CODE / KERNEL_VERSION() are available.
# /src/include/generated/uapi/linux/version.h exists in the siderolabs build container;
# standard /src/include/linux/version.h does not (only generated during full kernel build).
printf 'ccflags-y += -include $(srctree)/include/generated/uapi/linux/version.h\n' \
  >> ${NVIDIA_OOT}/drivers/gpu/host1x/Makefile

# host1x-fence: remove -Werror, add conftest + nvidia-oot includes
sed -i 's|ccflags-y += -Werror||g' \
  ${NVIDIA_OOT}/drivers/gpu/host1x-fence/Makefile
printf 'ccflags-y += -I$(srctree.nvconftest)\n' \
  >> ${NVIDIA_OOT}/drivers/gpu/host1x-fence/Makefile
printf 'ccflags-y += -I$(srctree.nvidia-oot)/include\n' \
  >> ${NVIDIA_OOT}/drivers/gpu/host1x-fence/Makefile
printf 'ccflags-y += -I$(srctree.nvidia-oot)/drivers/gpu/host1x/include\n' \
  >> ${NVIDIA_OOT}/drivers/gpu/host1x-fence/Makefile
grep -rl "class_create(THIS_MODULE," ${NVIDIA_OOT}/drivers/gpu/host1x-fence/ \
  | xargs -r sed -i 's/class_create(THIS_MODULE, /class_create(/g'
grep -rl "host1x_fence_devnode" ${NVIDIA_OOT}/drivers/gpu/host1x-fence/ \
  | xargs -r sed -i 's/static char \*host1x_fence_devnode(struct device \*/static char *host1x_fence_devnode(const struct device */g'
echo "Patched host1x-fence: class_create + devnode const fixes for kernel 6.x"

# nvmap: remove subdir -Werror, add conftest + nvidia-oot includes
sed -i 's|subdir-ccflags-y += -Werror||g' \
  ${NVIDIA_OOT}/drivers/video/tegra/nvmap/Makefile
printf 'ccflags-y += -I$(srctree.nvconftest)\n' \
  >> ${NVIDIA_OOT}/drivers/video/tegra/nvmap/Makefile
printf 'ccflags-y += -I$(srctree.nvidia-oot)/include\n' \
  >> ${NVIDIA_OOT}/drivers/video/tegra/nvmap/Makefile
printf 'ccflags-y += -I$(srctree.nvidia-oot)/drivers/video/tegra/nvmap/include\n' \
  >> ${NVIDIA_OOT}/drivers/video/tegra/nvmap/Makefile
# Force-include version.h for LINUX_VERSION_CODE guards in nvmap source patches below.
printf 'ccflags-y += -include $(srctree)/include/generated/uapi/linux/version.h\n' \
  >> ${NVIDIA_OOT}/drivers/video/tegra/nvmap/Makefile

# mc-utils: add nvidia-oot includes
printf 'ccflags-y += -I$(srctree.nvidia-oot)/include\n' \
  >> ${NVIDIA_OOT}/drivers/platform/tegra/mc-utils/Makefile

# governor_pod_scaling: add conftest + nvidia-oot includes
printf 'ccflags-y += -I$(srctree.nvconftest)\n' \
  >> ${NVIDIA_OOT}/drivers/devfreq/Makefile
printf 'ccflags-y += -I$(srctree.nvidia-oot)/include\n' \
  >> ${NVIDIA_OOT}/drivers/devfreq/Makefile

echo "Include paths patched into OOT module Makefiles."
