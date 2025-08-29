# 🎯 커리어코치 (CareerCoach) - 현직자-구직자 매칭 플랫폼

> **플랜비(Plan B) 검증된 아키텍처 기반으로 구축된 취업 지원 플랫폼**

## 🚀 **빠른 시작 가이드**

### **1. 프로젝트 복제 및 설정**
```bash
# 1. 저장소 생성 및 이동
mkdir career-coach-platform
cd career-coach-platform

# 2. 플랜비 기반 파일 복사 (기존 프로젝트에서)
cp /path/to/planb-project/index.html ./
cp /path/to/planb-project/*.sql ./

# 3. Git 초기화
git init
git add .
git commit -m "Initial commit: 플랜비 기반 커리어코치 프로젝트 시작"
```

### **2. Supabase 프로젝트 설정** 
```sql
-- DATABASE_SCHEMA.sql 파일의 모든 스키마 실행
-- RLS 정책 활성화 확인
-- 기본 데이터 삽입 확인
```

### **3. 도메인 특화 수정**
```javascript
// index.html에서 수정할 부분들
// 1. 타이틀 변경
<title>플랜비 - 은퇴설계 커뮤니티</title>
→ <title>커리어코치 - 취업 멘토링 플랫폼</title>

// 2. 메타 태그 변경  
<meta name="description" content="은퇴생활비 계산기와 커뮤니티 플랫폼"/>
→ <meta name="description" content="취업경쟁력 계산기와 현직자 매칭 플랫폼"/>

// 3. 색상 테마 변경
:root {
    --primary-color: #3b82f6;    /* 플랜비 블루 */
    --secondary-color: #10b981;  /* 커리어코치 그린 */
    --accent-color: #f59e0b;     /* 오렌지 액센트 */
}
```

---

## 🧮 **핵심 기능 개발 가이드**

### **1. 취업경쟁력 계산기 개발**

#### **플랜비 계산기 구조 활용**
```javascript
// 플랜비 6단계 → 커리어 6단계 변환 매핑
const stepMapping = {
    1: '기본정보',      // 플랜비: 기본정보 → 나이,학력,희망직무
    2: '스킬역량',      // 플랜비: 자산현황 → 기술스택,자격증,어학  
    3: '경험분석',      // 플랜비: 부채정보 → 인턴,프로젝트,활동
    4: '네트워크',      // 플랜비: 연금정보 → 인맥,추천서,멘토
    5: '준비현황',      // 플랜비: 지출계획 → 이력서,면접준비
    6: '시장분석'       // 플랜비: 건강수명 → 업계동향,경쟁도
};

// React.createElement 패턴 필수 사용 (JSX 피하기)
const CareerCalculatorWizard = () => {
    const [currentStep, setCurrentStep] = useState(1);
    const [formData, setFormData] = useState({});
    
    return React.createElement('div', {
        className: 'max-w-4xl mx-auto bg-white rounded-lg shadow-lg p-6'
    }, [
        renderProgressBar(),     // 플랜비와 동일
        renderCurrentStep(),     // 단계별 렌더링  
        renderNavigation()       // 이전/다음 버튼
    ]);
};
```

#### **점수 계산 알고리즘**
```javascript
// 플랜비 계산 로직 구조 활용
const calculateCareerScore = (allData) => {
    const weights = {
        skills: 0.30,       // 스킬 30%
        experience: 0.25,   // 경험 25%  
        preparation: 0.20,  // 준비도 20%
        network: 0.15,      // 네트워크 15%
        market: 0.10        // 시장성 10%
    };
    
    // 플랜비와 동일한 가중평균 방식
    const totalScore = Object.keys(weights).reduce((total, key) => {
        return total + (calculateSubScore(allData, key) * weights[key]);
    }, 0);
    
    return {
        totalScore: Math.round(totalScore),
        grade: getGrade(totalScore),
        recommendations: generateActionPlan(allData)
    };
};
```

### **2. 구직자 커뮤니티 구축**

