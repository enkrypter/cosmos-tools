#!/bin/bash
# Install Cosmos + create systemd service ,run and sync Cosmos Hub 3, by Víctor from melea "Genesis Cosmos Validator"

USER=$(whoami)
printf "Enter moniker: "
read _moniker

sudo apt-get update
sudo apt install build-essential -y
git clone https://github.com/cosmos/gaia.git
cd gaia
git checkout v5.0.8
make install
mkdir -p $HOME/.gaiad/config
gaiad init ${_moniker} --chain-id cosmoshub-4
sleep 3
gaiad version --long
sleep 3
sudo chmod -R 777 /home/$USER/.gaiad
cd /home/$USER/.gaiad/config/
rm genesis.json
wget https://github.com/cosmos/mainnet/raw/master/genesis.cosmoshub-4.json.gz
gzip -d genesis.cosmoshub-4.json.gz
mv genesis.cosmoshub-4.json ~/.gaia/config/genesis.json
cd
sed -E -i 's/seeds = \".*\"/seeds = \"ba3bacc714817218562f743178228f23678b2873@public-seed-node.cosmoshub.certus.one:26656,bf8328b66dceb4987e5cd94430af66045e59899f@public-seed.cosmos.vitwit.com:26656,cfd785a4224c7940e9a10f6c1ab24c343e923bec@164.68.107.188:26656,d72b3011ed46d783e369fdf8ae2055b99a1e5074@173.249.50.25:26656,3c7cad4154967a294b3ba1cc752e40e8779640ad@84.201.128.115:26656,366ac852255c3ac8de17e11ae9ec814b8c68bddb@51.15.94.196:26656,047f723806ee702b211e7227f89eacd829aabd86@52.9.212.125:26656,3e16af0cead27979e1fc3dac57d03df3c7a77acc@3.87.179.235:26656,2626942148fd39830cb7a3acccb235fab0332d86@173.212.199.36:26656,3028c6ee9be21f0d34be3e97a59b093e15ec0658@91.205.173.168:26656,89e4b72625c0a13d6f62e3cd9d40bfc444cbfa77@34.65.6.52:26656\"/' ~/.gaiad/config/config.toml
sed -E -i 's/persistent_peers = \".*\"/persistent_peers = \"e4f5becb53b568bfd18c7f086dada943f768bc7a@34.244.129.193:26656,94375d3642bf7366bb50f1d91dbeda70b013e6a1@34.255.217.37:26656,aacf186a5a711b1fe511a25e451c1ddbce2d8e4b@8.9.4.245:26656\"/' ~/.gaiad/config/config.toml
sed -E -i 's/minimum-gas-prices = \".*\"/minimum-gas-prices = \"0.025uatom\"/' ~/.gaiad/config/app.toml
sudo mkdir -p /var/log/gaiad
sudo touch /var/log/gaiad/gaiad.log
sudo touch /var/log/gaiad/gaiad_error.log
cat <<EOF > gaiad.service
[Unit]
Description=gaiad daemon
After=network-online.target

[Service]
ExecStart=/usr/local/go/bin/gaiad start --home=/home/$USER/.gaiad/
StandardOutput=file:/var/log/gaiad/gaiad.log
StandardError=file:/var/log/gaiad/gaiad_error.log
Restart=always
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

sudo mv gaiad.service /etc/systemd/system

sudo systemctl daemon-reload
sudo systemctl enable gaiad
sudo systemctl start gaiad
sleep 2
tail -f /var/log/gaiad/gaiad.log
