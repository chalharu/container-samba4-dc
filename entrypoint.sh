#!/bin/bash

set -eo pipefail

if [ ! -f /etc/timezone ] && [ ! -z "$TZ" ]; then
  echo 'Set timezone'
  cp /usr/share/zoneinfo/$TZ /etc/localtime
  echo $TZ >/etc/timezone
fi

if [ -z "$CONF_PATH" ]; then
  CONF_PATH=${TARGET_DIR}/etc/smb.conf
fi

# Configure the AD DC
if [ ! -f /var/lib/samba/private/sam.ldb ]; then
  if [ -z "$NETBIOS_NAME" ]; then
    NETBIOS_NAME=$(hostname -s | tr [a-z] [A-Z])
  else
    NETBIOS_NAME=$(echo $NETBIOS_NAME | tr [a-z] [A-Z])
  fi
  
  REALM=$(echo "$REALM" | tr [a-z] [A-Z])
  
  if [ -n "$HOST_IPV4ADDR" ] && [ -n "$HOST_IPV6ADDR" ]; then
    HOSTIP_OPTION="--host-ip=\"${HOST_IPV4ADDR}\" --host-ip6=\"${HOST_IPV6ADDR}\" --option=\"dns update command = /usr/sbin/samba_dnsupdate --current-ip ${HOST_IPV4ADDR} --current-ip ${HOST_IPV6ADDR}\""
  elif [ -n "$HOST_IPV4ADDR" ]; then
    HOSTIP_OPTION="--host-ip=\"${HOST_IPV4ADDR}\" --option=\"dns update command = /usr/sbin/samba_dnsupdate --current-ip ${HOST_IPV4ADDR}\""
  elif [ -n "$HOST_IPV6ADDR" ]; then
    HOSTIP_OPTION="--host-ip6=\"${HOST_IPV6ADDR}\" --option=\"dns update command = /usr/sbin/samba_dnsupdate --current-ip ${HOST_IPV6ADDR}\""
  else
    HOSTIP_OPTION=""
  fi
  
  if [ -n "$DNS_FORWARDER" ]; then
    DNS_FORWARDER_OPTION="--option=\"dns forwarder = ${DNS_FORWARDER}\""
  else
    DNS_FORWARDER_OPTION=""
  fi

  echo "${DOMAIN} - Begin Domain Provisioning"
  rm -f /etc/samba/smb.conf /etc/krb5.conf
  echo "samba-tool domain provision \
      --domain=\"${DOMAIN}\" \
      --adminpass=\"${ADMIN_PASSWORD}\" \
      --server-role=dc \
      --realm=\"${REALM}\" \
      --dns-backend=\"${DNS_BACKEND}\" \
      --use-rfc2307 \
      ${DNS_FORWARDER_OPTION} \
      ${HOSTIP_OPTION} \
      --option=\"rpc server dynamic port range = ${RPC_PORTS}\" \
      --host-name=\"${NETBIOS_NAME}\" \
      --targetdir=\"${TARGET_DIR}\" \
      ${ADDITIONAL_OPTIONS}" | sh
  echo "${DOMAIN} - Domain Provisioned Successfully"
fi

samba -i --configfile=${CONF_PATH}
