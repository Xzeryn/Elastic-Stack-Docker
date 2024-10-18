# elastic-stack-docker

This project creates a full Elastic stack in docker using `docker compose`.

It is based heavily on the work done by elkninja and adds local copies of the Elastic Package Registry (EPR) and Elastic Artifact Registry (EAR) containers for air-gapped environments.  

**WARNING:** The Elastic Package Registry image is ~15G and the Elastic Artifact Registry is ~4G in size.  

The EPR and EAR are integrated into the project, but not required for the Elastic stack to function.  

The project creates certs and stands up a 3-node Elasticsearch cluster, with Kibana and Fleet-Server already preconfigured.  It also stands up Logstash, Metricbeat, Filebeat, and a webapp APM example container using docker profiles.

Elasticsearch and Kibana are preconfigured and insturmented with APM.

---

## Stack Components

This project is broken into multiple docker compose files that build on each other, enabling multiple final configurations when the stack is brought up.

The `docker-compose.yml` is the base configuration of the stack. It generates the certs required and brings online the Elasticsearch nodes, Kibana, and Fleet/APM server. Therefore, it will always be used when issuing the `docker compose up` command.

The `air-gapped.yml` adds to the base configuration provided by the `docker-compose.yml` and provides the configuration changes and containers necessary to run the Elastic stack in an air-gapped environment.

The `elastic-maps-server.yml` adds a self-hosted maps server to the base configuration provided by the `docker-compose.yml` and provides the configuration changes and containers necessary to integrate it with the Elastic stack.

The `examples.yml` adds different functionality to the base configuration by bringing online different containers using docker's [profiles](#profiles) feature. (see below).  This file is included at the top of the `docker-compose.yml`.

The `stack-setup.yml` contains the code for the service that initially configures the Elastic stack and builds the certs for TLS encryption.

The `elastic-stack.yml` contains the basic configuration for core Elastic components (Elasticsearch, Kibana, and Agent).  These components are insturmented in the other compose files using the `extends` functionality of Docker Compose.

#### docker-compose.yml
- Elasticsearch (`es01`, `es02`, `es03`)
- Kibana (`kibana`) - accessible through https://localhost:5601/
- Fleet Server (`fleet-server`): Provides fleet and apm server functions

##
#### air-gapped.yml
- Elastic Package Registry (`epr`): Provides local copy of required elastic packages
- Elastic Artifact Registry (`ear`): Provides local copy of elastic binaries for agent install

##
#### elastic-maps-server.yml
- Elastic Maps Services (`ems-server`): Provides self-hosted maps service for the Elastic stack

##
#### examples.yml
- Machine Learning Node (`ml01`): Provides a dediated machine learning node to the cluster (default size is 8GB ram to allow for install of ELSER model)
- Metricbeat (`metricbeat01`): Provides stack monitoring in Kibana for Elasticsearch, Kibana, Logstash and Docker
- Filebeat (`filebeat01`): Provides the ability to ingest .log files into the cluster through the `/filebeat_ingest_data/` folder
- Logstash (`logstash01`): Provides the ability to test logstash and ingest data into the cluster through the `/logstash_ingest_data/` folder
- Web App (`webapp`): Demo web application that allows triggering of errors visible in the APM section of Kibana
- Elastic Agent Container (`container-agent`): Demo elastic agent container to test integrations.  It provides the ability to ingest files into the cluster through the `/agent_ingest_data/` folder, as well as through UDP port `9003` and TCP port `9004`. 

---

## Prerequisites

- Docker
- Docker Compose version `2.20.3` or greater

---

## Building Docker Images

Initially, internet access is required to build and pull the images.  The images are built or pulled automatically when docker compose executes.

---
## Initial Setup

Make a copy of the `env.template` file and name it `.env`.  Use the `.env` file to change settings.  You must set the `DOCKER_HOST_IP` variable to the correct host IP for the stack deployment to work

## Deploying the stack

The stack can be deployed in many configurations including air-gapped.  The various configurations can be enabled using the profiles feature of docker compose.

#### Usage:

To bring up the basic stack (Elasticsearch, Kibana and Fleet/APM Server):

