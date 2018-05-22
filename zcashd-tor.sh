service tor start
if curl --socks5-hostname localhost:9050 https://check.torproject.org 2>&1 | grep 'Sorry\|Connection refused'; then
  echo -e "\e[31mFailed to connect to Tor. No Zcash systems have been accessed.\e[0m"
  exit 1 
fi
zcashd &
# Continuously verify only TOR connections.
while true; do
  sleep 3  
  if zcash-cli getpeerinfo | grep addr | grep -v ".onion"; then
    killall zcashd
    echo -e "\e[31m!!!YOU HAVE CONNECTED TO A NON-TOR NODE!!!\e[0m"
    echo -e "\e[31mPlease verify your zcash.conf file. Zcashd has been killed\e[0m"
    exit 1
  fi
done