FROM ubuntu:24.04

ARG SAMBA_VERSION
ARG KRB5_VERSION
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    samba-ad-dc=${SAMBA_VERSION} \
    krb5-user=${KRB5_VERSION} && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD entrypoint.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/entrypoint.sh

VOLUME /samba
EXPOSE 53 53/udp 88 88/udp 135 137-138/udp 139 389 389/udp 445 464 464/udp 636 3268-3269 49152-49200

ENV REALM=ad.example.com
ENV ADMIN_PASSWORD=admin1234!
ENV DOMAIN=EXAMPLE
ENV DNS_BACKEND=SAMBA_INTERNAL
ENV RPC_PORTS=49152-49200
ENV TARGET_DIR=/samba
# ENV CONF_PATH=${TARGET_DIR}/etc/smb.conf

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
