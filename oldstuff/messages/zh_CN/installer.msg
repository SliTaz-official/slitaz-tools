# slitaz-installer: English translation.

# start_install
START_INSTALL_MSG="\n
欢迎启动安装界面.\n\n
\Z2开始安装或升级 ?\Zn"

# mount_cdrom
MOUNT_CDROM_ERROR_MSG="\
无法找到文件 : rootfs.gz"

# ask_for_target_dev
ASK_FOR_TARGET_DEV_MSG="\n
请定义目标分区.\n\n
\Z2可使用分区：\Zn"

# ask_for_mkfs_target_dev
ASK_FOR_MKFS_TARGET_DEV_MSG="\n
Slitaz将被安装在这个分区里 : $TARGET_DEV\n\n
 . Ext3 是健壮, \
稳定的日志文件系统. 若分区已经格式化， 你 \
可以跳过这一步, 否则请选是. 警告： 格式化分区将 \
清除分区上的所有数据.\n\n
\Z2确定要格式化成 ext3 吗?\Zn" 

# ask_for_hostname
ASK_FOR_HOSTNAME_MSG="\n
请设定主机名 \
用来在内网里表识本主机，也可以在安装完系统后，再修改。 \n\n
\Z2主机名:\Zn"

# grub_install
GRUB_INSTALL_MSG="\n
GRUB 启动引导工具， \
可以引导启动绝大多数操作系统. 如果你已经安装过了 \
请跳过这一步，添加几行内容至 \
配置文件(menu.lst). 注意Slitaz安装工具 \
会自动生成配置文件样例，放在安装分区上。 \
(/mnt/target/boot/grub/menu.lst).\n\n
\Z2安装Gurb到: $TARGET_DISK ?\Zn" 

# end_of_install
END_OF_INSTALL_MSG="\n
安装已经结束, 请重启进入新安装的 \
SliTaz GNU/Linux 操作系统。" 
