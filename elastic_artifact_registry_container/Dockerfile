# Use the nginx official image
FROM nginx

ARG ELASTIC_VERSION
ENV ELASTIC_VERSION=${ELASTIC_VERSION:-8.17.0}

# Install packages
RUN apt-get update && apt-get install -y jq

# Create Artifact storage directory
RUN mkdir -p /opt/elastic-packages/downloads
ENV DOWNLOAD_BASE_DIR=/opt/elastic-packages/downloads

# Artifact Registry creation
COPY get-artifacts.sh /root/get-artifacts.sh
RUN chmod 0755 /root/get-artifacts.sh
RUN /root/get-artifacts.sh

# Defend Artifact creation
COPY get-defend_artifacts.sh /root/get-defend_artifacts.sh
RUN chmod 0755 /root/get-defend_artifacts.sh
RUN /root/get-defend_artifacts.sh


# Copy EAR NGINX Configuration
RUN chown -R nginx:nginx /opt/elastic-packages 
COPY nginx-ear.conf /etc/nginx/nginx.conf
COPY index.html /opt/elastic-packages/index.html

# Expose the EAR port
EXPOSE 9080