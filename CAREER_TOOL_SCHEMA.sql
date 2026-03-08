-- =====================================================
-- 커리어 도구 (career-tool) 추가 스키마
-- insidejob Supabase 프로젝트에 추가할 테이블
-- =====================================================

-- 1. 개인정보 동의 기록 (개인정보보호법 제22조)
CREATE TABLE IF NOT EXISTS career_consent_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    agreed BOOLEAN NOT NULL DEFAULT true,
    consent_version VARCHAR(10) NOT NULL DEFAULT '1.0',
    agreed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_career_consent_email ON career_consent_records(email);
CREATE INDEX IF NOT EXISTS idx_career_consent_user ON career_consent_records(user_id);

-- 2. 커리어 진단 게스트 프로필 (비로그인 사용자용)
CREATE TABLE IF NOT EXISTS career_guest_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    name VARCHAR(100),
    gender VARCHAR(10),
    phone VARCHAR(20),
    age_group VARCHAR(20),
    privacy_consent BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_career_guest_user ON career_guest_profiles(user_id);

-- 3. 커리어 진단 결과
CREATE TABLE IF NOT EXISTS career_assessments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    guest_profile_id UUID REFERENCES career_guest_profiles(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    step1_responses JSONB,
    step2_responses JSONB,
    step3_responses JSONB,
    recommended_jobs JSONB,
    riasec_scores JSONB,
    action_plan JSONB,
    is_completed BOOLEAN DEFAULT false,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_career_assessments_guest ON career_assessments(guest_profile_id);
CREATE INDEX IF NOT EXISTS idx_career_assessments_user ON career_assessments(user_id);
CREATE INDEX IF NOT EXISTS idx_career_assessments_completed ON career_assessments(completed_at DESC);

-- 4. RLS 정책
ALTER TABLE career_consent_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE career_guest_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE career_assessments ENABLE ROW LEVEL SECURITY;

-- 비로그인 사용자도 삽입/조회 가능
CREATE POLICY "career_consent_insert" ON career_consent_records FOR INSERT TO anon, authenticated WITH CHECK (true);
CREATE POLICY "career_consent_select" ON career_consent_records FOR SELECT TO anon, authenticated USING (true);

CREATE POLICY "career_guest_insert" ON career_guest_profiles FOR INSERT TO anon, authenticated WITH CHECK (true);
CREATE POLICY "career_guest_select" ON career_guest_profiles FOR SELECT TO anon, authenticated USING (true);

CREATE POLICY "career_assessments_insert" ON career_assessments FOR INSERT TO anon, authenticated WITH CHECK (true);
CREATE POLICY "career_assessments_select" ON career_assessments FOR SELECT TO anon, authenticated USING (true);

-- 5. 통계 뷰
CREATE OR REPLACE VIEW career_assessment_statistics AS
SELECT
    DATE(completed_at) as assessment_date,
    COUNT(*) as total_assessments,
    COUNT(DISTINCT guest_profile_id) as unique_users,
    COUNT(user_id) as logged_in_users
FROM career_assessments
WHERE is_completed = true
GROUP BY DATE(completed_at)
ORDER BY assessment_date DESC;

SELECT '✅ 커리어 도구 스키마 추가 완료!' as status;
