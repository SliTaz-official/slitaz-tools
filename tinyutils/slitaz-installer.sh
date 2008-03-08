#!/bin/sh
# slitaz-installer.sh - SliTaz GNU/Linux installer script.
#
# So this is SliTaz installer all in SHell script compatible Ash from Busybox.
# All the comments are in English but displayed messages are in French. The 
# scrip starts with a few main variables, then all the functions and then
# a sequece of functions.
#
# (C) 2007-2008 SliTaz - GNU General Public License v3.
#
# Author : Christophe Lincoln <pankso@slitaz.org>
#
VERSION=0.1

# We need to know cdrom device and kernel version string
# to copy files.
DRIVE_NAME=`cat /proc/sys/dev/cdrom/info | grep "drive name" | cut -f 3`
CDROM=/dev/$DRIVE_NAME
TARGET_ROOT=/mnt/target
KERNEL=vmlinuz-`uname -r`

#######################
# Installer functions #
#######################

# Status function.
status()
{
	local CHECK=$?
	echo -en "\\033[70G[ "
	if [ $CHECK = 0 ]; then
		echo -en "\\033[1;33mOK"
	else
		echo -en "\\033[1;31mFailed"
	fi
	echo -e "\\033[0;39m ]"
}

# Start install with basic informations.
start_infos()
{
	clear
	echo ""
	echo -e "\033[1mSliTaz GNU/Linux - Installateur mode texte\033[0m
================================================================================

Bienvenue dans l'installateur en mode texte de SliTaz GNU/Linux. Il vous
suffirat de r�pondre � quelques questions lors des diff�rentes �tapes
d'installation. Avant de commencer, assurer vous de conna�tre le nom de la
partitions sur laquelle vous d�sirez installer SliTaz. L'installateur va
commencer par vous proposer de formater la partition cible et la monter.
Ensuite il va monter le cdrom, d�compresser les fichiers et les installer
sur la cible. Pour finir, vous aurez aussi la possibilit� d'installer le 
gestionnaire de d�marrage GRUB, si besoin est. A noter que pour continuer
cette installation, vous devez avoir les droits d'administrateur root, qui
peuvent s'obtenir via la commande 'su' et le mot de passe 'root'.

================================================================================"
	echo ""
	echo -n "Commencer l'installation (oui/Non) ? "; read anser
	if [ ! "$anser" = "oui" ]; then
		echo -e "\nArr�t volontaire.\n"
		exit 0
	fi
}

# Exit install if user is not root.
check_root()
{
	if test $(id -u) != 0 ; then
	   echo -e "
Vous devez �tre root pour continuer l'installation du syst�me. Arr�t.
Vous pouvez utiliser 'su' suivi du mot de passe root pour devenir 
administarteur.\n"
	   exit 0
	fi
}

# Display a list of available partition.
fdisk_list()
{
	echo ""
	fdisk -l | grep ^/dev
	echo ""
}

# We need a partition to install.
ask_for_target_dev()
{
	echo ""
	echo -e "\033[1mPartition racine\033[0m
================================================================================

Veuilliez indiquer la partition � utiliser pour installer SliTaz GNU/Linux,
exemple : '/dev/hda1'. Vous pouvez tapez 'list' pour afficher une liste 
des partitions disponibles sur le ou les disques durs."
	echo ""
	echo -n "Partition � utiliser : "; read anser
	while [ "$anser" == "list" ]; do
		fdisk_list
		echo -n "Partition � utiliser : "; read anser
	done
	if [ "$anser" == "" ]; then
		echo -e "\nPas de partition sp�cifi�e. Arr�t.\n"
		exit 0
	else
		TARGET_DEV=$anser
	fi
}

