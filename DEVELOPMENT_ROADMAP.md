# 🚀 커리어코치 개발 로드맵

**기반 프로젝트**: 플랜비 (Plan B) 은퇴설계 플랫폼  
**개발 방식**: 검증된 아키텍처 90% 재사용 + 도메인 특화 10% 개발  
**목표 기간**: **3개월** (플랜비 기반으로 단축 개발)  
**완성도 목표**: **90%** (플랜비 수준)

---

## 📅 **전체 개발 일정 (12주)**

### **🔥 Phase 1: 핵심 기능 구현 (1-4주)**
- **목표**: 취업경쟁력 계산기 + 기본 인증 시스템
- **완성도**: 40%
- **핵심 성과**: MVP 버전으로 사용자 피드백 수집 가능

### **💼 Phase 2: 커뮤니티 및 전문가 등록 (5-8주)**  
- **목표**: 구직자 커뮤니티 + 현직자 등록 시스템
- **완성도**: 70%
- **핵심 성과**: 양방향 플랫폼으로 네트워크 효과 창출

### **🤝 Phase 3: 매칭 및 결제 시스템 (9-12주)**
- **목표**: 상담 예약 + 결제 + 정산 시스템 완성
- **완성도**: 90%
- **핵심 성과**: 완전한 수익화 플랫폼 런칭

---

## 🛠️ **Phase 1: 핵심 기능 구현 (1-4주)**

### **1주차: 프로젝트 초기 설정**

#### **환경 구축** (1일)
```bash
# 플랜비 기반 구조 복제
mkdir career-coach-platform
cd career-coach-platform

# 플랜비 기본 파일들 복사 및 수정
cp /path/to/planb/index.html ./
cp /path/to/planb/*.sql ./

# 도메인 특화 수정
# - 타이틀: "플랜비" → "커리어코치"  
# - 색상 테마: 블루 계열 → 그린/오렌지 계열
# - 메타 태그: 은퇴 관련 → 취업/커리어 관련
```

#### **기본 컴포넌트 구조 설정** (2-3일)
```javascript
// 플랜비 메인 앱 구조 그대로 활용
const CareerCoachApp = () => {
    const [currentUser, setCurrentUser] = useState(null);
    const [currentView, setCurrentView] = useState('home');
    
    // 플랜비와 동일한 뷰 구조
    const views = {
        'home': renderHomePage,
        'calculator': renderCareerCalculator,      // 플랜비 계산기 → 경쟁력 계산기
        'community': renderJobSeekerCommunity,    // 플랜비 커뮤니티 → 구직자 커뮤니티  
        'experts': renderProfessionalFinder,      // 플랜비 전문가 → 현직자 찾기
        'mypage': renderMyPage,                   // 플랜비 마이페이지 그대로
        'auth': renderAuth                        // 플랜비 인증 그대로
    };
    
    return React.createElement('div', {
        className: 'min-h-screen bg-gray-50'
    }, [
        renderNavigation(),
        views[currentView](),
        renderFooter()
    ]);
};
```

#### **Supabase 프로젝트 설정** (1일)
- 새 Supabase 프로젝트 생성
- DATABASE_SCHEMA.sql 스키마 적용
- 플랜비와 동일한 RLS 정책 설정
- 인증 설정 (이메일/패스워드)

### **2주차: 취업경쟁력 계산기 기초 구현**

#### **6단계 입력 폼 구현** (4일)
```javascript
// 플랜비 6단계 구조를 그대로 활용하여 빠른 개발
const CareerCalculatorWizard = () => {
    // 플랜비와 완전 동일한 상태 구조
    const [currentStep, setCurrentStep] = useState(1);
    const [formData, setFormData] = useState({});
    const [errors, setErrors] = useState({});
    
    // 플랜비 계산기의 렌더링 함수 패턴 그대로 사용
    const renderStep1BasicInfo = () => { /* 기본정보 입력 */ };
    const renderStep2SkillAnalysis = () => { /* 스킬 분석 */ };
    const renderStep3ExperienceAnalysis = () => { /* 경험 분석 */ };
    const renderStep4NetworkAnalysis = () => { /* 네트워크 분석 */ };
    const renderStep5PreparationStatus = () => { /* 준비 현황 */ };
    const renderStep6MarketAnalysis = () => { /* 시장 분석 */ };
    
    // React.createElement 패턴 (JSX 문제 방지)
};
```

