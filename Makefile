.DEFAULT_GOAL := help
PROJECTNAME := trickster-demo

#COLORS
GREEN  := $(shell tput -Txterm setaf 2)
WHITE  := $(shell tput -Txterm setaf 7)
YELLOW := $(shell tput -Txterm setaf 3)
RED := $(shell tput -Txterm setaf 1)
RESET  := $(shell tput -Txterm sgr0)

# Shell variables
SHELL = /bin/bash
CFG = .env
CFG_BAK ?= $(CFG).bak
DCAPE_USED = 1
TZ ?= $(shell cat /etc/timezone)

# Java services
SERVICES_DIR = petclinic-services

# Docker Compose files
DOCKER_COMPOSE_FILE_SERVICES = compose-services.yml
DOCKER_COMPOSE_FILE_METRICS = compose-metrics.yml
DOCKER_COMPOSE_FILE_GRAFANA_DIRECT = compose-grafana-direct.yml
DOCKER_COMPOSE_FILE_GRAFANA_FS = compose-grafana-fs.yml
DOCKER_COMPOSE_FILE_GRAFANA_MEM = compose-grafana-mem.yml
DOCKER_COMPOSE_FILE_GRAFANA_REDIS = compose-grafana-redis.yml

# Docker variable
DOCKER = docker
DOCKER_COMPOSE = docker-compose
DOCKER_COMPOSE_FILE = docker-compose.yml

# Network configuration
FRONT_TIER_NETWORK = trk-ex-front-tier
BACK_TIER_NETWORK = trk-ex-back-tier

# Commands
confirm:
	@( read -p "$(RED)Are you sure? [y/N]$(RESET): " sure && case "$$sure" in [yY]) true;; *) false;; esac )

# Application commands
# ==============================================================================
## build-services: Build the Java Services and the Docker images
.PHONY: build-services
build-services:
	pushd ${SERVICES_DIR} && ./mvnw clean install -PbuildDocker; popd

## build-images: Build the Docker images (Not the service images)
.PHONY: build-images
build-images:
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE_SERVICES) build $(c)
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE_METRICS) build $(c)
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE_GRAFANA_DIRECT) build $(c)
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE_GRAFANA_FS) build $(c)
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE_GRAFANA_MEM) build $(c)
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE_GRAFANA_REDIS) build $(c)

## create-networks: Create the networks
.PHONY: create-networks
create-networks:
	@if [ -z `docker network ls --filter name=${FRONT_TIER_NETWORK} --quiet` ]; then \
		docker network create ${FRONT_TIER_NETWORK}; \
	fi; \
	if [ -z `docker network ls --filter name=${BACK_TIER_NETWORK} --quiet` ]; then \
		docker network create ${BACK_TIER_NETWORK}; \
	fi;

## clear-networks: Delete the networks
.PHONY: clear-networks
clear-networks:
	@if [ ! -z `docker network ls --filter name=${FRONT_TIER_NETWORK} --quiet` ]; then \
		docker network rm ${FRONT_TIER_NETWORK}; \
	fi; \
	if [ ! -z `docker network ls --filter name=${BACK_TIER_NETWORK} --quiet` ]; then \
		docker network rm ${BACK_TIER_NETWORK}; \
	fi;

## up-services: Up the Java service containers
.PHONY: up-services
up-services: create-networks
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE_SERVICES) up -d $(c)

## down-services: Down the Java service containers
.PHONY: down-services
down-services: confirm
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE_SERVICES) down -d $(c)

## up-metrics: Up the metric containers
.PHONY: up-metrics
up-metrics: create-networks
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE_METRICS) up -d $(c)

## down-metrics: Down the Java service containers
.PHONY: down-metrics
down-metrics: confirm
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE_METRICS) down -d $(c)

## up-grafana-direct: Up the Grafana container with direct connection
.PHONY: up-grafana-direct
up-grafana-direct: create-networks up-metrics
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE_GRAFANA_DIRECT) up -d $(c)

## down-grafana-direct: Down the Java service containers
.PHONY: down-grafana-direct
down-grafana-direct: confirm
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE_GRAFANA_DIRECT) down -d $(c)

## up-grafana-fs: Up the Grafana container with file system cache
.PHONY: up-grafana-fs
up-grafana-fs: create-networks up-metrics
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE_GRAFANA_FS) up -d $(c)

## down-grafana-fs: Down the Java service containers
.PHONY: down-grafana-fs
down-grafana-fs: confirm
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE_GRAFANA_FS) down -d $(c)

## up-grafana-mem: Up the Grafana container with memory cache
.PHONY: up-grafana-mem
up-grafana-mem: create-networks up-metrics
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE_GRAFANA_MEM) up -d $(c)

