# elastic-stack-docker

This project creates a full Elastic stack in docker using `docker compose`.

It is based heavily on the work done by elkninja and adds local copies of the Elastic Package Registry (EPR) and Elastic Artifact Registry (EAR) containers for air-gapped environments.  

**WARNING:** The Elastic Package Registry image is ~15G and the Elastic Artifact Registry is ~4G in size.  

The EPR and EAR are integrated into the project, but not required for the Elastic stack to function.  

The project creates certs and stands up a 3-node Elasticsearch cluster, with Kibana and Fleet-Server already preconfigured.  It also stands up Logstash, Metricbeat, Filebeat, and a webapp APM example container using docker profiles.

Elasticsearch and Kibana are preconfigured and insturmented with APM.

---

## Stack Components

- Elasticsearch (`es01`, `es02`, `es03`)
- Kibana (`kibana`) - accessible through https://localhost:5601/
- Fleet Server (`fleet-server`): Provides fleet and apm server functions
##
- Elastic Package Registry (`epr`): Provides local copy of required elastic packages
- Elastic Artifact Registry (`ear`): Provides local copy of elastic binaries for agent install
##
- Metricbeat (`metricbeat01`): Provides stack monitoring in Kibana for Elasticsearch, Kibana, Logstash and Docker
##
- Filebeat (`filebeat01`): Provides the ability to ingest .log files into the cluster through the `/filebeat_ingest_data/` folder
- Logstash (`logstash01`): Provides the ability to test logstash and ingest data into the cluster through the `/logstash_ingest_data/` folder
##
- Web App (`webapp`): Demo web application that allows triggering of errors visible in the APM section of Kibana
- Elastic Agent Container (`container-agent`): Demo elastic agent container to test integrations

---

## Prerequisites

- Docker

---

## Building Docker Images

Initially, internet access is required to build and pull the images.  The images are built or pulled automatically when docker compose executes.

---

## Deploying the stack

Make a copy of the `env.template` file and name it `.env`.  Use the `.env` file to change settings.  You must set the `DOCKER_HOST_IP` variable to the correct host IP for the stack deployment to work

There are two ways to bring up the stack, with internet connectivity and air-gapped.
To bring up the stack run `docker compose up -d`

To bring up the stack setup for an air-gapped configuration run `docker compose -f docker-compose.yml -f air-gapped.yml up -d`

---

## Bring down the stack

To bring down the stack without purging the data run `docker compose down`
To bring down the stack and remove the data run `docker compose down -v`

To bring down the stack running in the air-gapped configuration run `docker compose -f docker-compose.yml -f air-gapped.yml down`
To bring down the stack running in the air-gapped configuration and remove the data run `docker compose -f docker-compose.yml -f air-gapped.yml down -v`

---

## Running Air-Gapped 

The `air-gapped.yml` configures the stack to utilize local Elastic Package Registry (EPR) and Elastic Artifact Registry (EAR) services.  These services are required in an air-gapped environment to install integrations and binaries required by the stack.

---

## Profiles

Profiles are enabled to configure different services for demo/example purposes.

To use a profile add `--profile <name>` to the docker compose command.  Each profile enabled but have its own `--profile <name>`, you cannot use a list of comma separated profile names.

Usage Examples:
- `docker compose --profile monitoring --profile apm up -d`
- `docker compose -f docker-compose.yml -f air-gapped.yml --profile monitoring --profile apm up -d`

### Available Profiles

**Monitoring** 
- Configures metricbeat in the cluster and performs monitoring of the Elastic stack
- Use `--profile monitoring` in your docker compose startup command to enable

**Filebeat**
- Configures filebeat in the cluster to ingest data from the filebeat_ingest_data folder
- Drop .log files in this folder to ingest 
- Filebeat is also configured to pull logs for all docker containers (visible in the Kibana Logs Stream viewer)
- Use `--profile filebeat` in your docker compose startup command to enable

**Logstash**
- Configures logstash in the cluster to ingest data from the logstash_ingest_data folder
- Edit the `logstash.conf` file to try out different ingest pipelines
- Use `--profile logstash` in your docker compose startup command to enable

**APM** 
- Configures sample web application in the cluster that is insturmented with the elastic APM agent
- The webapp allows for the generation of error codes and messages that can be seen in the Kibana APM section
- Access the webapp through http://localhost:8000
- Use `--profile apm` in your docker compose startup command to enable

**Agent** 
- Configures an Elastic Agent container in the cluster registered in Fleet with only the system integration enabled
- The agent container allows for experimentation with agent integrations in the Kibana Fleet section
- Use `--profile agent` in your docker compose startup command to enable


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