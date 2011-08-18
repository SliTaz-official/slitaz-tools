#!/bin/sh
#
# Launcher for installer.cgi
#
# Copyright (C) 2011 SliTaz GNU/Linux - GNU General Public License v3.
#
# Authors : Dominique Corbex <domcox@slitaz.org>
#

HTTPD_PORT=83
PIDFILE=/run/installer.pid

if (ps | grep httpd | grep -q "\-p $HTTPD_PORT"); then
	export ALERT_DIALOG='
	<vbox>
		<pixmap icon_size="4">
			<input file stock="gtk-dialog-warning"></input>
		</pixmap>
		<text>
			<label>SliTaz Installer is already running!</label>
		</text>
		<hbox homogeneous="true">
			<button cancel></button>
		</hbox>
	</vbox>	'
	gtkdialog --program=ALERT_DIALOG
else
	# Start httpd
	httpd -p $HTTPD_PORT -u root -f \
		-r Installer Authentication - Default: root:root & \
		ps | grep "httpd" | grep "\-p $HTTPD_PORT" | \
		awk '{ print $1 }' > $PIDFILE
	# Run Tazweb
	tazweb localhost:83/installer/installer.cgi
	# Stop httpd
	kill $(cat $PIDFILE)
fi

