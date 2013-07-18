#!/bin/sh
#
# SliTaz IPtables firewall rules
#
. /etc/slitaz/firewall.conf

# Drop all input connections
iptables -P INPUT DROP

# Drop all output connections
iptables -P OUTPUT DROP

# Drop all forward connections
iptables -P FORWARD DROP

# Accept input on localhost (127.0.0.1)
iptables -A INPUT -i lo -j ACCEPT

# Accept input on the local network
iptables -A INPUT -s $LOCAL_NETWORK -j ACCEPT

# Accept (nearly) all output trafic
iptables -A OUTPUT -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT

# Accept input trafic only for connections initialized by user
iptables -A INPUT -m conntrack  --ctstate RELATED,ESTABLISHED -j ACCEPT

# If you manage a HTTP/SSH/FTP/IRC server you can accept input for
# non-established connections on some ports. Else you can disable the
# lines below for a more secure setup
for iface in $INTERFACES
do
	# Accept input on port 80 for the HTTP server
	iptables -A INPUT -i $iface -p tcp --source-port 80 -j ACCEPT

	# Accept input on port 22 for SSH
	iptables -A INPUT -i $iface -p tcp --destination-port 22 -j ACCEPT

	# Accept port 21 and 1024 to 60310 for FTP
	iptables -A INPUT -i $iface -p tcp --destination-port 21 -j ACCEPT
	iptables -A INPUT -i $iface -p tcp --destination-port 1024:60310 -j ACCEPT

	# Accept port 6667 for IRC chat
	iptables -A INPUT -i $iface -p tcp --source-port 6667 -j ACCEPT

	# Accept unprivileged ports
	iptables -A INPUT -i $iface -p udp --destination-port 1024:65535 -j ACCEPT

	# Accept ping
	iptables -A INPUT -i $iface -p icmp -j ACCEPT
done
