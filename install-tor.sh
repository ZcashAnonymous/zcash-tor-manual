#!/bin/bash
if [[ $EUID -ne 0 ]]; then
     echo "Please run this script with sudo." 
        exit 1
        fi

# Download Tor.
sudo apt-get update --force-yes
sudo apt-get dist-upgrade --force-yes
echo 'deb http://deb.torproject.org/torproject.org trusty main' | sudo tee -a /etc/apt/sources.list.d/torproject.list
gpg --keyserver keys.gnupg.net --recv A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -
sudo apt-get update --force-yes
sudo apt-get install tor --force-yes
sudo service tor stop
sudo apt-get install deb.torproject.org-keyring --force-yes
sudo apt-get install apt-transport-tor --force-yes

# Install nyx
sudo apt-get install tor-geoipdb apparmor-utils torsocks --force-yes

# Set the Tor configuration. 
sudo echo "ClientOnly 1
SOCKSPort 9050
SOCKSPolicy accept 127.0.0.1/8
Log notice file /var/log/tor/notices.log
ControlPort 9051
HiddenServiceStatistics 0
ORPort 9001
LongLivedPorts 21,22,706,1863,5050,5190,5222,5223,6523,6667,6697,8300,8233
ExitPolicy reject *:*
DisableDebuggerAttachment 0" > /etc/tor/torrc 

