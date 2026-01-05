# 📦 Maven GitHub Packages Kullanımı

## 🎯 Ne Yapıldı?

Maven JAR artifact'ları artık GitHub Packages'a otomatik deploy ediliyor!

**Deploy Edilen:**
- JAR dosyası (obs-demo-1.0.0.jar)
- POM dosyası
- Metadata

**URL:** `https://maven.pkg.github.com/YOUR_USERNAME/obs-demo`

---

## 🚀 Otomatik Deploy (GitHub Actions)

### Workflow Otomatik Çalışır:

```bash
git push origin main
```

**Pipeline:**
```
1. Maven Build → JAR oluşturur
2. Maven Deploy → GitHub Packages'a push eder
3. Docker Build → Container image oluşturur
4. Docker Push → DockerHub + GHCR'a push eder
```

**Sadece `main` branch için deploy edilir!**

---

## 📥 Maven Package'ı Kullanma (Başka Projeden)

### 1. GitHub Token Oluştur

```
GitHub → Settings → Developer settings → Personal access tokens
→ Generate new token (classic)

Scope:
✅ read:packages
```

Token'ı kopyala: `ghp_...`

---

### 2. Maven settings.xml Yapılandır

Dosya: `~/.m2/settings.xml`

```xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0">
  <servers>
    <server>
      <id>github</id>
      <username>YOUR_GITHUB_USERNAME</username>
      <password>ghp_YOUR_TOKEN</password>
    </server>
  </servers>
</settings>
```

---

### 3. Projenizin pom.xml'ine Ekleyin

```xml
<repositories>
  <repository>
    <id>github</id>
    <name>GitHub Packages</name>
    <url>https://maven.pkg.github.com/YOUR_USERNAME/obs-demo</url>
  </repository>
</repositories>

<dependencies>
  <dependency>
    <groupId>com.observability</groupId>
    <artifactId>obs-demo</artifactId>
    <version>1.0.0</version>
  </dependency>
</dependencies>
```

---

### 4. Maven Build

```bash
mvn clean install
```

Maven otomatik olarak GitHub Packages'tan dependency'yi çeker!

---

## 🔍 Package'ları Görüntüleme

### GitHub'da:

```
https://github.com/YOUR_USERNAME/obs-demo/packages
```

### Tüm Package'larınız:

```
https://github.com/YOUR_USERNAME?tab=packages
```

---

## 📊 Deploy Edilen Artifact Detayları

### Artifact Bilgileri:

```xml
<groupId>com.observability</groupId>
<artifactId>obs-demo</artifactId>
<version>1.0.0</version>
<packaging>jar</packaging>
```

### Maven Coordinates:

```
com.observability:obs-demo:1.0.0
```

---

## 🎯 Kullanım Senaryoları

### Senaryo 1: Microservice olarak kullanma

Başka bir Spring Boot projesinden obs-demo'yu dependency olarak ekleyin:

```xml
<dependency>
    <groupId>com.observability</groupId>
    <artifactId>obs-demo</artifactId>
    <version>1.0.0</version>
</dependency>
```

---

### Senaryo 2: JAR'ı direkt çalıştırma

```bash
# Package'tan indir (otomatik)
mvn dependency:copy \
  -Dartifact=com.observability:obs-demo:1.0.0 \
  -DoutputDirectory=.

# Çalıştır
java -jar obs-demo-1.0.0.jar
```

---

### Senaryo 3: Library olarak kullanma

obs-demo içindeki utility class'ları başka projelerde kullanın.

---

## 🔐 Güvenlik: Public vs Private

### Default: Public

Package otomatik olarak **public** oluşturulur (repository public ise).

### Private Yapma:

```
GitHub → Package → Package settings
→ Change visibility → Private
```

**Private ise:** Sadece token'ı olan kullanıcılar erişebilir.

---

## 🛠️ Gradle Kullanıcıları İçin

### build.gradle:

