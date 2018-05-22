#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "Please run this script with sudo" 
   exit 1
fi

# Download Tor.
sudo apt-get update
sudo apt-get dist-upgrade
echo 'deb http://deb.torproject.org/torproject.org trusty main' | sudo tee -a /etc/apt/sources.list.d/torproject.list
gpg --keyserver keys.gnupg.net --recv A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -
sudo apt-get update
sudo apt-get install tor
sudo service tor stop
sudo apt-get install deb.torproject.org-keyring
sudo apt-get install apt-transport-tor

# Install nyx
sudo apt-get install tor-geoipdb apparmor-utils torsocks

# Set the Tor configuration. 
sudo echo "ClientOnly 1
SOCKSPort 9050
SOCKSPolicy accept 127.0.0.1/8
Log notice file /var/log/tor/notices.log
ControlPort 9051
HiddenServiceStatistics 0
ORPort 9001
LongLivedPorts 21,22,706,1863,5050,5190,5222,5223,6523,6667,6697,8300,8233
ExitPolicy reject :
DisableDebuggerAttachment 0" > /etc/tor/torrc 

# Download privoxy.
sudo apt-get install -y tor-geoipdb privoxy


# Install Zcash directly from Tor
echo "deb [arch=amd64] tor+http://zcaptnv5ljsxpnjt.onion/ jessie main" | sudo tee /etc/apt/sources.list.d/zcash.list
sudo apt-get update && sudo apt-get install zcash


# Set the zcash configuration
mkdir ~/.zcash
touch ~/.zcash/zcash.conf
echo "listen=0
server=1
port=8233
rpcport=8232
rpcallowip=127.0.0.1
rpcuser=YOUR_RANDOM_RPCUSER
rpcpassword=YOUR_RANDOM_RPCPASSWORD
proxy=127.0.0.1:9050
maxconnections=8
onlynet=onion
addnode=zcashiqykswlzpsu.onion
addnode=zcashqhrmju6zfhn.onion
addnode=zcashgmvxwrmjsut.onion
addnode=zcashz3uma65ix7b.onion
addnode=zcashiyf4kxluf3x.onion
addnode=zcashwfe4x3jkz2b.onion
addnode=zcashvkeki52iqpc.onion
addnode=zcasha3cmfrpy7b7.onion
addnode=zcashz7ed3nvbdxm.onion
addnode=zcash5adwfpxfuvf.onion
addnode=zcashixg5ol2ndo4.onion
addnode=zcashuzwa365oh3n.onion
addnode=zcashskbeoiwtym3.onion
addnode=zcashuyvk5e7qfzy.onion
addnode=fhsxfrwpyrtoxeal.onion
addnode=zcash2iihed2wdux.onion
addnode=w3dxku36wbp3lowx.onion" > ~/.zcash/zcash.conf