## down-grafana-mem: Down the Java service containers
.PHONY: down-grafana-mem
down-grafana-mem: confirm
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE_GRAFANA_MEM) down -d $(c)

## up-grafana-redis: Up the Grafana container with Redis cache
.PHONY: up-grafana-redis
up-grafana-redis: create-networks up-metrics
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE_GRAFANA_REDIS) up -d $(c)

## down-grafana-redis: Down the Java service containers
.PHONY: down-grafana-redis
down-grafana-redis: confirm
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE_GRAFANA_REDIS) down -d $(c)

## up-all: Up all the containers
.PHONY: up-all
up-all: up-services up-metrics up-grafana-direct up-grafana-fs up-grafana-mem up-grafana-redis

## stop-all: Stop all the containers
.PHONY: stop-all
stop-all:
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE_SERVICES) stop $(c)
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE_METRICS) stop $(c)
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE_GRAFANA_DIRECT) stop $(c)
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE_GRAFANA_FS) stop $(c)
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE_GRAFANA_MEM) stop $(c)
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE_GRAFANA_REDIS) stop $(c)

## restart-all: Restart all the containers
.PHONY: restart-all
restart-all: stop-all up-all

## down-all: Down all the containers
.PHONY: clear-all
down-all: confirm
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE_SERVICES) down
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE_METRICS) down
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE_GRAFANA_DIRECT) down
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE_GRAFANA_FS) down
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE_GRAFANA_MEM) down
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE_GRAFANA_REDIS) down

# Docker commands
# ==============================================================================
# delete-all-containers: Delete all containers
.PHONY: delete-all-containers
delete-all-containers: confirm
	@$(DOCKER) rm -f $(docker ps -a -q)

# delete-all-images: Delete all the images
.PHONY: delete-all-images
delete-all-images: confirm
	@$(DOCKER) rmi -f $(docker images -q)

# delete-dangling-volumes: Delete all volumes
.PHONY: delete-dangling-volumes
delete-dangling-volumes: confirm
	@$(DOCKER) volume rm $(docker volume ls -q --filter dangling=true)

# delete-all-networks: Delete all networks
.PHONY: delete-all-networks
delete-all-networks: confirm
	@$(DOCKER) network rm $(docker network ls)

# docker-prune: Docker system prune
.PHONY: docker-prune
docker-prune: confirm
	@$(DOCKER) system prune
	@$(DOCKER) network prune

# purge-docker: Docker purge
.PHONY: purge-docker
purge-docker: confirm delete-all-containers delete-all-images delete-dangling-volumes delete-all-networks docker-prune

## status: Show the containers status
.PHONY: status
status:
	@$(DOCKER) ps

# Other commands
# ==============================================================================
## help: This message
.PHONY: help
all: help
help: Makefile
	@echo
	@echo " Choose a command to run in "$(PROJECTNAME)":"
	@echo ""
	@echo " Network commands:"
	@echo "   create-networks           Create the networks"
	@echo "   clear-networks            Delete the networks"
	@echo ""
	@echo " Application commands:"
	@echo "   build-services            Build the Java Services and the Docker images"
	@echo "   build-images              Build the Docker images (Not the service images)"
	@echo "   up-services               Up the Java service containers"
	@echo "   up-metrics                Up the metric containers"
	@echo "   up-grafana-direct         Up the Grafana container with direct connection"
	@echo "   up-grafana-fs             Up the Grafana container with file system cache"
	@echo "   up-grafana-mem            Up the Grafana container with memory cache"
	@echo "   up-grafana-redis          Up the Grafana container with Redis cache"
	@echo "   down-services             Down the Java service containers"
	@echo "   down-metrics              Down the metric containers"
	@echo "   down-grafana-direct       Down the Grafana container with direct connection"
	@echo "   down-grafana-fs           Down the Grafana container with file system cache"
	@echo "   down-grafana-mem          Down the Grafana container with memory cache"
	@echo "   down-grafana-redis        Down the Grafana container with Redis cache"
	@echo "   up-all                    Up all the containers"
	@echo "   stop-all                  Stop all the containers"
	@echo "   restart-all               Restart all the containers"
	@echo "   down-all                  Down all the containers"
	@echo ""
	@echo " Docker commands:"
	@echo "   delete-all-containers     Delete all containers"
	@echo "   delete-all-images         Delete all the images"
	@echo "   delete-dangling-volumes   Delete all volumes"
	@echo "   delete-all-networks       Delete all networks"
	@echo "   docker-prune              Docker system prune"
	@echo "   purge-docker              Docker purge"
	@echo "   status                    Show the containers status"
	@echo ""
	@echo " Other commands:"
	@echo "   help                      This message"
	@echo ""
