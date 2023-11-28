#!/bin/bash

rm -vf /etc/unbound/unbound.conf.d/*.conf

cat > /etc/unbound/unbound.conf.d/server.conf<< EOF
server:
    username: "unbound"

    chroot: ""

    qname-minimisation: yes

    interface: ${IP}
    do-ip6: no

    do-daemonize: no
    use-systemd: no
    use-syslog: no
    access-control: 0.0.0.0/0 allow

    include: /zones/*.zone

forward-zone:
    name: "."
    forward-addr: ${FORWARD_DNS_1}
    forward-addr: ${FORWARD_DNS_2}
EOF

if [ ! -d /zones ]; then
  mkdir -v /zones
  chown -vR dns: /zones
fi

/usr/sbin/unbound-checkconf

exec "$@"