# Mkfs if needed/wanted.
mkfs_target_dev()
{
	echo ""
	echo "SliTaz va �tre install� sur la partition : $TARGET_DEV"
	echo ""
	echo -n "Faut t'il formater la partition en ext3 (oui/Non) ? "; read anser
	if [ "$anser" == "oui" ]; then
		mkfs.ext3 $TARGET_DEV
	else
		echo "Le syst�me de fichiers d�j� pr�sent sera utilis�..."
	fi
}

# Mount target device and cdrom.
mount_devices()
{
	echo ""
	mkdir -p $TARGET_ROOT /media/cdrom
	echo "Montage de la partitions et du cdrom..."
	# Mount points can be already used.
	if mount | grep $TARGET_ROOT; then
		umount $TARGET_ROOT
	fi
	if mount | grep /media/cdrom; then
		umount /media/cdrom
	fi
	mount $TARGET_DEV $TARGET_ROOT
	mount -t iso9660 $CDROM /media/cdrom || exit 1
}

# Copy and install Kernel.
install_kernel()
{
	echo ""
	echo -n "Cr�ation du r�pertoire /boot..."
	mkdir -p $TARGET_ROOT/boot
	status
	echo -n "Copie du noyau Linux..."
	cp /media/cdrom/boot/bzImage $TARGET_ROOT/boot/$KERNEL
	status
}

# Syslinux/isolinux.
copy_bootloaders()
{
	echo -n "Copie des bootloaders syslinux/isolinux..."
	if [ -d "/media/cdrom/boot/syslinux" ]; then
		cp -a /media/cdrom/boot/syslinux $TARGET_ROOT/boot
	fi
	if [ -d "/media/cdrom/boot/isolinux" ]; then
		cp -a /media/cdrom/boot/isolinux $TARGET_ROOT/boot
	fi
	status
}

# Copy and extract lzma'ed or gziped rootfs.
copy_extract_rootfs()
{
	echo -n "Copie du syst�me de fichier racine..."
	cp /media/cdrom/boot/rootfs.gz $TARGET_ROOT
	status
	echo "Extraction du syst�me de fichiers racine (rootfs.gz)..."
	cd $TARGET_ROOT
	( zcat rootfs.gz 2>/dev/null || lzma d rootfs.gz -so 2>/dev/null || \
	  cat rootfs.gz ) | cpio -id
	# remove link to cdrom
	[ -d cdrom ] && rmdir cdrom
	if [ -L usr ]; then
		rm usr
		cp -a /cdrom/usr .
	fi
	# unpack /usr
	sqfs="/cdrom/usr.sqfs"
	[ -f $sqfs ] || sqfs=".usr.sqfs"
	if [ -f $sqfs ]; then
		echo -en "\nD�compression de /usr... "
		rmdir usr
		sbin/unsquashfs -d usr $sqfs
		[ "$sqfs" = ".usr.sqfs" ] && rm -f $sqfs
	fi
	cromfs="/media/cdrom/usr.cromfs"
	[ -f $cromfs ] || cromfs=".usr.cromfs"
	if [ -f $cromfs ]; then
		rmdir usr
		bin/unmkcromfs $cromfs usr
		[ "$cromfs" = ".usr.cromfs" ] && rm -f $cromfs
	fi
	if [ -d usr/.moved ]; then
		echo -en "\nRestoration des fichiers d�plac�s dans /usr... "
		( cd usr/.moved ; find * -print ) | \
		while read file; do
			[ -L "$file" ] || continue
			rm -f "$file"
			mv "usr/.moved/$file" "$file"
		done
		rm -rf usr/.moved
	fi
	echo ""
	echo -n "Suppression des fichiers copi�s..."
	rm -f rootfs.gz init
	status
}

# Pre configure freshly installed system.
pre_config_system()
{
	# /etc/skel with hacker default personnal files.
	echo -n "Copie des fichiers personnels de hacker dans : /etc/skel..."
	cp -a $TARGET_ROOT/home/hacker $TARGET_ROOT/etc/skel
	status
	# Add root device to CHECK_FS in rcS.conf to check filesystem 
	# on each boot.
	echo -n "Configuration de CHECK_FS dans /etc/rcS.conf..."
	sed -i s#'CHECK_FS=\"\"'#"CHECK_FS=\"$TARGET_DEV\""# $TARGET_ROOT/etc/rcS.conf	
	status
	sleep 2
}

