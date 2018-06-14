# Zcash <3 Tor Install scripts.

## What is this?
This is a way to privately install and run zcash.

## Why do I need this? Zcash works fine without it.
Yes! But the privacy of your transactions could possibly be compromised by an attacker knowing your IP address. By having the entire zcash ecosystem accessed exclusively through Tor, you increase your level of privacy. This will also install zcash through tor, helping keep private the fact that you use zcash at all.


## How to install
First, you'll need to install all of the necessary tor packages. This will be done through the normal web, so your IP will be exposed here.

```bash
sudo ./install-tor.sh
```
Next, we turn on the tor service and install zcash. This will assure us that all zcash software and parameters are only accessed through tor. 
 
 ```bash
 sudo service tor start
 sudo ./zcash-tor-install.sh
 ```
 
 
 ## How to use
 Once everything is installed, we can start running zcash easily!
 
 ```bash
 ./zcashd-tor.sh
 ```
 
By starting `zcashd` with this script rather than directly, you have constant monitoring that you only ever connect to other Tor nodes, incase something were to happen to your config file. If you do happen to connect to a non Tor peer, `zcashd` will terminate immediately. 
