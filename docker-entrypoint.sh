#!/bin/sh

set -eu

DISTRO="$(cat /etc/os-release | sed -n 's/^ID=//p')"
REGISTRY_CONFIG='/etc/registry'
REGISTRY_DATA='/var/lib/registry'
REGISTRY_CONFIG_FILE="${REGISTRY_CONFIG}/config.yml"
REGISTRY_HTPASSWD_FILE="${REGISTRY_CONFIG}/.htpasswd"

case "$1" in
  serve|garbage-collect|help|-*)
    set -- registry "$@"
  ;;
esac

if [ "$1" = 'registry' ]; then
  mkdir -p \
    "${REGISTRY_CONFIG}" \
    "${REGISTRY_DATA}"
  touch \
    "${REGISTRY_CONFIG_FILE}" \
    "${REGISTRY_HTPASSWD_FILE}"
  chown -R registry:registry \
    "${REGISTRY_CONFIG}" \
    "${REGISTRY_DATA}"

  if [ "$#" -eq 1 ]; then
    set -- "$@" serve "${REGISTRY_CONFIG_FILE}"
  fi

  if [ "${DISTRO}" = 'alpine' ]; then
    exec su-exec registry "$@"
  else 
    exec gosu registry "$@"
  fi
fi

exec "$@"