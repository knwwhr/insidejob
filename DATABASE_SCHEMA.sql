-- 인사이드잡 (InsideJob) 데이터베이스 스키마 v3.0
-- 기반: 플랜비(Plan B) 데이터베이스 구조 확장 및 변환
-- 최종 업데이트: 2025년 8월 31일

-- ==============================================
-- 0. 기존 데이터베이스 정리 (안전한 업데이트)
-- ==============================================

-- 기존 정책들 삭제 (존재하는 경우만)
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
DROP POLICY IF EXISTS "Anyone can create profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can view own calculations" ON career_calculations;
DROP POLICY IF EXISTS "Anyone can create calculations" ON career_calculations;
DROP POLICY IF EXISTS "Users can update own calculations" ON career_calculations;
DROP POLICY IF EXISTS "Anyone can view posts" ON job_seeker_posts;
DROP POLICY IF EXISTS "Members can create posts" ON job_seeker_posts;
DROP POLICY IF EXISTS "Users can update own posts" ON job_seeker_posts;
DROP POLICY IF EXISTS "Users can view own professional requests" ON professional_requests;
DROP POLICY IF EXISTS "Anyone can create professional requests" ON professional_requests;
DROP POLICY IF EXISTS "Admins can manage all professional requests" ON professional_requests;
DROP POLICY IF EXISTS "Users can view own bookings" ON consultation_bookings;
DROP POLICY IF EXISTS "Job seekers can create bookings" ON consultation_bookings;
DROP POLICY IF EXISTS "Participants can update bookings" ON consultation_bookings;
DROP POLICY IF EXISTS "Anyone can view active announcements" ON announcements;
DROP POLICY IF EXISTS "Admins can manage announcements" ON announcements;
DROP POLICY IF EXISTS "Admins can manage system settings" ON system_settings;
DROP POLICY IF EXISTS "Users can view own messages" ON member_messages;
DROP POLICY IF EXISTS "Users can send messages" ON member_messages;
DROP POLICY IF EXISTS "Users can update own messages" ON member_messages;
DROP POLICY IF EXISTS "Consultation participants can view chat messages" ON chat_messages;
DROP POLICY IF EXISTS "Consultation participants can send messages" ON chat_messages;
-- 새로운 테이블 정책들은 테이블이 존재할 때만 삭제
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'chat_files') THEN
        DROP POLICY IF EXISTS "Users can view shared files in their chat rooms" ON chat_files;
        DROP POLICY IF EXISTS "Users can upload files to their chat rooms" ON chat_files;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_documents') THEN
        DROP POLICY IF EXISTS "Users can view own documents" ON user_documents;
        DROP POLICY IF EXISTS "Users can upload own documents" ON user_documents;
        DROP POLICY IF EXISTS "Users can update own documents" ON user_documents;
    END IF;
END $$;

-- 새로운 테이블들만 삭제 (기존 core 테이블은 보존)
DROP TABLE IF EXISTS chat_files CASCADE;
DROP TABLE IF EXISTS user_documents CASCADE;

-- 기존 트리거들 삭제 (존재하는 테이블만)
DROP TRIGGER IF EXISTS update_user_profiles_updated_at ON user_profiles;
DROP TRIGGER IF EXISTS update_career_calculations_updated_at ON career_calculations;
DROP TRIGGER IF EXISTS update_job_seeker_posts_updated_at ON job_seeker_posts;
DROP TRIGGER IF EXISTS update_professional_requests_updated_at ON professional_requests;
DROP TRIGGER IF EXISTS update_consultation_bookings_updated_at ON consultation_bookings;
DROP TRIGGER IF EXISTS calculate_consultation_fees ON consultation_bookings;
DROP TRIGGER IF EXISTS update_comment_count ON post_comments;

-- 기존 함수들 삭제
DROP FUNCTION IF EXISTS update_updated_at_column();
DROP FUNCTION IF EXISTS calculate_consultation_fees();
DROP FUNCTION IF EXISTS update_post_comment_count();

-- ==============================================
-- 1. 사용자 프로필 (플랜비 구조 그대로 활용)
-- ==============================================