**개발 우선순위**:
1. **1-2단계**: 기본정보 + 스킬 분석 (가장 중요)
2. **3-4단계**: 경험 + 네트워크 분석
3. **5-6단계**: 준비현황 + 시장 분석

#### **기본 점수 계산 로직** (2일)
- 각 단계별 점수 계산 함수 구현
- 가중치 적용 종합 점수 산출  
- 등급 분류 및 피드백 생성

#### **임시 결과 표시** (1일)
- 기본적인 점수 표시 화면
- 간단한 권장사항 표시
- (차트는 3주차에 구현)

### **3주차: 계산기 고도화**

#### **결과 화면 완성** (3일)
```javascript
// 플랜비 결과 화면 구조 활용
const renderCalculationResult = (result) => {
    return React.createElement('div', {
        className: 'space-y-6'
    }, [
        renderMainScoreCard(result),      // 메인 점수 카드
        renderDetailedBreakdown(result),  // 상세 분석
        renderRecommendations(result),    // 개선 권장사항  
        renderPeerComparison(result),     // 또래 비교 (간단 버전)
        renderActionPlan(result)          // 액션 플랜
    ]);
};
```

#### **데이터 저장/복원** (2일)
- 플랜비와 동일한 게스트/회원 저장 로직
- localStorage + Supabase 이중 저장
- 게스트 → 회원 데이터 마이그레이션

### **4주차: Phase 1 완성 및 테스트**

#### **계산기 완성도 검증** (2일)
- 모든 입력 케이스 테스트
- 점수 계산 정확성 검증
- 오류 처리 완성도 확인

#### **사용자 테스트** (2일)  
- 실제 구직자 10명 테스트 진행
- 피드백 수집 및 개선사항 도출
- 계산 로직 정확성 검증

#### **Phase 1 마무리** (1일)
- 버그 수정 및 안정화
- GitHub Pages 배포 테스트
- Phase 2 계획 수립

---

## 💬 **Phase 2: 커뮤니티 및 전문가 등록 (5-8주)**

### **5주차: 구직자 커뮤니티 구현**

#### **플랜비 커뮤니티 구조 변환** (4일)
```javascript
// 플랜비 커뮤니티 카테고리 → 취업 카테고리 변경
const communityCategories = {
    'resume_review': '📝 서류 준비',      // 플랜비: 은퇴준비 → 서류준비
    'interview_prep': '🗣️ 면접 준비',    // 플랜비: 자산관리 → 면접준비  
    'industry_info': '💼 업계 정보',     // 플랜비: 생활 → 업계정보
    'job_analysis': '🎯 직무 탐구',      // 플랜비: 건강 → 직무탐구
    'networking': '🤝 네트워킹'          // 플랜비: 자유주제 → 네트워킹
};

const JobSeekerCommunity = () => {
    // 플랜비 커뮤니티 컴포넌트 구조 완전 동일하게 활용
    return React.createElement('div', {
        className: 'max-w-6xl mx-auto p-4'
    }, [
        renderCategoryTabs(),    // 플랜비와 동일
        renderPostsList(),       // 플랜비와 동일 
        renderPostDetail(),      // 플랜비와 동일
        renderWritePost()        // 플랜비와 동일
    ]);
};
```

#### **익명 뱃지 시스템** (1일)
- 플랜비 뱃지 시스템 구조 그대로 활용
- 은퇴 관련 뱃지 → 취업 관련 뱃지 변경

### **6주차: 현직자 등록 시스템**

#### **플랜비 전문가 등록 3단계 마법사 활용** (5일)
```javascript
// 플랜비 ExpertRegistrationWizard → ProfessionalRegistrationWizard 변환
const ProfessionalRegistrationWizard = () => {
    // 플랜비와 완전 동일한 구조 및 상태 관리
    const [currentStep, setCurrentStep] = useState(1);
    const [formData, setFormData] = useState({});
    
    // 플랜비 3단계 구조 그대로 활용
    const renderStep1BasicInfo = () => {
        // 플랜비: 이름, 전화번호, 이메일, 동의
        // 동일: 이름, 전화번호, 이메일, 동의 (완전 동일)
    };
    
    const renderStep2ProfessionalInfo = () => {
        // 플랜비: 전문분야, 경력, 키워드
        // 변환: 업계, 직무, 경력연수, 현재회사, 키워드
    };
    
    const renderStep3Verification = () => {
        // 플랜비: 4가지 검증 방법 
        // 변환: 재직증명서, 명함, LinkedIn, 포트폴리오
    };
    
    // React.createElement 패턴 (플랜비 경험 활용)
    return React.createElement('div', {
        className: 'max-w-4xl mx-auto bg-white rounded-lg shadow-lg p-6 sm:p-8'
    }, [
        renderProgressBar(),        // 플랜비와 동일
        renderCurrentStep(),        // 플랜비와 동일
        renderNavigationButtons()   // 플랜비와 동일
    ]);
};
```

