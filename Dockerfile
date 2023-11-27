FROM ubuntu:jammy

ENV UID=1100 GID=1100 IP=0.0.0.0 FORWARD_DNS_1=1.1.1.1 FORWARD_DNS_2=8.8.8.8

COPY rootfs /

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y unbound dnsutils && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/* && \
    chmod +x /entry.sh && \
    mkdir /zones && \
    groupadd --gid ${GID} dns && \
    useradd --gid ${GID} --uid ${UID} dns && \
    chown -R dns: /zones && \
    chown -R dns: /etc/unbound

EXPOSE 53

ENTRYPOINT ["/entry.sh"]

CMD ["/usr/sbin/unbound-control", "start"]