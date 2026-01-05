# Makefile for obs-demo Docker operations
# Usage: make [target]

.PHONY: help build run stop clean logs test push pull dev prod analyze

# Default target
.DEFAULT_GOAL := help

# Variables
IMAGE_NAME := obs-demo
IMAGE_TAG := latest
CONTAINER_NAME := obs-demo
PORT := 8080
DOCKERHUB_USER := $(shell echo $$DOCKERHUB_USERNAME)

##@ General

help: ## Display this help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Docker Build

build: ## Build Docker image with BuildKit
	@echo "🔨 Building Docker image with layer caching..."
	DOCKER_BUILDKIT=1 docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .
	@echo "✅ Build completed: $(IMAGE_NAME):$(IMAGE_TAG)"

build-no-cache: ## Build Docker image without cache
	@echo "🔨 Building Docker image without cache..."
	DOCKER_BUILDKIT=1 docker build --no-cache -t $(IMAGE_NAME):$(IMAGE_TAG) .
	@echo "✅ Build completed"

build-stages: ## Show all build stages
	@echo "📋 Available build stages:"
	@echo "  - dependencies: Maven dependency cache"
	@echo "  - builder: Application build"
	@echo "  - runtime: Final runtime image"

build-deps: ## Build only dependencies stage (for caching)
	@echo "📦 Building dependencies stage..."
	DOCKER_BUILDKIT=1 docker build --target dependencies -t $(IMAGE_NAME):deps .

##@ Docker Run

run: ## Run container in foreground
	@echo "🚀 Starting container..."
	docker run --rm --name $(CONTAINER_NAME) -p $(PORT):8080 $(IMAGE_NAME):$(IMAGE_TAG)

run-bg: stop ## Run container in background
	@echo "🚀 Starting container in background..."
	docker run -d --name $(CONTAINER_NAME) -p $(PORT):8080 $(IMAGE_NAME):$(IMAGE_TAG)
	@echo "✅ Container started: http://localhost:$(PORT)"
	@echo "📊 Metrics: http://localhost:$(PORT)/actuator/prometheus"

run-dev: ## Run with development settings
	@echo "🚀 Starting in development mode..."
	docker run -d --name $(CONTAINER_NAME) \
		-p $(PORT):8080 \
		-e SPRING_PROFILES_ACTIVE=dev \
		-e JAVA_OPTS="-Xmx256m -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005" \
		-p 5005:5005 \
		$(IMAGE_NAME):$(IMAGE_TAG)
	@echo "✅ Dev container started with debug port 5005"

run-prod: ## Run with production settings
	@echo "🚀 Starting in production mode..."
	docker run -d --name $(CONTAINER_NAME) \
		-p $(PORT):8080 \
		-e SPRING_PROFILES_ACTIVE=prod \
		--memory="512m" \
		--cpus="1" \
		--restart unless-stopped \
		$(IMAGE_NAME):$(IMAGE_TAG)
	@echo "✅ Production container started"

##@ Docker Compose

compose-up: ## Start with Docker Compose
	docker-compose up -d
	@echo "✅ Services started"

compose-up-monitoring: ## Start with monitoring stack (Prometheus + Grafana)
	docker-compose --profile monitoring up -d
	@echo "✅ Full monitoring stack started"
	@echo "📊 Application: http://localhost:8080"
	@echo "📈 Prometheus: http://localhost:9090"
	@echo "📉 Grafana: http://localhost:3000 (admin/admin)"

compose-down: ## Stop Docker Compose
	docker-compose --profile monitoring down
	@echo "✅ Services stopped"

compose-logs: ## Show Docker Compose logs
	docker-compose logs -f

##@ Container Management

stop: ## Stop and remove container
	@echo "🛑 Stopping container..."
	@docker stop $(CONTAINER_NAME) 2>/dev/null || true
	@docker rm $(CONTAINER_NAME) 2>/dev/null || true
	@echo "✅ Container stopped"

restart: stop run-bg ## Restart container

logs: ## Show container logs
	docker logs -f $(CONTAINER_NAME)

shell: ## Open shell in running container
	docker exec -it $(CONTAINER_NAME) sh

status: ## Show container status
	@docker ps -a --filter "name=$(CONTAINER_NAME)" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

health: ## Check container health
	@echo "🏥 Container health:"
	@docker inspect --format='{{.State.Health.Status}}' $(CONTAINER_NAME) 2>/dev/null || echo "Container not running"
	@echo "\n🌐 Application endpoints:"
	@curl -s http://localhost:$(PORT)/healthz | jq . || echo "❌ Not responding"

##@ Testing

test: ## Test application endpoints
	@echo "🧪 Testing endpoints..."
	@echo "\n1. Health check:"
	@curl -s http://localhost:$(PORT)/healthz | jq .
	@echo "\n2. Hello endpoint:"
	@curl -s http://localhost:$(PORT)/api/hello | jq .
	@echo "\n3. Metrics (first 10 lines):"
	@curl -s http://localhost:$(PORT)/actuator/prometheus | grep "http_requests_total" | head -5
	@echo "\n✅ Tests completed"