CREATE TABLE IF NOT EXISTS user_profiles (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
    nickname TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    age INTEGER,
    location TEXT,
    
    -- 커리어 서비스 특화 필드 추가
    education_level TEXT CHECK (education_level IN ('high_school', 'college', 'university', 'graduate')),
    major TEXT,
    career_status TEXT CHECK (career_status IN ('student', 'job_seeker', 'employed', 'career_change', 'freelancer')),
    target_industry TEXT,
    target_job TEXT,
    experience_years INTEGER DEFAULT 0,
    
    -- 3단계 역할 구조: 관리자, 일반회원, 전문가 회원
    role TEXT DEFAULT 'member' CHECK (role IN ('admin', 'member', 'expert')),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- ==============================================
-- 2. 취업경쟁력 계산 결과 (플랜비 계산 결과 구조 변환)
-- ==============================================

CREATE TABLE IF NOT EXISTS career_calculations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- 계산 입력 데이터 (JSON 형태 저장 - 플랜비 패턴)
    step1_basic_info JSONB, -- 기본정보 (나이, 학력, 전공, 희망직무/업계)
    step2_skills JSONB,     -- 스킬역량 (기술스택, 자격증, 어학, 포트폴리오)
    step3_experience JSONB, -- 경험분석 (인턴, 프로젝트, 활동, 수상)
    step4_network JSONB,    -- 네트워크 (인맥, 추천서, 멘토, SNS)
    step5_preparation JSONB, -- 준비현황 (이력서, 자소서, 면접, 지원수)
    step6_market JSONB,     -- 시장분석 (업계성장, 직무수요, 경쟁강도)
    
    -- 계산 결과 데이터
    total_score INTEGER NOT NULL, -- 종합 점수 (0-100)
    grade TEXT NOT NULL,          -- 등급 (S급, A급, B급, C급, D급, F급)
    
    -- 영역별 점수
    skill_score INTEGER,
    experience_score INTEGER, 
    preparation_score INTEGER,
    network_score INTEGER,
    market_score INTEGER,
    
    -- 추천사항 및 분석
    recommendations JSONB,     -- 개선 액션플랜
    peer_comparison JSONB,     -- 또래 비교 데이터
    predicted_success_rate INTEGER, -- 취업 성공률 예측 (%)
    estimated_job_period INTEGER,   -- 예상 취업 기간 (개월)
    
    -- 플랜비와 동일한 메타데이터
    migrated_from_guest BOOLEAN DEFAULT FALSE,
    calculation_version TEXT DEFAULT '1.0',
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- ==============================================
-- 3. 구직자 커뮤니티 (플랜비 커뮤니티 구조 확장)
-- ==============================================

CREATE TABLE IF NOT EXISTS job_seeker_posts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- 커리어 전용 카테고리
    category TEXT NOT NULL CHECK (category IN (
        'resume_review',    -- 서류 준비
        'interview_prep',   -- 면접 준비
        'industry_info',    -- 업계 정보
        'job_analysis',     -- 직무 탐구
        'networking'        -- 네트워킹
    )),
    
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    
    -- 익명성 보장을 위한 뱃지 시스템 (플랜비와 동일한 접근)
    author_badge JSONB, -- {education_level, target_industry, preparation_period}
    
    -- 커뮤니티 활동 지표
    view_count INTEGER DEFAULT 0,
    like_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    is_pinned BOOLEAN DEFAULT FALSE,
    is_featured BOOLEAN DEFAULT FALSE,
    
    -- 추천/신고 시스템
    upvotes INTEGER DEFAULT 0,
    downvotes INTEGER DEFAULT 0,
    report_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS post_comments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    post_id UUID REFERENCES job_seeker_posts(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    parent_comment_id UUID REFERENCES post_comments(id) ON DELETE CASCADE,
    
    content TEXT NOT NULL,
    author_badge JSONB, -- 댓글 작성자 익명 뱃지
    
    like_count INTEGER DEFAULT 0,
    report_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- ==============================================
-- 4. 현직자 등록 시스템 (플랜비 전문가 등록 구조 활용)
-- ==============================================

CREATE TABLE IF NOT EXISTS professional_requests (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- 기본 정보 (플랜비와 동일)
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT NOT NULL,
    
    -- 현직자 전문 분야 정보
    current_company TEXT NOT NULL,    -- 현재 회사
    current_position TEXT NOT NULL,   -- 현재 직책
    industry TEXT NOT NULL CHECK (industry IN (
        'tech_development',   -- IT/개발
        'finance_consulting', -- 금융/컨설팅
        'marketing_planning', -- 마케팅/기획
        'manufacturing',      -- 제조/엔지니어링
        'public_education',   -- 공공/교육
        'service_retail',     -- 서비스/유통
        'media_creative',     -- 미디어/크리에이티브
        'healthcare',         -- 의료/바이오
        'construction_real_estate', -- 건설/부동산
        'others'             -- 기타
    )),
    job_function TEXT NOT NULL,      -- 구체적 직무 (개발자, PM, 마케터, 등)
    experience_years INTEGER NOT NULL, -- 경력 연수
    keywords TEXT,                   -- 전문성 키워드 (JSON 배열 문자열)
    
    -- 검증 정보 (플랜비 구조 확장)
    verification_type TEXT NOT NULL CHECK (verification_type IN (
        'employment_certificate', -- 재직증명서
        'business_card',          -- 명함/사원증
        'linkedin_profile',       -- LinkedIn 프로필
        'portfolio'               -- 포트폴리오/경력증빙
    )),
    
    -- 검증 세부사항
    company_verification_doc TEXT,  -- 재직증명서 파일 경로
    business_card_image TEXT,       -- 명함 이미지 경로
    linkedin_url TEXT,              -- LinkedIn 프로필 URL
    portfolio_files TEXT,           -- 포트폴리오 파일들 (JSON 배열)
    additional_documents TEXT,       -- 추가 증빙 서류
    
    -- 상담 서비스 정보
    consultation_types TEXT,        -- 제공 가능 상담 유형 (JSON 배열)
    consultation_methods TEXT,      -- 상담 방식 (온라인/오프라인/전화)
    hourly_rate INTEGER,           -- 시간당 상담료 (원)
    available_times TEXT,          -- 상담 가능 시간 (JSON)
    consultation_experience TEXT,   -- 상담/멘토링 경험
    
    -- 승인 상태 관리 (플랜비와 동일)
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    reviewed_by UUID REFERENCES auth.users(id),
    review_reason TEXT,
    approved_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- ==============================================
-- 5. 매칭 및 상담 예약 시스템
-- ==============================================

CREATE TABLE IF NOT EXISTS consultation_bookings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    
    -- 매칭 정보
    job_seeker_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    professional_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- 상담 정보
    consultation_type TEXT NOT NULL CHECK (consultation_type IN (
        'resume_review',     -- 이력서 검토
        'interview_coaching', -- 면접 코칭  
        'industry_insight',  -- 업계 정보
        'career_planning',   -- 커리어 설계
        'skill_guidance',    -- 스킬 개발 가이드
        'company_culture'    -- 기업문화 정보
    )),
    consultation_method TEXT NOT NULL CHECK (consultation_method IN (
        'video_call',        -- 화상 통화
        'phone_call',        -- 전화
        'in_person',         -- 대면 미팅
        'message_chat'       -- 메시지 상담
    )),
    
    -- 예약 일정 (10분 단위 시스템)
    scheduled_date DATE NOT NULL,
    scheduled_time TIME NOT NULL,
    duration_minutes INTEGER DEFAULT 60 CHECK (duration_minutes IN (10, 20, 30, 40, 50, 60)), -- 10분 단위로 최대 60분
    timezone TEXT DEFAULT 'Asia/Seoul',
    
    -- 결제 정보 (20% 수수료 시스템)
    consultation_fee INTEGER NOT NULL,   -- 상담료 (분 단위 계산)
    platform_fee_rate DECIMAL(3,2) DEFAULT 0.20, -- 플랫폼 수수료율 (20%, 관리자 변경 가능)
    platform_fee INTEGER NOT NULL,       -- 플랫폼 수수료 금액
    expert_payout INTEGER NOT NULL,      -- 전문가 정산 금액 (80%)
    total_amount INTEGER NOT NULL,       -- 총 결제 금액
    payment_method TEXT,                 -- 결제 수단
    payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN (
        'pending',           -- 결제 대기
        'completed',         -- 결제 완료
        'failed',            -- 결제 실패
        'refunded',          -- 환불 완료
        'disputed'           -- 분쟁 상태
    )),
    
    -- 상담 현황
    booking_status TEXT DEFAULT 'requested' CHECK (booking_status IN (
        'requested',         -- 예약 요청
        'accepted',          -- 전문가 수락
        'rejected',          -- 전문가 거절
        'completed',         -- 상담 완료
        'cancelled',         -- 취소됨
        'no_show'           -- 노쇼
    )),
    
    -- 상담 내용 및 완료 정보
    consultation_notes TEXT,            -- 상담 노트 (전문가 작성)
    job_seeker_feedback TEXT,           -- 구직자 후기
    job_seeker_rating INTEGER CHECK (job_seeker_rating BETWEEN 1 AND 5),
    completed_at TIMESTAMP WITH TIME ZONE, -- 상담 완료 시각
    
    -- 연락처 교환 기능 제거 (사용자 자율 교환으로 단순화)
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- ==============================================
-- 6. 결제 및 정산 시스템 (플랜비 구조 확장)
-- ==============================================

CREATE TABLE IF NOT EXISTS payment_transactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    booking_id UUID REFERENCES consultation_bookings(id) ON DELETE CASCADE,
    
    -- 결제 정보
    payment_gateway TEXT, -- 결제 게이트웨이 (kakaopay, tosspay, card)
    transaction_id TEXT UNIQUE, -- 결제 시스템 거래 ID
    amount INTEGER NOT NULL,
    currency TEXT DEFAULT 'KRW',
    
    -- 결제 상태
    status TEXT DEFAULT 'pending' CHECK (status IN (
        'pending',           -- 결제 진행 중
        'completed',         -- 결제 완료
        'failed',            -- 결제 실패
        'cancelled',         -- 결제 취소
        'refunded',          -- 환불 완료
        'partial_refunded'   -- 부분 환불
    )),
    
    -- 환불 정보
    refund_amount INTEGER DEFAULT 0,
    refund_reason TEXT,
    refunded_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS professional_settlements (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    professional_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- 정산 기간
    settlement_period_start DATE NOT NULL,
    settlement_period_end DATE NOT NULL,
    
    -- 정산 금액
    total_consultation_fee INTEGER NOT NULL,  -- 총 상담료
    platform_fee INTEGER NOT NULL,           -- 플랫폼 수수료
    professional_payout INTEGER NOT NULL,    -- 전문가 수령액 (90%)
    
    -- 상담 건수 통계
    total_consultations INTEGER NOT NULL,
    completed_consultations INTEGER NOT NULL,
    cancelled_consultations INTEGER NOT NULL,
    
    -- 정산 상태
    status TEXT DEFAULT 'pending' CHECK (status IN (
        'pending',           -- 정산 대기
        'calculated',        -- 정산 계산 완료
        'paid',             -- 지급 완료
        'disputed'          -- 분쟁 상태
    )),
    
    -- 지급 정보
    payout_method TEXT,     -- 지급 방식 (bank_transfer, 등)
    payout_account TEXT,    -- 계좌 정보 (암호화)
    paid_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- 개별 상담 정산 테이블 (간단한 상담별 정산 처리용)
CREATE TABLE IF NOT EXISTS fee_settlements (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    booking_id UUID REFERENCES consultation_bookings(id) ON DELETE CASCADE,
    expert_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- 정산 금액
    total_revenue INTEGER NOT NULL,     -- 총 수익 (상담료)
    platform_fee INTEGER NOT NULL,     -- 플랫폼 수수료 (20%)
    expert_payout INTEGER NOT NULL,    -- 현직자 수령액 (80%)
    
    -- 정산 상태
    settlement_status TEXT DEFAULT 'completed' CHECK (settlement_status IN (
        'pending',      -- 정산 대기
        'completed',    -- 정산 완료
        'paid',         -- 지급 완료
        'disputed'      -- 분쟁
    )),
    
    completed_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    paid_date TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- ==============================================
-- 7. 시스템 설정 (관리자 전용)
-- ==============================================

CREATE TABLE IF NOT EXISTS system_settings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    setting_key TEXT NOT NULL UNIQUE,
    setting_value TEXT NOT NULL,
    description TEXT,
    
    -- 설정 유형
    setting_type TEXT DEFAULT 'string' CHECK (setting_type IN ('string', 'number', 'boolean', 'json')),
    
    -- 수정 권한
    updated_by UUID REFERENCES auth.users(id),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- ==============================================
-- 8. 공지사항 및 관리 (플랜비 구조 그대로)
-- ==============================================

CREATE TABLE IF NOT EXISTS announcements (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    
    -- 공지사항 유형
    category TEXT DEFAULT 'general' CHECK (category IN (
        'general',          -- 일반 공지
        'system_update',    -- 시스템 업데이트
        'service_notice',   -- 서비스 안내
        'event',           -- 이벤트
        'maintenance'      -- 점검 안내
    )),
    
    -- 표시 옵션
    is_important BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    display_start_date TIMESTAMP WITH TIME ZONE,
    display_end_date TIMESTAMP WITH TIME ZONE,
    
    -- 메타데이터
    author_id UUID REFERENCES auth.users(id),
    view_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS announcement_views (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    announcement_id UUID REFERENCES announcements(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    viewed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    
    UNIQUE(announcement_id, user_id)
);

-- ==============================================
-- 8. 쪽지 시스템 (일반 회원 간 메시지)
-- ==============================================

CREATE TABLE IF NOT EXISTS member_messages (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    sender_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    receiver_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    
    subject TEXT NOT NULL,
    content TEXT NOT NULL,
    
    -- 메시지 상태
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP WITH TIME ZONE,
    
    -- 삭제 상태 (발신자/수신자별 삭제 가능)
    sender_deleted BOOLEAN DEFAULT FALSE,
    receiver_deleted BOOLEAN DEFAULT FALSE,
    
    -- 답장 연결
    reply_to_message_id UUID REFERENCES member_messages(id) ON DELETE SET NULL,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- ==============================================
-- 9. 실시간 채팅 시스템 (전문가 상담 전용)
-- ==============================================

CREATE TABLE IF NOT EXISTS chat_rooms (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    room_type TEXT DEFAULT 'public' CHECK (room_type IN ('public', 'private', 'consultation')),
    max_participants INTEGER DEFAULT 100,
    is_active BOOLEAN DEFAULT TRUE,
    
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    room_id UUID REFERENCES chat_rooms(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    
    message_text TEXT NOT NULL,
    message_type TEXT DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'file', 'system', 'webrtc-signal')),
    
    -- 메시지 메타데이터
    reply_to UUID REFERENCES chat_messages(id),
    is_edited BOOLEAN DEFAULT FALSE,
    is_deleted BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS chat_participants (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    room_id UUID REFERENCES chat_rooms(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    last_read_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE,
    
    UNIQUE(room_id, user_id)
);

-- ==============================================
-- 10. 파일 저장 시스템 (채팅 파일 공유용)
-- ==============================================

CREATE TABLE IF NOT EXISTS chat_files (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    room_id UUID REFERENCES chat_rooms(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- 파일 정보
    original_filename TEXT NOT NULL,
    stored_filename TEXT NOT NULL,
    file_size INTEGER NOT NULL,
    mime_type TEXT NOT NULL,
    
    -- Supabase Storage 정보
    storage_bucket TEXT DEFAULT 'chat-files',
    storage_path TEXT NOT NULL,
    public_url TEXT,
    
    -- 메타데이터
    upload_status TEXT DEFAULT 'pending' CHECK (upload_status IN ('pending', 'completed', 'failed')),
    download_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- 이력서/포트폴리오 저장 테이블
CREATE TABLE IF NOT EXISTS user_documents (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- 문서 타입
    document_type TEXT NOT NULL CHECK (document_type IN (
        'resume',           -- 이력서
        'cover_letter',     -- 자기소개서
        'portfolio',        -- 포트폴리오
        'certificate',      -- 자격증
        'verification'      -- 검증 서류
    )),
    
    -- 파일 정보 (chat_files와 동일 구조)
    original_filename TEXT NOT NULL,
    stored_filename TEXT NOT NULL,
    file_size INTEGER NOT NULL,
    mime_type TEXT NOT NULL,
    
    -- Supabase Storage 정보
    storage_bucket TEXT DEFAULT 'user-documents',
    storage_path TEXT NOT NULL,
    public_url TEXT,
    
    -- 접근 권한
    is_public BOOLEAN DEFAULT FALSE,
    shared_with_experts BOOLEAN DEFAULT FALSE,
    
    -- 메타데이터
    upload_status TEXT DEFAULT 'pending' CHECK (upload_status IN ('pending', 'completed', 'failed')),
    is_active BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- ==============================================
-- 11. 알림 시스템 (이메일 & 플랫폼 알림)
-- ==============================================

CREATE TABLE IF NOT EXISTS notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- 알림 타입 및 내용
    type TEXT NOT NULL CHECK (type IN (
        'welcome',                  -- 회원가입 환영
        'expert_approved',          -- 현직자 승인
        'expert_rejected',          -- 현직자 거절
        'consultation_booked',      -- 상담 예약
        'consultation_reminder',    -- 상담 시작 알림
        'consultation_completed',   -- 상담 완료
        'new_message',              -- 새 쪽지
        'payment_completed',        -- 결제 완료
        'system_announcement',      -- 시스템 공지
        'others'                   -- 기타
    )),
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    
    -- 관련 데이터 (JSON)
    related_data JSONB,
    related_id UUID,
    
    -- 알림 상태
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP WITH TIME ZONE,
    
    -- 이메일 발송 상태
    email_sent BOOLEAN DEFAULT FALSE,
    email_sent_at TIMESTAMP WITH TIME ZONE,
    email_error TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- 이메일 발송 로그 테이블
CREATE TABLE IF NOT EXISTS email_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    
    -- 수신자 정보
    recipient_email TEXT NOT NULL,
    recipient_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    
    -- 이메일 내용
    email_type TEXT NOT NULL,
    subject TEXT NOT NULL,
    template_name TEXT,
    template_variables JSONB,
    
    -- 발송 상태
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'failed', 'bounced')),
    sent_at TIMESTAMP WITH TIME ZONE,
    
    -- 외부 서비스 연동 정보
    provider TEXT DEFAULT 'supabase_edge_function',
    external_id TEXT,
    error_message TEXT,
    
    -- 추적 정보
    opened_at TIMESTAMP WITH TIME ZONE,
    clicked_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- ==============================================
-- 인덱스 생성 (성능 최적화)
-- ==============================================

-- 사용자 프로필 인덱스
CREATE INDEX IF NOT EXISTS idx_user_profiles_role ON user_profiles(role);
CREATE INDEX IF NOT EXISTS idx_user_profiles_career_status ON user_profiles(career_status);
CREATE INDEX IF NOT EXISTS idx_user_profiles_target_industry ON user_profiles(target_industry);

-- 계산 결과 인덱스
CREATE INDEX IF NOT EXISTS idx_career_calculations_user_id ON career_calculations(user_id);
CREATE INDEX IF NOT EXISTS idx_career_calculations_total_score ON career_calculations(total_score DESC);
CREATE INDEX IF NOT EXISTS idx_career_calculations_created_at ON career_calculations(created_at DESC);

-- 커뮤니티 인덱스
CREATE INDEX IF NOT EXISTS idx_job_seeker_posts_category ON job_seeker_posts(category);
CREATE INDEX IF NOT EXISTS idx_job_seeker_posts_created_at ON job_seeker_posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_job_seeker_posts_view_count ON job_seeker_posts(view_count DESC);

-- 전문가 등록 인덱스
CREATE INDEX IF NOT EXISTS idx_professional_requests_status ON professional_requests(status);
CREATE INDEX IF NOT EXISTS idx_professional_requests_industry ON professional_requests(industry);
CREATE INDEX IF NOT EXISTS idx_professional_requests_created_at ON professional_requests(created_at DESC);

-- 예약 및 결제 인덱스
CREATE INDEX IF NOT EXISTS idx_consultation_bookings_job_seeker ON consultation_bookings(job_seeker_id);
CREATE INDEX IF NOT EXISTS idx_consultation_bookings_professional ON consultation_bookings(professional_id);
CREATE INDEX IF NOT EXISTS idx_consultation_bookings_scheduled_date ON consultation_bookings(scheduled_date);
CREATE INDEX IF NOT EXISTS idx_consultation_bookings_status ON consultation_bookings(booking_status);

-- 채팅 인덱스
CREATE INDEX IF NOT EXISTS idx_chat_messages_room_id ON chat_messages(room_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_created_at ON chat_messages(created_at DESC);

-- 파일 인덱스
CREATE INDEX IF NOT EXISTS idx_chat_files_room_id ON chat_files(room_id);
CREATE INDEX IF NOT EXISTS idx_chat_files_user_id ON chat_files(user_id);
CREATE INDEX IF NOT EXISTS idx_user_documents_user_id ON user_documents(user_id);
CREATE INDEX IF NOT EXISTS idx_user_documents_type ON user_documents(document_type);

-- 알림 시스템 인덱스
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications(type);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON notifications(user_id, is_read) WHERE is_read = false;
CREATE INDEX IF NOT EXISTS idx_email_logs_recipient ON email_logs(recipient_email);
CREATE INDEX IF NOT EXISTS idx_email_logs_status ON email_logs(status);
CREATE INDEX IF NOT EXISTS idx_email_logs_created_at ON email_logs(created_at DESC);

-- ==============================================
-- RLS (Row Level Security) 정책 설정
-- ==============================================

-- 모든 테이블에 RLS 활성화
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE career_calculations ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_seeker_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE professional_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE consultation_bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE professional_settlements ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcement_views ENABLE ROW LEVEL SECURITY;
ALTER TABLE member_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_files ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE email_logs ENABLE ROW LEVEL SECURITY;

-- 사용자 프로필 정책
CREATE POLICY "Users can view own profile"
    ON user_profiles FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update own profile"
    ON user_profiles FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Anyone can create profile"
    ON user_profiles FOR INSERT
    WITH CHECK (true);

-- 계산 결과 정책 (플랜비 동일)
CREATE POLICY "Users can view own calculations"
    ON career_calculations FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Anyone can create calculations"
    ON career_calculations FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Users can update own calculations"
    ON career_calculations FOR UPDATE
    USING (auth.uid() = user_id);

-- 커뮤니티 정책
CREATE POLICY "Anyone can view posts"
    ON job_seeker_posts FOR SELECT
    USING (true);

CREATE POLICY "Members can create posts"
    ON job_seeker_posts FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Users can update own posts"
    ON job_seeker_posts FOR UPDATE
    USING (auth.uid() = user_id);

-- 전문가 등록 정책 (플랜비 동일)
CREATE POLICY "Users can view own professional requests"
    ON professional_requests FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Anyone can create professional requests"
    ON professional_requests FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Admins can manage all professional requests"
    ON professional_requests FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE user_id = auth.uid() 
            AND role IN ('admin', 'super_admin')
        )
    );

-- 예약 및 결제 정책
CREATE POLICY "Users can view own bookings"
    ON consultation_bookings FOR SELECT
    USING (
        auth.uid() = job_seeker_id OR 
        auth.uid() = professional_id
    );

CREATE POLICY "Job seekers can create bookings"
    ON consultation_bookings FOR INSERT
    WITH CHECK (auth.uid() = job_seeker_id);

CREATE POLICY "Participants can update bookings"
    ON consultation_bookings FOR UPDATE
    USING (
        auth.uid() = job_seeker_id OR 
        auth.uid() = professional_id
    );

-- 공지사항 정책 (플랜비 동일)
CREATE POLICY "Anyone can view active announcements"
    ON announcements FOR SELECT
    USING (is_active = true);

CREATE POLICY "Admins can manage announcements"
    ON announcements FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE user_id = auth.uid() 
            AND role IN ('admin', 'super_admin')
        )
    );

-- 시스템 설정 정책 (관리자만 접근)
CREATE POLICY "Admins can manage system settings"
    ON system_settings FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE user_id = auth.uid() 
            AND role = 'admin'
        )
    );

-- 쪽지 정책 (발신자/수신자만 접근)
CREATE POLICY "Users can view own messages"
    ON member_messages FOR SELECT
    USING (
        auth.uid() = sender_id OR 
        auth.uid() = receiver_id
    );

CREATE POLICY "Users can send messages"
    ON member_messages FOR INSERT
    WITH CHECK (auth.uid() = sender_id);

CREATE POLICY "Users can update own messages"
    ON member_messages FOR UPDATE
    USING (
        auth.uid() = sender_id OR 
        auth.uid() = receiver_id
    );

-- 채팅 정책 (전문가 상담 전용)
CREATE POLICY "Consultation participants can view chat messages"
    ON chat_messages FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM chat_participants
            WHERE room_id = chat_messages.room_id
            AND user_id = auth.uid()
            AND is_active = true
        )
    );

CREATE POLICY "Consultation participants can send messages"
    ON chat_messages FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM chat_participants
            WHERE room_id = chat_messages.room_id
            AND user_id = auth.uid()
            AND is_active = true
        )
    );