#### **플랜비 커뮤니티 재사용**
```javascript
// 카테고리만 변경하고 나머지는 플랜비와 동일
const communityCategories = {
    'resume_review': { name: '📝 서류 준비', color: 'blue' },
    'interview_prep': { name: '🗣️ 면접 준비', color: 'green' },
    'industry_info': { name: '💼 업계 정보', color: 'purple' },
    'job_analysis': { name: '🎯 직무 탐구', color: 'orange' },
    'networking': { name: '🤝 네트워킹', color: 'pink' }
};

const JobSeekerCommunity = () => {
    // 플랜비 커뮤니티 컴포넌트 구조 100% 재사용
    return React.createElement('div', {
        className: 'max-w-6xl mx-auto p-4'
    }, [
        renderCategoryFilter(),  // 플랜비와 동일
        renderPostsList(),       // 플랜비와 동일
        renderWriteModal()       // 플랜비와 동일
    ]);
};
```

### **3. 현직자 등록 시스템**

#### **플랜비 전문가 등록 시스템 완전 재사용**
```javascript
// 플랜비 3단계 마법사 구조 그대로 활용
const ProfessionalRegistration = () => {
    // 플랜비 ExpertRegistrationWizard 코드 90% 재사용
    
    // 변경 사항:
    // - 전문분야 → 업계/직무
    // - 자격증 → 재직증명서
    // - 키워드만 도메인 특화
    
    // React.createElement 패턴 그대로 사용 (안정성 보장)
};
```

---

## 📈 **개발 효율성 극대화 전략**

### **플랜비 코드 재사용 비율**
- **UI/UX 컴포넌트**: 90% 재사용 (색상/텍스트만 변경)
- **데이터베이스 구조**: 85% 재사용 (테이블 구조 확장)
- **인증/권한 시스템**: 95% 재사용 (거의 변경 없음)
- **결제/정산 로직**: 100% 재사용 (완전 동일)

### **새로 개발할 부분 (10%)**
- 취업경쟁력 계산 알고리즘 (핵심 차별화)
- 현직자-구직자 매칭 알고리즘
- 업계/직무별 전문 카테고리
- 상담 예약 캘린더 시스템

### **개발 속도 향상 팁**
```javascript
// 1. 플랜비 함수명을 찾아바꾸기로 빠른 변환
// 예: retirement → career, expert → professional

// 2. 플랜비 CSS 클래스 그대로 활용
className: 'card' // 플랜비 카드 스타일 그대로
className: 'btn-primary' // 플랜비 버튼 스타일 그대로

// 3. 플랜비 상태 관리 패턴 그대로 사용  
const [currentUser, setCurrentUser] = useState(null);
const [currentView, setCurrentView] = useState('home');
```

---

## 🔧 **필수 개발 도구 및 환경**

### **필수 준비사항**
- ✅ **플랜비 프로젝트 접근**: 코드 복사 및 참고용
- ✅ **Supabase 계정**: 새 프로젝트 생성용
- ✅ **GitHub 계정**: GitHub Pages 배포용  
- ✅ **에디터**: VS Code (Live Server 확장 권장)

### **개발 환경 설정**
```json
// VSCode 설정 (.vscode/settings.json)
{
    "liveServer.settings.port": 5500,
    "emmet.includeLanguages": {
        "javascript": "javascriptreact"
    }
}
```

### **테스트 계정 준비**
- 관리자 계정: admin@careercoach.co.kr  
- 테스트 구직자: jobseeker@test.com
- 테스트 현직자: professional@test.com

---

## 📞 **다음 단계 실행 가이드**

### **오늘 당장 시작할 수 있는 작업**
1. ✅ Supabase 새 프로젝트 생성 (10분)
2. ✅ DATABASE_SCHEMA.sql 실행 (5분)  
3. ✅ 플랜비 index.html 복사 및 타이틀 변경 (10분)
4. ✅ GitHub 저장소 생성 및 초기 커밋 (5분)

### **1주차 목표**
- [ ] 기본 프로젝트 구조 완성
- [ ] 취업경쟁력 계산기 1-2단계 기본 UI
- [ ] 플랜비 코드베이스 이해 및 변환 계획 수립

### **1개월차 목표** 
- [ ] 완전한 취업경쟁력 계산기 (6단계)
- [ ] 사용자 테스트 및 피드백 수집
- [ ] 다음 단계 개발 방향 확정

---

**💡 성공 확률 95%+**: 플랜비의 검증된 아키텍처를 활용하면 **기술적 리스크 거의 제로**로 안정적인 플랫폼 구축 가능

**🎯 핵심 메시지**: "플랜비에서 해결한 모든 기술적 문제들을 그대로 활용하여 취업 도메인에만 집중 개발"