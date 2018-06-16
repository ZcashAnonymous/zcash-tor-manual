# Zcash <3 Tor Install Scripts.

## What is this?
This is a way to privately install and run zcash.

## Why do I need this? Zcash works fine without it.
Yes! But the privacy of your transactions could possibly be compromised by an attacker knowing your IP address. By having the entire zcash ecosystem accessed exclusively through Tor, you increase your level of privacy. This will also install zcash through tor, helping keep private the fact that you use zcash at all.


## How to privately download
If you are viewing this page on a normal browser, then you IP has already been leaked to github. ¯\\\_(ツ)_/¯

If you still want to try to be more private, then there are a few ways to get this script over tor.
#### Easiest way:
First, you'll need the [Tor Browser Bundle ](https://www.torproject.org/projects/torbrowser.html).
Once that is installed, come back to this page using the tor browser. Go to the main page of this repository, click on "Clone or download", then click on "Download as zip." Unzip the file, and open its directory. Right click anywhere on that window and select "Open in terminal". Keep the terminal open, as you will need it for the 'How to install' part.

#### Fancy way:
If you don't have access to a browser (say you are on a cloud machine), then you'll need to do some extra steps in order to ensure your privacy. If you are taking this path, I'll assume you already know how to use bash commands. 

```bash
sudo apt-get install torsocks
service tor restart
torsocks wget https://github.com/durbanpoison/zcash-tor/archive/master.zip
unzip master.zip
cd zcash-tor-master
```

## How to install
First, you'll need to install all of the necessary tor packages. This will be done through the normal web, so your IP will be exposed here. That's ok though, as nothing in this script touches anything related to Zcash. 

To be able to run these commands, your terminal must be in the same directory as these scripts.
```bash
sudo ./install-tor.sh
```
Next, we turn on the tor service and install zcash. This will assure us that all zcash software and parameters are only accessed through tor. 
 
 ```bash
 sudo service tor restart
 sudo ./zcash-tor-install.sh
 ```
 
 
 ## How to use
 Once everything is installed, we can start running zcash easily!
 
 ```bash
 ./zcashd-tor.sh
 ```
 
By starting `zcashd` with this script rather than directly, you have constant monitoring that you only ever connect to other Tor nodes, incase something were to happen to your config file. If you do happen to connect to a non Tor peer, `zcashd` will terminate immediately. 