-- 파일 저장 정책
CREATE POLICY "Users can view shared files in their chat rooms"
    ON chat_files FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM chat_participants
            WHERE room_id = chat_files.room_id
            AND user_id = auth.uid()
            AND is_active = true
        )
    );

CREATE POLICY "Users can upload files to their chat rooms"
    ON chat_files FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM chat_participants
            WHERE room_id = chat_files.room_id
            AND user_id = auth.uid()
            AND is_active = true
        ) AND auth.uid() = chat_files.user_id
    );

-- 사용자 문서 정책
CREATE POLICY "Users can view own documents"
    ON user_documents FOR SELECT
    USING (auth.uid() = user_id OR is_public = true);

CREATE POLICY "Users can upload own documents"
    ON user_documents FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own documents"
    ON user_documents FOR UPDATE
    USING (auth.uid() = user_id);

-- 알림 시스템 정책
CREATE POLICY "Users can view own notifications"
    ON notifications FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "System can create notifications"
    ON notifications FOR INSERT
    WITH CHECK (true); -- 시스템에서만 알림 생성

CREATE POLICY "Users can mark own notifications as read"
    ON notifications FOR UPDATE
    USING (auth.uid() = user_id);

-- 이메일 로그 정책 (관리자만 접근)
CREATE POLICY "Admins can view email logs"
    ON email_logs FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM user_profiles
            WHERE user_id = auth.uid() AND role = 'admin'
        )
    );