test-load: ## Generate load for testing metrics
	@echo "🔥 Generating load..."
	@for i in {1..20}; do \
		curl -s http://localhost:$(PORT)/api/hello > /dev/null; \
		echo -n "."; \
	done
	@echo "\n✅ Load test completed (20 requests)"
	@echo "\n📊 Metrics:"
	@curl -s http://localhost:$(PORT)/actuator/prometheus | grep "http_requests_total.*hello"

##@ DockerHub Operations

tag: ## Tag image for DockerHub
	@if [ -z "$(DOCKERHUB_USER)" ]; then \
		echo "❌ DOCKERHUB_USERNAME not set"; \
		exit 1; \
	fi
	docker tag $(IMAGE_NAME):$(IMAGE_TAG) $(DOCKERHUB_USER)/$(IMAGE_NAME):$(IMAGE_TAG)
	@echo "✅ Tagged: $(DOCKERHUB_USER)/$(IMAGE_NAME):$(IMAGE_TAG)"

push: tag ## Push image to DockerHub
	@if [ -z "$(DOCKERHUB_USER)" ]; then \
		echo "❌ DOCKERHUB_USERNAME not set"; \
		exit 1; \
	fi
	@echo "📤 Pushing to DockerHub..."
	docker push $(DOCKERHUB_USER)/$(IMAGE_NAME):$(IMAGE_TAG)
	@echo "✅ Pushed: $(DOCKERHUB_USER)/$(IMAGE_NAME):$(IMAGE_TAG)"

pull: ## Pull image from DockerHub
	@if [ -z "$(DOCKERHUB_USER)" ]; then \
		echo "❌ DOCKERHUB_USERNAME not set"; \
		exit 1; \
	fi
	@echo "📥 Pulling from DockerHub..."
	docker pull $(DOCKERHUB_USER)/$(IMAGE_NAME):$(IMAGE_TAG)
	@echo "✅ Pulled: $(DOCKERHUB_USER)/$(IMAGE_NAME):$(IMAGE_TAG)"

##@ Analysis & Cleanup

analyze: ## Analyze image layers with dive
	@echo "🔍 Analyzing image layers..."
	@which dive > /dev/null || (echo "❌ dive not installed. Install: brew install dive" && exit 1)
	dive $(IMAGE_NAME):$(IMAGE_TAG)

layers: ## Show image layer history
	@echo "📊 Image layers:"
	@docker history $(IMAGE_NAME):$(IMAGE_TAG) --human --no-trunc

size: ## Show image size
	@echo "💾 Image size:"
	@docker images $(IMAGE_NAME):$(IMAGE_TAG) --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

clean: stop ## Remove image and container
	@echo "🧹 Cleaning up..."
	@docker rmi $(IMAGE_NAME):$(IMAGE_TAG) 2>/dev/null || true
	@echo "✅ Cleanup completed"

clean-all: ## Remove all related images and containers
	@echo "🧹 Deep cleanup..."
	@docker stop $(CONTAINER_NAME) 2>/dev/null || true
	@docker rm $(CONTAINER_NAME) 2>/dev/null || true
	@docker rmi $(IMAGE_NAME):$(IMAGE_TAG) 2>/dev/null || true
	@docker rmi $(IMAGE_NAME):deps 2>/dev/null || true
	@docker system prune -f
	@echo "✅ Deep cleanup completed"

##@ Maven Operations

maven-build: ## Build with Maven locally
	@echo "🔨 Building with Maven..."
	mvn clean package -DskipTests
	@echo "✅ Maven build completed"

maven-test: ## Run Maven tests
	mvn test

maven-run: ## Run with Maven (no Docker)
	mvn spring-boot:run

##@ CI/CD

ci-build: ## Simulate CI build with cache
	@echo "🔄 CI Build simulation..."
	DOCKER_BUILDKIT=1 docker build \
		--cache-from $(IMAGE_NAME):latest \
		-t $(IMAGE_NAME):$(IMAGE_TAG) .

ci-test: build run-bg test stop ## Full CI pipeline (build, run, test, cleanup)

##@ Quick Commands

quick-start: build run-bg test ## Build, run, and test (quick start)
	@echo "\n✅ Quick start completed!"
	@echo "🌐 Application: http://localhost:$(PORT)"
	@echo "📊 Metrics: http://localhost:$(PORT)/actuator/prometheus"

quick-restart: stop run-bg ## Quick restart

full-cycle: clean build run-bg test ## Full cycle: clean, build, run, test
	@echo "\n✅ Full cycle completed!"

##@ Information

info: ## Show configuration
	@echo "📋 Configuration:"
	@echo "  Image Name: $(IMAGE_NAME)"
	@echo "  Image Tag: $(IMAGE_TAG)"
	@echo "  Container Name: $(CONTAINER_NAME)"
	@echo "  Port: $(PORT)"
	@echo "  DockerHub User: $(DOCKERHUB_USER)"

version: ## Show versions
	@echo "📦 Versions:"
	@echo "  Docker: $$(docker --version)"
	@echo "  Maven: $$(mvn --version | head -1)"
	@echo "  Java: $$(java -version 2>&1 | head -1)"

