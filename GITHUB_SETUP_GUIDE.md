# 🐙 인사이드잡 GitHub 설정 및 배포 가이드

**개발사**: (주)오픈커넥트  
**프로젝트**: 인사이드잡 - 현직자-구직자 매칭 플랫폼  
**배포 방식**: GitHub Pages (무료 호스팅)

---

## 📋 **필요한 GitHub 정보**

### **1. GitHub 계정 정보**
- **GitHub 계정명**: `your-github-username`
- **이메일**: GitHub 계정과 연결된 이메일
- **저장소명 권장**: `insidejob-platform` 또는 `career-matching-service`

### **2. 저장소 설정**
- **가시성**: Public (GitHub Pages 무료 사용을 위해)
- **라이선스**: MIT License 권장
- **README**: 자동 생성 체크
- **gitignore**: None (단순 HTML 프로젝트)

---

## 🚀 **단계별 설정 가이드**

### **1단계: GitHub 저장소 생성**

1. **GitHub.com 접속** → **New repository** 클릭
2. **Repository 설정**:
   ```
   Repository name: insidejob-platform
   Description: 현직자-구직자 매칭 플랫폼 (InsideJob)
   Public 선택 ✅
   Add a README file ✅
   Add .gitignore: None
   Choose a license: MIT License ✅
   ```
3. **Create repository** 클릭

### **2단계: 로컬에서 Git 초기 설정**

```bash
# 현재 insidejob 폴더에서 실행
cd /home/knoww/career-project/insidejob

# Git 저장소 초기화
git init

# GitHub 저장소와 연결 (본인 계정명으로 변경)
git remote add origin https://github.com/YOUR-USERNAME/insidejob-platform.git

# 사용자 정보 설정 (본인 정보로 변경)
git config user.name "Your Name"
git config user.email "your.email@example.com"

# 기본 브랜치 설정
git branch -M main
```

### **3단계: 초기 파일 준비**

현재 문서들을 정리해서 GitHub에 업로드:
```bash
# 현재 문서 상태 확인
ls -la /home/knoww/career-project/insidejob/

# 파일 추가
git add .

# 초기 커밋
git commit -m "Initial commit: 인사이드잡 프로젝트 문서 및 설정 파일"

# GitHub에 푸시
git push -u origin main
```

### **4단계: HTML 파일 생성 및 업로드**

기본 `index.html` 파일 생성:
```bash
# index.html 파일을 insidejob 폴더에 생성 후
git add index.html
git commit -m "Add: 기본 HTML 파일 추가 - Supabase 연동 완료"
git push origin main
```

### **5단계: GitHub Pages 활성화**

1. **GitHub 저장소 페이지**에서 **Settings** 탭 클릭
2. **Pages** 메뉴 (왼쪽 사이드바에서)
3. **Source** 설정:
   ```
   Deploy from a branch 선택
   Branch: main 선택
   Folder: / (root) 선택
   ```
4. **Save** 클릭
5. **약 5분 후** 배포 완료되면 URL 확인: 
   `https://YOUR-USERNAME.github.io/insidejob-platform/`

---

## 📁 **권장 파일 구조**

```
insidejob-platform/
├── index.html                    # 메인 SPA 파일 ⭐
├── README.md                     # 프로젝트 소개
├── docs/                         # 문서들
│   ├── PROJECT_OVERVIEW.md
│   ├── CAREER_CALCULATOR_DESIGN.md
│   ├── DATABASE_SCHEMA.sql
│   ├── DEVELOPMENT_ROADMAP.md
│   └── CLAUDE.md
├── assets/                       # 정적 자원 (나중에 추가)
│   ├── css/
│   ├── js/
│   └── images/
└── .github/                      # GitHub 설정 (선택)
    └── workflows/
        └── deploy.yml            # 자동 배포 (선택)
```

### **파일 이동 및 정리**
```bash
# 문서들을 docs 폴더로 정리
mkdir docs
mv *.md docs/
mv *.sql docs/

# assets 폴더 생성
mkdir -p assets/{css,js,images}

# 변경사항 커밋
git add .
git commit -m "Organize: 파일 구조 정리 - docs 폴더 분리"
git push origin main
```

---

## 🔧 **개발 워크플로**

