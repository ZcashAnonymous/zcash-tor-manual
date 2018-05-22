#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "Please run this script with sudo." 
   exit 1
fi

# Download Tor.
sudo apt-get update --force-yes
sudo apt-get dist-upgrade --force-yes
echo 'deb http://deb.torproject.org/torproject.org trusty main' | sudo tee -a /etc/apt/sources.list.d/torproject.list
gpg --keyserver keys.gnupg.net --recv A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -
sudo apt-get update --force-yes
sudo apt-get install tor --force-yes
sudo service tor stop
sudo apt-get install deb.torproject.org-keyring --force-yes
sudo apt-get install apt-transport-tor --force-yes

# Install nyx
sudo apt-get install tor-geoipdb apparmor-utils torsocks --force-yes

# Set the Tor configuration. 
sudo echo "ClientOnly 1
SOCKSPort 9050
SOCKSPolicy accept 127.0.0.1/8
Log notice file /var/log/tor/notices.log
ControlPort 9051
HiddenServiceStatistics 0
ORPort 9001
LongLivedPorts 21,22,706,1863,5050,5190,5222,5223,6523,6667,6697,8300,8233
ExitPolicy reject *:*
DisableDebuggerAttachment 0" > /etc/tor/torrc 

# # Download privoxy.
# sudo apt-get install -y tor-geoipdb privoxy --force-yes

sudo service tor start
# Assert Tor is running
if curl --socks5-hostname localhost:9050 https://check.torproject.org 2>&1 | grep 'Sorry\|Connection refused'; then
  echo -e "\e[31mFailed to connect to Tor. No Zcash systems have been accessed.\e[0m"
  exit 1 
fi

# Install Zcash over Tor.
echo "deb [arch=amd64] tor+http://zcaptnv5ljsxpnjt.onion/ jessie main" | sudo tee /etc/apt/sources.list.d/zcash.list
# TODO(Chase) Is there a good way to verify the fingerprint?
curl --socks5-hostname localhost:9050 https://apt.z.cash/zcash.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get install zcash --force-yes


# Set the zcash configuration
mkdir ~/.zcash
# TODO(Chase) Get /dev/urandom for RPC username and passwords
echo "listen=0
server=1
port=8233
rpcport=8232
rpcallowip=127.0.0.1
rpcuser=YOUR_RANDOM_RPCUSER
rpcpassword=YOUR_RANDOM_RPCPASSWORD
proxy=127.0.0.1:9050
maxconnections=8
onlynet=onion
addnode=zcashiqykswlzpsu.onion
addnode=zcashqhrmju6zfhn.onion
addnode=zcashgmvxwrmjsut.onion
addnode=zcashz3uma65ix7b.onion
addnode=zcashiyf4kxluf3x.onion
addnode=zcashwfe4x3jkz2b.onion
addnode=zcashvkeki52iqpc.onion
addnode=zcasha3cmfrpy7b7.onion
addnode=zcashz7ed3nvbdxm.onion
addnode=zcash5adwfpxfuvf.onion
addnode=zcashixg5ol2ndo4.onion
addnode=zcashuzwa365oh3n.onion
addnode=zcashskbeoiwtym3.onion
addnode=zcashuyvk5e7qfzy.onion
addnode=fhsxfrwpyrtoxeal.onion
addnode=zcash2iihed2wdux.onion
addnode=w3dxku36wbp3lowx.onion" > ~/.zcash/zcash.conf


# Fetch Zcash params 
# This is modified from https://github.com/zcash/zcash/blob/master/zcutil/fetch-params.sh
# to allow access over Tor.

set -eu

if [[ "$OSTYPE" == "darwin"* ]]; then
    PARAMS_DIR="$HOME/Library/Application Support/ZcashParams"
else
    PARAMS_DIR="$HOME/.zcash-params"
fi

SPROUT_PKEY_NAME='sprout-proving.key'
SPROUT_VKEY_NAME='sprout-verifying.key'
SAPLING_SPEND_NAME='sapling-spend-testnet.params'
SAPLING_OUTPUT_NAME='sapling-output-testnet.params'
SAPLING_SPROUT_GROTH16_NAME='sprout-groth16-testnet.params'
SPROUT_URL="https://z.cash/downloads"
SPROUT_IPFS="/ipfs/QmZKKx7Xup7LiAtFRhYsE1M7waXcv9ir9eCECyXAFGxhEo"

SHA256CMD="$(command -v sha256sum || echo shasum)"
SHA256ARGS="$(command -v sha256sum >/dev/null || echo '-a 256')"

CURLCMD="$(command -v curl || echo '')"

function fetch_curl {
    if [ -z "$CURLCMD" ] ; then
        return 1
    fi

    local filename="$1"
    local dlname="$2"

    cat <<EOF

Retrieving (curl): $SPROUT_URL/$filename
EOF

    curl --socks5-hostname localhost:9050 \
        --output "$dlname" \
        -# -L -C - \
        "$SPROUT_URL/$filename"

}

function fetch_failure {
    cat >&2 <<EOF

Failed to fetch the Zcash zkSNARK parameters!
Try verifying Tor installed correctly and make sure you're online.

EOF
    exit 1
}

function fetch_params {
    local filename="$1"
    local output="$2"
    local dlname="${output}.dl"
    local expectedhash="$3"

    if ! [ -f "$output" ]
    then
        for method in curl failure; do
            if "fetch_$method" "$filename" "$dlname"; then
                echo "Download successful!"
                break
            fi
        done

        "$SHA256CMD" $SHA256ARGS -c <<EOF
$expectedhash  $dlname
EOF

        # Check the exit code of the shasum command:
        CHECKSUM_RESULT=$?
        if [ $CHECKSUM_RESULT -eq 0 ]; then
            mv -v "$dlname" "$output"
        else
            echo "Failed to verify parameter checksums!" >&2
            exit 1
        fi
    fi
}

# Use flock to prevent parallel execution.
function lock() {
    local lockfile=/tmp/fetch_params.lock
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if shlock -f ${lockfile} -p $$; then
            return 0
        else
            return 1
        fi
    else
        # create lock file
        eval "exec 200>/$lockfile"
        # acquire the lock
        flock -n 200 \
            && return 0 \
            || return 1
    fi
}

function exit_locked_error {
    echo "Only one instance of fetch-params.sh can be run at a time." >&2
    exit 1
}

function main() {

    lock fetch-params.sh \
    || exit_locked_error

    cat <<EOF
Fetching the Zcash zkSNARK parameters over Tor and verify their
integrity with sha256sum.

If they already exist locally, it will exit now and do nothing else.
EOF

    cd "$PARAMS_DIR"

    fetch_params "$SPROUT_PKEY_NAME" "$PARAMS_DIR/$SPROUT_PKEY_NAME" "8bc20a7f013b2b58970cddd2e7ea028975c88ae7ceb9259a5344a16bc2c0eef7"
    fetch_params "$SPROUT_VKEY_NAME" "$PARAMS_DIR/$SPROUT_VKEY_NAME" "4bd498dae0aacfd8e98dc306338d017d9c08dd0918ead18172bd0aec2fc5df82"
}

main ${1:-}
rm -f /tmp/fetch_params.lock


echo -e "\e[32mInstallation is complete. Run ./zcashd-tor.sh to start your node. \e[0m"