### **7주차: 관리자 승인 시스템**

#### **플랜비 슈퍼관리자 승인 시스템 재사용** (3일)
```javascript
// 플랜비 ExpertApprovalComponent → ProfessionalApprovalComponent 단순 변환
const ProfessionalApprovalComponent = () => {
    // 플랜비와 완전 동일한 탭 구조
    const [activeTab, setActiveTab] = useState('pending');
    
    // 승인 대기/완료/거절 탭 동일
    const tabs = [
        { id: 'pending', label: '승인 대기', icon: '⏳' },
        { id: 'approved', label: '승인 완료', icon: '✅' },
        { id: 'rejected', label: '승인 거절', icon: '❌' }
    ];
    
    // 플랜비 승인 로직 그대로 재사용
    const handleApproval = async (requestId, status, reason) => {
        // 동일한 승인/거절 처리 로직
        // user_profiles.role 업데이트 로직 동일
    };
};
```

#### **승인 워크플로 테스트** (2일)
- 게스트 등록 → 승인 → 전문가 전환 전체 플로우 검증
- 이메일 알림 시스템 테스트  
- 권한 관리 시스템 검증

### **8주차: Phase 2 완성**

#### **통합 테스트** (3일)
- 계산기 → 커뮤니티 연동 테스트
- 현직자 등록 → 승인 → 전문가 활동 전체 플로우
- 다중 사용자 역할 권한 테스트

#### **UI/UX 개선** (2일)
- 모바일 반응형 최적화 (플랜비 패턴 활용)
- 접근성 개선 (키보드 네비게이션, 스크린 리더)
- 에러 메시지 한글화 (플랜비 경험 활용)

---

## 🤝 **Phase 3: 매칭 및 결제 시스템 (9-12주)**

### **9주차: 매칭 알고리즘 개발**

#### **스마트 매칭 시스템** (4일)
```javascript
// 매칭 알고리즘 구현
const findMatchingProfessionals = (jobSeekerProfile, consultationType) => {
    const matchingCriteria = {
        industry: 0.4,      // 업계 일치도 40%
        jobFunction: 0.3,   // 직무 유사도 30%
        experience: 0.2,    // 경력 수준 20%
        location: 0.1       // 지역 근접성 10%
    };
    
    // Supabase 쿼리로 매칭 후보 필터링
    // 매칭 점수 계산 및 정렬
    // 상위 10명 추천
};

const ProfessionalFinder = () => {
    // 전문가 검색 및 필터링 UI
    // 매칭 점수 기반 추천 리스트
    // 전문가 프로필 상세 보기
};
```

#### **상담 예약 기초 구현** (1일)
- 달력 기반 예약 시스템
- 시간대별 가능 여부 확인
- 예약 요청 생성

### **10주차: 결제 시스템 구현**

#### **플랜비 결제 구조 활용** (5일)  
```javascript
// 플랜비 결제 시스템 그대로 재사용
const PaymentComponent = ({ bookingData }) => {
    // 카카오페이, 토스페이, 신용카드 동일하게 지원
    // 10% 플랫폼 수수료 자동 계산 (플랜비와 동일)
    // 에스크로 방식으로 상담 완료 후 정산
};

const processPayment = async (paymentData) => {
    try {
        // 플랜비 결제 프로세스 재사용
        // 1. 예약 생성
        // 2. 결제 진행  
        // 3. 결제 완료시 상담 확정
        // 4. 연락처 교환 요청 생성
    } catch (error) {
        // 플랜비와 동일한 에러 처리
    }
};
```

### **11주차: 상담 시스템 완성**

