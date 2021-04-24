#!/bin/bash

UUID="580814c2-a784-44d0-9380-56aa03a7de75"
WS_PATH="/ring"

encode() {
  arg1=$1
  base64 $arg1 
}

cat > config.json << EOF
{
  "log": {
    "loglevel": "none"
    },
    "inbounds": [
        {
            "port": 8080,
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "${UUID}",
                        "alterId": 64
                    }
                ]
            },
            "streamSettings": {
                "network":"ws",
                "wsSettings": {
                    "path": "${WS_PATH}"
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "settings": {}
        }
    ]
}
EOF

v2ray_config_pb=`./v2ctl config config.json | encode`
echo $v2ray_config_pb

rm config.json
# Creat start.sh and then encrypt it with shc
cat > start.sh << EOF
#!/bin/sh
p_config_pb="${v2ray_config_pb}"

echo \$p_config_pb | base64 -di > config.pb
chmod 0755 ./ring
./ring -config=./config.pb  >/dev/null 2>/dev/null&
sleep 5 ; rm ./config.pb 
sleep 999d
EOF


export CFLAGS=-static 
shc -r -f  start.sh 
rm start.sh.x.c start.sh
mv start.sh.x ringworld
