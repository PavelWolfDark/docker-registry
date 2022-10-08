# Docker Registry

## Build

### Ubuntu

```
docker buildx build \
  --build-arg BASE=ubuntu \
  --build-arg UBUNTU_VERSION=<version> \
  --build-arg REGISTRY_VERSION=<version> \
  --build-arg UID=<uid> \
  --build-arg GID=<gid> \
  --target deploy \
  -t registry:<version> .
```

### Alpine

```
docker buildx build \
  --build-arg BASE=alpine \
  --build-arg ALPINE_VERSION=<version> \
  --build-arg REGISTRY_VERSION=<version> \
  --build-arg UID=<uid> \
  --build-arg GID=<gid> \
  --target deploy \
  -t registry:<version>-alpine .
```