# slitaz-installer: English translation.

# start_install
START_INSTALL_MSG="\n
Welcome to the slitaz-installer.\n\n
\Z2Start a new installation or upgrade ?\Zn"

# mount_cdrom
MOUNT_CDROM_ERROR_MSG="\
Unable to find : rootfs.gz"

# ask_for_target_dev
ASK_FOR_TARGET_DEV_MSG="\n
Please specify the target partition.\n\n
\Z2Partition to use:\Zn"

# ask_for_mkfs_target_dev
ASK_FOR_MKFS_TARGET_DEV_MSG="\n
SliTaz will be installed on the partition : $TARGET_DEV\n\n
The next step lets you format the target partition into ext3. Ext3 is a robust, \
stable and journaled filesystem. If the partition is already formated you \
can skip this stage, if not just accept. Warning formating a partition will \
destroy all current data.\n\n
\Z2Do you wish to format the partition in ext3 ?\Zn" 

# ask_for_hostname
ASK_FOR_HOSTNAME_MSG="\n
Hostname configuration allows you to specify the machine name. The hostname is used \
internally to identify the host on the network. This value can be changed after \
the system is installed.\n\n
\Z2Hostname:\Zn"

# grub_install
GRUB_INSTALL_MSG="\n
You now have the option to install the GRUB bootloader which is capable of \
booting any kind of operating system. If you want to use an existing \
GRUB installation, skip this step and add the correct lines to your GRUB \
configuration file (menu.lst). Note that the SliTaz Installer creates a \
configuration file on the target which can be used as an example \
(/mnt/target/boot/grub/menu.lst).\n\n
\Z2Install GRUB on: $TARGET_DISK ?\Zn" 

# end_of_install
END_OF_INSTALL_MSG="\n
Installation is finished, you can now exit the installer or reboot on your new \
SliTaz GNU/Linux operating system." 
