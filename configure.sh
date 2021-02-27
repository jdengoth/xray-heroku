#!/bin/sh

# Download and install Xray
mkdir /tmp/Xray
curl -L -H "Cache-Control: no-cache" -o /tmp/Xray/Xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
unzip /tmp/Xray/Xray.zip -d /tmp/Xray
install -m 755 /tmp/Xray/xray /usr/local/bin/xray

# Remove temporary directory
rm -rf /tmp/Xray

# Xray new configuration
install -d /usr/local/etc/xray
cat << EOF > /usr/local/etc/xray/config.json
{
	"log": {
		"access": "none",
		"loglevel": "error"
	},
	"dns": {
		"servers": [{
			"address": "https+local://1.0.0.1/dns-query",
			"port": 443
		}]
	},
	"inbounds": [{
		"port": $PORT,
		"protocol": "vless",
		"settings": {
			"decryption": "none",
			"clients": [{
				"id": "$UUID"
			}]
		},
		"streamSettings": {
			"network": "ws",
			"wsSettings": {
				"path": "/mypath"
			}
		}
	}],
	"outbounds": [{
		"protocol": "freedom",
		"settings": {
			"domainStrategy": "UseIP"
		}
	}]
}
EOF

# Run Xray
/usr/local/bin/xray run -c /usr/local/etc/xray/config.json
