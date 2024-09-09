#!/bin/bash


##### vm_max_map check ##
current_value=$(sysctl vm.max_map_count | awk '{print $3}')

if [ "$current_value" -lt 262144 ]; then
  echo "ERROR: vm.max_map_count is too low. Required: 262144, Found: $current_value"
  exit 1
fi

#### docker and docker compose version check 
docker_version=$(docker --version)
if [ $? -ne 0 ]; then
  echo "ERROR - >> Docker is not installed."
  exit 1
fi

docker_compose_version=$(docker compose version --short)
if [ $? -ne 0 ]; then
  echo "ERROR -->  Docker Compose is not installed..."
  exit 1
fi

if [ ! -f ".env" ]; then
  echo "ERROR --> .env file not found. Please make a copy of env.template and name it .env."
  exit 1
fi



usage() {
  echo "Usage: $0 [-p profiles] [-a air-gapped] [-d down] [-v volumes]"
  echo ""
  echo "Options:"
  echo "  -p, --profiles   Specify profiles (comma-separated) for Docker Compose"
  echo "  -a, --air-gapped Use the air-gapped setup"
  echo "  -d, --down       Bring down the stack"
  echo "  -v, --volumes    Remove data volumes when bringing down the stack"
  exit 1
}

# ELK Docker script Options 
PROFILES=""
AIR_GAPPED=false
ACTION="up -d"
VOLUMES=false


while [[ "$#" -gt 0 ]]; do
  case $1 in
    -p|--profiles) PROFILES="$2"; shift ;;
    -a|--air-gapped) AIR_GAPPED=true ;;
    -d|--down) ACTION="down" ;;
    -v|--volumes) VOLUMES=true ;;
    *) usage ;;
  esac
  shift
done

# Docker Compose command
COMPOSE_CMD="docker compose"


if [ "$AIR_GAPPED" = true ]; then
  COMPOSE_CMD="$COMPOSE_CMD -f docker-compose.yml -f air-gapped.yml"
else
  COMPOSE_CMD="$COMPOSE_CMD -f docker-compose.yml"
fi

if [ -n "$PROFILES" ]; then
  IFS=',' read -ra PROFILE_ARR <<< "$PROFILES"
  for profile in "${PROFILE_ARR[@]}"; do
    COMPOSE_CMD="$COMPOSE_CMD --profile $profile"
  done
fi

COMPOSE_CMD="$COMPOSE_CMD $ACTION"

if [ "$VOLUMES" = true ]; then
  COMPOSE_CMD="$COMPOSE_CMD -v"
fi

$COMPOSE_CMD
