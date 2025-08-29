# 📋 인사이드잡 (InsideJob) - 프로젝트 문서

**개발사**: (주)오픈커넥트  
**프로젝트명**: 인사이드잡 - 현직자와 구직자를 연결하는 취업 멘토링 플랫폼  
**기반**: 플랜비(Plan B) 검증된 아키텍처 + 최적화 개선  
**최종 업데이트**: 2025년 8월 29일

---

## 🎯 프로젝트 개요

**인사이드잡**은 취업을 준비하는 구직자와 해당 업계/직무의 현직자를 연결하여 실무 중심의 커리어 멘토링을 제공하는 플랫폼입니다.

### 핵심 기능
- **🧮 취업경쟁력 계산기**: 구직자의 현재 역량을 객관적으로 평가
- **💬 구직자 커뮤니티**: 같은 목표를 가진 구직자들의 정보 교환 공간
- **👨‍💼 현직자 매칭**: 실무 경험을 바탕으로 한 1:1 멘토링 서비스
- **💳 안전한 결제**: 상담료 20% 수수료로 플랫폼 운영

### 기술 스택
- **프론트엔드**: React 18 (CDN), Tailwind CSS
- **백엔드**: Supabase PostgreSQL + Auth + Realtime
- **배포**: GitHub Pages
- **개발 패턴**: React.createElement (JSX 대신)

---

## ⚠️ UI/UX 개발 시 필수 주의사항

> **플랜비 전문가 등록 시스템 구축 경험을 바탕으로 한 핵심 개발 가이드**

### 🔥 **절대 금지: JSX 사용 금지**

#### **문제점**
- CDN 방식 React에서 JSX 사용 시 **예측 불가능한 브라우저 호환성 문제** 발생
- Babel Standalone의 브라우저 파싱 오류로 **런타임에서 갑자기 실패**
- 개발 중에는 정상 동작하다가 **배포 후 오류 발생** 가능성 높음

#### **플랜비 실제 경험**
```javascript
// ❌ 절대 금지 - JSX 패턴
const ExpertRegistration = () => {
    return (
        <div className="registration-form">
            <h2>전문가 등록</h2>
            {currentStep === 1 && (
                <input 
                    type="text" 
                    value={formData.name}
                    onChange={(e) => updateFormData('name', e.target.value)}
                />
            )}
        </div>
    );
}; // 브라우저에서 SyntaxError 발생!
```

```javascript
// ✅ 필수 사용 - React.createElement 패턴
const ExpertRegistration = () => {
    return React.createElement('div', {
        className: 'registration-form'
    }, [
        React.createElement('h2', {
            key: 'title'
        }, '전문가 등록'),
        currentStep === 1 ? React.createElement('input', {
            key: 'name-input',
            type: 'text',
            value: formData.name,
            onChange: (e) => updateFormData('name', e.target.value)
        }) : null
    ]);
}; // 안정적으로 동작
```

#### **변환 작업의 현실**
- **규모**: 플랜비에서 1000줄+ 코드 수작업 변환 경험
- **소요시간**: 하루 종일 변환 작업
- **멘탈 타격**: "처음부터 React.createElement로 했으면..." 후회

### 🚨 **React Hooks 규칙 엄격 준수**

#### **문제점**
```javascript
// ❌ 내부 컴포넌트에서 hooks 사용 금지
const MainComponent = () => {
    const [state, setState] = useState({}); // ✅ 메인에서는 OK
    
    const InternalComponent = () => {
        useEffect(() => {}, []); // ❌ 내부 컴포넌트에서 hooks 사용시 오류
        return React.createElement('div', {}, 'content');
    };
    
    return InternalComponent(); // "Rendered fewer hooks than expected" 오류!
};
```

#### **해결 방법**
```javascript
// ✅ 올바른 패턴 - 렌더링 함수 사용
const MainComponent = () => {
    const [state, setState] = useState({}); // ✅ 최상위에서만 hooks 사용
    
    const renderInternalContent = () => { // 단순 함수로 변경
        // hooks 사용 금지, DOM 조작은 setTimeout 활용
        setTimeout(() => {
            const element = document.getElementById('target');
            if (element) element.focus();
        }, 0);
        
        return React.createElement('div', {}, 'content');
    };
    
    return renderInternalContent(); // 정상 동작
};
```

