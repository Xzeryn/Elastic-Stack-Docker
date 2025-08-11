# Elastic Artifact Registry (EAR) - Comprehensive Guide

## Overview

The Elastic Artifact Registry (EAR) is a specialized Docker container designed to serve as a local, air-gapped repository for Elastic Stack artifacts and packages. It provides a centralized location for storing and distributing Elastic Stack components, Beats agents, and security artifacts within environments that cannot directly access the internet or Elastic's official artifact repositories.

## Background

### Why Elastic Artifact Registry?

In enterprise environments, particularly those with strict security requirements or air-gapped networks, direct access to external repositories is often restricted. This creates challenges when deploying and updating Elastic Stack components. The Elastic Artifact Registry addresses these challenges by:

- **Eliminating Internet Dependencies**: Provides local access to all necessary Elastic artifacts
- **Ensuring Consistency**: Guarantees all deployments use the same artifact versions
- **Improving Security**: Reduces exposure to external networks during deployments
- **Enabling Compliance**: Supports environments with strict regulatory requirements
- **Facilitating Offline Deployments**: Enables Elastic Stack deployment in completely isolated networks

### Use Cases

- **Air-gapped Networks**: Military, government, and high-security environments
- **Compliance Requirements**: Industries with strict data sovereignty requirements
- **Disaster Recovery**: Ensuring artifact availability during network outages
- **Development/Testing**: Consistent artifact versions across development environments
- **Production Deployments**: Reliable artifact delivery in production environments

## Architecture

### Container Structure

The EAR container is built on top of Nginx and includes:

- **Web Server**: Nginx configured to serve artifacts on port 9080
- **Artifact Storage**: Local directory structure at `/opt/elastic-packages/downloads`
- **Package Management**: Scripts for downloading and organizing Elastic artifacts
- **Security Integration**: Support for Elastic Defend security artifacts

### Artifact Categories

The registry stores several types of Elastic artifacts:

#### Core Elastic Stack Components
- **APM Server**: Application Performance Monitoring
- **Beats Agents**: 
  - Auditbeat (audit data)
  - Elastic Agent (unified agent)
  - Filebeat (log files)
  - Heartbeat (uptime monitoring)
  - Metricbeat (metrics)
  - Osquerybeat (OS query data)
  - Packetbeat (network packet analysis)
- **Cloudbeat**: Cloud security posture management
- **Endpoint Security**: Host-based security monitoring
- **Fleet Server**: Centralized agent management

#### Platform-Specific Packages
- **Linux**: TAR.GZ packages for x86_64 architecture
- **Windows**: ZIP packages for x86_64 architecture
- **Package Managers**: RPM (Red Hat/CentOS) and DEB (Ubuntu/Debian) packages

#### Security Artifacts
- **Elastic Defend**: Endpoint security detection rules and configurations
- **Manifest Files**: Artifact metadata and version information

## Technical Implementation

### Dockerfile Components

```dockerfile
# Base Image
FROM nginx

# Version Configuration
ARG ELASTIC_VERSION
ENV ELASTIC_VERSION=${ELASTIC_VERSION:-8.17.0}

# Dependencies
RUN apt-get update && apt-get install -y jq

# Directory Structure
RUN mkdir -p /opt/elastic-packages/downloads
ENV DOWNLOAD_BASE_DIR=/opt/elastic-packages/downloads

# Artifact Download Scripts
COPY get-artifacts.sh /root/get-artifacts.sh
COPY get-defend_artifacts.sh /root/get-defend_artifacts.sh

# Web Server Configuration
COPY nginx-ear.conf /etc/nginx/nginx.conf
COPY index.html /opt/elastic-packages/index.html

# Port Configuration
EXPOSE 9080
```

### Artifact Download Process

#### Main Artifact Script (`get-artifacts.sh`)
1. **Version Detection**: Uses `ELASTIC_VERSION` environment variable
2. **Package Discovery**: Defines common and platform-specific package prefixes
3. **Multi-Platform Support**: Downloads Linux and Windows packages
4. **Package Types**: Includes main packages, SHA512 checksums, and GPG signatures
5. **Directory Organization**: Creates structured directory hierarchy for easy access

#### Security Artifact Script (`get-defend_artifacts.sh`)
1. **Manifest Download**: Retrieves artifact manifest from Elastic Security
2. **Artifact Processing**: Uses `jq` to parse manifest and extract URLs
3. **Bulk Download**: Downloads all security artifacts in parallel
4. **Directory Creation**: Maintains proper directory structure

### Web Server Configuration

The Nginx configuration (`nginx-ear.conf`) provides:
- **Port 9080**: Dedicated port for artifact access
- **Static File Serving**: Direct access to artifact directory
- **Performance Optimization**: Configured for efficient file delivery
- **Access Logging**: Comprehensive request logging for monitoring

## Usage

