# Lightweight LGOGDownloader Docker image

![lgogdownloader version](https://img.shields.io/badge/lgogdownloader-v3.17-informational.svg?logo=gogdotcom)
![alpine version](https://img.shields.io/badge/alpine-v3.21-informational.svg?logo=alpinelinux)

This repository contains the code of a lightweight Docker image for [LGOGDownloader](https://github.com/Sude-/lgogdownloader) which is unofficial open source downloader for [GOG.com](https://www.gog.com/).

## Features

- **Lightweight**. Image size is up to 32.1 MB.
- **Secure**. Runs as a non-root user, uses checksum verification for lgogdownloader and includes updated ca-certificates.
- **Persistent**. Uses volumes for configuration and downloads.
- **Flexibility**. Supports proxying arguments in lgogdownloader.
- **Health checks**. Includes built-in container health monitoring.

## Usage examples

### Show help

```bash
docker run -it --rm vsayapin/lgogdownloader --help
```

### Login

```bash
docker run -it --rm \
  -v ~/.config/lgogdownloader:/config/lgogdownloader \
  vsayapin/lgogdownloader --login
```

### Listing games

```bash
docker run -it --rm \
  -v ~/.config/lgogdownloader:/config/lgogdownloader \
  vsayapin/lgogdownloader --list
```

### Download all files

```bash
docker run -it --rm \
  -v ~/.config/lgogdownloader:/config/lgogdownloader \
  -v ~/.cache/lgogdownloader:/cache/lgogdownloader \
  -v ~/Downloads/GOG:/downloads \
  vsayapin/lgogdownloader --download
```

### Create named container and repair all files

```bash
docker run -it --name gog-repair \
  -v ~/.config/lgogdownloader:/config/lgogdownloader \
  -v ~/.cache/lgogdownloader:/cache/lgogdownloader \
  -v ~/Downloads/GOG:/downloads \
  vsayapin/lgogdownloader --download
```

### Reuse created container

```bash
docker start -ai gog-repair
```

## Volumes

|Container path|Purpose|
|-|-|
|`/config/lgogdownloader`|Configuration files|
|`/cache/lgogdownloader`|Cache and temporary files|
|`/downloads`|Download directory|

Volumes should be mounted to persist downloaded games and configurations across container runs.

## Image architecture

Dual-stage build ensures security and minimal footprint:
1. **Build stage**. Compiles lgogdownloader from source in an Alpine Linux environment;
2. **Runtime stage**. Creates a minimal runtime image with only the necessary dependencies.

## ⚠️ Troubleshooting

### Permission denied errors

If you encounter permission errors like:
```
Error: boost::filesystem::create_directories: Permission denied [system:13]: "/cache/lgogdownloader/xml", "/cache/lgogdownloader/xml"
```

#### Solution: Fix host directory ownership

Check permissions for directories mounted to the container:
```bash
ls -la ~/.config/lgogdownloader
ls -la ~/.cache/lgogdownloader
ls -la ~/Downloads/GOG
```

Set correct ownership (using your UID and GUI, typically 1000):
```bash
sudo chown -R $(id -u):$(id -g) ~/.config/lgogdownloader ~/.cache/lgogdownloader ~/Downloads/GOG
```

### WSL2/Docker Desktop/NTFS volume "Permission denied"

When using Windows paths with WSL2, you might encounter errors like:
```
terminate called after throwing an instance of 'boost::filesystem::filesystem_error'
  what(): boost::filesystem::create_directories: Permission denied [system:13]: "/mnt/e/games/age_of_wonders_4", "/mnt/e"
```

#### Solution: Use Windows-style paths for volumes

```bash
-v /e/games:/downloads
or
-v e:/games:/downloads
or
-v "E:\games":/downloads
```

## Links

- [Official lgogdownloader GitHub Repository](https://github.com/Sude-/lgogdownloader)
- [Docker image source GitHub Repository](https://github.com/v-sayapin/docker-lgogdownloader)
- [Docker Hub Repository](https://hub.docker.com/r/vsayapin/lgogdownloader)
