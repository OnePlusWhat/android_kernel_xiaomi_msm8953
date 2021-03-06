#!/bin/bash
rm .version
# Bash Color
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
KERNEL="Image"
DTBIMAGE="dtb"

DEFCONFIG="baracuda_defconfig"


## Always ARM64
ARCH=arm64

## Always use all threads
THREADS=$(nproc --all)
export CLANG_PATH=~/Android/kernel/tc/clang/clang-8.x/bin
export PATH=${CLANG_PATH}:${PATH}
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=${HOME}/Android/kernel/tc/gcc/aosp/aarch64-linux-android-4.9/bin/aarch64-linux-android-
export CROSS_COMPILE_ARM32=${HOME}/Android/kernel/tc/gcc/aosp/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-

# Kernel Details
VER=".R3.02"

# Paths
KERNEL_DIR=`pwd`
REPACK_DIR=~/Android/kernel/AnyKernel2/
PATCH_DIR=~/Android/kernel/AnyKernel2/patch
MODULES_DIR=~/Android/kernel/AnyKernel2/modules
ZIP_MOVE=~/Android/kernel/AK-releases/
ZIMAGE_DIR=~/Android/kernel/EAS/arch/arm64/boot

# Functions
function clean_all {
		cd $REPACK_DIR
		rm -r *
		git reset --hard && git clean -f -d
		cd $KERNEL_DIR
		make clean && make mrproper
}

function make_kernel {
		echo
		make $DEFCONFIG
		make ARCH=${ARCH} CC=clang -j${THREADS}

}

function make_zip {
		cd $REPACK_DIR
		mkdir kernel
		mkdir treble-supported
		mkdir treble-unsupported
		cp $KERNEL_DIR/arch/arm64/boot/dts/qcom/msm8953-qrd-sku3-mido-nontreble.dtb $REPACK_DIR/treble-unsupported/
		cp $KERNEL_DIR/arch/arm64/boot/dts/qcom/msm8953-qrd-sku3-mido-treble.dtb $REPACK_DIR/treble-supported/
		cp $KERNEL_DIR/arch/arm64/boot/Image.gz $REPACK_DIR/kernel/
		zip -r9 `echo $ZIP_NAME`.zip *
		cd $KERNEL_DIR
}


DATE_START=$(date +"%s")


echo -e "${green}"
echo "-----------------"
echo "Making REVOLT Kernel:"
echo "-----------------"
echo -e "${restore}"


# Vars
BASE_AK_VER="SYBERIA"
DATE=`date +"%Y%m%d-%H%M"`
AK_VER="$BASE_AK_VER$VER"
ZIP_NAME="$AK_VER"-"$DATE"
export LOCALVERSION=~`echo $AK_VER`
export LOCALVERSION=~`echo $AK_VER`
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER=NATO66613
export KBUILD_BUILD_HOST=PENTAGON

echo

while read -p "Do you want to clean stuffs (y/n)? " cchoice
do
case "$cchoice" in
	y|Y )
		clean_all
		echo
		echo "All Cleaned now."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo

while read -p "Do you want to build?" dchoice
do
case "$dchoice" in
	y|Y )
		make_kernel
		make_zip
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done


echo -e "${green}"
echo "-------------------"
echo "Build Completed in:"
echo "-------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo
