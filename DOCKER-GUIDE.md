# Docker & CI/CD Kullanım Kılavuzu

## 🐳 Docker Build ve Run

### Local Build

```bash
# Docker image oluştur
docker build -t obs-demo:local .

# Container çalıştır
docker run -d \
  --name obs-demo \
  -p 8080:8080 \
  obs-demo:local

# Test et
curl http://localhost:8080/api/hello

# Logları görüntüle
docker logs -f obs-demo

# Container'ı durdur
docker stop obs-demo
docker rm obs-demo
```

---

## 🚀 Docker Compose ile Çalıştırma

### Sadece Uygulama

```bash
# Başlat
docker-compose up -d

# Logları izle
docker-compose logs -f obs-demo

# Durdur
docker-compose down
```

### Monitoring Stack ile (Prometheus + Grafana)

```bash
# Tüm stack'i başlat
docker-compose --profile monitoring up -d

# Servisleri kontrol et
docker-compose ps

# Durdur ve temizle
docker-compose --profile monitoring down -v
```

**Erişim URL'leri:**
- Application: http://localhost:8080
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000 (admin/admin)

---

## 📦 DockerHub'dan Çekme

```bash
# Image'ı çek (GitHub Actions build'inden sonra)
docker pull YOUR_USERNAME/obs-demo:latest

# Çalıştır
docker run -d \
  --name obs-demo \
  -p 8080:8080 \
  YOUR_USERNAME/obs-demo:latest
```

---

## 🔧 Docker Image Özellikleri

### Multi-stage Build
- **Stage 1:** Maven build (eclipse-temurin:21-jdk)
- **Stage 2:** Runtime (eclipse-temurin:21-jre)
- **Sonuç:** Optimize edilmiş, küçük image boyutu

### Security
- ✅ Non-root user (spring user)
- ✅ Minimal runtime image (JRE only)
- ✅ Health check built-in

### JVM Optimizations
- Container-aware JVM settings
- Optimized memory usage (75% of container RAM)
- G1GC garbage collector
- String deduplication enabled

---

## 🎯 Image Tag'leri

GitHub Actions otomatik olarak şu tag'leri oluşturur:

```bash
# Latest (main branch)
YOUR_USERNAME/obs-demo:latest

# Branch name
YOUR_USERNAME/obs-demo:main
YOUR_USERNAME/obs-demo:develop

# Git commit SHA
YOUR_USERNAME/obs-demo:main-abc1234

# Semantic version (tag'lerden)
YOUR_USERNAME/obs-demo:1.0.0
YOUR_USERNAME/obs-demo:1.0
YOUR_USERNAME/obs-demo:1
```

---

## 🔍 Health Check

Container health check otomatik olarak çalışır:

```bash
# Container health durumunu kontrol et
docker inspect --format='{{.State.Health.Status}}' obs-demo

# Health check loglarını gör
docker inspect --format='{{json .State.Health}}' obs-demo | jq
```

---

## 📊 Container Metrics

### Container stats
```bash
docker stats obs-demo
```

### Container içindeki uygulama metrics
```bash
curl http://localhost:8080/actuator/prometheus
```

---

## 🛠️ Troubleshooting

### Container başlamıyor

```bash
# Logları kontrol et
docker logs obs-demo

# Container detaylarını gör
docker inspect obs-demo

# Interactive shell aç
docker exec -it obs-demo sh
```

### Memory sorunları

```bash
# JVM memory ayarlarını değiştir
docker run -d \
  --name obs-demo \
  -p 8080:8080 \
  -e JAVA_OPTS="-Xmx256m -Xms128m" \
  obs-demo:local
```

### Port çakışması

```bash
# Farklı port kullan
docker run -d \
  --name obs-demo \
  -p 9090:8080 \
  obs-demo:local

# Test et
curl http://localhost:9090/api/hello
```

---

## 🔄 CI/CD Pipeline

### Pipeline Akışı

```
Git Push → GitHub Actions → Maven Build → Docker Build → DockerHub Push
```

### Pipeline Adımları

1. ✅ **Checkout:** Code'u çek
2. ✅ **Setup Java:** JDK 21 kur
3. ✅ **Maven Build:** JAR oluştur
4. ✅ **Run Tests:** Unit test'leri çalıştır
5. ✅ **Docker Login:** DockerHub'a login ol
6. ✅ **Docker Build:** Multi-stage build
7. ✅ **Docker Push:** Image'ı push et
8. ✅ **Tag:** Otomatik versiyonlama

### Trigger Koşulları

- ✅ Push to `main` branch
- ✅ Push to `develop` branch
- ✅ Git tag (`v*` pattern)
- ✅ Pull request to `main`
- ✅ Manual trigger (workflow_dispatch)

---

## 📝 Environment Variables

### Runtime Değişkenler

```bash
docker run -d \
  --name obs-demo \
  -p 8080:8080 \
  -e SPRING_PROFILES_ACTIVE=prod \
  -e JAVA_OPTS="-Xmx512m" \
  obs-demo:local
```

### Desteklenen Değişkenler

| Variable | Açıklama | Default |
|----------|----------|---------|
| `JAVA_OPTS` | JVM parametreleri | Container-aware settings |
| `SPRING_PROFILES_ACTIVE` | Spring profile | default |
| `SERVER_PORT` | Uygulama portu | 8080 |

---

## 🎯 Production Best Practices

### Resource Limits

```bash
docker run -d \
  --name obs-demo \
  -p 8080:8080 \
  --memory="512m" \
  --memory-swap="512m" \
  --cpus="1" \
  obs-demo:local
```

### Logging

```bash
# JSON logging
docker run -d \
  --name obs-demo \
  -p 8080:8080 \
  --log-driver json-file \
  --log-opt max-size=10m \
  --log-opt max-file=3 \
  obs-demo:local
```

### Restart Policy

```bash
docker run -d \
  --name obs-demo \
  -p 8080:8080 \
  --restart unless-stopped \
  obs-demo:local
```

---

## 🚀 Kubernetes Deployment (Bonus)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: obs-demo
spec:
  replicas: 3
  selector:
    matchLabels:
      app: obs-demo
  template:
    metadata:
      labels:
        app: obs-demo
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8080"
        prometheus.io/path: "/actuator/prometheus"
    spec:
      containers:
      - name: obs-demo
        image: YOUR_USERNAME/obs-demo:latest
        ports:
        - containerPort: 8080
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /healthz
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
```

---

## ✅ Checklist

**Local Development:**
- [ ] Dockerfile oluşturuldu
- [ ] .dockerignore eklendi
- [ ] docker-compose.yml hazır
- [ ] Local'de test edildi

**CI/CD:**
- [ ] GitHub workflow oluşturuldu
- [ ] DOCKERHUB_USERNAME secret eklendi
- [ ] DOCKERHUB_TOKEN secret eklendi
- [ ] Pipeline test edildi

**Production:**
- [ ] Image DockerHub'da
- [ ] Health check çalışıyor
- [ ] Metrics expose ediliyor
- [ ] Resource limits tanımlandı

🎉 **Hazırsınız!**

