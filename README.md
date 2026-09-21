# Achterhus Docker Configurations

This repository contains the relevant `docker-compose.yaml` configurations
running on the `achterhus` home server.

At this point, there are configurations for:

* the SmartHome/Home Assistant/ESPHome containers
* the Samba/NAS configuration for backups
* the centralised `achterhus` gateway
* the service telemetry application
* the server tools
* the PostgreSQL and `pgadmin` containers for applications requiring a database

## Docker Network

There is a single unified Docker network for all applications:

```bash
docker network create achterhus-network
```

Each new `docker-compose.yaml` which will run an application in the same
network will now use the following `networks` configuration:

```yaml
networks:
  achterhus-network:
    external: true
```
