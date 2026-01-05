# 🔧 DockerHub Token Hatası Çözümü

## ❌ Hata Mesajı

```
ERROR: failed to build: failed to solve: failed to fetch oauth token: 
unexpected status from GET request to https://auth.docker.io/token
401 Unauthorized: access token has insufficient scopes
```

---

## 🔍 Sorun Nedir?

DockerHub Access Token'ının **yetersiz yetkisi** var. Token oluşturulurken doğru izinler verilmemiş.

**Olası nedenler:**
1. ❌ Token "Read-only" olarak oluşturulmuş
2. ❌ Token "Read & Write" ama "Delete" yetkisi yok
3. ❌ Token süresi dolmuş
4. ❌ Token yanlış kopyalanmış

---

## ✅ Çözüm: Token'ı Yeniden Oluştur

### Adım 1: DockerHub'a Giriş Yapın

1. https://hub.docker.com adresine gidin
2. Kullanıcı adı ve şifrenizle login olun

---

### Adım 2: Eski Token'ı Silin (Opsiyonel)

1. Sağ üst köşeden **Account Settings** (profil ikonu)
2. **Security** sekmesine tıklayın
3. **Access Tokens** bölümünü bulun
4. Eski `github-actions` token'ı bulun
5. **Delete** butonuna tıklayın
6. Onaylayın

---

### Adım 3: Yeni Token Oluşturun

1. **Access Tokens** bölümünde
2. **New Access Token** butonuna tıklayın

#### Token Ayarları:

**Description (Token açıklaması):**
```
github-actions-obs-demo
```

**Access permissions (Yetkiler):**
```
✅ Read, Write, Delete
```

⚠️ **ÇOK ÖNEMLİ:** Mutlaka **"Read, Write, Delete"** seçin!

**"Read-only"** veya sadece **"Read, Write"** YETERLI DEĞİL!

3. **Generate** butonuna tıklayın

---

### Adım 4: Token'ı Kopyalayın

Token şu şekilde görünecek:

```
dckr_pat_AbCdEfGhIjKlMnOpQrStUvWxYz1234567890-EXAMPLE
```

⚠️ **ÖNEMLİ:** 
- Bu token **sadece bir kez** gösterilir!
- Hemen kopyalayın ve güvenli bir yere kaydedin
- Sayfayı kapatırsanız bir daha göremezsiniz

**Kopyalama:**
- Mac: `Cmd + C`
- Windows: `Ctrl + C`

---

### Adım 5: GitHub Secret'ı Güncelleyin

1. GitHub repository'nize gidin
2. **Settings** → **Secrets and variables** → **Actions**
3. **DOCKERHUB_TOKEN** secret'ını bulun
4. Sağdaki **üç nokta (...)** → **Update**
5. Yeni token'ı yapıştırın
6. **Update secret** butonuna tıklayın

---

## ✅ Doğrulama: Token Çalışıyor mu?

### Manuel Test (Local)

```bash
# Token'ı environment variable olarak ayarla
export DOCKERHUB_USERNAME="your-username"
export DOCKERHUB_TOKEN="dckr_pat_..."

# Login test et
echo "$DOCKERHUB_TOKEN" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin

# Başarılı olursa:
# Login Succeeded
```

**Başarılı ise:** ✅ Token doğru çalışıyor  
**Hata verirse:** ❌ Token hatalı, tekrar oluşturun

---

### GitHub Actions'da Test

#### Yöntem 1: Manuel Workflow Çalıştır

1. GitHub repository → **Actions** sekmesi
2. Sol menüden **"Build and Push to DockerHub"** seçin
3. Sağda **"Run workflow"** butonu
4. Branch seçin: **main**
5. **"Run workflow"** tekrar tıklayın

**Sonuç kontrol:**
- ✅ Yeşil tik → Başarılı
- ❌ Kırmızı X → Hala hata var

---

#### Yöntem 2: Commit ile Tetikle

```bash
# Küçük bir değişiklik yap
echo "# Token fixed" >> README.md

# Commit et
git add README.md
git commit -m "test: verify dockerhub token"

# Push et
git push origin main
```

**Actions sekmesinde** workflow'u izleyin.

---

## 🔍 Hata Devam Ediyorsa

### Kontrol Listesi

#### 1. Username Doğru mu?

```bash
# GitHub Secrets'ta kontrol et
Settings → Secrets → DOCKERHUB_USERNAME
```

**Doğru format:**
- ✅ `hasanaktas`
- ✅ `mycompany`
- ❌ `https://hub.docker.com/u/hasanaktas` (URL DEĞİL!)
- ❌ `hasanaktas@email.com` (Email DEĞİL!)

---

#### 2. Token Formatı Doğru mu?

