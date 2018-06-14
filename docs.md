## How to use
First, you'll need to install all of the nessisary tor packages. This will be done through the normal web, so your IP will be exposed here.

```bash
sudo ./install-tor.sh
```
Next, we turn on the tor service and install zcash. This will assure us that zcash software and parameters are only accessed through tor. 
 
 ```bash
 sudo service tor start
 sudo ./zcash-tor-install.sh
 ```
 
 Finally. Once everything is installed, we can start running zcash!
 
 ```bash
 ./zcashd-tor.sh
 ```
