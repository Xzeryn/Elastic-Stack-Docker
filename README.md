# Elastic Stack Docker

A comprehensive Docker Compose project that provides a production-ready Elastic Stack (ELK Stack) deployment with multiple configuration options and advanced features.

## Overview

This project provides a complete Elastic Stack deployment using Docker Compose, featuring Elasticsearch, Kibana, Fleet Server, and various optional components. It's designed for development, testing, and production use with enterprise-grade security, monitoring, and scalability features.

## What is the Elastic Stack?

This project creates a full Elastic stack in docker using `docker compose`.

It is based heavily on the work done by elkninja and adds local copies of the Elastic Package Registry (EPR) and Elastic Artifact Registry (EAR) (including the Elastic Defend integration policy artifacts) containers for air-gapped environments.  

**WARNING:** The Elastic Package Registry image is ~15G and the Elastic Artifact Registry is ~8G in size.  

The EPR and EAR are integrated into the project, but not required for the Elastic stack to function.  

The project creates certs and stands up a 3-node Elasticsearch cluster, with Kibana and Fleet-Server already preconfigured. It also stands up Logstash, Metricbeat, Filebeat, and a webapp APM example container using docker profiles.

Elasticsearch and Kibana are preconfigured and instrumented with APM.

The Elastic Stack (formerly known as the ELK Stack) is a collection of open-source tools for data ingestion, enrichment, storage, analysis, and visualization:

- **Elasticsearch**: Distributed search and analytics engine
- **Kibana**: Data visualization and management platform
- **Fleet Server**: Centralized agent management for Elastic Agents
- **Elastic Agent**: Unified data collection and shipping agent
- **Beats**: Lightweight data shippers (Filebeat, Metricbeat, etc.)
- **Logstash**: Data processing pipeline

## Project Components

This project is broken into multiple docker compose files that build on each other, enabling multiple final configurations when the stack is brought up.

The `docker-compose.yml` is the base configuration of the stack. It generates the certs required and brings online the Elasticsearch nodes, Kibana, and Fleet/APM server. Therefore, it will always be used when issuing the `docker compose up` command.

The `air-gapped.yml` adds to the base configuration provided by the `docker-compose.yml` and provides the configuration changes and containers necessary to run the Elastic stack in an air-gapped environment.

The `elastic-maps-server.yml` adds a self-hosted maps server to the base configuration provided by the `docker-compose.yml` and provides the configuration changes and containers necessary to integrate it with the Elastic stack.

The `examples.yml` adds different functionality to the base configuration by bringing online different containers using docker's [profiles](#profiles) feature. This file is included at the top of the `docker-compose.yml`.

The `stack-setup.yml` contains the code for the service that initially configures the Elastic stack and builds the certs for TLS encryption.

The `elastic-stack.yml` contains the basic configuration for core Elastic components (Elasticsearch, Kibana, and Agent). These components are instrumented in the other compose files using the `extends` functionality of Docker Compose.

### Core Services

#### 1. Elasticsearch Cluster (`es01`, `es02`, `es03`)

- **Purpose**: Distributed search and analytics engine
- **Configuration**: 3-node cluster with master, data, ingest, and transform capabilities
- **Security**: TLS/SSL encryption, X-Pack security enabled
- **Features**: 
  - Hot/warm/cold data lifecycle management
  - Machine learning capabilities
  - Remote cluster client support
  - Transform functionality
- **Access**: Preconfigured and instrumented with APM

#### 2. Kibana

- **Purpose**: Web interface for data visualization and management
- **Features**: 
  - Fleet management for Elastic Agents
  - Dashboard creation and visualization
  - Index management and monitoring
  - SSL/TLS encryption
- **Access**: https://localhost:5601/ (preconfigured and instrumented with APM)

#### 3. Fleet Server (`fleet-server`)

- **Purpose**: Centralized agent management and communication hub
- **Features**:
  - Agent enrollment and policy management
  - Secure communication with Elasticsearch
  - Health monitoring and status reporting
  - APM server functions
- **Functionality**: Provides fleet and APM server functions

#### 4. Elastic Agent

- **Purpose**: Unified data collection and shipping
- **Capabilities**:
  - Docker container monitoring
  - System metrics collection
  - Log aggregation
  - Integration with Fleet Server

### Optional Services (Profiles)

Profiles are enabled to configure different services for demo/example purposes. To use a profile add `--profile <name>` to the docker compose command. Each profile enabled must have its own `--profile <name>`, you cannot use a list of comma separated profile names.

#### Machine Learning Profile (`--profile ml`)

