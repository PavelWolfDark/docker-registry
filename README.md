# Docker Registry

## Supported versions

- 2.8.1
- 2.8.0

## Pull

### Docker Hub

```
docker pull dwreg/registry
docker pull dwreg/registry:<version>
```

### Darkwolf Registry

```
docker pull registry.darkwolf.cloud/registry
docker pull registry.darkwolf.cloud/registry:<version>
```

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