# ============================================================================
# Multi-stage Dockerfile with Optimized Layer Caching
# ============================================================================
#
# Stage 1: Dependencies cache layer (Maven dependencies)
# Stage 2: Build layer (Application compilation)
# Stage 3: Runtime layer (Minimal JRE with exploded JAR)
#
# Layer Caching Strategy:
# - Dependencies are cached separately from source code
# - Only rebuild when pom.xml changes
# - Source code changes don't invalidate dependency cache
# - Exploded JAR for better layer separation in final image
# ============================================================================

# ============================================================================
# STAGE 1: Maven Dependencies Download
# ============================================================================
# This stage downloads Maven dependencies and caches them
# This layer is rebuilt ONLY when pom.xml changes
FROM eclipse-temurin:21-jdk-jammy AS dependencies

WORKDIR /build

# Install Maven
RUN apt-get update && \
    apt-get install -y --no-install-recommends maven && \
    rm -rf /var/lib/apt/lists/*

# Copy only pom.xml first (for dependency caching)
# This layer will be cached as long as pom.xml doesn't change
COPY pom.xml .

# Download dependencies (will be cached)
# Even if source code changes, this layer won't be rebuilt
RUN mvn dependency:go-offline -B

# ============================================================================
# STAGE 2: Application Build
# ============================================================================
# This stage compiles the application
# Uses cached dependencies from Stage 1
FROM dependencies AS builder

WORKDIR /build

# Copy source code (this invalidates cache from here)
# But dependencies from Stage 1 are already cached
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests -B

# Extract JAR layers for better Docker layer caching
# Spring Boot supports layered JARs for optimal caching
RUN mkdir -p target/extracted && \
    java -Djarmode=layertools -jar target/*.jar extract --destination target/extracted

# ============================================================================
# STAGE 3: Runtime Image
# ============================================================================
# Minimal runtime image with exploded JAR layers
# Each layer is cached independently
FROM eclipse-temurin:21-jre-jammy AS runtime

# Metadata
LABEL maintainer="your-email@example.com" \
      description="Spring Boot Observability Demo Service" \
      version="1.0.0" \
      org.opencontainers.image.source="https://github.com/yourusername/obs-demo" \
      org.opencontainers.image.licenses="MIT"

# Install curl/wget for health checks
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget curl && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user for security best practices
RUN groupadd -r spring --gid=1000 && \
    useradd -r -g spring --uid=1000 --create-home spring

WORKDIR /app

# Copy extracted JAR layers in optimal order
# Layers are ordered by change frequency (least to most)
# This maximizes Docker layer cache hits

# Layer 1: Dependencies (changes rarely)
COPY --from=builder --chown=spring:spring /build/target/extracted/dependencies/ ./

# Layer 2: Spring Boot Loader (changes very rarely)
COPY --from=builder --chown=spring:spring /build/target/extracted/spring-boot-loader/ ./

# Layer 3: Snapshot dependencies (changes occasionally)
COPY --from=builder --chown=spring:spring /build/target/extracted/snapshot-dependencies/ ./

# Layer 4: Application code (changes frequently)
COPY --from=builder --chown=spring:spring /build/target/extracted/application/ ./

# Switch to non-root user
USER spring:spring

# Expose application port
EXPOSE 8080

# Health check configuration
HEALTHCHECK --interval=30s \
            --timeout=3s \
            --start-period=40s \
            --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/healthz || exit 1

# JVM options optimized for containerized environments
ENV JAVA_OPTS="-XX:+UseContainerSupport \
    -XX:MaxRAMPercentage=75.0 \
    -XX:InitialRAMPercentage=50.0 \
    -XX:+UseG1GC \
    -XX:+UseStringDeduplication \
    -XX:MaxGCPauseMillis=200 \
    -Djava.security.egd=file:/dev/./urandom \
    -Dspring.backgroundpreinitializer.ignore=true"

# Use exec form to ensure proper signal handling
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS org.springframework.boot.loader.launch.JarLauncher"]

# ============================================================================
# Build Instructions:
# ============================================================================
# Build with BuildKit for better caching:
#   DOCKER_BUILDKIT=1 docker build -t obs-demo:latest .
#
# Build with specific target stage:
#   docker build --target builder -t obs-demo:builder .
#
# Build with cache from registry:
#   docker build --cache-from obs-demo:latest -t obs-demo:latest .
# ============================================================================

