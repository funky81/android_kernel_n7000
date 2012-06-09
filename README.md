android_kernel_n7000
====================

For Galaxy Note - n7000 kernel

How to build this:
1. Download all the required links
- toolchain : linaro-build
2. extract kernel.tar.gz
3. patch from speedmod
4. make required changes to Makefile regarding cross compile toolchain
5. do make arch=arm q1_speedmod_defconfig
6. make
7. make modules
8. copy all modules file to [initramfs path file]
9. make -j5 CONFIG_INITRAMFS_SOURCE=[Path to initramfs file]
10. change to cd arch/arm/boot/
11. tar cvf MyKernel.tar zImage