CREATE POLICY "System can create email logs"
    ON email_logs FOR INSERT
    WITH CHECK (true); -- 시스템/Edge Function에서만 로그 생성

-- ==============================================
-- 함수 및 트리거 설정
-- ==============================================

-- updated_at 자동 갱신 함수 (플랜비 동일)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- updated_at 트리거 생성
CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_career_calculations_updated_at
    BEFORE UPDATE ON career_calculations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_job_seeker_posts_updated_at
    BEFORE UPDATE ON job_seeker_posts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_professional_requests_updated_at
    BEFORE UPDATE ON professional_requests
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_consultation_bookings_updated_at
    BEFORE UPDATE ON consultation_bookings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_documents_updated_at
    BEFORE UPDATE ON user_documents
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 플랫폼 수수료 자동 계산 함수 (20% 가변형 수수료)
CREATE OR REPLACE FUNCTION calculate_consultation_fees()
RETURNS TRIGGER AS $$
BEGIN
    -- 플랫폼 수수료 계산 (기본 20%, 관리자가 변경 가능)
    NEW.platform_fee = ROUND(NEW.consultation_fee * NEW.platform_fee_rate);
    NEW.expert_payout = NEW.consultation_fee - NEW.platform_fee;
    NEW.total_amount = NEW.consultation_fee;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER calculate_consultation_fees
    BEFORE INSERT OR UPDATE ON consultation_bookings
    FOR EACH ROW
    EXECUTE FUNCTION calculate_consultation_fees();

