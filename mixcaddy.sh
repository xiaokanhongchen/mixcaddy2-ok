#!/bin/sh

wget -qO- https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip | busybox unzip - 
chmod +x /v2ray /v2ctl /usr/bin/gost

# config caddy
mkdir -p /usr/share/caddy
wget -O /usr/share/caddy/index.html https://github.com/ringring1/mixcaddy2-ok/raw/master/index.html
cat << EOF > /etc/caddy/Caddyfile
:$PORT
root * /usr/share/caddy
file_server

@websocket_gost {
header Connection *Upgrade*
header Upgrade    websocket
path /ringgost
}
reverse_proxy @websocket_gost 127.0.0.1:2234

@websocket_v2ray {
header Connection *Upgrade*
header Upgrade    websocket
path /ring
}
reverse_proxy @websocket_v2ray 127.0.0.1:9090
EOF

# config v2ray
cat << EOF > /v2ray.json
{
    "inbounds": 
    [
        {
            "port": 9090,"listen": "127.0.0.1","protocol": "vmess",
            "settings": {"clients": [{"id": "580814c2-a784-44d0-9380-56aa03a7de75", "alterId": 64}]},
            "streamSettings": {"network": "ws", "security": "auto", "wsSettings": {"path": "/ring"}}
        }
    ],
    "outbounds": [{"protocol": "freedom"}]
}	
EOF

# start
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &

#gost -L ss+ws://AEAD_CHACHA20_POLY1305:$PASSWORD@127.0.0.1:2234?path=$GOSTPATH & test&ok 
#client& ./gost -L :8888 -F=ss+wss://AEAD_CHACHA20_POLY1305:password@***.herokuapp.com:443?path=/gostpath

#gost -L http+ws://admin:123456@127.0.0.1:2234?path=$GOSTPATH & &test & ok
#client& ./gost -L :8888 -F=http+wss://admin:123456@***.herokuapp.com:443?path=/gostpath

#gost -L ss2://AEAD_CHACHA20_POLY1305:password@127.0.0.1:2234?path=$GOSTPATH &
gost -L ss+ws://AEAD_CHACHA20_POLY1305:password@127.0.0.1:2234?path=$GOSTPATH &

/v2ray -config /v2ray.json
