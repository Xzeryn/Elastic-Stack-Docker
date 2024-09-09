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
  echo "Docker Compose is installed: $docker_compose_version"
  
  # Check if Docker Compose version is 2.20.3 or greater
  required_version="2.20.3"
  if [ "$(printf '%s\n' "$required_version" "$docker_compose_version" | sort -V | head -n1)" != "$required_version" ]; then
    echo "ERROR --> Docker Compose version is less than 2.20.3. Please update."
    exit 1
  else
    echo "Docker Compose version meets the requirement: $docker_compose_version"
  fi

fi

if [ ! -f ".env" ]; then
  echo "ERROR --> .env file not found. Please make a copy of env.template and name it .env."
  exit 1
fi



usage() {
  echo "Usage: $0 [-p profiles] [-a air-gapped] [up|down] [-d] [-v]"
  echo ""
  echo "Options:"
  echo "  -p, --profiles   Specify profiles -- comma-separated -- for Docker Compose"
  echo "  -a, --air-gapped Use the air-gapped setup"
  echo "  up               Bring up the stack"
  echo "  down             Bring down the stack"
  echo "  -d               Detach (run in background)"
  echo "  -v               Remove data volumes when bringing down the stack"
  exit 1
}

# ELK Docker script Options 
PROFILES=""
AIR_GAPPED=false
ACTION=""
DETACH=false
VOLUMES=false

while [[ "$#" -gt 0 ]]; do
  case $1 in
    -p|--profiles) PROFILES="$2"; shift ;;
    -a|--air-gapped) AIR_GAPPED=true ;;
    up|down) ACTION="$1" ;;
    -d) DETACH=true ;;
    -v) VOLUMES=true ;;
    *) usage ;;
  esac
  shift
done


# Docker Compose command
COMPOSE_CMD="docker compose"

if [ -z "$ACTION" ]; then
  usage
fi

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

if [ "$DETACH" = true ] && [ "$ACTION" = "up" ]; then
  COMPOSE_CMD="$COMPOSE_CMD -d"
fi

if [ "$VOLUMES" = true ]; then
  COMPOSE_CMD="$COMPOSE_CMD -v"
fi

$COMPOSE_CMD
