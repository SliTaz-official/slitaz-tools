#!/bin/sh
#
# Main CGI interface for Tazinst, the SliTaz installer.
#
# Copyright (C) 2011 SliTaz GNU/Linux - BSD License
#
# Authors : Dominique Corbex <domcox@slitaz.org>
#

VERSION="0.10"

# Get parameters with GET, POST and FILE functions
. /usr/bin/httpd_helper.sh
header

# Include gettext helper script.
. /usr/bin/gettext.sh

# Export package name for gettext.
TEXTDOMAIN='installer'
export TEXTDOMAIN

TITLE="SliTaz Installer"

# Tazinst required version
TAZINST_REQUIRED_VERSION="3.3"

# Tazinst setup file
INSTFILE=/var/lib/tazinst.conf

get_config()
{
	[ -r /etc/slitaz/installer.conf ] && . /etc/slitaz/installer.conf
}

read_setup()
{
	[ -e "$INSTFILE" ] && . $INSTFILE  || gettext "Tazinst setup file not found!"
}

write_setup()
{
	if [ -e "$INSTFILE" ]; then
		# Read vars from URL
		read_query_string GET
		# Install type
		INST_TYPE=$GET_INST_TYPE
		# Source File
		case "$INST_TYPE" in
			usb)
				SRC_FILE=$GET_SRC_USB ;;
			iso)
				SRC_FILE=$GET_SRC_ISO ;;
			web)
				SRC_FILE=$GET_SRC_WEB ;;
		esac
		SRC_FILE=$(echo "$SRC_FILE" | sed 's/\//\\\//'g)
		[ -n $GET_URL ] && SRC_WEB=$GET_URL
		# Main Partition
		TGT_PARTITION=$(echo "$GET_TGT_PARTITION" | sed 's/\//\\\//'g)
		[ -n "$GET_MAIN_FMT" ] && TGT_FS=$GET_MAIN_FS || TGT_FS=""
		# Home Partition
		if [ -n "$GET_HOME_SPLIT" ] ; then
			TGT_HOME=$(echo "$GET_HOME_PART" | sed 's/\//\\\//'g)
			[ -n "$GET_HOME_FMT" ] && TGT_HOME_FS=$GET_HOME_FS
		else
			TGT_HOME=""
			TGT_HOME_FS=""
		fi
		# Hostname
		TGT_HOSTNAME=$GET_TGT_HOSTNAME
		# Root pwd
		TGT_ROOT_PWD=$GET_TGT_ROOT_PWD
		# User Login
		TGT_USER=$GET_TGT_USER
		# User Pwd
		TGT_USER_PWD=$GET_TGT_USER_PWD
		# Grub
		TGT_GRUB=$GET_TGT_GRUB
		[ "$TGT_GRUB" == "yes" ] || TGT_GRUB=no
		# Win Dual-Boot
		TGT_WINBOOT=$GET_TGT_WINBOOT

		# Save changes to INSTFILE
		sed -i s/"^INST_TYPE=.*"/"INST_TYPE=\"$INST_TYPE\"/" $INSTFILE
		sed -i s/"^SRC_FILE=.*"/"SRC_FILE=\"$SRC_FILE\"/" $INSTFILE
		sed -i s/"^TGT_PARTITION=.*"/"TGT_PARTITION=\"$TGT_PARTITION\"/" $INSTFILE
		sed -i s/"^TGT_FS=.*"/"TGT_FS=\"$TGT_FS\"/" $INSTFILE
		sed -i s/"^TGT_HOME=.*"/"TGT_HOME=\"$TGT_HOME\"/" $INSTFILE
		sed -i s/"^TGT_HOME_FS=.*"/"TGT_HOME_FS=\"$TGT_HOME_FS\"/" $INSTFILE
		sed -i s/"^TGT_HOSTNAME=.*"/"TGT_HOSTNAME=\"$TGT_HOSTNAME\"/" $INSTFILE
		sed -i s/"^TGT_ROOT_PWD=.*"/"TGT_ROOT_PWD=\"$TGT_ROOT_PWD\"/" $INSTFILE
		sed -i s/"^TGT_USER=.*"/"TGT_USER=\"$TGT_USER\"/" $INSTFILE
		sed -i s/"^TGT_USER_PWD=.*"/"TGT_USER_PWD=\"$TGT_USER_PWD\"/" $INSTFILE
		sed -i s/"^TGT_GRUB=.*"/"TGT_GRUB=\"$TGT_GRUB\"/" $INSTFILE
		sed -i s/"^TGT_WINBOOT=.*"/"TGT_WINBOOT=\"$TGT_WINBOOT\"/" $INSTFILE
	fi
}

