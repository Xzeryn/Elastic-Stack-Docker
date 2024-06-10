# elastic-stack-docker

This project creates a full Elastic stack in docker using `docker compose`.

It is based heavily on the work done by elkninja and adds local copies of the Elastic Package Registry (EPR) and Elastic Artifact Registry (EAR) containers for air-gapped environments.  

**WARNING:** The Elastic Package Registry image is ~15G and the Elastic Artifact Registry is ~4G in size.  

The EPR and EAR are integrated into the project, but not required for the Elastic stack to function.  To disable the local EPR/EAR and use the official registries on the elastic.co site, you will need to comment out sections of various files.  (Instructions below) 

The project creates certs and stands up a 3-node Elasticsearch cluster, with Kibana and Fleet-Server already preconfigured.  It also stands up Logstash, Metricbeat, Filebeat, and a webapp APM example container.

Elasticsearch and Kibana are preconfigured and insturmented with APM

---

## Stack Components

- Elasticsearch (`es01`, `es02`, `es03`)
- Kibana (`kibana`)
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

Edit the .env file to change settings.  You must set the `DOCKER_HOST_IP` variable to the correct host IP for the stack deployment to work

To bring up the stack run `docker compose up -d`

---

## Bring down the stack

To bring down the stack without purging the data run `docker compose down`
To bring down the stack and remove the data run `docker compose down -v`

---

## Running without EPR and EAR

### Removing references to the Elastic Package Registry (EPR)

Comment out the sections between the `##### Comment out if EPR is not desired #####` and `##### End EPR Comment #####` markers.  

There are 3 sections for the EPR in the `docker-compose.yml`:

- Under `services`, comment out the entire `epr` section.
- Under `services` -> `kibana` -> `depends_on`, comment out the `epr` section.
- Under `services` -> `kibana` -> `environment`, comment out the `- XPACK_FLEET_REGISTRYURL=` line.

### Removing references to the Elastic Artifact Registry (EAR)

Comment out the section between the `##### Comment out if EAR is not desired #####` and `##### End EAR Comment #####` markers.

There is 1 section for the EAR in the `docker-compose.yml`:

- Under `services`, comment out the entire `ear` section.
- Under `services` -> `fleet-server` -> `volumes`, comment out the `- ./fleet-startup.sh:/usr/share/elastic-agent/fleet-startup.sh` line.

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