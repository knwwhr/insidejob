# 📤 인사이드잡 GitHub 업로드 가이드

**상황**: WSL 환경에서 GitHub 인증 문제로 `git push` 실패  
**해결**: Personal Access Token을 사용한 업로드

---

## 🔑 **Personal Access Token 생성**

1. **GitHub.com 접속** → 우상단 프로필 → Settings
2. **Developer settings** → Personal access tokens → Tokens (classic)
3. **Generate new token (classic)** 클릭
4. **설정**:
   ```
   Note: insidejob-upload-token
   Expiration: 90 days
   Scopes: ✅ repo (전체 선택)
   ```
5. **Generate token** → **토큰 복사** (한번만 보여짐!)

---

## 🚀 **토큰으로 업로드**

### **명령어 실행**:
```bash
# 현재 디렉터리: /home/knoww/career-project/insidejob
cd /home/knoww/career-project/insidejob

# 토큰을 사용하여 push
git push -u origin main
```

**인증 프롬프트가 나타나면**:
- Username: `knwwhr`
- Password: `[생성한 Personal Access Token 붙여넣기]`

---

## 📁 **현재 업로드 준비된 파일들**

```
insidejob/
├── index.html                           # 🌐 메인 웹사이트 (16KB)
├── PROJECT_OVERVIEW.md                  # 📋 프로젝트 개요
├── CAREER_CALCULATOR_DESIGN.md          # 🧮 계산기 설계
├── FLEXIBLE_CALCULATOR_DESIGN.md        # 🔧 유연한 계산기
├── DATABASE_SCHEMA.sql                  # 🗄️ DB 스키마 (27KB)
├── DEVELOPMENT_ROADMAP.md               # 🚀 개발 로드맵
├── PLANB_OPTIMIZATION_IMPROVEMENTS.md   # ⚡ 최적화 개선
├── SUPABASE_SETUP.md                   # 🔧 Supabase 설정
├── GITHUB_SETUP_GUIDE.md               # 🐙 GitHub 가이드
├── CLAUDE.md                           # 🎯 개발 가이드
├── README.md                           # 📖 프로젝트 소개
└── .gitignore                          # 🚫 제외 파일 목록
```

**총 파일 크기**: 약 200KB (문서 포함)  
**핵심 파일**: `index.html` (완전 작동하는 웹사이트)

---

## ✅ **업로드 성공 확인**

업로드 완료 후:
1. **저장소 확인**: https://github.com/knwwhr/insidejob
2. **GitHub Pages 활성화**:
   - Settings → Pages
   - Source: Deploy from a branch
   - Branch: main → Save
3. **배포 URL**: https://knwwhr.github.io/insidejob/ (5분 후 접속 가능)

---

## 🎉 **완료 시 결과**

- ✅ **실시간 웹사이트** 배포됨
- ✅ **Supabase 연결** 테스트 가능  
- ✅ **인사이드잡 브랜딩** 적용됨
- ✅ **모바일 최적화** 완료
- ✅ **개발 문서** 모두 공개

**즉시 서비스 시작 가능!** 🚀