# zcash <3 tor

Open an issue to report an error and submit a pull request to close an open issue.

All contributions are made under The Unlicense. See the LICENSE file in this repository.

# Bounties

There are open bounties to solve issues in this repo:

- https://github.com/durbanpoison/zcash-tor/issues/5

**Note: Bounties will only be paid out to z-addresses.**

# Installing and running Zcash over Tor on a Debian server.

**This is still a work in progress. I do not suggest using it unless you’re willing to do some research to make sure it’s working properly.**

Open Terminal, SSH into your Debian server, and follow these instructions.

### Install and run Tor + nyx

Make sure your existing software is up to date.

`sudo apt-get update`

`sudo apt-get dist-upgrade`

Add the Tor package repo to your apt sources.

`echo 'deb http://deb.torproject.org/torproject.org trusty main' | sudo tee -a /etc/apt/sources.list.d/torproject.list`

Download the Tor signing key and add it to apt's trusted keyring. This key will be used to verify the publisher's signature on the Tor software.

`gpg --keyserver keys.gnupg.net --recv A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89`

`gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -`

Update apt again.

`sudo apt-get update`

Install Tor.

`sudo apt-get install tor`

Make sure Tor is not running.

`sudo service tor stop`

Tor developers also provide a keyring to download here.

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

Press `CTRL+X` then `Y` then `Enter` to save and exit.

Start Tor.

`sudo service tor start`

Start nyx.

`sudo -H -u debian-tor nyx`

You can navigate nyx with your arrow keys. Pressing `M` will show the menu. `Q` to quit. `R` to reconnect. Note that Tor can also be stopped or restarted via the nyx menu.

### Install and run Zcash

Open a new Tab in Terminal then SSH into your server in the new Tab.

--

**TODO: INSTRUCTIONS FOR INSTALLING OVER TOR**

Configure wget to connect over Tor.

Download and install Privoxy.

`sudo apt-get install -y tor-geoipdb privoxy`

Open the wget configuration file:

`sudo nano /etc/wgetrc`

Find lines starting with: 

> #https_proxy =
> #http_proxy =

Replace both lines (including #) with: 

> https_proxy = https://localhost:8118
> http_proxy = http://localhost:8118

Press `CTRL+X` then `Y` then `Enter` to save and exit.

Open the Privoxy configuration file.

`sudo nano /etc/Privoxy`

Add these lines to the file so Privoxy will take traffic from wget and send it through Tor.

> listen-address localhost:8118
> forward-socks5 / 127.0.0.1:9050

Press `CTRL+X` then `Y` then `Enter` to save and exit.

Run a test to ensure that wget is connecting over Tor. As a test we will try to download wget from gnu.org.

`wget http://ftp.gnu.org/gnu/wget/wget-1.15.tar.gz`

The console should show the message:

> Resolving localhost... 127.0.0.1
> Connecting to localhost|127.0.0.1|:8118... connected

The `Resolving localhost...` and `Connecting to localhost...` messages will be evidence that wget is correctly connecting over Tor. If the console shows `Resolving ftp.gnu.org...` and `Connecting to ftp.gnu.org...` then the proxy isn't working. Double-check that the wget and Privoxy configuration files are correct by comparing what's shown on the console with the lines referenced above.

Proceed when wget is confirmed to be connecting over Tor.

Download the Zcash signing key and add it to apt's trusted keyring. This key will be used to verify the publisher's signature on the Zcash software.

`wget -qO - https://apt.z.cash/zcash.asc | sudo apt-key add -`

The fingerprint of the key is (F1E2 1403 7E94 E950 BA85 77B2 63C4 A216 9C1B 2FA2)[https://github.com/zcash/zcash/wiki/Debian-binary-packages].

Install a tool that will enable downloading and updating software from apt package repositories over Tor.

`sudo apt-get install apt-transport-tor`

Add the official Zcash Tor apt repo to the list of Zcash installation sources.

`echo "deb [arch=amd64] tor+http://zcaptnv5ljsxpnjt.onion/ jessie main" | sudo tee /etc/apt/sources.list.d/zcash.list`

Update apt sources and install Zcash.

`sudo apt-get update && sudo apt-get install zcash`

Download the Zcash parameters.

`zcash-fetch-params`

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
> onlynet=onion  
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

Press `CTRL+X` then `Y` then `Enter` to save and exit.

Run the following command to start the Zcash daemon:

`zcashd`

Let zcashd run while the blockchain is synchronized.

After the blockchain is 100% synchronized, open a new tab in Terminal and SSH into your server.

Make sure that Zcash is connecting over Tor as expected.

`zcash-cli getpeerinfo`

All peers should have a line that looks like:

`"addr": "w3dxku36wbp3lowx.onion"`

If any peers have a line that looks like:

`"addr": "85.143.104.14:8233"`

Then Zcash is not connecting over Tor properly. Double check the Tor and Zcash configuration files and compare against the versions shown above.

Zcash can be used after it is confirmed to be connecting exclusively over Tor.

### Start using Zcash over Tor

Follow the Zcash 1.0 User Guide to begin using Zcash.

https://github.com/zcash/zcash/wiki/1.0-User-Guide

# Acknowledgements

Thanks for @str4d in the Zcash community chat for answering some of my questions during the production of this guide.

Thanks @l0sec for solving (Issue #4)[https://github.com/durbanpoison/zcash-tor/issues/4] and making other helpful suggestions.

This guide borrows heavily from the following resources:

https://github.com/zcash/zcash/wiki/Debian-binary-packages

https://github.com/zcash/zcash/blob/master/doc/tor.md

https://forum.z.cash/t/set-up-guide-for-running-zcash-on-tor-ubuntu-debian-linux-desktop/18748/2

https://forum.z.cash/t/zcash-addnode-tor-hidden-service-onion/13007/3