**Doğru format:**
```
dckr_pat_xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

**Yanlış formatlar:**
- ❌ Şifreniz (token değil!)
- ❌ `ghp_...` (bu GitHub token!)
- ❌ Boşluk veya satır sonu karakteri var

---

#### 3. Token Yetkisi Yeterli mi?

DockerHub'da kontrol edin:

```
Account Settings → Security → Access Tokens
→ Token'ın yanında "Read, Write, Delete" yazmalı
```

**Sadece "Read" veya "Read, Write" YETERLI DEĞİL!**

---

#### 4. Token Aktif mi?

- Token silindi mi?
- Süresi doldu mu?
- DockerHub hesabı aktif mi?

---

## 🛠️ Alternatif Çözüm: Docker Password Kullan

⚠️ **Önerilmez ama acil durumlarda:**

```yaml
# Workflow'da
- name: Login to DockerHub
  uses: docker/login-action@v3
  with:
    username: ${{ secrets.DOCKERHUB_USERNAME }}
    password: ${{ secrets.DOCKERHUB_PASSWORD }}  # Token yerine şifre
```

**Ancak:**
- ❌ Güvenli değil
- ❌ Best practice değil
- ✅ Token kullanın!

---

## 📋 Adım Adım Çözüm Özeti

```
1. DockerHub → Security → Access Tokens
2. Eski token'ı SİL
3. NEW Access Token → "Read, Write, Delete" ✅
4. Generate → Token'ı KOPYALA
5. GitHub → Settings → Secrets → DOCKERHUB_TOKEN
6. Update secret → Yeni token'ı YAPIŞTIR
7. Test: Workflow'u manuel çalıştır
8. ✅ Başarılı!
```

---

## 🎯 Doğru Token Ayarları

### ✅ Doğru

```
Token Name: github-actions-obs-demo
Permissions: Read, Write, Delete
Description: CI/CD pipeline for obs-demo project
```

### ❌ Yanlış

```
Token Name: my-token
Permissions: Read-only          ← YANLIŞ!
```

```
Token Name: test
Permissions: Read, Write        ← YETERSİZ! (Delete eksik)
```

---

## 💡 Pro Tips

### 1. Token İsmi Açıklayıcı Olsun

```
✅ İyi: github-actions-obs-demo
✅ İyi: ci-cd-automation
❌ Kötü: token1
❌ Kötü: test
```

### 2. Her Proje İçin Ayrı Token

```
Project 1: github-actions-project1
Project 2: github-actions-project2
```

**Avantaj:** Bir token compromised olsa diğerleri güvende

### 3. Token'ları Düzenli Yenileyin

```
Her 6 ayda bir: Token'ı yenile
Eski token'ı sil
```

### 4. Token'ı Güvenli Saklayın

- ✅ Password manager (1Password, LastPass)
- ✅ GitHub Secrets
- ❌ Git commit'te
- ❌ Slack message'da
- ❌ Email'de

---

## 🔐 Güvenlik Best Practices

### Token Yetkilerini Minimize Edin

Sadece ihtiyacınız olanı verin:

```
CI/CD için: Read, Write, Delete ✅
Sadece pull için: Read-only ✅
Geliştirme için: Read, Write ✅
```

### Secret'ları Asla Commit Etmeyin

```bash
# .gitignore'a ekleyin
.env
secrets.txt
*.key
*.pem
```

### Token Leaked mi? Hemen Silin!

1. DockerHub → Access Tokens → **Delete**
2. GitHub → Settings → Secrets → **Update**
3. Yeni token oluştur

---

## 📞 Hala Çalışmıyor mu?

### GitHub Actions Loglarını İnceleyin

```
Actions → Failed workflow → Job: docker-push → Step: Login to DockerHub
```

**Logda arayın:**
- `401 Unauthorized` → Token/Username yanlış
- `403 Forbidden` → Yetki yetersiz
- `500 Internal Server Error` → DockerHub problemi

---

### DockerHub Status Kontrol

https://status.docker.com/

DockerHub'da sorun olabilir.

---

### Local Test

```bash
# Manuel login
docker login -u YOUR_USERNAME

# Token'ı girin (şifre olarak)
Password: dckr_pat_...

# Başarılı ise:
Login Succeeded
```

---

## ✅ Başarılı Sonuç

Workflow başarılı olduğunda göreceksiniz:

```
✅ Maven Build: Success
✅ Docker Build: Success  
✅ Docker Push: Success
✅ Image pushed to DockerHub
```

**DockerHub'da kontrol:**
```
https://hub.docker.com/r/YOUR_USERNAME/obs-demo/tags
```

Yeni tag'leri görmelisiniz! 🎉

---

## 📝 Özet

**Sorun:** Token yetkisi yetersiz (401 Unauthorized)

**Çözüm:**
1. ✅ Yeni token oluştur (Read, Write, Delete)
2. ✅ GitHub Secret'ı güncelle
3. ✅ Workflow'u test et

**Süre:** ~2-3 dakika

**Sonuç:** ✅ Pipeline çalışır!

---

🎉 **Token düzeldi mi? Harika! Şimdi push edebilirsiniz!**

