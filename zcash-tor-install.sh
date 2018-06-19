#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "Please run this script with sudo." 
   exit 1
fi

# Assert Tor is running
if curl --socks5-hostname localhost:9050 https://check.torproject.org 2>&1 | grep 'Sorry\|Connection refused'; then
  echo -e "\e[31mFailed to connect to Tor. No Zcash systems have been accessed.\e[0m"
  echo -e "\e[31mPlease assert tor service is active by running 'sudo service tor start'" 
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
echo "listen=0
server=1
port=8233
rpcport=8232
rpcallowip=127.0.0.1
proxy=127.0.0.1:9050
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
adnode=fhsxfrwpyrtoxeal.onion
addnode=zcash2iihed2wdux.onion
addnode=w3dxku36wbp3lowx.onion
maxconnections=100
dnsseed=0
onlynet=onion" > ~/.zcash/zcash.conf

# Add random username and passwords.
# Not super clean but it works.
printf "rpcuser=" >> ~/.zcash/zcash.conf
xxd -l 16 -p /dev/random >> ~/.zcash/zcash.conf
echo "" >>  ~/.zcash/zcash.conf
printf "rpcpassword=" >> ~/.zcash/zcash.conf
xxd -l 16 -p /dev/random >> ~/.zcash/zcash.conf


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

function main() {

    cat <<EOF
Fetching the Zcash zkSNARK parameters over Tor and verify their
integrity with sha256sum.

If they already exist locally, it will exit now and do nothing else.
EOF
# Now create PARAMS_DIR and insert a README if necessary:
    if ! [ -d "$PARAMS_DIR" ]
    then
        mkdir -p "$PARAMS_DIR"
        README_PATH="$PARAMS_DIR/README"
        cat >> "$README_PATH" <<EOF
This directory stores common Zcash zkSNARK parameters. Note that it is
distinct from the daemon's -datadir argument because the parameters are
large and may be shared across multiple distinct -datadir's such as when
setting up test networks.
EOF
       cat <<EOF
The parameters are currently just under 911MB in size, so plan accordingly
for your bandwidth constraints. If the files are already present and
have the correct sha256sum, no networking is used.
Creating params directory. For details about this directory, see:
$README_PATH
EOF
    fi
    cd "$PARAMS_DIR"

    fetch_params "$SPROUT_PKEY_NAME" "$PARAMS_DIR/$SPROUT_PKEY_NAME" "8bc20a7f013b2b58970cddd2e7ea028975c88ae7ceb9259a5344a16bc2c0eef7"
    fetch_params "$SPROUT_VKEY_NAME" "$PARAMS_DIR/$SPROUT_VKEY_NAME" "4bd498dae0aacfd8e98dc306338d017d9c08dd0918ead18172bd0aec2fc5df82"
}

main ${1:-}

echo -e "\e[32mInstallation is complete. Run ./zcashd-tor.sh to start your node. \e[0m"
