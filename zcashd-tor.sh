service tor start
if curl --socks5-hostname localhost:9050 https://check.torproject.org 2>&1 | grep 'Sorry\|Connection refused'; then
  echo -e "\e[31mFailed to connect to Tor. No Zcash systems have been accessed.\e[0m"
  exit 1 
fi
zcashd &
if zcash-cli getpeerinfo | grep addr | grep -v ".onion"; then
  echo -e "\e[31mWARNNG!!! YOU ARE NOT RUNNING 'zcashd' OVER TOR!!!\e[0m"
  echo -e "\e[31mPlease verify your zcash.conf file.\e[0m"
  killall zcashd
  exit 1
fi