### 🎛️ **Input 컨트롤 문제 해결 패턴**

#### **문제점**
- React controlled input에서 **체크박스/라디오버튼 클릭이 안 되는** 현상
- 상태 변경이 DOM에 즉시 반영되지 않는 문제

#### **해결 패턴**
```javascript
// ❌ 문제가 되는 패턴
React.createElement('input', {
    type: 'checkbox',
    checked: formData.agree,
    onChange: (e) => updateFormData('agree', e.target.checked) // 클릭 안됨
});

// ✅ 해결 패턴 - onClick + DOM 직접 조작
React.createElement('label', {
    onClick: () => {
        const newValue = !formData.agree;
        updateFormData('agree', newValue);
        
        // DOM 직접 조작으로 동기화 보장
        setTimeout(() => {
            const checkbox = document.getElementById('agree-checkbox');
            if (checkbox) checkbox.checked = newValue;
        }, 0);
    },
    className: 'cursor-pointer flex items-center'
}, [
    React.createElement('input', {
        id: 'agree-checkbox',
        type: 'checkbox',
        readOnly: true, // onChange 대신 onClick 사용
        className: 'pointer-events-none mr-2' // 직접 클릭 방지
    }),
    '동의합니다'
]);
```

### 📱 **반응형 개발 필수 패턴**

#### **모바일 최적화 클래스 구조**
```javascript
// ✅ 플랜비에서 검증된 반응형 패턴
const responsiveClasses = {
    container: 'max-w-4xl mx-auto p-4 sm:p-6 lg:p-8',
    card: 'bg-white rounded-lg shadow-lg p-4 sm:p-6',
    button: 'w-full sm:w-auto px-6 py-3 text-base sm:text-lg',
    grid: 'grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4',
    text: 'text-sm sm:text-base lg:text-lg'
};

// 터치 최적화 (44px 이상 터치 영역)
const touchOptimized = {
    button: 'min-h-[44px] min-w-[44px] p-3',
    checkbox: 'w-6 h-6', // 기본보다 크게
    input: 'px-4 py-3 text-base' // 16px 이상으로 줌 방지
};
```

### 🔍 **디버깅 및 오류 추적**

#### **개발 환경 설정**
```javascript
// ✅ 개발용 React CDN 사용 (상세한 오류 메시지)
<script src="https://unpkg.com/react@18/umd/react.development.js"></script>

// ❌ 프로덕션용은 디버깅이 어려움
<script src="https://unpkg.com/react@18/umd/react.production.min.js"></script>
```

#### **오류 캐치 패턴**
```javascript
// ✅ 컴포넌트 렌더링 오류 캐치
const safeRenderComponent = (renderFunction) => {
    try {
        return renderFunction();
    } catch (error) {
        console.error('Component render error:', error);
        return React.createElement('div', {
            className: 'error-boundary p-4 bg-red-50 border border-red-200'
        }, [
            React.createElement('h3', { key: 'title' }, '오류가 발생했습니다'),
            React.createElement('p', { key: 'message' }, error.message)
        ]);
    }
};

// 사용법
const MyComponent = () => safeRenderComponent(() => {
    // 실제 컴포넌트 로직
    return React.createElement('div', {}, 'content');
});
```

### 🎨 **CSS 스타일링 주의사항**

#### **Tailwind CSS 안전 사용법**
```javascript
// ✅ 안전한 클래스 조합
const safeClasses = 'bg-white p-6 rounded-lg shadow-md border border-gray-200';

// ⚠️ 동적 클래스는 미리 검증
const dynamicClass = (isActive) => {
    const baseClasses = 'px-4 py-2 rounded transition-all';
    const activeClasses = isActive ? 'bg-blue-500 text-white' : 'bg-gray-100 text-gray-700';
    return `${baseClasses} ${activeClasses}`;
};
```

