# zcash <3 tor

Open an issue to report an error and submit a pull request to close open issues.

All contributions are made under The Unlicense. See LICENSE.md in this repository.

# Installing and running Zcash over Tor on a Debian server.

Open Terminal, SSH into your Debian server, and follow these instructions.

**Install and run Tor + nyx**

Enter the following commands:

`sudo apt-get update`

`sudo apt-get dist-upgrade`

`echo 'deb http://deb.torproject.org/torproject.org trusty main' | sudo tee -a /etc/apt/sources.list.d/torproject.list`

`gpg --keyserver keys.gnupg.net --recv A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89`

`gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -`

`sudo apt-get update`

`sudo apt-get install tor`

`sudo service tor stop`

`sudo apt-get install deb.torproject.org-keyring`

Install nyx, a command-line tool for monitoring Tor.

`sudo apt-get install tor-geoipdb apparmor-utils torsocks`

Edit the Tor configuration file.

`sudo nano /etc/tor/torrc`

Press and hold `CTRL+K` to delete the existing content until the file is blank then copy+paste:

> ClientOnly 1  
> SOCKSPort 9050  
> SOCKSPolicy accept 127.0.0.1/8  
> Log notice file /var/log/tor/notices.log  
> ControlPort 9051  
> HiddenServiceStatistics 0  
> ORPort 9001  
> LongLivedPorts 21,22,706,1863,5050,5190,5222,5223,6523,6667,6697,8300,8233  
> ExitPolicy reject *:*  
> DisableDebuggerAttachment 0  

`CTRL+X` then `Y` then `Enter`

Start Tor.

`sudo service tor start`

Start nyx.

`sudo -H -u debian-tor nyx`

You can navigate nyx with your arrow keys. Pressing `M` will show the menu. `Q` to quit. `R` to reconnect. Note that Tor can also be stopped or restarted via the nyx menu.

**Install and run Zcash**

Open a new Tab in Terminal then SSH into your server in the new Tab and enter the following commands:

--

**TODO: INSTRUCTIONS FOR INSTALLING OVER TOR**

Need easier step-by-step instructions for doing this:

> The repository is also accessible via Tor, after installing the apt-transport-tor package, at the address zcaptnv5ljsxpnjt.onion. Use the following pattern in your sources.list file: deb [arch=amd64] tor+http://zcaptnv5ljsxpnjt.onion/ jessie main

From: https://github.com/zcash/zcash/wiki/Debian-binary-packages

**WIP, needs review:**

`sudo apt-get install apt-transport-tor`

`echo "deb [arch=amd64] tor+http://zcaptnv5ljsxpnjt.onion/ jessie main" | sudo tee /etc/apt/sources.list.d/zcash.list`

`sudo apt-get update && sudo apt-get install zcash`

*Question: After completing the above steps, are the params also fetched over Tor?*

`zcash-fetch-params`

--

**TODO: Remove HTTPS instructions after finishing the Tor instructions above**

`sudo apt-get install apt-transport-https`

`wget -qO - https://apt.z.cash/zcash.asc | sudo apt-key add -`

`echo "deb [arch=amd64] https://apt.z.cash/ jessie main" | sudo tee /etc/apt/sources.list.d/zcash.list`

`sudo apt-get update && sudo apt-get install zcash`

--

`mkdir ~/.zcash`

`sudo nano ~/.zcash/zcash.conf`

Delete any information in this file (it should be blank but if not, then delete everything) then copy+paste:

> listen=0  
> server=1  
> port=8233  
> rpcport=8232  
> rpcallowip=127.0.0.1  
> rpcuser=YOUR_RANDOM_RPCUSER  
> rpcpassword=YOUR_RANDOM_RPCPASSWORD  
> proxy=127.0.0.1:9050  
> maxconnections=8  
> addnode=mainnet.z.cash  
> addnode=zcashiqykswlzpsu.onion  
> addnode=zcashqhrmju6zfhn.onion  
> addnode=zcashgmvxwrmjsut.onion  
> addnode=zcashz3uma65ix7b.onion  
> addnode=zcashiyf4kxluf3x.onion  
> addnode=zcashwfe4x3jkz2b.onion  
> addnode=zcashvkeki52iqpc.onion  
> addnode=zcasha3cmfrpy7b7.onion  
> addnode=zcashz7ed3nvbdxm.onion  
> addnode=zcash5adwfpxfuvf.onion  
> addnode=zcashixg5ol2ndo4.onion  
> addnode=zcashuzwa365oh3n.onion  
> addnode=zcashskbeoiwtym3.onion  
> addnode=zcashuyvk5e7qfzy.onion  
> addnode=fhsxfrwpyrtoxeal.onion  
> addnode=zcash2iihed2wdux.onion  
> addnode=w3dxku36wbp3lowx.onion  

`CTRL+X` then `Y` then `Enter`

Run the following command to start the Zcash daemon:

`zcashd`

Wait until the blockchain is 100% synchronized, then you can begin using Zcash over Tor.

Follow the Zcash 1.0 User Guide to begin using Zcash.

https://github.com/zcash/zcash/wiki/1.0-User-Guide

*Question: Is there a way to check and make sure you're properly connecting over Tor so you don't accidentally shoot yourself in the foot?*

**ACKNOWLEDGEMENTS**

Thanks for @str4d in the Zcash community chat for answering some of my questions during the production of this guide.

This guide borrows heavily from the following resources:

https://github.com/zcash/zcash/wiki/Debian-binary-packages

https://github.com/zcash/zcash/blob/master/doc/tor.md

https://forum.z.cash/t/set-up-guide-for-running-zcash-on-tor-ubuntu-debian-linux-desktop/18748/2

https://forum.z.cash/t/zcash-addnode-tor-hidden-service-onion/13007/3
