function sig_handle {
  killall zcashd
  exit 1
}
trap sig_handle SIGTERM
if curl --socks5-hostname localhost:9050 https://check.torproject.org 2>&1 | grep 'Sorry\|Connection refused'; then
  echo -e "\e[31mFailed to connect to Tor. No Zcash systems have been accessed.\e[0m"
  echo -e "\e[31mPlease assert that the tor service is active by running 'sudo service tor start'"
  exit 1 
fi
zcashd -onlynet=onion &
# Continuously verify only TOR connections just in case.
while true; do
  sleep 0.5 # Check every half second, should minimize turn around time.
  if zcash-cli getpeerinfo 2> /dev/null 2> /dev/null | grep addr | grep -v ".onion"; then
    killall zcashd
    echo -e "\e[31m!!!YOU HAVE CONNECTED TO A NON-TOR NODE!!!\e[0m"
    echo -e "\e[31mPlease verify your zcash.conf file. Zcashd has been killed\e[0m"
    exit 1
  fi
done
