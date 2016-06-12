#!/bin/sh

##
## Usage: ./generate_ovpn.sh SERVER CA_CERT CLIENT_CERT CLIENT_KEY SHARED_SECRET > client.ovpn
##

server=${1?"The server address is required"}
cacert=${2?"The path to the ca certificate file is required"}
client_cert=${3?"The path to the client certificate file is required"}
client_key=${4?"The path to the client private key file is required"}
tls_key=${5?"The path to the TLS shared secret file is required"}

cat << EOF
client
remote ${server}
port 1194
proto udp
persist-key
tls-client
pull
dev tun
persist-tun
comp-lzo adaptive
nobind
auth-nocache
auth-user-pass
cipher AES-256-CBC
key-direction 1
remote-cert-tls server
keepalive 10 120
verb 1
resolv-retry infinite

<ca>
EOF
cat ${cacert}
cat << EOF
</ca>
<cert>
EOF
cat ${client_cert}
cat << EOF
</cert>
<key>
EOF
cat ${client_key}
cat << EOF
</key>
<tls-auth>
EOF
cat ${tls_key}
cat << EOF
</tls-auth>
EOF