### **일반적인 개발 프로세스**
```bash
# 1. 로컬에서 개발
# index.html 파일 수정...

# 2. 변경사항 확인
git status
git diff

# 3. 스테이징 및 커밋
git add .
git commit -m "Feature: 취업경쟁력 계산기 1단계 구현"

# 4. GitHub에 푸시 (자동 배포됨)
git push origin main

# 5. 약 1-2분 후 라이브 사이트에서 확인
# https://YOUR-USERNAME.github.io/insidejob-platform/
```

### **브랜치 전략 (선택사항)**
```bash
# 개발용 브랜치 생성
git checkout -b feature/calculator
# 개발 작업...
git commit -m "WIP: 계산기 개발 중"

# 완성 후 메인 브랜치에 병합
git checkout main
git merge feature/calculator
git push origin main
```

---

## 🌐 **도메인 설정 (선택사항)**

### **커스텀 도메인 연결**
1. **도메인 구매** (예: `insidejob.co.kr`)
2. **DNS 설정**:
   ```
   Type: CNAME
   Name: www
   Value: YOUR-USERNAME.github.io
   ```
3. **GitHub Settings > Pages**에서:
   ```
   Custom domain: www.insidejob.co.kr
   Enforce HTTPS 체크 ✅
   ```

### **서브도메인 활용**
```
메인 사이트: https://insidejob.co.kr
개발 버전: https://dev.insidejob.co.kr  
문서 사이트: https://docs.insidejob.co.kr
```

---

## ⚡ **자동 배포 설정 (선택사항)**

### **GitHub Actions 워크플로**
`.github/workflows/deploy.yml` 파일 생성:
```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        
    - name: Install dependencies (if any)
      run: npm install
      
    - name: Build project (if needed)
      run: npm run build
      
    - name: Deploy to GitHub Pages
      uses: peaceiris/actions-gh-pages@v3
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./
```

---

## 📊 **배포 확인 체크리스트**

### **배포 후 테스트 항목**
- [ ] ✅ 메인 페이지 로딩 확인
- [ ] ✅ Supabase 연결 성공 메시지 확인  
- [ ] ✅ 모바일 반응형 동작 확인
- [ ] ✅ 브라우저별 호환성 (Chrome, Safari, Firefox)
- [ ] ✅ HTTPS 인증서 정상 작동
- [ ] ✅ 페이지 로딩 속도 3초 이내

### **성능 모니터링**
- **Google PageSpeed Insights**: 성능 점수 90+ 목표
- **Google Search Console**: SEO 및 검색 노출 관리
- **Google Analytics**: 사용자 행동 분석 (나중에 추가)

---

## 🚨 **주의사항 및 팁**

### **보안 주의사항**
```javascript
// ✅ 공개 저장소에서 안전한 방법
const SUPABASE_URL = 'https://upsedttmnulbmarhawyj.supabase.co';
const SUPABASE_ANON_KEY = 'eyJ...'; // Anon key는 공개되어도 안전

// ❌ 절대 GitHub에 올리면 안 되는 것들
// Service Role Key (서버 전용)
// 개인 정보, 비밀번호
// API 시크릿 키
```

### **성능 최적화**
- **이미지 최적화**: WebP 포맷, 적절한 크기 조절
- **코드 압축**: HTML/CSS/JS 압축 (나중에 빌드 도구 추가 시)
- **CDN 활용**: GitHub Pages 자체가 글로벌 CDN

### **SEO 최적화**
```html
<!-- 메타 태그 최적화 -->
<meta property="og:title" content="인사이드잡 - 취업 멘토링 플랫폼">
<meta property="og:description" content="현직자와 구직자를 연결하는 실무 중심 커리어 상담 서비스">
<meta property="og:url" content="https://your-username.github.io/insidejob-platform">
<meta property="og:type" content="website">
```

---

## 📞 **다음 단계**

### **즉시 필요한 정보**
1. **GitHub 계정명**: `your-github-username`
2. **사용할 저장소명**: `insidejob-platform` (권장)
3. **커밋할 때 사용할 이름/이메일**

### **설정 완료 후 확인할 것**
1. **저장소 URL**: `https://github.com/your-username/insidejob-platform`
2. **배포된 사이트 URL**: `https://your-username.github.io/insidejob-platform`
3. **Supabase 연결 테스트** 통과 여부

---

**💡 GitHub 정보를 알려주시면 구체적인 명령어와 URL로 즉시 설정 가능합니다!**

**필요한 정보**:
- GitHub 사용자명
- 사용할 저장소명 (insidejob-platform 권장)
- Git에 사용할 이름과 이메일