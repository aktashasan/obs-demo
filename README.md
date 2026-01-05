# Observability Demo Service (obs-demo)

A production-ready Spring Boot 4.0 microservice demonstrating comprehensive observability patterns with Prometheus metrics.

## Features

- ✅ Spring Boot 4.0 with Java 21 LTS
- ✅ Prometheus metrics exposition via Micrometer
- ✅ Custom HTTP request instrumentation (counter + timer)
- ✅ JVM metrics (memory, GC, threads, CPU)
- ✅ Kubernetes-ready health probes
- ✅ Low-cardinality metrics (path normalization)
- ✅ Production-ready configuration

## Project Structure

```
obs-demo/
├── pom.xml
├── src/main/
│   ├── java/com/example/observability/
│   │   ├── ObsDemoApplication.java          # Main application
│   │   ├── config/
│   │   │   └── MetricsConfig.java           # Metrics configuration
│   │   ├── controller/
│   │   │   ├── HelloController.java         # /api/hello endpoint
│   │   │   └── HealthController.java        # /healthz endpoint
│   │   └── filter/
│   │       └── MetricsFilter.java           # HTTP metrics instrumentation
│   └── resources/
│       └── application.yml                   # Application configuration
```

## Endpoints

### Application Endpoints

| Endpoint | Method | Description | Response |
|----------|--------|-------------|----------|
| `/api/hello` | GET | Returns greeting with timestamp | `{"message":"hello","timestamp":"2026-01-05T..."}` |
| `/healthz` | GET | Simple health check for K8s probes | `{"status":"ok"}` |

### Actuator Endpoints

| Endpoint | Description |
|----------|-------------|
| `/actuator/health` | Detailed health information with K8s probe support |
| `/actuator/prometheus` | Prometheus metrics in text format |
| `/actuator/info` | Application information |

## Metrics Exposed

### Custom Metrics

1. **`http_requests_total`** (Counter)
   - Description: Total number of HTTP requests
   - Labels: `method`, `endpoint`, `status`
   - Example: `http_requests_total{method="GET",endpoint="/api/hello",status="200"}`

2. **`http_request_duration_seconds`** (Timer/Histogram)
   - Description: HTTP request duration in seconds
   - Labels: `method`, `endpoint`, `status`
   - Includes percentiles and histogram buckets
   - Example: `http_request_duration_seconds{method="GET",endpoint="/api/hello",status="200"}`

### JVM Metrics (Auto-enabled)

- `jvm_memory_used_bytes` - JVM memory usage
- `jvm_memory_max_bytes` - JVM memory limits
- `jvm_gc_*` - Garbage collection metrics
- `jvm_threads_*` - Thread pool metrics
- `process_cpu_usage` - CPU usage
- `system_cpu_usage` - System CPU metrics

### Cardinality Protection

The `MetricsFilter` includes path normalization to prevent metric cardinality explosion:
- Well-known paths preserved: `/api/hello`, `/healthz`, `/actuator/*`
- Dynamic IDs replaced: `/api/users/123` → `/api/users/{id}`
- Query parameters removed

## Building and Running

### Prerequisites

- Java 21 (JDK) - LTS version
- Maven 3.6+

### Build

```bash
cd obs-demo
mvn clean package
```

### Run

```bash
mvn spring-boot:run
```

Or run the JAR directly:

```bash
java -jar target/obs-demo-1.0.0-SNAPSHOT.jar
```

The service will start on **port 8080**.

## Testing the Service

### 1. Test Hello Endpoint

```bash
curl http://localhost:8080/api/hello
```

Expected response:
```json
{"message":"hello","timestamp":"2026-01-05T12:34:56.789Z"}
```

### 2. Test Health Endpoint

```bash
curl http://localhost:8080/healthz
```

Expected response:
```json
{"status":"ok"}
```

### 3. Test Actuator Health

```bash
curl http://localhost:8080/actuator/health
```

### 4. View Prometheus Metrics

```bash
curl http://localhost:8080/actuator/prometheus
```

You should see metrics like:
```
# HELP http_requests_total Total number of HTTP requests
# TYPE http_requests_total counter
http_requests_total{application="obs-demo",endpoint="/api/hello",method="GET",status="200",} 1.0

# HELP http_request_duration_seconds HTTP request duration in seconds
# TYPE http_request_duration_seconds histogram
http_request_duration_seconds_bucket{application="obs-demo",endpoint="/api/hello",method="GET",status="200",le="0.01",} 1.0
...
```

## Configuration

Key configuration in `application.yml`:

```yaml
server:
  port: 8080

management:
  endpoints:
    web:
      exposure:
        include: health,prometheus,info  # Only expose necessary endpoints
  
  endpoint:
    health:
      probes:
        enabled: true  # Enable K8s liveness/readiness
  
  metrics:
    distribution:
      percentiles-histogram:
        http.server.requests: true  # Enable histogram
      slo:
        http.server.requests: 10ms,50ms,100ms,200ms,500ms,1s,2s,5s
```

## Kubernetes Integration

### Liveness Probe

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10
```

### Readiness Probe

```yaml
readinessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

### Prometheus Scrape Config

```yaml
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/path: "/actuator/prometheus"
  prometheus.io/port: "8080"
```

## Observability Best Practices

1. **Low Cardinality**: Endpoint paths are normalized to prevent cardinality explosion
2. **Histogram Buckets**: SLO-based buckets (10ms to 5s) for latency analysis
3. **Complete Coverage**: All HTTP requests are automatically instrumented
4. **JVM Metrics**: Full visibility into JVM health and resource usage
5. **Health Separation**: Simple `/healthz` for probes, detailed `/actuator/health` for monitoring

## Dependencies

- Spring Boot 4.0.0
- Spring Boot Starter Web
- Spring Boot Starter Actuator
- Micrometer Registry Prometheus

## License

This is a demo service for educational purposes.