# Determin disk letter, GRUB partition number and GRUB disk number.
grub_install()
{
	DISK_LETTER=${TARGET_DEV#/dev/[h-s]d}
	DISK_LETTER=${DISK_LETTER%[0-9]}
	GRUB_PARTITION=$((${TARGET_DEV#/dev/[h-s]d[a-z]}-1))
	for disk in a b c d e f g h
	do
		nb=$(($nb+1))
		if [ "$disk" = "$DISK_LETTER" ]; then
			GRUB_DISK=$(($nb-1))
			break
		fi
	done
	GRUB_ROOT="(hd${GRUB_DISK},${GRUB_PARTITION})"

	# Creat the target GRUB configuration.
	echo -n "Cr�ation du fichier de configuration de GRUB (menu.lst)..."
	mkdir -p $TARGET_ROOT/boot/grub
	cat > $TARGET_ROOT/boot/grub/menu.lst << _EOF_
# /boot/grub/menu.lst: GRUB boot loader configuration.
#

# By default, boot the first entry.
default 0

# Boot automatically after 8 secs.
timeout 8

# Change the colors.
color yellow/brown light-green/black

# For booting SliTaz from : $TARGET_DEV
#
title 	SliTaz GNU/Linux (cooking) (Kernel $KERNEL)
		root $GRUB_ROOT
		kernel /boot/$KERNEL root=$TARGET_DEV

_EOF_
	status
	# GRUB info with disk name used for grub-install
	TARGET_DISK=`echo $TARGET_DEV | sed s/"[0-9]"/''/`
	echo ""
	echo -e "\033[1mGRUB - Informations et installation\033[0m
================================================================================

Avant de red�marrer sur votre nouveau syst�me SliTaz GNU/Linux, veuillez vous
assurer qu'un gestionnaire de d�marrage est bien install�. Si ce n'est pas le
cas vous pouvez r�pondre oui et installer GRUB ou lancer la commande :

    # grub-install --no-floppy --root-directory=$TARGET_ROOT $TARGET_DISK

Les lignes suivantes on �t� ajout�es au fichier de configuration de GRUB
/boot/grub/menu.lst de la cible. Elles feront d�marrer SliTaz en installant
GRUB. Si vous n'installez pas GRUB, vous pouvez utiliser ces m�me lignes dans
un autre fichier menu.lst, situ� sur une autre partitions :

    title  SliTaz GNU/Linux (cooking) (Kernel $KERNEL)
           root $GRUB_ROOT
           kernel /boot/$KERNEL root=$TARGET_DEV

================================================================================"
	echo ""

	# GRUB install
	echo -n "Installer GRUB sur le disque : $TARGET_DISK (oui/Non) ? "; read anser
	if [ "$anser" = "oui" ]; then
		grub-install --no-floppy --root-directory=$TARGET_ROOT $TARGET_DISK
	else
		echo "GRUB n'a pas �t� install�."
	fi
}

# End of installation
end_of_install()
{
	echo ""
	echo -e "\033[1mFin de l'installation\033[0m
================================================================================

Installation termin�e. Vous pouvez d�s maintenant red�marrer sur votre nouveau
syst�me SliTaz GNU/Linux et commencer � finement le configurer en fonction de
vos besoins et pr�f�rences. Vous trouverez un support technique gratuit via
la liste de discussion et/ou le forum officiel du projet."
	echo ""
}

######################
# Installer sequence #
######################

start_infos
check_root
ask_for_target_dev
mkfs_target_dev
mount_devices
install_kernel
copy_bootloaders
copy_extract_rootfs
pre_config_system
grub_install
end_of_install

exit 0