-- 댓글 수 자동 업데이트 함수
CREATE OR REPLACE FUNCTION update_post_comment_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE job_seeker_posts 
        SET comment_count = comment_count + 1
        WHERE id = NEW.post_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE job_seeker_posts 
        SET comment_count = comment_count - 1
        WHERE id = OLD.post_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_comment_count
    AFTER INSERT OR DELETE ON post_comments
    FOR EACH ROW
    EXECUTE FUNCTION update_post_comment_count();

-- ==============================================
-- 초기 데이터 삽입
-- ==============================================

-- 시스템 기본 설정 (중복 방지)
INSERT INTO system_settings (setting_key, setting_value, description, setting_type) VALUES
('platform_commission_rate', '0.20', '플랫폼 수수료율 (기본 20%)', 'number'),
('min_consultation_minutes', '10', '최소 상담 시간 (분)', 'number'),
('max_consultation_minutes', '60', '최대 상담 시간 (분)', 'number'),
('consultation_time_units', '[10,20,30,40,50,60]', '예약 가능한 상담 시간 단위 (분)', 'json'),
('payment_methods', '["kakaopay","tosspay","card"]', '지원하는 결제 방식', 'json'),
('expert_approval_required', 'true', '전문가 등록 시 관리자 승인 필요 여부', 'boolean')
ON CONFLICT (setting_key) DO NOTHING;