### Automatic Creation (Recommended)

The EAR container is automatically created when using the air-gapped Docker Compose configuration:

```yaml
# From air-gapped.yml
ear:
  image: elastic-artifact-registry:${STACK_VERSION}
  build:
    context: elastic_artifact_registry_container
    dockerfile: Dockerfile
    args:
      - ELASTIC_VERSION=${STACK_VERSION}
  container_name: ear
  restart: always
  ports:
    - ${EAR_PORT}:9080
  healthcheck:
    test: ["CMD-SHELL", "curl -f -L http://localhost:9080/"]
    interval: 10s
    timeout: 10s
    retries: 120
```

### Manual Creation

To manually build the EAR container:

1. **Edit Version**: Modify the `ELASTIC_VERSION` in the Dockerfile
2. **Build Container**: Execute the build command with desired version
3. **Run Container**: Start the container with appropriate port mapping

```bash
# Example: Build for Elastic version 8.13.4
docker build -t elastic-artifact-registry:8.13.4 .

# Run the container
docker run -d \
  --name ear \
  -p 9080:9080 \
  elastic-artifact-registry:8.13.4
```

### Accessing Artifacts

Once running, artifacts are accessible via HTTP:

- **Base URL**: `http://localhost:9080/`
- **Downloads Directory**: `http://localhost:9080/downloads/`
- **Specific Packages**: `http://localhost:9080/downloads/beats/elastic-agent/elastic-agent-8.13.4-linux-x86_64.tar.gz`

## Integration with Elastic Stack

### Fleet Server Configuration

The EAR integrates with Fleet Server for agent management:

```bash
# Fleet startup script configuration
#!/bin/bash
# Download agent from local EAR
curl -o elastic-agent.tar.gz "http://ear:9080/downloads/beats/elastic-agent/elastic-agent-${STACK_VERSION}-linux-x86_64.tar.gz"
```

### Kibana Integration

Kibana can be configured to use the local package registry:

```yaml
environment:
  - XPACK_FLEET_REGISTRYURL=http://epr:8080  # Package registry
  # EAR provides artifacts for agent downloads
```

## Configuration Options

### Environment Variables

- **`ELASTIC_VERSION`**: Elastic Stack version (default: 8.17.0)
- **`DOWNLOAD_BASE_DIR`**: Base directory for artifact storage
- **`ARTIFACT_DOWNLOADS_BASE_URL`**: Source URL for artifact downloads

### Port Configuration

- **Default Port**: 9080 (configurable via Docker port mapping)
- **Health Check**: Available at `http://localhost:9080/`

### Storage Considerations

- **Artifact Size**: Varies by version (typically 500MB - 2GB)
- **Disk Space**: Ensure sufficient storage for all artifacts
- **Network Bandwidth**: Initial download requires significant bandwidth

## Best Practices

### Version Management

1. **Consistent Versions**: Use the same version across all Elastic components
2. **Version Pinning**: Pin specific versions for production stability
3. **Update Strategy**: Plan artifact updates as part of maintenance windows

### Security Considerations

1. **Access Control**: Restrict EAR access to authorized networks
2. **Artifact Verification**: Verify checksums and signatures
3. **Network Isolation**: Use internal networks for EAR communication

### Performance Optimization

1. **Caching**: Implement reverse proxy caching for frequently accessed artifacts
2. **Load Balancing**: Use multiple EAR instances for high-availability
3. **Storage**: Use fast storage for artifact serving

## Troubleshooting

### Common Issues

1. **Build Failures**: Ensure sufficient disk space and network access
2. **Artifact Downloads**: Check internet connectivity during build
3. **Port Conflicts**: Verify port 9080 is available
4. **Storage Issues**: Monitor disk space usage

### Health Checks

The container includes built-in health monitoring:

```bash
# Manual health check
curl -f -L http://localhost:9080/

# Container health status
docker ps --filter "name=ear"
```

### Logs and Monitoring

```bash
# View container logs
docker logs ear

# Monitor resource usage
docker stats ear
```

## Maintenance

### Regular Tasks

1. **Version Updates**: Update artifacts when new Elastic versions are released
2. **Storage Cleanup**: Remove old artifact versions to save space
3. **Security Updates**: Ensure security artifacts are current
4. **Performance Monitoring**: Monitor access patterns and optimize accordingly

### Backup Strategy

1. **Artifact Backup**: Backup artifact directory for disaster recovery
2. **Configuration Backup**: Save Docker and Nginx configurations
3. **Version Catalog**: Maintain list of available artifact versions

## Conclusion

The Elastic Artifact Registry provides a robust solution for managing Elastic Stack artifacts in restricted or air-gapped environments. By centralizing artifact storage and distribution, it enables reliable Elastic Stack deployments while maintaining security and compliance requirements.

For additional information, refer to the main project documentation and Elastic's official documentation on air-gapped deployments.
