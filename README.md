# Achterhus Docker Config

This repository contains the relevant `docker-compose.yaml` configurations running on the `achterhus` server.

At this point, we have configurations for the SmartHome/Home Assistant/ESPHome containers and the Samba/NAS configuration for backups.

# Docker Network

We've switched to using a single Docker network for new applications:

```shell
docker network create achterhus-network
```

Each new `docker-compose.yaml` which will run an application in the same network will now use the following `networks` configuration:

```yaml
networks:
  achterhus-network:
    external: true
```
