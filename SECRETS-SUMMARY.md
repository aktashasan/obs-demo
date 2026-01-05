# 🔐 GitHub Secrets - Hızlı Özet

## Tanımlanması Gereken 2 Secret:

### 1. DOCKERHUB_USERNAME
```
Değer: DockerHub kullanıcı adınız
Örnek: hasanaktas
```

**Nasıl Bulunur:**
- https://hub.docker.com → Login → Sağ üst köşedeki kullanıcı adı

---

### 2. DOCKERHUB_TOKEN
```
Değer: DockerHub Access Token
Format: dckr_pat_xxxxxxxxxxxxxxxxxxxxx
```

**Nasıl Oluşturulur:**
1. https://hub.docker.com → Login
2. **Account Settings** → **Security** → **Access Tokens**
3. **New Access Token** 
4. Name: `github-actions` veya `github-actions-obs-demo`
5. Permissions: ⚠️ **Mutlaka "Read, Write, Delete" seçin!**
   - ✅ "Read, Write, Delete" ← DOĞRU
   - ❌ "Read-only" ← YANLIŞ (hata verir!)
   - ❌ "Read, Write" ← YANLIŞ (Delete eksik!)
6. **Generate** → Token'ı kopyala (bir kez gösterilir!)

⚠️ **Önemli:** Yanlış yetki seçerseniz `401 Unauthorized` hatası alırsınız!

---

## GitHub'a Ekleme:

```
Repository → Settings → Secrets and variables → Actions → New repository secret
```

**İki secret ekleyin:**
- Name: `DOCKERHUB_USERNAME` → Value: `your-username`
- Name: `DOCKERHUB_TOKEN` → Value: `dckr_pat_...`

---

## ✅ Kontrol:

Settings → Secrets and variables → Actions sayfasında görmeli:
```
✓ DOCKERHUB_USERNAME
✓ DOCKERHUB_TOKEN
```

---

## 🚀 Test:

**Manuel:** Actions → Build and Push to DockerHub → Run workflow

**Otomatik:** `git push` yaptığınızda otomatik çalışır

---

## 📦 Sonuç:

Her push'ta otomatik olarak:
1. Maven build alınır
2. Docker image oluşturulur
3. DockerHub'a push edilir
4. `YOUR_USERNAME/obs-demo:latest` olarak yayınlanır

---

**Detaylı bilgi için:** `GITHUB-SETUP.md` dosyasına bakın.

