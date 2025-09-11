#!/bin/bash

rm -vf /etc/unbound/unbound.conf.d/*.conf

if [[ -n $FORWARD_DNS_2 ]]
then
  ForwardDNSConf="    forward-addr: ${FORWARD_DNS_2}"
fi

if [[ -n $FORWARD_DNS_3 ]]
then
  ForwardDNSConf="${ForwardDNSConf}
    forward-addr: ${FORWARD_DNS_3}"
fi

if [[ -n $FORWARD_DNS_4 ]]
then
  ForwardDNSConf="${ForwardDNSConf}
    forward-addr: ${FORWARD_DNS_4}"
fi

if $TLS
then
  TLSConf="    forward-tls-upstream: yes"
fi

cat > /etc/unbound/unbound.conf.d/server.conf<< EOF
server:
    username: "unbound"

    chroot: ""

    qname-minimisation: yes

    interface: ${IP}
    do-ip6: ${IPv6}

    do-daemonize: no
    use-systemd: no
    use-syslog: no
    access-control: 0.0.0.0/0 allow

    tls-cert-bundle: /etc/ssl/certs/ca-certificates.crt

    include: /zones/*.zone

forward-zone:
    name: "."
${TLSConf}

    forward-addr: ${FORWARD_DNS_1}
${ForwardDNSConf}
EOF

if [ ! -d /zones ]; then
  mkdir -v /zones
  chown -vR dns: /zones
fi

/usr/sbin/unbound-checkconf

exec "$@"