check_setup()
{
	local ret
	IFS=$'\n'
	for line in $(tazinst check $INSTFILE; ret=$?)  
	do
		line=$(echo $line | sed 's/\[1m//g')
		line=$(echo $line | sed 's/\[0m//g')
		line=$(echo $line | sed 's/\s/\&nbsp;/g')
		line=$(echo $line | sed 's/</\&lt;/g')
		line=$(echo $line | sed 's/>/\&gt;/g')
		echo "<font color=\"red\">$line<br /></font>"
	done  
	unset IFS
	return $ret
}

select_action()
{
	cat <<EOT
<div id="wrapper">
	<h2>$(gettext "SliTaz Installer")</h2>
	<p>$(gettext "The SliTaz Installer installs or upgrade SliTaz to a hard disk 
		drive from a	device like a Live-CD or LiveUSB key, from a SliTaz ISO file, or 
		from the web by downloading an ISO file.")<p>
</div>
EOT
}

select_gparted()
{
	cat <<EOT
<table>
<tr>
	<td>$(gettext "Before installation, you'll may need to resize partitions
on your hard disk drive in order to make space for SlItaz GNU/Linux.")</td>
</tr>
<tr>
	<td><a class="button" href="$SCRIPT_NAME?page=gparted">$(gettext "Launch GParted")</a></td>
</tr>
</table>
EOT
}

select_install()
{
	cat <<EOT
</table>
<form method="get" action="$SCRIPT_NAME">
<table>
<tr>
	<td><h4>$(gettext "Install")</h4></td>
</tr>
<tr>
	<td>$(gettext "Install SliTaz on a partition of your hard disk drive. If
	you decide to format your HDD, all data will be lost. If you do not 
	format, all data except for any existing /home directory will be removed, 
	the home directory will be kept as is.")</td>
</tr>
<tr>
	<td><a class="button" href="$SCRIPT_NAME?page=install">$(gettext "Install SliTaz")</a></td>
</tr>
</table>
EOT
}

select_upgrade()
{
	cat <<EOT
<table>
<tr>
	<td><h4>$(gettext "Upgrade")</h4></td>
</tr>
<tr>
	<td>$(gettext "Upgrade an already installed SliTaz system on your hard disk
	drive. Your /home /etc /var/www directories will be kept, all other directories
	will be removed. Any additional package added to your old Slitaz system
	will be updated as long you have an active internet connection.")</td>
</tr>
<tr>
	<td><a class="button" href="$SCRIPT_NAME?page=upgrade">$(gettext "Upgrade SliTaz")</a></td>
</tr>
</table>
</form>
EOT
}

display_action()
{
	case $1 in
		install)
			cat << EOT
<div id="wrapper">
<h3>$(gettext "Install SliTaz")</h3>
<p>$(gettext "You're going to install SliTaz on a partition of your hard disk drive. If
	you decide to format your HDD, all data will be lost. If you do not 
	format, all data except for any existing /home directory will be removed, 
	the home directory will be kept as is.")<p>
</div>
<input type="hidden" name="INST_ACTION" value="$1">
EOT
			;;
		upgrade)
			cat << EOT
<div id="wrapper">
<h2>$(gettext "Upgrade SliTaz")</h2>
<p>$(gettext "You're going to upgrade an already installed SliTaz system on your hard disk
	drive. Your /home /etc /var/www directories will be kept, all other directories
	will be removed. Any additional package added to your old Slitaz system
	will be updated as long you have an active internet connection.")<p>
</div>
<input type="hidden" name="INST_ACTION" value="$1">
EOT
			;;
	esac
}

select_source()
{
	cat <<EOT
<a name="source"></a>
<h4>$(gettext "Source")</h4>
	<table>
	<tr>
	<td><input type="radio" name="INST_TYPE" value="cdrom" $([ "$INST_TYPE" == "cdrom" ] && echo "checked") id="cdrom" />
	<label for="cdrom">$(gettext "LiveCD")</td></label>
	</tr>
	<tr>
	<td><input type="radio" name="INST_TYPE" value="usb" $([ "$INST_TYPE" == "usb" ] && echo "checked") id="usb" />
	<label for="usb">$(gettext "LiveUSB"):</label>
	<select name="SRC_USB">
EOT
	# List disks if plugged USB device
	usb=0
	if [ -d /proc/scsi/usb-storage ]; then
		for DEV in /sys/block/sd* ; do
			if readlink $DEV | grep -q usb; then
				DEV=$(basename $DEV)
				if [ -d /sys/block/${DEV}/${DEV}1 ]; then
					for i in $(fdisk -l /dev/$DEV | awk '/^\/dev/ {printf "%s ", $1}') ; do
						echo "<option value='$i' $([ "$i" == "$SRC_FILE" ] && echo "selected") >$i</option>"
						usb=$usb+1
					done
				fi
			fi
		done
	fi
	if [ $usb -lt 1 ]; then
		echo "<option value="">$(gettext "Not found")</option>"
	fi
	cat << EOT
	</select>
	</td>
	</tr>
	<tr>
	<td><input type="radio" name="INST_TYPE" value="iso" $([ "$INST_TYPE" == "iso" ] && echo "checked") id="iso" />
	<label for="iso">$(gettext "ISO file"):</label>
	<input type="url" size="50" name="SRC_ISO" $([ "$INST_TYPE" == "iso" ] && echo -e "value=\"$SRC_FILE\"") placeholder="$(gettext "Full path to the ISO image file")" />
	</td>
	</tr>
	<tr>
	<td><input type="radio" name="INST_TYPE" value="web" $([ "$INST_TYPE" == "web" ] && echo "checked" id="web") />
	<label for="web">$(gettext "Web"):
	<a class="button" href="$SCRIPT_NAME?page=$GET_page&SRC_WEB=stable">$(gettext "Stable")</a>
	<a class="button" href="$SCRIPT_NAME?page=$GET_page&SRC_WEB=cooking">$(gettext "Cooking")</a>
	$(gettext "URL:")</label>
EOT
	case $GET_SRC_WEB in
		stable|cooking)
			GET_SRC_WEB=$(tazinst showurl $GET_SRC_WEB) ;;
		*)
			[ "$INST_TYPE" == "web" ] && GET_SRC_WEB=$SRC_FILE ;;
	esac
cat <<EOT
	<input type="url" size="55" name="SRC_WEB" value="$GET_SRC_WEB" placeholder="$(gettext "Full url to an ISO image file")" /></td>
	</tr>
	</table>
EOT
}

select_partition()
{
cat <<EOT
<a name="partition"></a>
<h4></span>$(gettext "Main Partition")</h4>
<table>
<tr><td>
	$(gettext "Partition to use:")
	<select name="TGT_PARTITION">
EOT
	# List partitions
	if fdisk -l | grep -q ^/dev/ ; then
		for i in `blkid | cut -d ":" -f 1`; do
			echo "<option value='$i' $([ "$i" == "$TGT_PARTITION" ] && echo "selected")>$i</option>"
		done
	else
		echo "<option value="">$(gettext "Not found")</option>"
	fi
	cat << EOT
	</select>
	<br />
	<input type="checkbox" name="MAIN_FMT" value="yes" $([ -n "$TGT_FS" ] && echo "checked") id="mainfs" />
	<label for="mainfs">$(gettext "Format partition as"):</label>
	<select name="MAIN_FS">
EOT
	scan_mkfs
	for i in $FS
	do
		echo  "<option value='$i' $([ "$i" == "$TGT_FS" ] && echo "selected")>$i</option>"
	done
	cat <<EOT
</select>
</td></tr>
</table>
EOT
}

select_old_slitaz()
{
cat <<EOT
<a name="partition"></a>
<h4></span>$(gettext "Existing SliTaz Partition")</h4>
<table>
<tr><td>
	$(gettext "Partition in use:")
	<select name="TGT_PARTITION">
EOT
	# List partitions
	if fdisk -l | grep -q ^/dev/ ; then
		for i in `blkid | cut -d ":" -f 1`; do
			echo "<option value='$i' $([ "$i" == "$TGT_PARTITION" ] && echo "selected")>$i</option>"
		done
	else
		echo "<option value="">$(gettext "Not found")</option>"
	fi
	cat <<EOT
</select>
</td></tr>
</table>
EOT
}

select_home()
{
	cat <<EOT
<a name="home"></a>
<h4>$(gettext "Home partition")</h4>
<input type="checkbox" name="HOME_SPLIT" value="yes" $([ -n "$TGT_HOME" ] && echo "checked") id="homepart" />
	<label for="homepart">$(gettext "Use a separate partition for /home:")</label>
	<select name="HOME_PART">
EOT
	# List disk if plugged USB device
	if fdisk -l | grep -q ^/dev/ ; then
		for i in `blkid | cut -d ":" -f 1`; do
			echo "<option value='$i' $([ "$i" == "$TGT_HOME" ] && echo "selected")>$i</option>"
		done
	else
		echo "<option value="">$(gettext "Not found")</option>"
	fi
cat <<EOT
	</select>
	
	<input type="checkbox" name="HOME_FMT" value="yes" $([ -n "$TGT_HOME_FS" ] && echo "checked") id="homefs" />
	<label for="homefs">$(gettext "Format partition as:")</label>
	<select name="HOME_FS">"
EOT
	for i in $FS
	do
		echo  "<option value='$i' $([ "$i" == "$TGT_HOME_FS" ] && echo "selected")>$i</option>"
	done
	echo "</select>"
}

select_hostname()
{
cat << EOT
<a name="hostname"></a>
<h4>$(gettext "Host")</h4>
$(gettext "Hostname:")
<input type="text" name="TGT_HOSTNAME" value="$TGT_HOSTNAME" placeholder="$(gettext "Name of your system")" />
EOT
}

select_root()
{
cat << EOT
<a name="root"></a>
<h4>$(gettext "Root")</h4>
$(gettext "Root passwd:")
<input type="text" name="TGT_ROOT_PWD" value="$TGT_ROOT_PWD" placeholder="$(gettext "Password of root")" />
EOT
}

select_user()
{
cat << EOT
<a name="user"></a>
<h4>$(gettext "User")</h4>
$(gettext "User login:")
<input type="text" name="TGT_USER" value="$TGT_USER" placeholder="$(gettext "Name of the first user")" />
$(gettext "User passwd:")
<input type="text" name="TGT_USER_PWD" value="$TGT_USER_PWD" placeholder="$(gettext "Password of the first user")" />
EOT
}

select_grub()
{
cat << EOT
<a name="grub"></a>
<h4>$(gettext "Grub")</h4>
<input type="checkbox" name="TGT_GRUB" value="yes" $([ "$TGT_GRUB" == "yes" ] && echo "checked") id="grub" />
<label for="grub">$(gettext "Install Grub bootloader")<br /></label>
<input type="checkbox" name="TGT_WINBOOT" value="auto" $([ -n "$TGT_WINBOOT" ] && echo "checked") id="dualboot" />
<label for="dualboot">$(gettext "Enable Windows Dual-Boot")</label>
EOT
}

moveto_page()
{
	case $1 in
		*)
			page=home
			title1=$(gettext "Back to Home") ;;
	esac
	case $2 in
		write|run)
			title2=$(gettext "Proceed to SliTaz installation") ;;
		reboot)
			title2=$(gettext "Installation complete. You can now restart (reboot)") ;;
		failed)
			title2=$(gettext "Installation failed. See log") ;;
		*)
			page=home
			title2=$(gettext "Back to Home") ;;
	esac
	cat <<EOT