```groovy
repositories {
    maven {
        url = uri("https://maven.pkg.github.com/YOUR_USERNAME/obs-demo")
        credentials {
            username = project.findProperty("gpr.user") ?: System.getenv("GITHUB_USERNAME")
            password = project.findProperty("gpr.token") ?: System.getenv("GITHUB_TOKEN")
        }
    }
}

dependencies {
    implementation 'com.observability:obs-demo:1.0.0'
}
```

### gradle.properties:

```properties
gpr.user=YOUR_GITHUB_USERNAME
gpr.token=ghp_YOUR_TOKEN
```

---

## 📈 Version Yönetimi

### SNAPSHOT Version:

```xml
<version>1.0.0-SNAPSHOT</version>
```

**SNAPSHOT:** Development version, sık güncellenir

---

### Release Version:

```xml
<version>1.0.0</version>
```

**Release:** Stable version

---

### Version Güncelleme:

```bash
# pom.xml'de version'ı değiştir
<version>1.1.0</version>

# Commit ve push
git add pom.xml
git commit -m "chore: bump version to 1.1.0"
git push origin main

# Otomatik deploy edilir
```

---

## 🔄 CI/CD Akışı

### Full Pipeline:

```
1. Code push (main branch)
   ↓
2. Maven Build (JAR oluştur)
   ↓
3. Maven Deploy (GitHub Packages'a push)
   ↓
4. Docker Build (Container image)
   ↓
5. Docker Push (DockerHub + GHCR)
```

**3 farklı artifact:**
1. Maven JAR (GitHub Packages)
2. Docker Image (DockerHub)
3. Docker Image (GHCR)

---

## 📦 Package Özellikleri

| Özellik | Değer |
|---------|-------|
| **Type** | Maven JAR |
| **GroupId** | com.observability |
| **ArtifactId** | obs-demo |
| **Version** | 1.0.0 |
| **Registry** | GitHub Packages |
| **Visibility** | Public |
| **URL** | maven.pkg.github.com |

---

## 🆘 Troubleshooting

### Hata: "Could not find artifact"

**Çözüm:** 
1. settings.xml doğru mu?
2. Token geçerli mi?
3. Repository URL doğru mu?

```bash
# Test et
mvn dependency:get \
  -DremoteRepositories=github::default::https://maven.pkg.github.com/YOUR_USERNAME/obs-demo \
  -Dartifact=com.observability:obs-demo:1.0.0
```

---

### Hata: "401 Unauthorized"

**Çözüm:** Token scope'larını kontrol et

```
✅ read:packages (mutlaka olmalı)
```

---

### Hata: "Failed to deploy"

**Çözüm:** GitHub Actions için permissions kontrol et

```yaml
permissions:
  contents: read
  packages: write  # Bu satır olmalı
```

---

## 💡 Best Practices

### 1. Semantic Versioning

```
Major.Minor.Patch
1.0.0 → 1.0.1 (bugfix)
1.0.1 → 1.1.0 (new feature)
1.1.0 → 2.0.0 (breaking change)
```

---

### 2. SNAPSHOT vs Release

```
Development: 1.0.0-SNAPSHOT
Production:  1.0.0
```

---

### 3. Dependency Management

```xml
<dependencyManagement>
  <dependencies>
    <dependency>
      <groupId>com.observability</groupId>
      <artifactId>obs-demo</artifactId>
      <version>1.0.0</version>
    </dependency>
  </dependencies>
</dependencyManagement>
```

---

## 🎯 Özet

### Deploy Edilenler:

```
✅ Maven JAR      → GitHub Packages
✅ Docker Image   → DockerHub
✅ Docker Image   → GitHub Container Registry
```

### Kullanım:

```xml
<!-- pom.xml -->
<repository>
  <url>https://maven.pkg.github.com/YOUR_USERNAME/obs-demo</url>
</repository>

<dependency>
  <groupId>com.observability</groupId>
  <artifactId>obs-demo</artifactId>
  <version>1.0.0</version>
</dependency>
```

### Komut:

```bash
mvn clean install
```

🎉 **Maven package hazır ve kullanıma hazır!**

