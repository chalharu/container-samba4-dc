FROM ubuntu:24.04

ARG SAMBA_VERSION_ARM64
ARG SAMBA_VERSION_X64
ARG KRB5_VERSION_ARM64
ARG KRB5_VERSION_X64

RUN KRB5_VERSION=$( \
        case ${TARGETPLATFORM} in \
            linux/amd64 ) echo "${KRB5_VERSION_X64}";; \
            linux/arm64 ) echo "${KRB5_VERSION_ARM64}";; \
        esac \
    ) && \
    SAMBA_VERSION=$( \
        case ${TARGETPLATFORM} in \
            linux/amd64 ) echo "${SAMBA_VERSION_X64}";; \
            linux/arm64 ) echo "${SAMBA_VERSION_ARM64}";; \
        esac \
    ) && \
    apt-get update && \
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