### 🗄️ **Supabase 연동 안전 패턴**

#### **RLS 정책 고려 개발**
```javascript
// ✅ 게스트 사용자 고려한 안전한 쿼리
const safeQuery = async (userId) => {
    try {
        const { data, error } = await supabase
            .from('career_calculations')
            .select('*')
            .eq('user_id', userId || null); // 게스트는 null 허용
            
        if (error) throw error;
        return data;
    } catch (error) {
        console.error('Query error:', error);
        return []; // 빈 배열로 fallback
    }
};
```

#### **에러 처리 표준화**
```javascript
// ✅ 사용자 친화적 에러 메시지
const handleSupabaseError = (error) => {
    const errorMessages = {
        'auth/user-not-found': '사용자를 찾을 수 없습니다',
        'auth/wrong-password': '비밀번호가 올바르지 않습니다',
        'database/permission-denied': '접근 권한이 없습니다'
    };
    
    return errorMessages[error.code] || '알 수 없는 오류가 발생했습니다';
};
```

---

## 🚀 **성능 최적화 체크리스트**

### **메모리 관리**
- [ ] ✅ 컴포넌트 언마운트 시 이벤트 리스너 정리
- [ ] ✅ setTimeout/setInterval 정리
- [ ] ✅ 대용량 데이터 가상 스크롤 적용
- [ ] ✅ 이미지 지연 로딩 구현

### **네트워크 최적화**
- [ ] ✅ API 호출 디바운싱 (300ms)
- [ ] ✅ 데이터 캐싱 구현
- [ ] ✅ 무한 스크롤로 페이지네이션
- [ ] ✅ 압축 가능한 JSON 구조 사용

### **사용자 경험**
- [ ] ✅ 로딩 스피너 모든 비동기 작업에 적용
- [ ] ✅ 에러 상태 명확한 메시지 제공
- [ ] ✅ 오프라인 상태 감지 및 안내
- [ ] ✅ 접근성 (ARIA 레이블) 완성

---

## 📋 **개발 진행 시 체크 포인트**

### **매일 체크사항**
1. **JSX 사용 여부 점검**: 모든 코드에서 React.createElement 사용 확인
2. **Hooks 규칙 준수**: 컴포넌트 내부에 hooks 사용 금지 확인
3. **Input 동작 테스트**: 모든 폼 요소 실제 클릭/입력 테스트
4. **모바일 반응형**: 실제 모바일 기기에서 동작 확인

### **주간 체크사항**
1. **성능 지표 확인**: 페이지 로딩 속도, 메모리 사용량
2. **에러 로그 분석**: 브라우저 콘솔 에러 제로 유지
3. **Supabase 쿼리 최적화**: RLS 정책 준수 및 성능 체크
4. **크로스 브라우저 테스트**: Chrome, Safari, Firefox 동작 확인

### **출시 전 최종 체크**
1. **전체 사용자 플로우 테스트**: 회원가입부터 결제까지 완전한 동작
2. **다양한 디바이스 테스트**: 아이폰, 안드로이드, 태블릿, 데스크탑
3. **데이터베이스 정합성**: RLS 정책으로 권한 완벽 차단 확인
4. **성능 벤치마크**: 플랜비 대비 개선된 지표 달성 확인

---

## 🎯 **성공 지표**

### **기술적 지표**
- **초기 로딩**: 1.8초 이하 (플랜비 3.2초 대비 44% 개선)
- **계산기 완료율**: 85% 이상 (플랜비 65% 대비 31% 개선)
- **에러율**: 1% 이하
- **모바일 사용성**: 100% 터치 최적화

### **사용자 경험 지표**
- **사용자 만족도**: NPS 50 이상
- **재방문률**: 70% 이상
- **평균 세션 시간**: 15분 이상
- **계산 후 커뮤니티 전환율**: 60% 이상

---

**💡 핵심 원칙**: 플랜비에서 발견한 모든 기술적 문제점을 사전에 방지하고, 검증된 안정성을 바탕으로 사용자 경험을 극대화하는 것이 인사이드잡 개발의 최우선 목표입니다.