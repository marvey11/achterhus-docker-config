# Achterhus Docker Configurations

This repository contains the relevant `docker-compose.yaml` configurations
running on the `achterhus` home server.

At this point, there are configurations for:

* the SmartHome/Home Assistant/ESPHome containers
* the Samba/NAS configuration for backups
* the centralised `achterhus` gateway
* the PostgreSQL and `pgadmin` containers for applications requiring a database
* the service telemetry application, consisting of [Telemetry API](https://github.com/marvey11/achterhus-telemetry-api) and [Telemetry Dashboard](https://github.com/marvey11/achterhus-telemetry-dashboard)
* the [service orchestrator](https://github.com/marvey11/achterhus-service-orchestrator) running Dockerised worker services from
  * the [Achterhus Server Tools](https://github.com/marvey11/achterhus-server-tools) -- a collection of Bash worker scripts specifically for the Achterhus home server
  * the [Achterhus Utilities](https://github.com/marvey11/achterhus-utilities) -- a collection of Python workers specifically for the Achterhus home server
  * the [Codescape Utilities](https://github.com/marvey11/codescape-utilities) -- a collection of Python workers in the Codescape namespace that are not tied as closely to the Achterhus home server

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
