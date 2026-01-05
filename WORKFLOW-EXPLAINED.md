# 🔄 GitHub Actions Workflow Açıklaması

## 📋 Workflow Yapısı

Workflow **3 ayrı job**'a bölünmüştür:

```
┌─────────────────┐
│  1. Maven Build │  → JAR oluştur + Test çalıştır
└────────┬────────┘
         │ Artifact (JAR dosyası)
         ↓
┌─────────────────┐
│ 2. Docker Build │  → Docker image oluştur (push YOK)
└────────┬────────┘
         │ Artifact (Docker image .tar)
         ↓
┌─────────────────┐
│ 3. Docker Push  │  → DockerHub'a push et
└─────────────────┘
```

---

## 🎯 Neden Bu Yapı?

### Avantajlar:

1. **Modülerlik** - Her aşama bağımsız
2. **Hata ayıklama** - Hangi aşamada hata olduğu net görülür
3. **Yeniden çalıştırma** - Sadece başarısız job tekrar çalışır
4. **Pull Request güvenliği** - PR'larda push yapılmaz
5. **Artifact paylaşımı** - Job'lar arası veri paylaşımı
6. **Paralel çalışma** - Bağımsız job'lar paralel çalışabilir

### Dezavantajlar (Minimal):

- Artifact upload/download zamanı (~10 saniye)
- Biraz daha kompleks yapı

---

## 🔍 Job Detayları

### JOB 1: Maven Build and Test

**Görev:** JAR dosyası oluşturmak ve testleri çalıştırmak

**Adımlar:**
1. ✅ Code checkout
2. ✅ Java 21 kurulumu (Maven cache ile)
3. ✅ Maven build (`mvn clean package -DskipTests`)
4. ✅ Test çalıştırma (`mvn test`)
5. ✅ JAR artifact'i upload et

**Çıktı:**
- `target/*.jar` - Çalıştırılabilir JAR
- `target/*.jar.original` - Original JAR
- `pom.xml` - Maven config

**Süre:** ~45-60 saniye (cache ile ~20 saniye)

**Çalışma Koşulu:** Her push, PR, tag

---

### JOB 2: Docker Build