#### **화상 상담 시스템** (3일)
```javascript
// WebRTC 또는 외부 API 연동
const VideoConsultationRoom = ({ bookingId }) => {
    // 기본 화상 통화 기능
    // 화면 공유 (이력서 리뷰용)
    // 채팅 기능 (자료 공유)
};
```

#### **상담 후 시스템** (2일)
- 상담 완료 처리
- 상호 평가 시스템
- 연락처 교환 (플랜비 시스템 활용)

### **12주차: 최종 완성 및 런칭**

#### **정산 시스템** (2일)
```javascript
// 플랜비 수수료 정산 시스템 활용
const ProfessionalSettlement = () => {
    // 월별 정산 내역
    // 90% 전문가 수익, 10% 플랫폼 수수료
    // 자동 정산 시스템
};
```

#### **관리자 대시보드** (2일)
- 사용자 통계 및 관리
- 매칭 성공률 모니터링
- 결제 및 정산 관리

#### **최종 QA 및 런칭** (1일)
- 전체 시스템 통합 테스트
- 성능 최적화
- GitHub Pages 프로덕션 배포

---

## 📊 **주차별 완성도 및 성과 지표**

### **마일스톤 체크포인트**

| 주차 | 완성도 | 핵심 기능 | 테스트 가능 여부 |
|------|--------|-----------|------------------|
| 1주 | 10% | 프로젝트 구조 | ❌ |
| 2주 | 25% | 기본 계산기 | ✅ (계산 테스트) |
| 4주 | 40% | 완전한 계산기 | ✅ (사용자 테스트) |
| 6주 | 55% | 커뮤니티 + 등록 | ✅ (커뮤니티 활동) |
| 8주 | 70% | 승인 시스템 | ✅ (전문가 워크플로) |
| 10주 | 80% | 결제 시스템 | ✅ (결제 테스트) |
| 12주 | 90% | 전체 시스템 | ✅ (상용 서비스) |

### **각 Phase별 성공 기준**

#### **Phase 1 성공 기준**
- ✅ 취업경쟁력 계산 완료율 95% 이상
- ✅ 사용자 피드백 평균 4.0/5.0 이상  
- ✅ 계산 결과 저장 성공률 98% 이상
- ✅ 모바일 사용성 문제 없음

#### **Phase 2 성공 기준**  
- ✅ 일일 커뮤니티 활성 사용자 50명 이상
- ✅ 현직자 등록 신청 주당 10건 이상
- ✅ 전문가 승인률 70% 이상
- ✅ 커뮤니티 게시글 일일 5개 이상

#### **Phase 3 성공 기준**
- ✅ 매칭 요청 성공률 80% 이상
- ✅ 결제 완료율 95% 이상  
- ✅ 상담 완료율 90% 이상
- ✅ 사용자 만족도 NPS 50 이상

---

## 🎯 **핵심 성공 전략**

### **플랜비 성공 요소 100% 활용**
1. **검증된 기술 스택**: React.createElement 패턴으로 안정성 확보
2. **단계별 사용자 여정**: 계산기 → 커뮤니티 → 전문가 동일 구조
3. **게스트 친화성**: 회원가입 부담 없는 서비스 접근
4. **신뢰 기반**: 판매 목적 없는 순수 매칭 서비스

### **취업 도메인 특화 강점**
- 💼 **명확한 목표**: 모든 구직자의 최종 목표는 '취업 성공'
- 📈 **측정 가능한 성과**: 취업 성공률로 서비스 효과 검증 가능
- 🎯 **타겟 집중**: 플랜비보다 연령대가 명확하여 마케팅 효율성 높음
- 💰 **지불 의사 명확**: 취업 성공시 투자 대비 회수 확실

### **리스크 관리**
- **기술적 리스크**: 플랜비 검증된 코드 재사용으로 최소화
- **시장 리스크**: 기존 취업 서비스와 차별화된 포지셔닝
- **운영 리스크**: 플랜비 운영 경험 활용한 점진적 확장

---

**💡 결론: 플랜비의 90% 완성도 경험을 활용하면 3개월 내 동일 수준의 커리어 매칭 플랫폼 구축 가능**

**🚀 즉시 시작 가능 요소**: 
- ✅ 검증된 React.createElement 코드 패턴
- ✅ Supabase 데이터베이스 구조  
- ✅ 사용자 인증 및 권한 시스템
- ✅ 커뮤니티 및 전문가 등록 워크플로