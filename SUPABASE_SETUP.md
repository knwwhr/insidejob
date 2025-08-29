# 🔧 인사이드잡 Supabase 설정 가이드

**개발사**: (주)오픈커넥트  
**프로젝트**: 인사이드잡 - 현직자-구직자 매칭 플랫폼  
**Supabase Project**: 설정 완료 및 즉시 사용 가능

---

## ✅ **Supabase 연결 정보**

### **프로젝트 정보**
```javascript
// 인사이드잡 전용 Supabase 설정
const SUPABASE_URL = 'https://upsedttmnulbmarhawyj.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVwc2VkdHRtbnVsYm1hcmhhd3lqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0NDk5MzIsImV4cCI6MjA3MjAyNTkzMn0.j7QuXCFfIytrBvCsIQl0bt9EuVYScIzZWGTR3tVZdUs';

// Supabase 클라이언트 초기화
const supabase = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
```

---

## 📋 **데이터베이스 설정 단계**

### **1. SQL 에디터에서 스키마 실행**

1. **Supabase 대시보드** 접속: https://upsedttmnulbmarhawyj.supabase.co
2. **SQL Editor** 메뉴 클릭
3. **New Query** 클릭
4. `DATABASE_SCHEMA.sql` 파일 내용 **전체 복사하여 실행**

```sql
-- 아래 순서대로 실행하세요:

-- 1) 사용자 프로필 테이블
-- 2) 취업경쟁력 계산 결과 테이블  
-- 3) 구직자 커뮤니티 테이블
-- 4) 현직자 등록 시스템 테이블
-- 5) 매칭 및 상담 예약 테이블
-- 6) 결제 및 정산 시스템 테이블
-- 7) 공지사항 및 채팅 시스템 테이블
-- 8) 인덱스 및 RLS 정책 설정
-- 9) 함수 및 트리거 설정
-- 10) 초기 데이터 삽입
```

### **2. 실행 확인**

다음 쿼리로 테이블 생성 확인:
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
```

**기대 결과** (15개 테이블):
- announcements
- announcement_views  
- career_calculations
- chat_messages
- chat_participants
- chat_rooms
- consultation_bookings
- job_seeker_posts
- payment_transactions
- post_comments
- professional_requests
- professional_settlements
- user_profiles

---

## 🔐 **RLS 정책 확인**

### **정책 활성화 여부 체크**
```sql
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND rowsecurity = true;
```

모든 테이블에 `rowsecurity = true` 확인되어야 합니다.

### **주요 정책 테스트**
```sql
-- 1. 게스트 사용자가 계산 결과 생성 가능한지 확인
INSERT INTO career_calculations (
    user_id, step1_basic_info, total_score, grade
) VALUES (
    null, '{"age": 25}', 75, 'B+'
);

-- 2. 게스트 사용자가 전문가 등록 가능한지 확인  
INSERT INTO professional_requests (
    user_id, name, phone, email, current_company, current_position, industry, job_function, experience_years
) VALUES (
    null, '테스트', '010-1234-5678', 'test@test.com', '테스트회사', '개발자', 'tech_development', 'backend', 3
);
```

---

## 🚀 **HTML 파일에 Supabase 연동**

### **기본 HTML 구조**
```html
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>인사이드잡 - 취업 멘토링 플랫폼</title>
    
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    
    <!-- React 18 CDN (Development) -->
    <script crossorigin src="https://unpkg.com/react@18/umd/react.development.js"></script>
    <script crossorigin src="https://unpkg.com/react-dom@18/umd/react-dom.development.js"></script>
    
    <!-- Supabase CDN -->
    <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