```
docker compose up -d
```

To enable included examples reference the [profiles](#profiles) section below. For example, to bring up the stack with Metricbeat enabled for cluster monitoring use the following command:

```
docker compose --profile monitoring up -d
```

Multiple profiles can also be chained together.
The following command enables Metricbeat, Logstash and an APM example.

```
docker compose --profile monitoring --profile logstash --profile apm up -d
```

**NOTE:** _You can view the configuration that docker compose will apply prior to starting the project by using the `config` parameter instead of `up -d`._ 

Examples:

```
docker compose config
```
or
```
docker compose --profile monitoring config
```

---

## Running Air-Gapped 

The `air-gapped.yml` configures the stack to utilize local Elastic Package Registry (EPR) and Elastic Artifact Registry (EAR) services.  These services are required in an air-gapped environment to install integrations and binaries required by the stack.

Using the air-gapped configuration requires chaining multiple docker-compose files due to configuration changes that need to be made to the base configuration.  This is done using the `-f <filename>` flag when executing the `docker compose` command.

#### Usage:
To bring up the basic air-gapped stack (Elasticsearch, Kibana, Fleet/APM Server, EAR, and EPR):
```
docker compose -f docker-compose.yml -f air-gapped.yml up -d
```
Profiles may also be used when using air-gapped.  Using the same metricbeat example above, the command would be:
```
docker compose -f docker-compose.yml -f air-gapped.yml --profile monitoring up -d
```
---

## Running Self-hosted Elastic Maps Service

The `elastic-maps-server.yml` configures the stack to utilize a self-hosted Elastic Maps Service (EMS) server.  This service would be required in an air-gapped environment where there is a use case to use maps in dashboards.

Using the EMS configuration requires chaining multiple docker-compose files due to configuration changes that need to be made to the base configuration.  This is done using the `-f <filename>` flag when executing the `docker compose` command.

#### Usage:
To bring up the basic Elastic Maps Service stack (Elasticsearch, Kibana, Fleet/APM Server, EMS):
```
docker compose -f docker-compose.yml -f elastic-maps-server.yml up -d
```
To bring up the basic air-gapped stack with Elastic Maps Service (Elasticsearch, Kibana, Fleet/APM Server, EAR, and EPR):
```
docker compose -f docker-compose.yml -f air-gapped.yml -f elastic-maps-server.yml up -d
```
Profiles may also be used when using the Elastic Maps Service.  Using the same metricbeat example above, the command would be:
```
docker compose -f docker-compose.yml -f elastic-maps-server.yml --profile monitoring up -d
```
---

## Bring down the stack

To bring down the stack without purging the data volumes, execute the same command (including `-f <filename>` and `--profile` flags) but replace the `up -d` with `down`

```
docker compose down
```
or
```
docker compose --profile monitoring down
```
or
```
docker compose -f docker-compose.yml -f air-gapped.yml --profile monitoring down
```

To bring down the stack and remove the data volumes, add `-v` to your command

```
docker compose down -v
```
or
```
docker compose --profile monitoring down -v
```
or
```
docker compose -f docker-compose.yml -f air-gapped.yml --profile monitoring down -v
```

---

## Profiles

Profiles are enabled to configure different services for demo/example purposes.

To use a profile add `--profile <name>` to the docker compose command.  Each profile enabled but have its own `--profile <name>`, you cannot use a list of comma separated profile names.

Usage Examples:
- `docker compose --profile monitoring --profile apm up -d`
- `docker compose -f docker-compose.yml -f air-gapped.yml --profile monitoring --profile apm up -d`

### Available Profiles

**Machine Learning**
- Configures and adds a dedicated machine learning node to the Elastic Stack
- Default configuration is set to 8GB of RAM to allow for the install of the ELSER model
- The amount of memory can be changed by editing the `ML_MEM_LIMIT` variable in the `.env` file
- Functionality is limited unless you enable the _trial_ or provide a _license_
- User `--profile ml` in your docker compose startup command to enable

**Monitoring** 
- Configures metricbeat in the cluster and performs monitoring of the Elastic stack
- Use `--profile monitoring` in your docker compose startup command to enable

**Filebeat**
- Configures filebeat in the cluster to ingest data from the `filebeat_ingest_data` folder
- Drop .log files in this folder to ingest 
- Filebeat is also configured to pull logs for all docker containers (visible in the Kibana Logs Stream viewer)
- Use `--profile filebeat` in your docker compose startup command to enable

**Logstash**
- Configures logstash in the cluster to ingest data from the `logstash_ingest_data` folder
- Edit the `logstash.conf` file to try out different ingest pipelines
- Use `--profile logstash` in your docker compose startup command to enable

**APM** 
- Configures sample web application in the cluster that is insturmented with the elastic APM agent
- The webapp allows for the generation of error and messages that can be seen in the Kibana APM section
- Access the webapp through http://localhost:8000
- Use `--profile apm` in your docker compose startup command to enable

**Agent** 
- Configures an Elastic Agent container in the cluster registered in Fleet with 3 custom log integrations enabled
- Data ingested in through this container may not be parsed and requires modifying the integration setting or ingest pipeline to parse into the format desired.
- The agent container allows for experimentation with agent integrations in the Kibana Fleet section
- Use `--profile agent` in your docker compose startup command to enable
- Methods to ingest data:

1. Using Custom Logs integraton: 
    * Drop log files in the `agent_ingest_data` folder to ingest logs using the Custom Logs integration.  
    * The data will be in the `messages` field of the `logs-generic-*` index. 
    * Modify the processor field of the integration (in the settings) or the `logs-generic-*` pipeline to extract and format the data.
2. Using the Custom UDP Logs integration:
    * Send logs over UDP to the docker host IP to the port designated in the `.env` file (default: `9003`)
    * The integration has syslog parsing enabled by default
    * Changes can be made to the `logs-udp.generic-*` ingest pipeline for additional formatting or to the settings of the integration
3. Using the Custom TCP Logs integration:
    * Send logs over TCP to the docker host IP to the port designated in the `.env` file (default: `9004`)
    * The integration has syslog parsing enabled by default
    * Changes can be made to the `logs-TCP.generic-*` ingest pipeline for additional formatting or to the settings of the integration

- [Help defining processors in integration settings](https://www.elastic.co/guide/en/fleet/current/elastic-agent-processor-configuration.html)
- [Help configuring ingest pipelines](https://www.elastic.co/guide/en/elasticsearch/reference/current/ingest.html)

---

## References

- [Getting Started with the Elastic Stack and Docker Compose](https://www.elastic.co/blog/getting-started-with-the-elastic-stack-and-docker-compose) or visit it's [GitHub repo](https://github.com/elkninja/elastic-stack-docker-part-one)
- [Getting Started with the Elastic Stack and Docker Compose: Part 2](https://www.elastic.co/blog/getting-started-with-the-elastic-stack-and-docker-compose-part-2) or visit it's [GitHub repo](https://github.com/elkninja/elastic-stack-docker-part-two)

---

## Resources:

### Fleet/Agent

- Overview: https://www.elastic.co/guide/en/fleet/current/fleet-overview.html
- Policy Creation, No UI: https://www.elastic.co/guide/en/fleet/current/create-a-policy-no-ui.html
- Adding Fleet On-Prem: https://www.elastic.co/guide/en/fleet/current/add-fleet-server-on-prem.html
- Agent in a Container: https://www.elastic.co/guide/en/fleet/current/elastic-agent-container.html
- Air Gapped: https://www.elastic.co/guide/en/fleet/current/air-gapped.html
- Secure Fleet: https://www.elastic.co/guide/en/fleet/current/secure-connections.html

### APM:

- APM: https://www.elastic.co/guide/en/apm/guide/current/upgrade-to-apm-integration.html
- On Prem: https://www.elastic.co/guide/en/apm/guide/current/apm-integration-upgrade-steps.html
- Fleet-Managed: https://www.elastic.co/guide/en/fleet/8.8/install-fleet-managed-elastic-agent.html
- Queue Full Error: https://www.elastic.co/guide/en/apm/server/current/common-problems.html#queue-full

### Add more Elasticsearch nodes or configure for production

https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#docker-compose-file
