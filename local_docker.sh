#!/bin/bash

# 프로젝트 이름을 인자로 받거나 기본값 사용
PROJECT_NAME=${1:-$(docker-compose config --services | head -n 1 | sed 's/[^a-zA-Z0-9_]//g')}

echo "Using Docker Compose project: $PROJECT_NAME"

# Docker Compose 프로젝트와 관련된 컨테이너 목록
CONTAINERS=$(docker ps -a --filter "name=$PROJECT_NAME" --format "{{.ID}}")

# Docker Compose 프로젝트와 관련된 네트워크 목록
NETWORKS=$(docker network ls --filter "name=$PROJECT_NAME" --format "{{.Name}}")

# Docker Compose 프로젝트와 관련된 볼륨 목록
VOLUMES=$(docker volume ls --filter "name=$PROJECT_NAME" --format "{{.Name}}")

echo "Cleaning up Docker Compose environment..."

# 기존 컨테이너 제거
if [ -n "$CONTAINERS" ]; then
  echo "Removing containers..."
  docker rm -f $CONTAINERS
else
  echo "No containers to remove."
fi

# 네트워크 제거 (옵션에 따라)
if [ -n "$NETWORKS" ]; then
  echo "Removing networks..."
  docker network rm $NETWORKS
else
  echo "No networks to remove."
fi

# 볼륨 제거 (옵션에 따라)
if [ -n "$VOLUMES" ]; then
  echo "Removing volumes..."
  docker volume rm $VOLUMES
else
  echo "No volumes to remove."
fi

# 새로운 컨테이너 실행
echo "Starting Docker Compose..."
docker-compose up --build -d

# 사용되지 않는 리소스 정리
echo "Pruning unused Docker resources..."
docker system prune -f --volumes

echo "Docker Compose up complete and unused resources cleaned."