- **ml01**: Dedicated machine learning node to the Elastic Stack
- **Configuration**: Default configuration is set to 8GB of RAM to allow for the install of the ELSER model
- **Memory**: The amount of memory can be changed by editing the `ML_MEM_LIMIT` variable in the `.env` file
- **Functionality**: Limited unless you enable the _trial_ or provide a _license_
- **Use Case**: Training and running ML models, ELSER model support

#### Frozen Tier & Searchable Snapshots Profile (`--profile frozen`)

- **fz01**: Dedicated frozen node to the Elastic Stack
- **minio**: S3 storage container to be used with Frozen Tier searchable snapshots
- **minio-setup**: Configures MinIO based on values in .env file
- **Use Case**: Cost-effective long-term data retention, searchable snapshots

#### Monitoring Profile (`--profile monitoring`)

- **metricbeat01**: Provides stack monitoring in Kibana for Elasticsearch, Kibana, Logstash and Docker
- **Use Case**: Infrastructure monitoring, performance metrics, cluster health

#### Filebeat Profile (`--profile filebeat`)

- **filebeat01**: Provides the ability to ingest .log files into the cluster through the `/filebeat_ingest_data/` folder
- **Features**: Filebeat is also configured to pull logs for all docker containers (visible in the Kibana Logs Stream viewer)
- **Use Case**: Application log collection, Docker container logs

#### Logstash Profile (`--profile logstash`)

- **logstash01**: Provides the ability to test logstash and ingest data into the cluster through the `/logstash_ingest_data/` folder
- **Configuration**: Edit the `logstash.conf` file to try out different ingest pipelines
- **Use Case**: Complex log parsing, data enrichment, custom processing pipelines

#### APM Profile (`--profile apm`)

- **webapp**: Demo web application that allows triggering of errors visible in the APM section of Kibana
- **Access**: Access the webapp through `http://localhost:8000`
- **Use Case**: Application performance monitoring, APM testing and demonstration

#### Agent Profile (`--profile agent`)

- **container-agent**: Demo elastic agent container to test integrations
- **Features**: 
  - Provides the ability to ingest files into the cluster through the `/agent_ingest_data/` folder
  - UDP port `9003` and TCP port `9004` for syslog ingestion
  - Registered in Fleet with 3 custom log integrations enabled
- **Use Case**: Individual container monitoring, syslog ingestion, agent integration experimentation
- **Data Ingestion Methods**:
  1. **Custom Logs Integration**: Drop log files in the `agent_ingest_data` folder to ingest logs using the Custom Logs integration. The data will be in the `messages` field of the `logs-generic-*` index. Modify the processor field of the integration (in the settings) or the `logs-generic-*` pipeline to extract and format the data.
  2. **Custom UDP Logs Integration**: Send logs over UDP to the docker host IP to the port designated in the `.env` file (default: `9003`). The integration has syslog parsing enabled by default. Changes can be made to the `logs-udp.generic-*` ingest pipeline for additional formatting or to the settings of the integration.
  3. **Custom TCP Logs Integration**: Send logs over TCP to the docker host IP to the port designated in the `.env` file (default: `9004`). The integration has syslog parsing enabled by default. Changes can be made to the `logs-TCP.generic-*` ingest pipeline for additional formatting or to the settings of the integration.

#### MCP Profile (`--profile mcp`)

