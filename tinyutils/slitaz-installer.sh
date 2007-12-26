#!/bin/sh
# SliTaz GNU/Linux text mode installer.
#
VERSION=beta

DRIVE_NAME=`cat /proc/sys/dev/cdrom/info | grep "drive name" | cut -f 3`
CDROM=/dev/$DRIVE_NAME
KERNEL=vmlinuz-`uname -r`

# Check if user is root.
check_root()
{
	if test $(id -u) != 0 ; then
	   echo -e "
Vous devez être root pour continuer l'installation du système. Arrêt.
Vous pouvez utiliser 'su' suivi du mot de passe root pour devenir 
administarteur.\n"
	   exit 0
	fi
}

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

# Basic informations.
echo ""
echo -e "\033[1mSliTaz GNU/Linux - Installateur mode texte\033[0m"
echo "================================================================================"
echo "
Bienvenue dans l'installateur en mode texte de SliTaz GNU/Linux. Il vous
suffirat de répondre à quelques questions lors des différentes étapes
d'installation. Avant de commencer, assurer vous de connaître le nom de la
partitions sur laquelle vous désirez installer SliTaz. L'installateur va
commencer par vous proposer de formater la partition cible et la monter.
Ensuite il va monter le cdrom, décompresser les fichiers et les installer
sur la cible. Pour finir, vous aurez aussi la possibilité d'installer le 
gestionnaire de démarrage GRUB, si besoin est. A noter que pour continuer
cette installation, vous devez avoir les droits d'administrateur root, qui
peuvent s'obtenir via la commande 'su' et le mot de passe 'root'."
echo ""
echo "================================================================================"
echo ""

echo -n "Commencer l'installation (oui/Non) ? "; read anser
if [ ! "$anser" = "oui" ]; then
	echo -e "\nArrêt volontaire.\n"
	exit 0
fi

# Exit install if user is not root.
#check_root

# Ask for partitions.
echo "
Veuilliez indiquer la partition à utiliser pour installer SliTaz,
exemple : /dev/hda1."
echo ""
echo -n "Partition à utiliser ? "; read anser
if [ "$anser" == "" ]; then
	echo -e "\nPas de partition spécifiée. Arrêt.\n"
	exit 0
else
	TARGET_DEV=$anser
fi

# Mkfs if needed/wanted.
echo "
SliTaz va être installé sur la partition : $TARGET_DEV"
echo ""
echo -n "Faut t'il formater la partition en ext3 (oui/Non) ? "; read anser
if [ "$anser" == "oui" ]; then
	mkfs.ext3 $TARGET_DEV
else
	echo "Le système de fichiers déjà présent sera utilisé..."
fi

# Mount.
echo "Montage de la partitions et du cdrom..."
mkdir -p /mnt/target /media/cdrom
mount $TARGET_DEV /mnt/target
mount -t iso9660 $CDROM /media/cdrom

# Copy and install.
echo -n "Création du répertoire /boot..."
mkdir -p /mnt/target/boot
status
echo -n "Copie du noyau Linux..."
cp /media/cdrom/boot/bzImage /mnt/target/boot/$KERNEL
status

# Copy and extract lzma'ed or gziped rootfs
echo -n "Copie du système de fichier racine..."
cp /media/cdrom/boot/rootfs.gz /mnt/target
status
echo "Extraction du système de fichiers racine (rootfs.gz)..."
cd /mnt/target
(zcat rootfs.gz 2>/dev/null || lzma d rootfs.gz -so) | cpio -id
echo -n "Suppression des fichiers copiés..."
rm -f rootfs rootfs.cpio rootfs.gz init
status

# Creat the target GRUB configuration.
#
if [ ! -f /mnt/target/boot/grub/menu.lst ]; then
	echo "Creating default GRUB menu.lst..."
	mkdir -p /mnt/target/boot/grub
cat > /mnt/target/boot/grub/menu.lst << EOF
# /boot/grub/menu.lst: GRUB boot loader configuration.
#

# By default, boot the first entry.
default 0

# Boot automatically after 20 secs.
timeout 20

# Change the colors.
color yellow/brown light-green/black

# For booting SliTaz from : $TARGET_DEV
#
title 	SliTaz GNU/Linux (cooking) (Kernel $KERNEL)
		root(hd0,0)
		kernel /boot/$KERNEL root=$TARGET_DEV

EOF
	fi

# End info
echo ""
echo -e "\033[1mInstallation terminée\033[0m
================================================================================

Avant de redémarrer sur votre nouveau système SliTaz GNU/Linux, veuillez vous
assurer qu'un gestionnaire de démarrage est bien installé. Si ce n'est pas le
cas vous pouvez lancer la commande (en modifiant 'hda' en fonction de votre
système) :

    # grub-install --root-directory=/mnt/target /dev/hda

Les lignes suivantes on été ajoutées au fichier de configuration de GRUB
/boot/grub/menu.lst de la cible. Elles feront démarrer SliTaz en modifiant 
la valeure root(hd0,0) en fonction de votre système. Si vous n'installé pas
GRUB, vous pouvez utiliser ces même lignes dans un autre fichier menu.lst,
situé sur une autre partitions :

    title  SliTaz GNU/Linux (cooking) (Kernel $KERNEL)
           root(hd0,0)
           kernel /boot/$KERNEL root=$TARGET_DEV

================================================================================"
echo ""
