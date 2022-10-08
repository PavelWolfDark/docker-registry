ARG TARGETPLATFORM=linux/amd64
ARG BASE=ubuntu
ARG UBUNTU_VERSION=22.04
ARG ALPINE_VERSION=3.16
ARG REGISTRY_VERSION=2.8.1

FROM ubuntu:${UBUNTU_VERSION} AS ubuntu

FROM alpine:${ALPINE_VERSION} AS alpine

FROM ubuntu AS ubuntu-registry-2.8.1-build
ARG TARGETPLATFORM
ENV REGISTRY_VERSION=2.8.1
RUN \
  set -eux \
  && apt-get update \
  && apt-get install --no-install-recommends -y \
    ca-certificates \
    wget \
  && rm -rf /var/lib/apt/lists/*
WORKDIR /src
RUN \
  set -eux \
  && case "${TARGETPLATFORM}" in \
    linux/amd64) \
      arch='amd64' \
      && sha256='f1a376964912a5fd7d588107ebe5185da77803244e15476d483c945959347ee2' \
      ;; \
    linux/arm64) \
      arch='arm64' \
      && sha256='4c588c8e62c9a84f1eecfba4c842fe363b91be87fd42e3b5dac45148a2f46c52' \
      ;; \
    linux/arm/v6) \
      arch='armv6' \
      && sha256='d711b3b6e77f3acc7c89fad9310413ef145751ac702627dc1fa89991bf3b6104' \
      ;; \
    linux/arm/v7) \
      arch='armv7' \
      && sha256='d2f2180c1a847056f9c5dcfd1d6fda4c6086d126204541e0ed047c04f30a0f91' \
      ;; \
    linux/ppc64le) \
      arch='ppc64le' \
      && sha256='ca77cdfb7b1415869558c118b5e783bb9d695a74d8426a0bd8d8a39beb23fb85' \
      ;; \
    linux/s390x) \
      arch='s390x' \
      && sha256='3e505af15c562870869441d5d1f79988c3c666b9a4370894ecf2f064860b48ba' \
      ;; \
    *) \
      echo "Target platform '${TARGETPLATFORM}' is not supported." >&2 \
      && exit 1 \
      ;; \
  esac \
  && wget -O registry.tar.gz "https://github.com/distribution/distribution/releases/download/v${REGISTRY_VERSION}/registry_${REGISTRY_VERSION}_linux_${arch}.tar.gz" \
  && echo "${sha256} registry.tar.gz" | sha256sum -c - \
  && mkdir registry \
  && tar -xzvf registry.tar.gz -C registry
WORKDIR /dist
RUN \
  set -eux \
  && mkdir bin \
  && cp /src/registry/registry bin/

FROM scratch AS ubuntu-registry-2.8.1-release
COPY --from=ubuntu-registry-2.8.1-build /dist /

FROM ubuntu AS ubuntu-registry-2.8.1-deploy
ARG UID=1000
ARG GID=1000
RUN \
  set -eux \
  && apt-get update \
  && apt-get install --no-install-recommends -y \
    gosu \
  && rm -rf /var/lib/apt/lists/*
COPY --from=ubuntu-registry-2.8.1-release / /usr/
RUN \
  set -eux \
  && groupadd -g "${GID}" registry \
  && useradd -u "${UID}" -g registry registry
COPY config.yml /etc/registry/
VOLUME \
  /etc/registry \
  /var/lib/registry
EXPOSE 5000
COPY --chmod=700 docker-entrypoint.sh /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
CMD ["registry"]

FROM alpine AS alpine-registry-2.8.1-build
ARG TARGETPLATFORM
ENV REGISTRY_VERSION=2.8.1
WORKDIR /src
RUN \
  set -eux \
  && case "${TARGETPLATFORM}" in \
    linux/amd64) \
      arch='amd64' \
      && sha256='f1a376964912a5fd7d588107ebe5185da77803244e15476d483c945959347ee2' \
      ;; \
    linux/arm64) \
      arch='arm64' \
      && sha256='4c588c8e62c9a84f1eecfba4c842fe363b91be87fd42e3b5dac45148a2f46c52' \
      ;; \
    linux/arm/v6) \
      arch='armv6' \
      && sha256='d711b3b6e77f3acc7c89fad9310413ef145751ac702627dc1fa89991bf3b6104' \
      ;; \
    linux/arm/v7) \
      arch='armv7' \
      && sha256='d2f2180c1a847056f9c5dcfd1d6fda4c6086d126204541e0ed047c04f30a0f91' \
      ;; \
    linux/ppc64le) \
      arch='ppc64le' \
      && sha256='ca77cdfb7b1415869558c118b5e783bb9d695a74d8426a0bd8d8a39beb23fb85' \
      ;; \
    linux/s390x) \
      arch='s390x' \
      && sha256='3e505af15c562870869441d5d1f79988c3c666b9a4370894ecf2f064860b48ba' \
      ;; \
    *) \
      echo "Target platform '${TARGETPLATFORM}' is not supported." >&2 \
      && exit 1 \
      ;; \
  esac \
  && wget -O registry.tar.gz "https://github.com/distribution/distribution/releases/download/v${REGISTRY_VERSION}/registry_${REGISTRY_VERSION}_linux_${arch}.tar.gz" \
  && echo "${sha256}  registry.tar.gz" | sha256sum -c - \
  && mkdir registry \
  && tar -xzvf registry.tar.gz -C registry
WORKDIR /dist
RUN \
  set -eux \
  && mkdir bin \
  && cp /src/registry/registry bin/

FROM scratch AS alpine-registry-2.8.1-release
COPY --from=alpine-registry-2.8.1-build /dist /

FROM alpine AS alpine-registry-2.8.1-deploy
ARG UID=1000
ARG GID=1000
RUN \
  set -eux \
  && apk add --no-cache \
    su-exec
COPY --from=alpine-registry-2.8.1-release / /usr/
RUN \
  set -eux \
  && addgroup -g "${GID}" registry \
  && adduser -u "${UID}" -G registry -D registry
COPY config.yml /etc/registry/
VOLUME \
  /etc/registry \
  /var/lib/registry
EXPOSE 5000
COPY --chmod=700 docker-entrypoint.sh /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
CMD ["registry"]

FROM ubuntu AS ubuntu-registry-2.8.0-build
ARG TARGETPLATFORM
ENV REGISTRY_VERSION=2.8.0
RUN \
  set -eux \
  && apt-get update \
  && apt-get install --no-install-recommends -y \
    ca-certificates \
    wget \
  && rm -rf /var/lib/apt/lists/*
WORKDIR /src
RUN \
  set -eux \
  && case "${TARGETPLATFORM}" in \
    linux/amd64) \
      arch='amd64' \
      && sha256='7b2ebc3d67e21987b741137dc230d0f038b362ba21e02f226150ff5577f92556' \
      ;; \
    linux/arm64) \
      arch='arm64' \
      && sha256='16b9f497751bd3abe8b75d0f1538e2767ef3c536f4f11d05a312fb1767d43e85' \
      ;; \
    linux/arm/v6) \
      arch='armv6' \
      && sha256='5021831ba045a3cc409f6f62ab50c04db2c935a058eb53ce9d74a4dd5ba41102' \
      ;; \
    linux/arm/v7) \
      arch='armv7' \
      && sha256='ff659c577266662edb247d4719399fa1179bfcb90fb6006fc63396b7089c0f70' \
      ;; \
    linux/ppc64le) \
      arch='ppc64le' \
      && sha256='46fbd645b415c68222ee0e8043a91c27b6bb2ec2e0a568f663d1e78cc69d8cda' \
      ;; \
    linux/s390x) \
      arch='s390x' \
      && sha256='ebbd08228cf290ceef50ab542ae6087b66173b18fa84868210cbbdb458d11bd3' \
      ;; \
    *) \
      echo "Target platform '${TARGETPLATFORM}' is not supported." >&2 \
      && exit 1 \
      ;; \
  esac \
  && wget -O registry.tar.gz "https://github.com/distribution/distribution/releases/download/v${REGISTRY_VERSION}/registry_${REGISTRY_VERSION}_linux_${arch}.tar.gz" \
  && echo "${sha256} registry.tar.gz" | sha256sum -c - \
  && mkdir registry \
  && tar -xzvf registry.tar.gz -C registry
WORKDIR /dist
RUN \
  set -eux \
  && mkdir bin \
  && cp /src/registry/registry bin/

FROM scratch AS ubuntu-registry-2.8.0-release
COPY --from=ubuntu-registry-2.8.0-build /dist /

FROM ubuntu AS ubuntu-registry-2.8.0-deploy
ARG UID=1000
ARG GID=1000
RUN \
  set -eux \
  && apt-get update \
  && apt-get install --no-install-recommends -y \
    gosu \
  && rm -rf /var/lib/apt/lists/*
COPY --from=ubuntu-registry-2.8.0-release / /usr/
RUN \
  set -eux \
  && groupadd -g "${GID}" registry \
  && useradd -u "${UID}" -g registry registry
COPY config.yml /etc/registry/
VOLUME \
  /etc/registry \
  /var/lib/registry
EXPOSE 5000
COPY --chmod=700 docker-entrypoint.sh /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
CMD ["registry"]

FROM alpine AS alpine-registry-2.8.0-build
ARG TARGETPLATFORM
ENV REGISTRY_VERSION=2.8.0
WORKDIR /src
RUN \
  set -eux \
  && case "${TARGETPLATFORM}" in \
    linux/amd64) \
      arch='amd64' \
      && sha256='7b2ebc3d67e21987b741137dc230d0f038b362ba21e02f226150ff5577f92556' \
      ;; \
    linux/arm64) \
      arch='arm64' \
      && sha256='16b9f497751bd3abe8b75d0f1538e2767ef3c536f4f11d05a312fb1767d43e85' \
      ;; \
    linux/arm/v6) \
      arch='armv6' \
      && sha256='5021831ba045a3cc409f6f62ab50c04db2c935a058eb53ce9d74a4dd5ba41102' \
      ;; \
    linux/arm/v7) \
      arch='armv7' \
      && sha256='ff659c577266662edb247d4719399fa1179bfcb90fb6006fc63396b7089c0f70' \
      ;; \
    linux/ppc64le) \
      arch='ppc64le' \
      && sha256='46fbd645b415c68222ee0e8043a91c27b6bb2ec2e0a568f663d1e78cc69d8cda' \
      ;; \
    linux/s390x) \
      arch='s390x' \
      && sha256='ebbd08228cf290ceef50ab542ae6087b66173b18fa84868210cbbdb458d11bd3' \
      ;; \
    *) \
      echo "Target platform '${TARGETPLATFORM}' is not supported." >&2 \
      && exit 1 \
      ;; \
  esac \
  && wget -O registry.tar.gz "https://github.com/distribution/distribution/releases/download/v${REGISTRY_VERSION}/registry_${REGISTRY_VERSION}_linux_${arch}.tar.gz" \
  && echo "${sha256}  registry.tar.gz" | sha256sum -c - \
  && mkdir registry \
  && tar -xzvf registry.tar.gz -C registry
WORKDIR /dist
RUN \
  set -eux \
  && mkdir bin \
  && cp /src/registry/registry bin/

FROM scratch AS alpine-registry-2.8.0-release
COPY --from=alpine-registry-2.8.0-build /dist /

FROM alpine AS alpine-registry-2.8.0-deploy
ARG UID=1000
ARG GID=1000
RUN \
  set -eux \
  && apk add --no-cache \
    su-exec
COPY --from=alpine-registry-2.8.0-release / /usr/
RUN \
  set -eux \
  && addgroup -g "${GID}" registry \
  && adduser -u "${UID}" -G registry -D registry
COPY config.yml /etc/registry/
VOLUME \
  /etc/registry \
  /var/lib/registry
EXPOSE 5000
COPY --chmod=700 docker-entrypoint.sh /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
CMD ["registry"]

FROM ${BASE}-registry-${REGISTRY_VERSION}-build AS build
LABEL maintainer="cyberviking@darkwolf.team"

FROM ${BASE}-registry-${REGISTRY_VERSION}-release AS release
LABEL maintainer="cyberviking@darkwolf.team"

FROM ${BASE}-registry-${REGISTRY_VERSION}-deploy AS deploy
LABEL maintainer="cyberviking@darkwolf.team"