# Use the nginx official image
FROM nginx

ARG ELASTIC_VERSION
ENV ELASTIC_VERSION=${ELASTIC_VERSION}

# Create Artifact storage directory
RUN mkdir -p /opt/elastic-packages/downloads
ENV DOWNLOAD_BASE_DIR=/opt/elastic-packages/downloads

# Copy Artifact Registry creation script
COPY get-artifacts.sh /root/get-artifacts.sh
RUN chmod 0755 /root/get-artifacts.sh

# Execute Artifact Script
RUN /root/get-artifacts.sh
RUN chown -R nginx:nginx /opt/elastic-packages 

# Copy EAR NGINX Configuration
COPY nginx-ear.conf /etc/nginx/nginx.conf
COPY index.html /opt/elastic-packages/index.html

# Expose the EAR port
EXPOSE 9080