-- 기본 공지사항 (중복 방지: title 기준)
INSERT INTO announcements (title, content, category, is_important, author_id) 
SELECT title, content, category, is_important, author_id::UUID FROM (VALUES
    ('인사이드잡 서비스 오픈 안내', '현직자-구직자 매칭 플랫폼 인사이드잡이 정식 오픈했습니다.', 'general', true, NULL),
    ('취업경쟁력 계산기 이용 안내', '무료 취업경쟁력 진단을 통해 나의 현재 수준을 확인해보세요.', 'service_notice', false, NULL),
    ('현직자 등록 모집 안내', '후배 구직자들을 위한 멘토링에 참여해주세요.', 'event', false, NULL),
    ('새로운 상담 시스템 안내', '10분 단위로 유연하게 상담 시간을 선택할 수 있습니다.', 'service_notice', false, NULL)
) AS new_announcements(title, content, category, is_important, author_id)
WHERE NOT EXISTS (
    SELECT 1 FROM announcements WHERE announcements.title = new_announcements.title
);

-- 완료
COMMENT ON TABLE user_profiles IS '사용자 프로필 - 3단계 역할 시스템 (관리자/일반회원/전문가)';
COMMENT ON TABLE career_calculations IS '취업경쟁력 계산 결과 - 6단계 진단 시스템';
COMMENT ON TABLE job_seeker_posts IS '구직자 커뮤니티 게시글';
COMMENT ON TABLE professional_requests IS '현직자 전문가 등록 요청 - 관리자 승인 시스템';
COMMENT ON TABLE consultation_bookings IS '상담 예약 시스템 - 10분 단위, 20% 수수료';
COMMENT ON TABLE payment_transactions IS '결제 거래 내역';
COMMENT ON TABLE professional_settlements IS '전문가 수익 정산 시스템 - 80% 지급';
COMMENT ON TABLE system_settings IS '시스템 설정 - 관리자가 수수료율 등 변경 가능';
COMMENT ON TABLE member_messages IS '일반 회원 간 쪽지 시스템';
COMMENT ON TABLE chat_rooms IS '실시간 채팅방 - 전문가 상담 전용';
COMMENT ON TABLE chat_messages IS '채팅 메시지 - 전문가 상담에서만 사용';
COMMENT ON TABLE chat_files IS '채팅 파일 공유 - Supabase Storage 연동';
COMMENT ON TABLE user_documents IS '사용자 문서 저장 - 이력서, 포트폴리오 등';

-- 스키마 버전 정보 (중복 방지)
INSERT INTO announcements (title, content, category) 
SELECT '데이터베이스 스키마 v3.0', '인사이드잡 플랫폼 파일 공유 시스템이 추가되었습니다.', 'system_update'
WHERE NOT EXISTS (
    SELECT 1 FROM announcements WHERE title = '데이터베이스 스키마 v3.0'
);