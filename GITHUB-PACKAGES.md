# 📦 GitHub Packages (Container Registry) Kullanımı

## 🎯 Nedir?

GitHub Container Registry (ghcr.io), Docker image'larınızı GitHub üzerinde barındırmanızı sağlar.

**Avantajlar:**
- ✅ GitHub ile entegre
- ✅ Ücretsiz public image'lar
- ✅ Private repository desteği
- ✅ GitHub Actions ile otomatik deploy
- ✅ Fine-grained access control

---

## 🚀 Otomatik Push (GitHub Actions)

### Workflow Eklendi: `build-push-multi-registry.yml`

Bu workflow **hem DockerHub hem de GitHub Packages**'a push eder!

```yaml
# Push edilecek yerler:
- docker.io/USERNAME/obs-demo:latest          # DockerHub
- ghcr.io/USERNAME/obs-demo:latest            # GitHub Packages
```

### Nasıl Çalışır?

```bash
# 1. Code'u push edin
git push origin main

# 2. Workflow otomatik çalışır
# 3. Her iki registry'ye de push edilir!
```

---

## 🔐 GitHub Token (Otomatik)

GitHub Actions için **manual setup gerekmez!**

Workflow otomatik olarak `GITHUB_TOKEN` kullanır:

```yaml
password: ${{ secrets.GITHUB_TOKEN }}
```

Bu token otomatik olarak her workflow'da oluşturulur.

---

## 💻 Manuel Push (Local'den)

### 1. GitHub Token Oluşturun

```
GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
→ Generate new token (classic)
```

**Seçilecek scope'lar:**
```
✅ write:packages    (Container Registry'ye yazma)
✅ read:packages     (Container Registry'den okuma)
✅ delete:packages   (Package silme - opsiyonel)
```

Token'ı kopyalayın: `ghp_...`

---

### 2. Environment Variable Ayarlayın

```bash
# ~/.zshrc veya ~/.bashrc dosyasına ekleyin:
export GITHUB_USERNAME="your-github-username"
export GITHUB_TOKEN="ghp_..."

# Aktif edin
source ~/.zshrc
```

---

### 3. Login Olun

```bash
# Makefile ile (kolay)
make ghcr-login
# Token'ı soracak, yapıştırın

# veya manuel
echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USERNAME --password-stdin
```

---

### 4. Build, Tag ve Push

```bash
# Build
make build

# GitHub Packages'a push
make ghcr-push

# Veya her iki registry'ye birden
make push-all
```

---

## 📥 Image'ı Çekme (Pull)

### Public Image (Login Gerekmez)

```bash
# Makefile ile
make ghcr-pull

# veya manuel
docker pull ghcr.io/YOUR_USERNAME/obs-demo:latest
```

---

### Private Image (Login Gerekir)

```bash
# Login ol
echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USERNAME --password-stdin

# Pull yap
docker pull ghcr.io/YOUR_USERNAME/obs-demo:latest
```

---

## 🏷️ Tag Stratejisi

Workflow otomatik olarak şu tag'leri oluşturur:

### DockerHub:
```
docker.io/USERNAME/obs-demo:latest
docker.io/USERNAME/obs-demo:main
docker.io/USERNAME/obs-demo:main-abc1234
```

### GitHub Packages:
```
ghcr.io/USERNAME/obs-demo:latest
ghcr.io/USERNAME/obs-demo:main
ghcr.io/USERNAME/obs-demo:main-abc1234
```

**Aynı tag'ler, farklı registry'ler!**

---

## 🌐 Package Visibility

### Default: Private

Yeni image'lar **private** olarak oluşturulur.

### Public Yapma:

```
1. GitHub → Your Profile → Packages
2. obs-demo package'ini seç
3. Package settings
4. Change visibility → Public
5. Confirm
```

**Artık herkes çekebilir! (login gerekmez)**

---

## 📊 Kullanım Karşılaştırması

### DockerHub:

```bash
# Pull
docker pull YOUR_USERNAME/obs-demo:latest

# Run
docker run -p 8080:8080 YOUR_USERNAME/obs-demo:latest
```

**Avantajlar:**
- ✅ Popüler, yaygın kullanım
- ✅ Docker Hub web UI
- ✅ Otomatik README sync

---

### GitHub Packages:

```bash
# Pull
docker pull ghcr.io/YOUR_USERNAME/obs-demo:latest

# Run
docker run -p 8080:8080 ghcr.io/YOUR_USERNAME/obs-demo:latest
```

**Avantajlar:**
- ✅ GitHub ile entegre
- ✅ Source code ile aynı yerde
- ✅ GitHub Actions entegrasyonu
- ✅ Fine-grained permissions

---

## 🛠️ Makefile Komutları

### GitHub Packages:

```bash
make ghcr-login    # GitHub Container Registry'ye login
make ghcr-tag      # Image'ı ghcr.io için tag'le
make ghcr-push     # GitHub Packages'a push et
make ghcr-pull     # GitHub Packages'tan pull et
```

### Multi-Registry:

```bash
make push-all      # Hem DockerHub hem GHCR'a push et
```

### DockerHub (Mevcut):

```bash
make tag           # DockerHub için tag
make push          # DockerHub'a push
make pull          # DockerHub'dan pull
```

---

## 🔍 Package'ları Görüntüleme

### Web UI:

```
https://github.com/YOUR_USERNAME?tab=packages
```

### Belirli Package:

```
https://github.com/users/YOUR_USERNAME/packages/container/obs-demo
```

---

## 🎯 Kubernetes'te Kullanım

### Public Image:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: obs-demo
spec:
  template:
    spec:
      containers:
      - name: obs-demo
        # DockerHub
        image: docker.io/USERNAME/obs-demo:latest
        
        # veya GitHub Packages
        image: ghcr.io/USERNAME/obs-demo:latest
```

---

### Private Image:

```bash
# 1. Secret oluştur
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=YOUR_USERNAME \
  --docker-password=YOUR_GITHUB_TOKEN \
  --docker-email=your-email@example.com

# 2. Deployment'ta kullan
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: obs-demo
spec:
  template:
    spec:
      imagePullSecrets:
      - name: ghcr-secret
      containers:
      - name: obs-demo
        image: ghcr.io/USERNAME/obs-demo:latest
```

---

## 🐳 Docker Compose

```yaml
version: '3.8'
services:
  obs-demo:
    # DockerHub
    image: docker.io/USERNAME/obs-demo:latest
    
    # veya GitHub Packages
    # image: ghcr.io/USERNAME/obs-demo:latest
    
    ports:
      - "8080:8080"
```

---

## 📈 Storage ve Limits

### GitHub Packages:

- **Public:** Unlimited storage, unlimited bandwidth
- **Private:** 500 MB storage, 1 GB bandwidth/month (ücretsiz)

### DockerHub:

- **Free:** Unlimited public, 1 private repo
- **Rate Limit:** 100 pulls/6 hours (anonymous)

---

## 🔄 Workflow Detayları

### build-push-multi-registry.yml

```yaml
# Login to both registries
- DockerHub (with DOCKERHUB_TOKEN)
- GitHub Packages (with GITHUB_TOKEN)

# Build once
- Multi-platform: linux/amd64, linux/arm64

# Push to both
- docker.io/USERNAME/obs-demo
- ghcr.io/USERNAME/obs-demo
```

**Avantaj:** Tek build, çift push! Hem DockerHub hem GitHub Packages güncel!

---

## 🎓 Best Practices

### Development:

```bash
# GitHub Packages kullan (source code ile aynı yerde)
docker pull ghcr.io/USERNAME/obs-demo:latest
```

### Production:

```bash
# DockerHub kullan (yaygın, güvenilir)
docker pull docker.io/USERNAME/obs-demo:1.0.0
```

### CI/CD:

```bash
# Her ikisine de push et (yedekleme)
make push-all
```

---

## 🆘 Troubleshooting

### Hata: "denied: permission_denied"

**Çözüm:** Token scope'larını kontrol edin, `write:packages` olmalı

---

### Hata: "unauthorized: authentication required"

**Çözüm:** Login olun
```bash
make ghcr-login
```

---

### Package Görünmüyor

**Çözüm:** İlk push'tan sonra package oluşur. Profil → Packages'ta görünür.

---

## ✅ Quick Start

```bash
# 1. Token oluştur (write:packages)
# 2. Environment variable ayarla
export GITHUB_USERNAME="your-username"
export GITHUB_TOKEN="ghp_..."

# 3. Login
make ghcr-login

# 4. Build ve push
make build
make ghcr-push

# 5. Kontrol et
https://github.com/YOUR_USERNAME?tab=packages

# 6. Pull ve test
make ghcr-pull
docker run -p 8080:8080 ghcr.io/YOUR_USERNAME/obs-demo:latest
curl http://localhost:8080/api/hello
```

---

## 🎉 Özet

| Özellik | DockerHub | GitHub Packages |
|---------|-----------|-----------------|
| **Registry** | docker.io | ghcr.io |
| **Login** | DOCKERHUB_TOKEN | GITHUB_TOKEN |
| **Visibility** | Public default | Private default |
| **Integration** | Standalone | GitHub entegre |
| **Kullanım** | `make push` | `make ghcr-push` |
| **Web UI** | hub.docker.com | github.com/packages |

**Her ikisini de kullanabilirsiniz!**

🚀 **Workflow otomatik her ikisine de push eder!**