**Görev:** Docker image oluşturmak (DockerHub'a push **YOK**)

**Adımlar:**
1. ✅ Code checkout
2. ✅ Docker Buildx kurulumu
3. ✅ Tag'leri oluştur (metadata-action)
4. ✅ Docker build (layer cache ile)
5. ✅ Image'ı tar dosyası olarak kaydet
6. ✅ Tar artifact'i upload et

**Çıktı:**
- `/tmp/obs-demo-image.tar` - Docker image

**Süre:** ~60-90 saniye (cache ile ~15-30 saniye)

**Çalışma Koşulu:** Maven build başarılı olduysa

**Özellikler:**
- Multi-stage build
- BuildKit cache (registry cache)
- Layer optimization
- No push (sadece build)

---

### JOB 3: Docker Push to DockerHub

**Görev:** Build edilmiş image'ı DockerHub'a push etmek

**Adımlar:**
1. ✅ Code checkout
2. ✅ Docker Buildx kurulumu
3. ✅ DockerHub login
4. ✅ Docker image artifact'i download et
5. ✅ Image'ı load et
6. ✅ Tag'le ve DockerHub'a push et
7. ✅ Doğrulama

**Süre:** ~30-60 saniye (layer cache sayesinde)

**Çalışma Koşulu:**
- Docker build başarılı **VE**
- Event `pull_request` **DEĞİL** (sadece main/develop/tag'lerde push)

**Push edilir:**
- ✅ Push to `main` branch
- ✅ Push to `develop` branch
- ✅ Git tag (`v*`)
- ❌ Pull request (güvenlik için push yapılmaz)

---

## 🏷️ Tag Stratejisi

Workflow otomatik olarak şu tag'leri oluşturur:

| Event | Oluşturulan Tag'ler | Örnek |
|-------|---------------------|-------|
| Push to `main` | `main`, `main-abc1234`, `latest` | `obs-demo:main` |
| Push to `develop` | `develop`, `develop-abc1234` | `obs-demo:develop` |
| Tag `v1.2.3` | `1.2.3`, `1.2`, `1`, `latest` | `obs-demo:1.2.3` |
| Pull Request #42 | `pr-42` | `obs-demo:pr-42` (push edilmez) |

---

## 📦 Artifact Sistemi

### Neden Artifact Kullanıyoruz?

Job'lar arasında veri paylaşımı için GitHub Actions artifact sistemi kullanılır.

### Maven Artifacts

**Kaynak:** Job 1 (Maven Build)  
**Kullanıcı:** Job 2 (Docker Build) - opsiyonel  
**İçerik:**
- `target/*.jar`
- `pom.xml`

**Retention:** 1 gün (maliyeti azaltmak için)

### Docker Image Artifact

**Kaynak:** Job 2 (Docker Build)  
**Kullanıcı:** Job 3 (Docker Push)  
**İçerik:**
- Docker image (tar formatında)

**Boyut:** ~150-200 MB (compressed)  
**Retention:** 1 gün

---

## 🔐 Pull Request Güvenliği

### Neden PR'larda Push Yok?

```yaml
if: github.event_name != 'pull_request'
```

**Güvenlik nedenleri:**

1. ✅ **Fork'lardan gelen PR'lar** - Zararlı kod DockerHub'a push edilemez
2. ✅ **Test amaçlı PR'lar** - Gereksiz image oluşturmaz
3. ✅ **Spam koruması** - DockerHub rate limit koruması
4. ✅ **Cost efficiency** - Gereksiz push'ları önler

**PR'larda ne olur:**

```
✅ Maven Build    → Çalışır
✅ Docker Build   → Çalışır (push etmeden test eder)
❌ Docker Push    → ATLANIR (skip edilir)
```

**Sonuç:** PR'lar güvenle test edilir ama image push edilmez.

---

## 🚀 Workflow Senaryoları

### Senaryo 1: Normal Push (main branch)

```bash
git push origin main
```

**Ne olur:**

1. ✅ **Maven Build** çalışır → JAR oluşturur (60s)
2. ✅ **Docker Build** çalışır → Image oluşturur (30s)
3. ✅ **Docker Push** çalışır → DockerHub'a push eder (40s)

**Toplam:** ~130 saniye (cache ile ~60 saniye)

**Sonuç:**
- ✅ JAR artifact oluşturuldu
- ✅ Docker image oluşturuldu
- ✅ DockerHub'a push edildi
- ✅ Tag: `main`, `main-abc1234`, `latest`

---

### Senaryo 2: Pull Request

```bash
git push origin feature-branch
# GitHub'da PR aç: feature-branch → main
```

**Ne olur:**

1. ✅ **Maven Build** çalışır → JAR oluşturur
2. ✅ **Docker Build** çalışır → Image oluşturur
3. ⏭️ **Docker Push** ATLANIR → `if: github.event_name != 'pull_request'`

**Toplam:** ~90 saniye

**Sonuç:**
- ✅ Build test edildi
- ✅ Image oluşturuldu (local artifact)
- ❌ DockerHub'a push **EDİLMEDİ** (güvenlik)
- ℹ️ Tag: `pr-42` (sadece build)

---

### Senaryo 3: Release (Tag)

```bash
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

**Ne olur:**

1. ✅ **Maven Build** çalışır
2. ✅ **Docker Build** çalışır
3. ✅ **Docker Push** çalışır

**Toplam:** ~130 saniye

**Sonuç:**
- ✅ Semantic version tag'leri oluşturuldu
- ✅ DockerHub'a push edildi
- ✅ Tag: `1.0.0`, `1.0`, `1`, `latest`

---

## 📊 Build Cache Mekanizması

### Maven Cache

```yaml
- name: Set up JDK 21
  uses: actions/setup-java@v4
  with:
    cache: 'maven'  # Maven dependencies cache'lenir
```

**Avantaj:** Dependencies tekrar indirilmez (~40 saniye kazanç)

### Docker Layer Cache

```yaml
cache-from: type=registry,ref=$USERNAME/obs-demo:buildcache
cache-to: type=registry,ref=$USERNAME/obs-demo:buildcache,mode=max
```

**Avantaj:** Docker layer'ları DockerHub'da cache'lenir

**Cache stratejisi:**
- Dependencies layer → Cache'den (pom.xml değişmezse)
- Application layer → Rebuild (kod değişirse)

---

## 🔍 Job Dependencies (Bağımlılıklar)

```yaml
jobs:
  maven-build:
    # Bağımlılık yok, ilk çalışır

  docker-build:
    needs: maven-build  # Maven başarılı olmalı
    
  docker-push:
    needs: docker-build  # Docker build başarılı olmalı
    if: github.event_name != 'pull_request'
```

**Mantık:**

```
maven-build başarısız → docker-build çalışmaz → docker-push çalışmaz
docker-build başarısız → docker-push çalışmaz
docker-push (PR) → ATLANIR
```

---

## 🎯 Job Output ve Summary

Her job GitHub Actions summary'ye bilgi yazar:

### Maven Build Summary

```markdown
## ✅ Maven Build Successful

- Java Version: 21
- Build Tool: Maven
- Artifact: obs-demo-1.0.0-SNAPSHOT.jar
```

### Docker Build Summary

```markdown
## 🐳 Docker Build Successful

**Image:** username/obs-demo

**Tags:**
```
username/obs-demo:main
username/obs-demo:main-abc1234
username/obs-demo:latest
```
```

### Docker Push Summary

```markdown
## 🚀 Push to DockerHub Successful

✅ **Status:** Successfully pushed to DockerHub

📦 **Repository:** https://hub.docker.com/r/username/obs-demo

🏷️ **Pushed Tags:**
```
username/obs-demo:main
username/obs-demo:latest
```

**Pull command:**
```bash
docker pull username/obs-demo:latest
```
```

---

## 🛠️ Troubleshooting

### Job 1 Başarısız (Maven Build)

**Olası nedenler:**
- ❌ Compilation error
- ❌ Test failure
- ❌ pom.xml hatası

**Çözüm:**
1. Job loglarını incele
2. Local'de test et: `mvn clean package`
3. Düzelt ve yeniden push et

---

### Job 2 Başarısız (Docker Build)

**Olası nedenler:**
- ❌ Dockerfile syntax hatası
- ❌ Base image çekilemiyor
- ❌ Build context problemi

**Çözüm:**
1. Local'de test et: `make build`
2. Dockerfile'ı kontrol et
3. BuildKit cache temizle

---

### Job 3 Başarısız (Docker Push)

**Olası nedenler:**
- ❌ DockerHub credentials yanlış
- ❌ Token yetkisi yetersiz
- ❌ Network timeout

**Çözüm:**
1. Secrets'ı kontrol et
2. Token'ı yenile (Read, Write, Delete)
3. Yeniden çalıştır

---

## 📈 Performans Optimizasyonları

### Uygulanan Optimizasyonlar:

1. ✅ **Maven cache** - Dependencies cache'lenir
2. ✅ **Docker layer cache** - Registry'de cache
3. ✅ **BuildKit** - Paralel build, cache optimization
4. ✅ **Artifact reuse** - Job'lar arası veri paylaşımı
5. ✅ **Conditional push** - Gereksiz push'ları önle

### Performans Metrikleri:

| Durum | İlk Run | Cached Run | Kazanç |
|-------|---------|------------|--------|
| Maven Build | 60s | 20s | 67% |
| Docker Build | 90s | 30s | 67% |
| Docker Push | 60s | 40s | 33% |
| **Toplam** | **210s** | **90s** | **57%** |

---

## ✅ Sonuç

### Workflow Özeti:

- 🎯 **3 bağımsız job** - Modüler yapı
- 🔒 **PR güvenliği** - Fork'lardan gelen PR'lar güvenli
- 📦 **Artifact sistemi** - Job'lar arası veri paylaşımı
- ⚡ **Cache mekanizması** - %57 daha hızlı
- 🏷️ **Otomatik tagging** - Semantic versioning
- 📊 **Detaylı summary** - Her aşama raporlanır

### İş Akışı:

```
Push/Tag → Maven Build → Docker Build → Docker Push → DockerHub ✅
Pull Request → Maven Build → Docker Build → ATLA → Güvenli Test ✅
```

🎉 **Production-ready CI/CD pipeline!**

