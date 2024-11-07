FROM alpine:3.20

RUN apk add --update --no-cache krb5 ldb-tools samba-dc samba-winbind-clients tdb \
      bind bind-libs bind-tools libcrypto3 libxml2 tzdata py3-setuptools jinja2-cli

RUN rm -rf /etc/samba && \
    rm -rf /var/lib/samba && \
    ln -s /samba/etc /etc/samba && \
    ln -s /samba/lib /var/lib/samba

ADD entrypoint.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/entrypoint.sh

VOLUME /samba
EXPOSE 53 53/udp 88 88/udp 135 137-138/udp 139 389 389/udp 445 464 464/udp 636 3268-3269 49152-49200

ENV REALM=ad.example.com
ENV ADMIN_PASSWORD=admin1234!
ENV DOMAIN=EXAMPLE
ENV DNS_BACKEND=SAMBA_INTERNAL
ENV RPC_PORTS=49152-49200

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
