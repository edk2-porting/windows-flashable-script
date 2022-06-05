(Installer) Copyright BigfootACA            All Rights Reserved.
(Firmware)  Copyright Renegade Project      All Rights Reserved.
(System)    Copyright Microsoft Corporation All Rights Reserved.

Package contents:

data/BCD:
data/win11.wim.xz:
	Microsoft Windows
	https://microsoft.com/
	Generate by:
	wimlib-imagex capture --compress=none --pipable /dev/sda1 - | pixz -9 > win11.wim.xz

data/uefi/*.img:
	EDK2 firmware for SDM845
	https://github.com/edk2-porting/edk2-sdm845

META-INF/com/google/android/update-binary.c:
META-INF/com/google/android/update-binary:
	Simple update-binary for Android Recovery flash package.
	https://github.com/BigfootACA/update-binary

updater.sh:
	Updater script
	-

bin/bcdboot:
	BCD default boot partition updater by BigfootACA
	https://github.com/BigfootACA/bcdboot
	-

bin/bash:
	The GNU Bourne Again shell
	https://www.gnu.org/software/bash/bash.html

bin/cat:
bin/sleep:
bin/nproc:
bin/cp:
bin/mkdir:
bin/sync:
	The basic file, shell and text manipulation utilities of the GNU operating system
	https://www.gnu.org/software/coreutils/

bin/blkid:
bin/mount:
bin/umount:
	Miscellaneous system utilities for Linux
	https://github.com/karelzak/util-linux

bin/pixz:
	Parallel, indexed xz compressor
	https://github.com/vasi/pixz

bin/pv:
	A terminal-based tool for monitoring the progress of data through a pipeline.
	https://www.ivarch.com/programs/pv.shtml

bin/mkfs.fat:
	DOS filesystem utilities
	https://github.com/dosfstools/dosfstools

bin/ntfs-3g:
bin/ntfsfix:
bin/mkntfs:
	NTFS filesystem driver and utilities
	https://www.tuxera.com/community/open-source-ntfs-3g/

bin/wimlib-imagex
	A library and program to extract, create, and modify WIM files
	https://wimlib.net/
