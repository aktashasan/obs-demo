# Quick Start Guide - obs-demo

## 🚀 Start the Application

```bash
cd obs-demo
mvn spring-boot:run
```

The service will start on **http://localhost:8080**

---

## 🧪 Test the Endpoints

### 1. Hello Endpoint
```bash
curl http://localhost:8080/api/hello
```

**Expected:**
```json
{"message":"hello","timestamp":"2026-01-05T13:31:30.974604Z"}
```

---

### 2. Health Check
```bash
curl http://localhost:8080/healthz
```

**Expected:**
```json
{"status":"ok"}
```

---

### 3. Actuator Health (detailed)
```bash
curl http://localhost:8080/actuator/health
```

---

### 4. Prometheus Metrics
```bash
curl http://localhost:8080/actuator/prometheus
```

---

## 📊 View Specific Metrics

### Custom HTTP Metrics
```bash
# Request counter
curl -s http://localhost:8080/actuator/prometheus | grep "http_requests_total"

# Request duration
curl -s http://localhost:8080/actuator/prometheus | grep "http_request_duration_seconds"
```

---

### JVM Metrics
```bash
# Memory usage
curl -s http://localhost:8080/actuator/prometheus | grep "jvm_memory_used_bytes"

# Garbage collection
curl -s http://localhost:8080/actuator/prometheus | grep "jvm_gc_"

# Thread metrics
curl -s http://localhost:8080/actuator/prometheus | grep "jvm_threads_"

# CPU usage
curl -s http://localhost:8080/actuator/prometheus | grep "process_cpu_usage"
```

---

## 🛠️ Development Commands

### Build the project
```bash
mvn clean package
```

### Run tests (if any)
```bash
mvn test
```

### Run with specific profile
```bash
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

### Run the JAR directly
```bash
java -jar target/obs-demo-1.0.0-SNAPSHOT.jar
```

---

## 🔍 Generate Load for Testing

### Hit the hello endpoint 10 times
```bash
for i in {1..10}; do curl -s http://localhost:8080/api/hello; done
```

### Check updated metrics
```bash
curl -s http://localhost:8080/actuator/prometheus | grep "http_requests_total.*hello"
```

---

## 🛑 Stop the Application

If running in foreground:
- Press `Ctrl+C`

If running in background:
```bash
# Find the process
ps aux | grep obs-demo

# Kill it
kill <PID>
```

---

## 📦 Package for Deployment

### Create executable JAR
```bash
mvn clean package
# JAR will be at: target/obs-demo-1.0.0-SNAPSHOT.jar
```

### Run in production mode
```bash
java -jar target/obs-demo-1.0.0-SNAPSHOT.jar
```

---

## 🐳 Docker Build (Optional)

If you want to containerize (requires Dockerfile):

```bash
# Build image
docker build -t obs-demo:latest .

# Run container
docker run -p 8080:8080 obs-demo:latest

# Test
curl http://localhost:8080/api/hello
```

---

## 🔧 Configuration

### Change Port
Edit `src/main/resources/application.yml`:
```yaml
server:
  port: 9090  # Change to desired port
```

### Enable Debug Logging
Run with debug flag:
```bash
mvn spring-boot:run -Dspring-boot.run.arguments=--debug
```

Or add to `application.yml`:
```yaml
logging:
  level:
    root: DEBUG
```

---

## 📚 Useful Endpoints

| Endpoint | Purpose | Example |
|----------|---------|---------|
| `/api/hello` | Main API endpoint | `curl http://localhost:8080/api/hello` |
| `/healthz` | Simple health probe | `curl http://localhost:8080/healthz` |
| `/actuator/health` | Detailed health | `curl http://localhost:8080/actuator/health` |
| `/actuator/prometheus` | All metrics | `curl http://localhost:8080/actuator/prometheus` |
| `/actuator/info` | App info | `curl http://localhost:8080/actuator/info` |

---

## 🎯 Key Metrics to Monitor

1. **Request Rate:** `http_requests_total`
2. **Latency:** `http_request_duration_seconds`
3. **Memory:** `jvm_memory_used_bytes`
4. **GC Pressure:** `jvm_gc_memory_allocated_bytes_total`
5. **Threads:** `jvm_threads_live_threads`
6. **CPU:** `process_cpu_usage`

---

## ✅ Verify Everything Works

Run this one-liner:
```bash
curl http://localhost:8080/api/hello && \
curl http://localhost:8080/healthz && \
curl -s http://localhost:8080/actuator/prometheus | grep "http_requests_total" && \
echo "✅ All systems operational!"
```