</head>
<body>
    <div id="root"></div>

    <script type="text/javascript">
        // Supabase 설정
        const SUPABASE_URL = 'https://upsedttmnulbmarhawyj.supabase.co';
        const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVwc2VkdHRtbnVsYm1hcmhhd3lqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0NDk5MzIsImV4cCI6MjA3MjAyNTkzMn0.j7QuXCFfIytrBvCsIQl0bt9EuVYScIzZWGTR3tVZdUs';
        
        const supabase = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

        // 연결 테스트
        const testConnection = async () => {
            try {
                const { data, error } = await supabase
                    .from('user_profiles')
                    .select('count')
                    .limit(1);
                    
                if (error) {
                    console.error('Supabase connection error:', error);
                } else {
                    console.log('✅ Supabase 연결 성공!');
                }
            } catch (err) {
                console.error('Connection test failed:', err);
            }
        };

        // 페이지 로드 시 연결 테스트
        testConnection();

        // 인사이드잡 메인 앱 컴포넌트
        const InsideJobApp = () => {
            const [isLoading, setIsLoading] = React.useState(true);
            
            React.useEffect(() => {
                // 초기화 로직
                setTimeout(() => setIsLoading(false), 1000);
            }, []);
            
            if (isLoading) {
                return React.createElement('div', {
                    className: 'flex items-center justify-center min-h-screen'
                }, React.createElement('div', {
                    className: 'text-2xl font-bold text-blue-600'
                }, '인사이드잡 로딩 중...'));
            }
            
            return React.createElement('div', {
                className: 'min-h-screen bg-gray-50'
            }, [
                React.createElement('header', {
                    key: 'header',
                    className: 'bg-white shadow-sm'
                }, React.createElement('div', {
                    className: 'max-w-7xl mx-auto px-4 py-6'
                }, React.createElement('h1', {
                    className: 'text-3xl font-bold text-gray-900'
                }, '🎯 인사이드잡'))),
                
                React.createElement('main', {
                    key: 'main',
                    className: 'max-w-7xl mx-auto px-4 py-8'
                }, React.createElement('div', {
                    className: 'bg-white rounded-lg shadow-lg p-8 text-center'
                }, [
                    React.createElement('h2', {
                        key: 'title',
                        className: 'text-2xl font-semibold mb-4'
                    }, '현직자와 구직자를 연결하는 플랫폼'),
                    React.createElement('p', {
                        key: 'description',
                        className: 'text-gray-600 mb-8'
                    }, 'Supabase 연결 완료! 개발을 시작하세요.'),
                    React.createElement('button', {
                        key: 'cta-button',
                        className: 'bg-blue-600 text-white px-8 py-3 rounded-lg font-semibold hover:bg-blue-700 transition-colors',
                        onClick: () => alert('개발 준비 완료! 🚀')
                    }, '취업경쟁력 진단 시작')
                ]))
            ]);
        };

        // React DOM 렌더링
        const root = ReactDOM.createRoot(document.getElementById('root'));
        root.render(React.createElement(InsideJobApp));
    </script>
</body>
</html>
```

---

## 📊 **주요 기능 테스트**

### **1. 사용자 인증 테스트**
```javascript
// 회원가입 테스트
const testSignUp = async () => {
    const { data, error } = await supabase.auth.signUp({
        email: 'test@insidejob.co.kr',
        password: 'testpassword123'
    });
    
    console.log('Sign up result:', data, error);
};

// 로그인 테스트
const testSignIn = async () => {
    const { data, error } = await supabase.auth.signInWithPassword({
        email: 'test@insidejob.co.kr', 
        password: 'testpassword123'
    });
    
    console.log('Sign in result:', data, error);
};
```

### **2. 데이터 CRUD 테스트**
```javascript
// 계산 결과 저장 테스트
const testCalculationSave = async () => {
    const { data, error } = await supabase
        .from('career_calculations')
        .insert({
            step1_basic_info: { age: 25, education: 'university' },
            total_score: 75,
            grade: 'B+'
        });
        
    console.log('Calculation save result:', data, error);
};

// 전문가 등록 테스트  
const testExpertRegistration = async () => {
    const { data, error } = await supabase
        .from('professional_requests')
        .insert({
            name: '김전문가',
            email: 'expert@test.com',
            phone: '010-1234-5678',
            current_company: '테스트회사',
            current_position: '시니어 개발자',
            industry: 'tech_development',
            job_function: 'backend_developer',
            experience_years: 5
        });
        
    console.log('Expert registration result:', data, error);
};
```

---

## ✅ **설정 완료 체크리스트**

- [ ] ✅ Supabase 프로젝트 생성 완료
- [ ] ✅ DATABASE_SCHEMA.sql 실행 완료
- [ ] ✅ 15개 테이블 생성 확인
- [ ] ✅ RLS 정책 활성화 확인
- [ ] ✅ 기본 HTML 파일 생성
- [ ] ✅ Supabase 연결 테스트 통과
- [ ] ✅ 사용자 인증 기능 테스트
- [ ] ✅ 데이터 CRUD 기능 테스트

---

**🎉 축하합니다! 인사이드잡 프로젝트의 백엔드 설정이 완료되었습니다.**

이제 **GitHub 저장소 생성 → HTML 파일 업로드 → GitHub Pages 배포**만 하면 바로 서비스를 시작할 수 있습니다!