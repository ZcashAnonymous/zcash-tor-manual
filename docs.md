# Zcash <3 Tor Install Scripts.

## What is this?
This is a way to privately install and run a Zcash full node.

## Why do I need this? Zcash works fine without it.
Yes! But the privacy of your transactions could possibly be compromised by an attacker knowing your IP address. By having the entire Zcash ecosystem accessed exclusively through Tor, you increase your level of privacy. This will also install Zcash through Tor, helping to keep private the fact that you use Zcash at all.

## How to privately download
If you are viewing this page on a normal browser, then your IP has already been leaked to GitHub. ¯\_(ツ)_/¯

If you still want to try to be more private, then there are two ways we recommend to get this script over Tor.

#### Easiest way:
First, you'll need the [Tor Browser Bundle ](https://www.torproject.org/projects/torbrowser.html). Once that is installed, come back to this page using the Tor Browser. Go to the [main page](https://github.com/durbanpoison/zcash-tor) of this repository, click on "Clone or download", then click on "Download ZIP". Unzip the file and open its directory on your computer. Right click anywhere on that window and select "Open in terminal" in the menu. Keep the terminal open, as you will need it for the **How to install** part of this guide.

#### Fancy way:
If you don't have access to a browser (say you are on a cloud machine), then you'll need to do some extra steps in order to ensure your privacy. If you are taking this path, I'll assume you already know how to use bash commands.

First, let's get the basic version of Tor installed and running.

```bash
sudo apt-get install torsocks
service tor restart
```

Next, let's verify that wget is running through Tor. 

```bash
torsocks wget -qO- https://check.torproject.org/ | grep -E "Congratulations|Sorry"
```

You should see "Congratulations. This browser is configured to use Tor." if everything is working properly. If you get an error or "Sorry" message, then try reinstalling or restarting the Tor service.

Once you are ready, go ahead and download this script over Tor. 

```bash
torsocks wget https://github.com/durbanpoison/zcash-tor/archive/master.zip
unzip master.zip
cd zcash-tor-master
```

## How to install
First, you'll need to install all of the necessary Tor packages. This will be done through the normal web, so your IP will be exposed here. That's ok though, as nothing in this script touches anything related to Zcash. 

To be able to run these commands, your terminal must be in the same directory as these scripts (`~/zcash-tor-master`).

```bash
sudo ./install-tor.sh
```

Next, we turn on the Tor service and install Zcash. This will assure us that all Zcash software and parameters are only accessed through Tor. 
 
 ```bash
 sudo service tor restart
 sudo ./zcash-tor-install.sh
 ```
 
 ## How to use
 Once everything is installed, we can start running Zcash easily!
 
 ```bash
 ./zcashd-tor.sh
 ```
 
By starting `zcashd` with this script rather than directly, you have constant monitoring that you only ever connect to other Tor nodes, in case something were to happen to your config file. If you do happen to connect to a non-Tor peer, `zcashd` will terminate immediately.
