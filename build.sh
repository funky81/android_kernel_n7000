#!/bin/sh
#Copy the initramfs
mkdir -p kernel/usr/initramfs
rm -rf kernel/usr/initramfs/*
echo "Step 1"
cp -R ../initramfs/initramfs-n7000/* kernel/usr/initramfs
chmod -R g-w kernel/usr/initramfs/*
echo "Step 2"
rm $(find kernel/usr/initramfs -name EMPTY_DIRECTORY -print)
echo "Step 3"
rm -rf $(find kernel/usr/initramfs -name .git -print)
export CONFIG_INITRAMFS_SOURCE=kernel/usr/initramfs/out
#Enable FIPS mode
export USE_SEC_FIPS_MODE=true
make goku_defconfig
make -j4
echo "Copying Modules"
cp -a $(find . -name *.ko -print |grep -v initramfs) kernel/usr/initramfs/out/lib/modules/
echo "Modules Copied"
sleep 5
touch kernel/usr/initramfs
echo "Rebuilding kernel with new initramfs"
make -j4
# adb shell reboot download
# sleep 5
# heimdall flash --kernel arch/arm/boot/zImage
echo "Make Odin File"
tar -H ustar -c arch/arm/boot/zImage > kernel-zImage.tar
md5sum -t kernel-zImage.tar >> kernel-zImage.tar
#mv kernel-zImage.tar /media/sf_Kernel-N7000/Goku-v1.2.tar