<script type="text/javascript">
	function SubmitForm() {
		var r=confirm("$(gettext "Do you really want to continue?")");
		if (r==true)
		{
			document.ConfigForm.submit();
		}
	}
</script>
<hr />
<input type="hidden" name="page" value="$2" />
<a class="button" value="$1"  href="$SCRIPT_NAME?page=$1" >$title1</a>
<a class="button" value="$2" onclick="SubmitForm()">$title2</a>
EOT
}

page_redirection()
{
	cat <<EOT
<html>
<head>
<title>$(gettext "A web page that points a browser to a different page after 2 seconds")</title>
<meta http-equiv="refresh" content="0; URL=$SCRIPT_NAME?page=$1">
<meta name="keywords" content="automatic redirection">
</head>
<body>
$(gettext "If your browser doesn't automatically go there within a few seconds, 
you may want to go manually to ")
<a href="$SCRIPT_NAME?page=$1">$1</a> 
</body>
</html>
EOT
}

check_ressources()
{
	local code 
	code=0
	# Check tazinst
	if ! tazinst usage | grep -q Usage: ; then
		cat <<EOT
<h3>$(gettext "Tazinst Error")</h3>
<p><strong>tazinst</strong>, $(gettext "the lightweight SliTaz HDD installer
is missing. Any installation can't be done without tazinst.")</p>
<p>$(gettext "Check tazinst' permissions, or reinstall the slitaz-tools package:")</p>
<code># tazpkg get-install slitaz-tools --forced</code>
EOT
		code=1
	else
		# Check tazinst required version
		v=$(tazinst version | tr -d '[:alpha:]')
		r=$TAZINST_REQUIRED_VERSION
		if ! (echo "$v" | awk -v r=$r '{v=$v+0}{ if (v < r) exit 1}') ; then
			cat <<EOT
<h3>$(gettext "Tazinst Error")</h3>
<p><strong>tazinst</strong> ($v) $(gettext "is not at the required version ($r),
use tazinst in a xterm or reinstall the slitaz-tools package:")</p>
<code># tazpkg get-install slitaz-tools --forced</code>
EOT
			code=1
		fi
		# Check setup file
		if [ !  -e "$INSTFILE" ]; then
			gettext "Creating setup file $INSTFILE."
			tazinst new $INSTFILE
		fi
		if [ ! -e "$INSTFILE" ]; then
			cat <<EOT
<h3>$(gettext "Setup File Error")</h3>
<p>$(gettext "The setup file <strong>$INSTFILE</strong> doesn't exists.")</p>
EOT
			code=1
		else
			if [ ! -r $INSTFILE ]; then
				cat <<EOT
<h3>$(gettext "Setup File Error")</h3>
<p>$(gettext "The setup file <strong>$INSTFILE</strong> is not readable. 
Check permissions and ownership.")</p>
EOT
				code=1
			fi
		fi
	fi
	return $code
}

run_tazinst()
{
	echo "<h4>$(gettext "Proceeding:")</h4>"
	table_start
	tazinst $GET_INST_ACTION $INSTFILE | \
		awk '{print "<tr><td><tt>" $0 "</tt></td></tr>"}'
	table_end
	return $(grep -c "cancelled on error" $INSTFILE)
}

tazinst_log()
{
	echo "<pre>"
	tazinst log
	echo "</pre>"
}

scan_mkfs()
{
	for path in /bin /sbin /usr/bin /usr/sbin
	do
		[ -e $path/mkfs.btrfs ] && FS=btrfs
		[ -e $path/mkfs.cramfs ] && FS="$FS cramfs"
		[ -e $path/mkfs.ext2 ] && FS="$FS ext2"
		[ -e $path/mkfs.ext3 ] && FS="$FS ext3"
		[ -e $path/mkfs.ext4 ] && FS="$FS ext4"
		[ -e $path/mkfs.vfat ] && FS="$FS fat32"
		[ -e $path/mkfs.jfs ] && FS="$FS jfs"
		[ -e $path/mkfs.minix ] && FS="$FS minix"
		[ -e $path/mkfs.ntfs ] && FS="$FS ntfs"
		[ -e $path/mkfs.reiserfs ] && FS="$FS reiserfs"
		[ -e $path/mkfs.xfs ] && FS="$FS xfs"
	done
}

xhtml_header() 
{
	cat <<EOT
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<title>$TITLE</title>
	<meta charset="utf-8" />
	<link rel="shortcut icon" href="/styles/default/favicon.ico" />
	<link rel="stylesheet" type="text/css" href="style.css" />
	<!-- Function to hide the loading message when page is generated. -->
	<script type="text/javascript">
		function showLoading(){
			document.getElementById("loading").style.display='none';
		}
	</script>
</head>
<body onload="showLoading()"> 

<!-- Page content -->
<div id="content">
EOT
}

xhtml_footer()
{
cat <<EOT

<!-- End of content-->
</div>

<div id="footer">
	Copyright &copy; 2011
	<a href="http://www.slitaz.org/">SliTaz GNU/Linux</a>
	- <a href="/index.cgi?file=/usr/share/licenses/bsd.txt">BSD License</a>
</div>

</body>
</html>
EOT
}

table_start() {
	cat << EOT
<table>
	<tbody>
EOT
}

table_end () {
	cat << EOT
	</tbody>
</table>
EOT
	
}

form_start()
{
	cat <<EOT
<form name="ConfigForm" method="get" action="$SCRIPT_NAME">
EOT
}

form_end()
{
	echo "</form>"
}

#
# Main
#
get_config

read_query_string GET

#
# Pages
#

case "$GET_page" in
	gparted)
		gparted
 		xhtml_header
		page_redirection home
		;;
	install)
		read_setup
		xhtml_header
		form_start
		display_action install
		check_setup
		select_source
		select_partition
		select_home
		select_hostname
		select_root
		select_user
		select_grub
		moveto_page home write
		form_end
		;;
	upgrade)
		read_setup
		xhtml_header
		form_start
		display_action upgrade
		check_setup
		select_source
		select_old_slitaz
		select_grub
		moveto_page home write
		form_end
		;;
	write)
		write_setup
		xhtml_header
		if ! (tazinst check $INSTFILE); then
			page_redirection $GET_INST_ACTION
		else
			read_setup
			form_start
			display_action $GET_INST_ACTION
			if run_tazinst; then
				moveto_page home reboot
			else
				moveto_page home failed
			fi
			form_end
		fi
		;;
	reboot)
		reboot ;;
	home)
		xhtml_header
		select_action
		select_gparted
		select_install
		select_upgrade
		;;
	failed)
		xhtml_header
		display_log
		;;
	*)
		xhtml_header
		if check_ressources; then
			page_redirection home
		fi
		;;
esac

xhtml_footer

exit 0