- **elastic-mcp-server**: Provides a MCP server configured as streamable-HTTP to communicate with the Elastic cluster
- **Implementation**: Implementation of the MCP Server can be followed on its [GitHub Repo](https://github.com/elastic/mcp-server-elasticsearch)
- **Configuration**: The MCP configuration follows this [blog post](https://www.elastic.co/search-labs/blog/model-context-protocol-elasticsearch) you can use as a reference
- **Endpoint**: MCP server endpoint is available at `http://localhost:8090/mcp`
- **Use Case**: AI/ML model integration, LLM client communication

#### Elastic Maps Profile

- **ems-server**: Elastic Maps Service for geographic data visualization
- **Use Case**: Geospatial data analysis, map visualizations, self-hosted maps in air-gapped environments

### Air-Gapped Deployment

- **epr**: Elastic Package Registry (`epr`) - Provides local copy of required elastic packages
- **ear**: Elastic Artifact Registry (`ear`) - Provides local copy of elastic binaries for agent install
- **Use Case**: Secure environments without internet access
- **Warning**: The Elastic Package Registry image is ~15G and the Elastic Artifact Registry is ~8G in size
- **Integration**: The EPR and EAR are integrated into the project, but not required for the Elastic stack to function

## Prerequisites

- **Docker**: Version `24.10.6` or higher
- **Docker Compose**: Version `2.22.0` or greater

### System Requirements

- **Operating System**: Linux (WSL2 supported), macOS, Windows
- **Memory**: Minimum 8GB RAM (16GB+ recommended)
- **Storage**: At least 50GB available disk space
- **Kernel Settings**: `vm.max_map_count` must be at least 262144

### Docker Compose Commands

The project uses Docker Compose v2 syntax:

```bash
# Check Docker Compose version
docker compose version

# Basic commands
docker compose up -d          # Start services in background
docker compose down           # Stop and remove services
docker compose ps             # List running services
docker compose logs           # View service logs
```

### Required Environment Variables

Create a `.env` file based on `env.template` with the following essential variables:

```bash
# Stack Configuration
STACK_VERSION=8.17.0
CLUSTER_NAME=docker-cluster
LICENSE=basic

# Security
ELASTIC_PASSWORD=your_secure_password
KIBANA_PASSWORD=your_kibana_password
ENCRYPTION_KEY=your_32_character_encryption_key

# Network Configuration
DOCKER_HOST_IP=your_host_ip_address
ES_PORT=9200
KIBANA_PORT=5601
FLEET_PORT=8220
APMSERVER_PORT=8200

# Memory Limits
ES_MEM_LIMIT=2g
KB_MEM_LIMIT=1g
FLEET_MEM_LIMIT=512m
```

## Initial Setup

Make a copy of the `env.template` file and name it `.env`. Use the `.env` file to change settings. You must set the `DOCKER_HOST_IP` variable to the correct host IP for the stack deployment to work.

## Building Docker Images

Initially, internet access is required to build and pull the images. The images are built or pulled automatically when docker compose executes.

## Quick Start

### 1. Basic Setup

```bash
# Clone the repository
git clone <repository-url>
cd Elastic-Stack-Docker

# Copy environment template
cp env.template .env

# Edit .env file with your configuration
nano .env

# Deploy the stack
docker compose up -d
```

### 2. Access the Stack

- **Elasticsearch**: https://localhost:9200
- **Kibana**: https://localhost:5601
- **Fleet Server**: https://localhost:8220

**Default Credentials**: `elastic` / `[ELASTIC_PASSWORD from .env]`

## Deploying the Stack

The stack can be deployed in many configurations including air-gapped. The various configurations can be enabled using the profiles feature of docker compose.

### Basic Stack

```bash
docker compose up -d
```

Deploys core services: Elasticsearch cluster, Kibana, Fleet Server, and Elastic Agent.

### With Machine Learning

```bash
docker compose --profile ml up -d
```

Adds dedicated ML node for machine learning capabilities.

### With Monitoring

```bash
docker compose --profile monitoring up -d
```

Adds Metricbeat for comprehensive stack monitoring.

### With Log Ingestion

```bash
docker compose --profile filebeat --profile logstash up -d
```

Adds Filebeat and Logstash for advanced log processing.

### Air-Gapped Deployment

```bash
docker compose -f docker-compose.yml -f air-gapped.yml up -d
```

Deploys with offline package and artifact registries.

### Multiple Profiles

```bash
docker compose --profile ml --profile monitoring --profile frozen up -d
```

Combines multiple optional services.

**NOTE:** You can view the configuration that docker compose will apply prior to starting the project by using the `config` parameter instead of `up -d`.

Examples:

```bash
docker compose config
```

or

```bash
docker compose --profile monitoring config
```

Multiple profiles can also be chained together. The following command enables Metricbeat, Logstash and an APM example:

```bash
docker compose --profile monitoring --profile logstash --profile apm up -d
```

## Running Air-Gapped

The `air-gapped.yml` configures the stack to utilize local Elastic Package Registry (EPR) and Elastic Artifact Registry (EAR) services. These services are required in an air-gapped environment to install integrations and binaries required by the stack.

Using the air-gapped configuration requires chaining multiple docker-compose files due to configuration changes that need to be made to the base configuration. This is done using the `-f <filename>` flag when executing the `docker compose` command.

### Usage:

To bring up the basic air-gapped stack (Elasticsearch, Kibana, Fleet/APM Server, EAR, and EPR):

```bash
docker compose -f docker-compose.yml -f air-gapped.yml up -d
```

Profiles may also be used when using air-gapped. Using the same metricbeat example above, the command would be:

```bash
docker compose -f docker-compose.yml -f air-gapped.yml --profile monitoring up -d
```

Multiple profiles can also be chained together. The following command enables Metricbeat, Logstash and an APM example:

```bash
docker compose -f docker-compose.yml -f air-gapped.yml --profile monitoring --profile logstash --profile apm up -d
```

If using the Elastic Defend integration in the air-gapped configuration, you will need to configure the advanced settings of the Elastic Defend integration to point to the EAR server. The artifacts are built into the server in under: `<url>/downloads/endpoint/`

Please reference this article for integration settings required for Elastic Defend in an air-gapped environment: https://www.elastic.co/guide/en/security/current/offline-endpoint.html

## Running Self-hosted Elastic Maps Service

The `elastic-maps-server.yml` configures the stack to utilize a self-hosted Elastic Maps Service (EMS) server. This service would be required in an air-gapped environment where there is a use case to use maps in dashboards.

Using the EMS configuration requires chaining multiple docker-compose files due to configuration changes that need to be made to the base configuration. This is done using the `-f <filename>` flag when executing the `docker compose` command.

### Usage:

To bring up the basic Elastic Maps Service stack (Elasticsearch, Kibana, Fleet/APM Server, EMS):

```bash
docker compose -f docker-compose.yml -f elastic-maps-server.yml up -d
```

To bring up the basic air-gapped stack with Elastic Maps Service (Elasticsearch, Kibana, Fleet/APM Server, EAR, and EPR):

```bash
docker compose -f docker-compose.yml -f air-gapped.yml -f elastic-maps-server.yml up -d
```

Profiles may also be used when using the Elastic Maps Service. Using the same metricbeat example above, the command would be:

```bash
docker compose -f docker-compose.yml -f elastic-maps-server.yml --profile monitoring up -d
```

Multiple profiles can also be chained together:

```bash
docker compose -f docker-compose.yml -f elastic-maps-server.yml --profile monitoring --profile logstash up -d
```

## Advanced Configurations

### Frozen Data Node with MinIO

The frozen profile creates a cost-effective long-term storage solution:

- **fz01**: Elasticsearch frozen data node
- **minio**: S3-compatible object storage
- **minio-setup**: Automated MinIO configuration

### Elastic Maps Service

Provides geographic data visualization capabilities:

- **ems-server**: Maps service with SSL/TLS
- **mapsdata01**: Persistent maps data storage

### Container Monitoring

The agent profile enables comprehensive container monitoring:

- **container-agent**: Standalone Elastic Agent
- **Syslog Support**: UDP (9003) and TCP (9004) ports
- **Docker Integration**: Container log collection

## Data Ingestion

### Filebeat Integration

- **Source**: `./filebeat_ingest_data/` directory
- **Configuration**: `./config/filebeat.yml`
- **Features**: Docker container logs, custom log files

### Logstash Pipeline

- **Source**: `./logstash_ingest_data/` directory
- **Configuration**: `./config/logstash.conf`
- **Processing**: Custom log parsing and transformation

### Agent Data Collection

- **Source**: `./agent_ingest_data/` directory
- **Integration**: Fleet Server policies
- **Monitoring**: Real-time data collection

## Security Features

### TLS/SSL Encryption

- **Transport Layer**: Encrypted node-to-node communication
- **HTTP Layer**: Encrypted client-to-cluster communication
- **Certificate Management**: Automated CA and certificate generation

### X-Pack Security

- **Authentication**: Username/password authentication
- **Authorization**: Role-based access control
- **Encryption**: Data encryption at rest and in transit

### Fleet Security

- **Agent Enrollment**: Secure agent registration
- **Policy Management**: Centralized security policies
- **Certificate Distribution**: Automated certificate management

## Monitoring and Health Checks

### Service Health Monitoring

All services include comprehensive health checks:

- **Elasticsearch**: Authentication endpoint verification
- **Kibana**: API status monitoring
- **Fleet Server**: Health endpoint validation
- **Agents**: Fleet Server connectivity checks

### Stack Monitoring

- **Metricbeat**: System and application metrics
- **Kibana Monitoring**: Built-in stack monitoring
- **Health Dashboards**: Service status visualization

## Troubleshooting

### Common Issues

#### 1. Memory Issues

```bash
# Check vm.max_map_count
sysctl vm.max_map_count

# Set if too low (requires root)
sudo sysctl -w vm.max_map_count=262144
```

#### 2. Certificate Issues

```bash
# Remove existing certificates by removing the certs volume
docker compose down -v
docker compose up -d
```

**Note**: Certificates are stored in Docker volumes, not in local directories. To regenerate certificates, you must remove the volume containing the certificates and restart the stack.

#### 3. Port Conflicts

Check for port conflicts and update `.env` file:

```bash
# Check port usage
netstat -tulpn | grep :9200
netstat -tulpn | grep :5601
```

### Logs and Debugging

```bash
# View service logs
docker compose logs es01
docker compose logs kibana
docker compose logs fleet-server

# Follow logs in real-time
docker compose logs -f es01
```

### Stopping and Managing the Stack

```bash
# Stop all services
docker compose down

# Stop and remove volumes
docker compose down -v

# Restart specific services
docker compose restart es01

# View running services
docker compose ps

# Scale services (if applicable)
docker compose up -d --scale es01=1
```

## Bring down the stack

To bring down the stack without purging the data volumes, execute the same command (including `-f <filename>` and `--profile` flags) but replace the `up -d` with `down`

```bash
docker compose down
```

or

```bash
docker compose --profile monitoring down
```

or

```bash
docker compose -f docker-compose.yml -f air-gapped.yml --profile monitoring down
```

To bring down the stack and remove the data volumes, add `-v` to your command

```bash
docker compose down -v
```

or

```bash
docker compose --profile monitoring down -v
```

or

```bash
docker compose -f docker-compose.yml -f air-gapped.yml --profile monitoring down -v
```

## Performance Tuning

### Memory Configuration

Adjust memory limits in `.env` file:

```bash
ES_MEM_LIMIT=4g          # Elasticsearch memory
KB_MEM_LIMIT=2g          # Kibana memory
FLEET_MEM_LIMIT=1g       # Fleet Server memory
ML_MEM_LIMIT=4g          # ML node memory
FZ_MEM_LIMIT=2g          # Frozen node memory
```

### Cluster Scaling

- **Horizontal Scaling**: Add more data nodes
- **Vertical Scaling**: Increase memory limits
- **Role Separation**: Dedicated nodes for specific functions

## Backup and Recovery

### Snapshot Configuration

- **Repository**: MinIO S3-compatible storage
- **Policy**: Automated snapshot scheduling
- **Retention**: Configurable retention policies

### Data Persistence

All data is stored in Docker volumes:

- **esdata01/02/03**: Elasticsearch data
- **kibanadata**: Kibana data
- **fleetserverdata**: Fleet Server data
- **mldata01**: ML node data
- **fzdata01**: Frozen node data

## Development and Testing

### Local Development

```bash
# Start with minimal services
docker compose up -d

# Add development profiles
docker compose --profile filebeat --profile logstash up -d
```

### Testing Profiles

- **APM Testing**: `docker compose --profile apm up -d` for application monitoring
- **Agent Testing**: `docker compose --profile agent up -d` for agent functionality
- **ML Testing**: `docker compose --profile ml up -d` for machine learning features
- **Multiple Profiles**: `docker compose --profile apm --profile monitoring --profile filebeat up -d` for comprehensive testing

## Contributing

### Project Structure

```text
├── docker-compose.yml          # Main compose file
├── elastic-stack.yml           # Core service definitions
├── examples.yml                # Optional service profiles
├── stack-setup.yml            # Initialization service
├── air-gapped.yml             # Offline deployment
├── elastic-maps-server.yml    # Maps service
├── config/                     # Configuration files
└── README.md                  # Documentation
```

### Adding New Services

1. Define service in appropriate compose file
2. Add configuration files to `config/` directory
3. Use Docker Compose profiles for optional services
4. Document in README

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## References

- [Getting Started with the Elastic Stack and Docker Compose](https://www.elastic.co/blog/getting-started-with-the-elastic-stack-and-docker-compose) or visit its [GitHub repo](https://github.com/elkninja/elastic-stack-docker-part-one)
- [Getting Started with the Elastic Stack and Docker Compose: Part 2](https://www.elastic.co/blog/getting-started-with-the-elastic-stack-and-docker-compose-part-2) or visit its [GitHub repo](https://github.com/elkninja/elastic-stack-docker-part-two)

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

## Support

### Documentation

- [Elasticsearch Documentation](https://www.elastic.co/guide/index.html)
- [Kibana User Guide](https://www.elastic.co/guide/en/kibana/current/index.html)
- [Fleet Server Guide](https://www.elastic.co/guide/en/fleet/current/index.html)

### Community

- [Elastic Community](https://discuss.elastic.co/)
- [GitHub Issues](https://github.com/elastic/elasticsearch/issues)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/elasticsearch)

## Version Compatibility

This project is tested with:

- **Elastic Stack**: 8.x versions
- **Docker**: 20.10+
- **Docker Compose**: 2.20.3+
- **Operating Systems**: Linux, macOS, Windows (WSL2)

For specific version compatibility, check the [Elastic compatibility matrix](https://www.elastic.co/support/matrix).
