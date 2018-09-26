# zcash <3 tor

This guide contains instructions for using Tor to ensure that your IP address is not exposed to any Zcash-related services when installing, running, and updating a Zcash full node (zcashd) on a Debian server.

Note: These instructions are intended for use with a Debian server that is running 24/7 but should work with a Debian desktop as well. If you use a Debian desktop Zcash node then make sure to shutdown the node safely before shutting down your desktop, and restart Tor and the Zcash node after restarting the desktop.

## Table of Contents<sup id="a1"></sup>

- [Installing, running, and Zcash over Tor on a Debian server](#installing-running-and-updating-zcash-over-tor-on-a-debian-server)
- [Editor](#editor)
- [Forum thread](#forum-thread)
- [Bounties](#bounties)
- [Contribute](#contribute)
- [Acknowledgements](#acknowledgements)
- [License](#license)

## Installing, running, and updating Zcash over Tor on a Debian server. [↩](#a1)

**Install automatically**  
Follow the instructions [here](https://github.com/ZcashAnonymous/zcash-tor-auto/blob/master/README.md) to use open source scripts that automate most of the process detailed below. This could save you a lot of time!

**Install manually**

Open Terminal, SSH into your Debian server, and follow these instructions.

### Install and run Tor + nyx

Make sure your existing software is up to date.

`sudo apt-get update`

`sudo apt-get upgrade`

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

Press and hold `CTRL+K` to delete the existing content until the file is blank then copy+paste the following into the file:

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

Configure wget to connect over Tor.

Download and install Privoxy.

`sudo apt-get install -y tor-geoipdb privoxy`

Open the wget configuration file:

`sudo nano /etc/wgetrc`

Find the lines starting with: 

> #https_proxy =  
> #http_proxy =  

Replace both lines (including # symbol) with: 

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

`mkdir ~/.zcash`

`sudo nano ~/.zcash/zcash.conf`

Press and hold `CTRL+K` to delete the existing content (if any) until the file is blank then copy+paste the following into the file:

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

> "addr": "w3dxku36wbp3lowx.onion"  

If any peers have a line that looks like:

> "addr": "85.143.104.14:8233"  

Then Zcash is not connecting over Tor properly. Double check the Tor and Zcash configuration files and compare against the versions shown above.

Zcash can be used after it is confirmed to be connecting exclusively over Tor.

### The moment you've been waiting for: Using Zcash

Follow the Zcash User Guide to begin using Zcash.

https://zcash.readthedocs.io/en/latest/rtd_pages/rtd_docs/user_guide.html#usage

### Updating Zcash

You should keep your software up to date to fix bugs, close security holes, and stay in sync with the Zcash network. To update your software, enter these commands:

`zcash-cli stop`

Wait a minute for zcashd to completely stop then enter these commands:

`sudo service tor stop`

`sudo apt-get update -y`

`sudo apt-get upgrade -y`

`sudo apt-get dist-upgrade -y`

`sudo shutdown –r now`

Wait a minute then SSH back into your server and enter these commands:

`sudo service tor start`

`zcashd`

Your Zcash node should start and run over Tor as expected. After giving the node time to sync the blockchain, you can begin using your Zcash node again.

## Editor [↩](#a1)

The editor of [this guide](https://github.com/ZcashAnonymous/zcash-tor) is [@durbanpoison](https://github.com/durbanpoison). To help improve this guide, see the [Contribute](#contribute) section below.

## Forum thread [↩](#a1)

https://forum.z.cash/t/new-guide-zcash-3-tor-installing-running-and-updating-zcash-over-tor-on-a-debian-server/

## Bounties [↩](#a1)

Check for open bounties to solve issues in this repo:

- https://github.com/durbanpoison/zcash-tor/labels/bounty

**Note: Bounties will only be paid out to z-addresses.**

Total [bounties paid](https://github.com/durbanpoison/zcash-tor/issues?q=is%3Aissue+is%3Aclosed+label%3Abounty): 0.325 ZEC

Contribute to the bounty fund: `zc9kJ1jZUnKRghsLC9cVoRAWFgCiU5Mq4V6gS8pGXSBBgS3hS9VmLRFawkhpiFEuFpAKbBoxnGWRNeXfJzHNbAWk7tUh2s4`

You can also add and fund your own bounties. Just add the amount of the bounty to your issue and ask for the bounty label in a comment on your issue.

## Contribute [↩](#a1)

Open an issue to report an error or suggest a change and submit a pull request to close an open issue.

All contributions are made under the CC0 license. See the [LICENSE](https://github.com/ZcashAnonymous/zcash-tor/blob/master/LICENSE.md) file in this repository.

## Acknowledgements [↩](#a1)

Thanks [Tor Project](https://torproject.org) for building software that helps protect internet users' network privacy.

Thanks [Zcash](https://z.cash) for building software that helps protect internet users' financial privacy.

Thanks for @str4d in the Zcash community chat for answering some of my questions during the production of this guide.

Thanks @l0sec for solving [Issue #4](https://github.com/durbanpoison/zcash-tor/issues/4) and making other helpful suggestions.

Thanks to @Thenerdstation for solving [Issue #5](https://github.com/durbanpoison/zcash-tor/issues/5) and to both @ConnorFoody and @jfeldis for reviewing the related [Pull Request #8](https://github.com/durbanpoison/zcash-tor/pull/8).

This guide borrows heavily from the following resources:

https://github.com/zcash/zcash/wiki/Debian-binary-packages

https://github.com/zcash/zcash/blob/master/doc/tor.md

https://forum.z.cash/t/set-up-guide-for-running-zcash-on-tor-ubuntu-debian-linux-desktop/18748/2

https://forum.z.cash/t/zcash-addnode-tor-hidden-service-onion/13007/3

## License [↩](#a1)

[![CC0](http://mirrors.creativecommons.org/presskit/buttons/88x31/svg/cc-zero.svg)](https://creativecommons.org/publicdomain/zero/1.0/)

To the extent possible under law, [durbanpoison](https://github.com/durbanpoison) has waived all copyright and related or neighboring rights to this work.
