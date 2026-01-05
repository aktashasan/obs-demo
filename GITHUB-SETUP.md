# 🔐 GitHub Secrets Yapılandırması

GitHub Actions workflow'unun çalışması için aşağıdaki environment variable'ları (secrets) GitHub repository'nize eklemeniz gerekiyor.

---

## 📋 Tanımlanması Gereken Secrets

**Yol:** GitHub Repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

---

## 1️⃣ DOCKERHUB_USERNAME

**Açıklama:** DockerHub kullanıcı adınız

**Nasıl Bulunur:**
1. https://hub.docker.com adresine gidin
2. Login olun
3. Sağ üst köşedeki kullanıcı adınızı kopyalayın

**Örnek Değer:** `hasanaktas` veya `mycompany`

---

## 2️⃣ DOCKERHUB_TOKEN

**Açıklama:** DockerHub Access Token (şifre değil, güvenli token)

**Nasıl Oluşturulur:**

### Adım 1: DockerHub'a Gidin
https://hub.docker.com → Login

### Adım 2: Access Token Oluşturun
1. **Account Settings** (sağ üst profil)
2. **Security** sekmesi
3. **Access Tokens** bölümü
4. **New Access Token** butonuna tıklayın

### Adım 3: Token Ayarları
- **Description:** `github-actions` (veya istediğiniz isim)
- **Access permissions:** **Read, Write, Delete** seçin
- **Generate** butonuna tıklayın

### Adım 4: Token'ı Kopyalayın
⚠️ **ÖNEMLİ:** Token sadece bir kez gösterilir! Hemen kopyalayın.

**Token Formatı:** `dckr_pat_AbCdEfGhIjKlMnOpQrStUvWxYz1234567890`

---

## 🔧 GitHub'a Secret Ekleme

### Her Secret için:

1. GitHub repository'ye gidin
2. **Settings** → **Secrets and variables** → **Actions**
3. **New repository secret** butonuna tıklayın
4. **Name:** Secret adını girin (tam olarak bu isimler)
   - `DOCKERHUB_USERNAME`
   - `DOCKERHUB_TOKEN`
5. **Secret:** İlgili değeri yapıştırın
6. **Add secret** butonuna tıklayın

---

## ✅ Kontrol Listesi

Secret'ları ekledikten sonra şunları görmelisiniz:

```
✓ DOCKERHUB_USERNAME
✓ DOCKERHUB_TOKEN
```

⚠️ Secret değerleri güvenlik nedeniyle **gösterilmez**, sadece isimleri görünür.

---

## 🚀 Workflow'u Test Etme

### Manuel Çalıştırma

1. Repository'de **Actions** sekmesine gidin
2. Sol menüden **"Build and Push to DockerHub"** seçin
3. Sağ tarafta **"Run workflow"** butonuna tıklayın
4. Branch seçin (main)
5. **"Run workflow"** tekrar tıklayın

### Otomatik Çalışma

Workflow şu durumlarda otomatik çalışır:
- ✅ `main` branch'ine push
- ✅ `develop` branch'ine push  
- ✅ `v*` tag oluşturma (örn: `v1.0.0`)
- ✅ `main`'e pull request

---

## 📦 Oluşturulacak Docker Image Tag'leri

| Durum | Tag Örnekleri |
|-------|--------------|
| Push to main | `latest`, `main`, `main-abc1234` |
| Push to develop | `develop`, `develop-abc1234` |
| Tag v1.2.3 | `1.2.3`, `1.2`, `1`, `latest` |

---

## 🔍 DockerHub'da Kontrol

Build tamamlandıktan sonra:

1. https://hub.docker.com → Login
2. **Repositories** → **obs-demo** repository
3. **Tags** sekmesinde yeni image'ları göreceksiniz

**Image URL:**
```
docker.io/YOUR_USERNAME/obs-demo:latest
```

---

## 🐳 Image'ı Kullanma

```bash
# Pull
docker pull YOUR_USERNAME/obs-demo:latest

# Run
docker run -d -p 8080:8080 YOUR_USERNAME/obs-demo:latest

# Test
curl http://localhost:8080/api/hello
```

---

## 🎯 Özet

**Gerekli İşlemler:**
1. ✅ DockerHub'da Access Token oluştur
2. ✅ GitHub'da 2 secret ekle (USERNAME ve TOKEN)
3. ✅ Code'u push et veya workflow'u manuel çalıştır
4. ✅ DockerHub'da image'ı kontrol et

**Tamamdır!** Her commit'te otomatik Docker image oluşturulacak! 🚀

