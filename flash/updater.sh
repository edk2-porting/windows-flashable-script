#!/tmp/install/bin/bash
export DEVICE
export USERDATA
export SYSTEM
export BOOT
export mode
DEVICES=(
        dipper
        enchilada
        fajita
        polaris
        beryllium
        perseus
        nx616j
        m1882
        skr-a0
        judyln
        star2qltechn
        dipper-old
        pafm00
        trident
        olympic
)
function copyright(){ cat<<EOF>&2

--------------------------------------------------------------------------------------
Windows11 for SDM845
小太阳ACA / BigfootACA QQ:859220819, E-Mail:bigfoot@classfun.cn

刷机包内容/Package contents:
  bigfoot update-binary  1.0             LGPLv2
  libzip                 1.6.1           BSD
  bash                   5.0.0           GPL
  util-linux             2.35.281        GPLv2
  coreutils              8.32            GPLv3
  pixz                   1.0.6           BSD
  libarchive             3.4.3           BSD
  xz                     5.3.1alpha      GPL/LGPL
  pv                     1.6.6           Artistic 2.0
  ntfs-3g                2017.3.23       GPLv2
  dosfstools             4.2             GPLv2
  wimlib                 1.13.4          GPLv3/LGPLv3
  edk2-sdm845            0.3             WTFPL
  Windows 11             10.0.22000.1    -

请勿将此软件用于商业用途或进行售卖，转载请与作者联系并标注来源。
任何未经允许的转载将被追究法律责任!
Please do not use the software for commercial purposes or for sale.
Please contact the author and indicate the source for reprint.
Any unauthorized reprint will be prosecuted!

Author/作者:   小太阳ACA / BigfootACA (QQ:859220819, E-Mail:bigfoot@classfun.cn)
OS/操作系统:   Microsoft Windows 11   (https://www.microsoft.com/)
Firmware/固件: Renegade Project       (https://github.com/edk2-porting/)
Firmware/固件: Tianocore EDK2         (https://www.tianocore.org/)

支持机型:
	${DEVICES[@]}

项目地址:
https://github.com/edk2-porting/edk2-sdm845
https://gitee.com/edk2-porting/edk2-sdm845

BuildID: ${BUILDID}
--------------------------------------------------------------------------------------
EOF
}
function warning_clean(){ cat<<EOF>&2
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!WARNING: ALL YOUR USERDATA WILL BE CLEARED!!!!!!
!!!!!!!!!!!!!警告:你的所有数据将会被清空!!!!!!!!!!!!!
!!!!!!!!!If you want to cancel the operation,!!!!!!!!
!!!!!!!!!!!please click cancel or shutdown!!!!!!!!!!!
!!!!!!!!!!!!your device within 10 seconds.!!!!!!!!!!!
!!!!!!!!!!!!!!如果要取消操作请在十秒内!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!点击取消或者关闭设备。!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
EOF
}
function wait_cancel(){
	local i
	i="${1}"
	while [[ "${i}" -gt 0 ]]
	do	echo "Start operation in ${i} second. ${i}秒后开始操作。"
		((i-=5))
		sleep 5
	done
}
function check_power(){
	local LEVEL STATUS BAT L25 L80
	L25=false;L80=false;
	BAT=/sys/class/power_supply/battery
	[ -h "${BAT}" ]||BAT=/sys/class/power_supply/BAT
	[ -h "${BAT}" ]||BAT=/sys/class/power_supply/BAT0
	[ -h "${BAT}" ]||BAT=/sys/class/power_supply/bms
	[ -h "${BAT}" ]||return 0
	LEVEL="$(<${BAT}/capacity)"||LEVEL=0
	STATUS="$(<${BAT}/status)"||STATUS=Unknown
	echo "电池状态/Battery status: ${LEVEL}% ${STATUS}"
	case "${STATUS}" in Full);;Charging)L25=true;;*)L25=true;L80=true;;esac
	if [[ "${LEVEL}" -le 25 ]]&&"${L25}"
	then
		echo "电池电量过低，请充电到25%以上再进行刷机! " >&2
		echo "The battery power is low,please charge to 25% or more before flashing!" >&2
		exit 1
	fi
	if [[ "${LEVEL}" -le 80 ]]&&"${L80}"
	then
		echo "电池低于80%，请插上充电器再进行刷机! " >&2
		echo "Battery power is less than 80%,please plug in charger to flashing!" >&2
		exit 1
	fi
}
function check_device(){
	export DEVICE
	DEVICE="$(/sbin/getprop ro.product.device)"
	echo "Device: ${DEVICE}"
	local FOUND=false
	for i in "${DEVICES[@]}"
	do [ "${DEVICE}" == "${i}" ]&&FOUND=true
	done
	if ! "${FOUND}"
	then	echo "This package only supports SDM845. 此刷机包只支持SDM845:" >&2
		echo "${DEVICES[@]}" >&2
		exit 1
	fi
	if ! [ -f "${PACKAGE}" ];then echo "Package not found! 刷机包未找到!" >&2;exit 1;fi
	local _PKG
	_PKG=/tmp/install.zip
	case "${PACKAGE}" in
		/data/*|/sdcard/*|/system/*)
			echo "请不要将刷机包放置在/data或者/sdcard或者/system进行刷机!"
			echo "Please do not place the package in /data or /sdcard or /system for flashing!" >&2
			exit 1
			PACKAGE="${_PKG}"
		;;
	esac
	export PACKAGE
	unset _PKG FOUND
}
function find_block(){
	BOOT="$(blkid -o device -t PARTLABEL=boot)"
	SYSTEM="$(blkid -o device -t PARTLABEL=system)"
	USERDATA="$(blkid -o device -t PARTLABEL=userdata)"
	if ! [ -b "${BOOT}" ];then BOOT="$(blkid -o device -t PARTLABEL=boot_a)";fi
	if ! [ -b "${BOOT}" ];then BOOT="$(blkid -o device -t PARTLABEL=boot_b)";fi
	if ! [ -b "${BOOT}" ];then BOOT="$(blkid -o device -t PARTLABEL=recovery)";fi
	if ! [ -b "${SYSTEM}" ];then BOOT="$(blkid -o device -t PARTLABEL=system_a)";fi
	if ! [ -b "${SYSTEM}" ];then BOOT="$(blkid -o device -t PARTLABEL=system_b)";fi
	if ! [ -b "${BOOT}" ];then echo "cannot found boot partition! 无法找到(boot)启动分区!" >&2;exit 1;fi
	if ! [ -b "${SYSTEM}" ];then echo "cannot found system partition! 无法找到(system)系统分区!" >&2;exit 1;fi
	if ! [ -b "${USERDATA}" ];then echo "cannot found userdata partition! 无法找到(userdata)数据分区!" >&2;exit 1;fi
	export USERDATA BOOT SYSTEM
}
function is_device_mounted(){
	while read -r name _
	do [ "${1}" == "${name}" ]&&return 0
	done</proc/self/mounts
	return 1
}
function prepare_filesystem(){
	umount -A "${SYSTEM}" &>/dev/null;umount -Al "${SYSTEM}" &>/dev/null
	umount -A "${SYSTEM}" &>/dev/null;umount -Al "${SYSTEM}" &>/dev/null
	umount -A "${USERDATA}" &>/dev/null;umount -Al "${USERDATA}" &>/dev/null
	umount -A "${USERDATA}" &>/dev/null;umount -Al "${USERDATA}" &>/dev/null
	if is_device_mounted "${SYSTEM}";then echo "Failed to umount system partition!无法卸载SYSTEM分区!">&2;exit 1;fi
	if is_device_mounted "${USERDATA}";then echo "Failed to umount userdata partition!无法卸载USERDATA分区!">&2;exit 1;fi
	cat</dev/zero>"${BOOT}" 2>/dev/null
	if ! mkfs.fat -F 32 -n ESP -S 4096 "${SYSTEM}"
	then echo "Failed to format system partition! 无法格式化SYSTEM分区!" >&2;exit 1;fi
	if ! mkntfs --fast --sector-size 4096 --label "Windows11" "${USERDATA}"
	then echo "Failed to format system partition! 无法格式化SYSTEM分区!" >&2;exit 1;fi
}
function flash_system(){
	echo "Flashing UEFI boot image to boot partition... 正在刷入UEFI启动镜像到BOOT分区..."
	if ! "${1}" get_file "data/uefi/${DEVICE}.img" >"${BOOT}"
	then echo "Failed to flash UEFI boot image! 无法刷入UEFI启动镜像!" >&2;exit 1;fi
	echo "Writing Windows11 ARM64... 正在写入Windows11 ARM64..."
	if ! \
		"${1}" get_file data/win11.wim.xz | \
		pixz -d -p "$(nproc)" | \
		pv -fberz -s 8989234319 -i 3 -N "Windows11" | \
		wimlib-imagex apply --quiet - "${USERDATA}"
	then echo "Failed to write userdata partition! 无法写入USERDATA分区!" >&2;exit 1;fi
}
function install_boot(){
	echo "Installing bootloader... 正在安装引导..."
	if ! mount -t vfat -o rw,noatime "${SYSTEM}" /system
	then echo "Failed to mount system partition! 无法挂载SYSTEM分区!" >&2;exit 1;fi
	if ! ntfs-3g -o ro "${USERDATA}" /data
	then echo "Failed to mount userdata partition! 无法挂载USERDATA分区!" >&2;exit 1;fi
	if
		! mkdir -p /system/EFI/{Boot,Microsoft} ||\
		! cp -r /data/Windows/Boot/EFI /system/EFI/Microsoft/Boot ||\
		! cp /system/EFI/Microsoft/Boot/bootmgfw.efi /system/EFI/Boot/bootaa64.efi
	then echo "Failed to copy bootloader! 复制引导失败!" >&2;exit 1;fi
	if
		! "${1}" get_file data/BCD >/system/EFI/Microsoft/Boot/BCD ||\
		! bcdboot /system/EFI/Microsoft/Boot/BCD "${USERDATA}"
	then echo "Failed to update BCD! 更新BCD失败!" >&2;exit 1;fi
	umount -A "${SYSTEM}" &>/dev/null;umount -Al "${SYSTEM}" &>/dev/null
	umount -A "${USERDATA}" &>/dev/null;umount -Al "${USERDATA}" &>/dev/null
}
function complete_setup(){
	echo "Completing setup... 正在完成安装..."
	echo -ne '\xfe' # 'update-binary' flush command.
	sync
}
BUILDID="$(buildid)"
[ "${#BUILDID}" == 32 ]||exit 2
copyright
check_device
check_power
find_block
warning_clean
wait_cancel 10
echo "Starting flash... 开始刷入..."
find_block
check_device
prepare_filesystem
flash_system "${1}"
install_boot "${1}"
complete_setup
echo "Done! 完成!"
copyright
exit 0
