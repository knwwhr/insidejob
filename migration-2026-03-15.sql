-- =====================================================
-- InsideJob 마이그레이션: 전문가 카테고리 15개 확장
-- 실행일: 2026-03-15
-- Supabase SQL Editor에서 실행
-- =====================================================

-- =====================================================
-- 1. professional_requests.industry CHECK 제약 업데이트
--    기존 10개 → career-tool 기반 15개 카테고리
-- =====================================================

-- 기존 CHECK 제약 제거
ALTER TABLE professional_requests DROP CONSTRAINT IF EXISTS professional_requests_industry_check;

-- 새 CHECK 제약 추가 (15개 카테고리 + 기존 키 호환)
ALTER TABLE professional_requests ADD CONSTRAINT professional_requests_industry_check
CHECK (industry IN (
    -- 새 카테고리 (career-tool 직무 분류 기반)
    'it_ict',                      -- IT/개발
    'business_planning',           -- 경영/기획
    'marketing_sales',             -- 마케팅/영업
    'design',                      -- 디자인
    'hr_education',                -- 인사/교육
    'finance_legal',               -- 재무/회계/법무
    'manufacturing',               -- 제조/생산
    'healthcare_bio',              -- 의료/바이오
    'media_content',               -- 미디어/콘텐츠
    'finance_insurance',           -- 금융/보험
    'service_support',             -- 서비스/고객지원
    'public_ngo',                  -- 공공/비영리
    'research_development',        -- 연구/R&D
    'environment_energy',          -- 환경/에너지
    'transportation_logistics',    -- 물류/운송
    -- 기존 키 호환 (이전 데이터 보호)
    'tech_development',
    'finance_consulting',
    'marketing_planning',
    'public_education',
    'service_retail',
    'media_creative',
    'healthcare',
    'construction_real_estate',
    'others'
));

-- =====================================================
-- 2. professional_requests에 category 컬럼 추가
--    프론트엔드에서 category 필드명으로 전송하므로
-- =====================================================

-- category 컬럼이 없으면 추가
ALTER TABLE professional_requests ADD COLUMN IF NOT EXISTS category TEXT;

-- 기존 industry 값을 category로 복사 (기존 데이터 보존)
UPDATE professional_requests SET category = industry WHERE category IS NULL;

-- =====================================================
-- 3. NOT NULL 제약 완화
--    프론트엔드에서 보내지 않는 필수 필드들
-- =====================================================

-- current_company, current_position, job_function이 NOT NULL인데
-- 프론트엔드 전문가 등록 폼에서 이 필드를 보내지 않을 수 있음
ALTER TABLE professional_requests ALTER COLUMN current_company DROP NOT NULL;
ALTER TABLE professional_requests ALTER COLUMN current_position DROP NOT NULL;
ALTER TABLE professional_requests ALTER COLUMN industry DROP NOT NULL;
ALTER TABLE professional_requests ALTER COLUMN job_function DROP NOT NULL;
ALTER TABLE professional_requests ALTER COLUMN verification_type DROP NOT NULL;

-- verification_type CHECK도 프론트 폼에서 사용하는 값 추가
ALTER TABLE professional_requests DROP CONSTRAINT IF EXISTS professional_requests_verification_type_check;
ALTER TABLE professional_requests ADD CONSTRAINT professional_requests_verification_type_check
CHECK (verification_type IS NULL OR verification_type IN (
    'employment_certificate',  -- 재직증명서
    'business_card',           -- 명함/사원증
    'linkedin_profile',        -- LinkedIn 프로필
    'portfolio',               -- 포트폴리오/경력증빙
    'business',                -- 사업자등록증 (프론트 코드)
    'license',                 -- 자격증 (프론트 코드)
    'organization',            -- 소속기관 (프론트 코드)
    'experience'               -- 경력기반 (프론트 코드)
));

-- =====================================================
-- 4. 프론트엔드에서 사용하는 추가 컬럼들
--    코드에서 insert하는데 DB에 없는 컬럼
-- =====================================================

-- 전문가 등록 폼에서 전송하는 필드들
ALTER TABLE professional_requests ADD COLUMN IF NOT EXISTS business_number TEXT;
ALTER TABLE professional_requests ADD COLUMN IF NOT EXISTS license_type TEXT;
ALTER TABLE professional_requests ADD COLUMN IF NOT EXISTS organization TEXT;
ALTER TABLE professional_requests ADD COLUMN IF NOT EXISTS experience_description TEXT;

-- =====================================================
-- 5. career_calculations 테이블 호환성
--    프론트에서 보내는 필드 중 DB에 없는 것들
-- =====================================================

-- 프론트에서 national_pension, private_pension 등을 보내지만
-- career_calculations에는 이 컬럼들이 없음
-- calculation_result JSONB에 통째로 저장되므로 별도 컬럼 불필요
-- 단, 코드에서 개별 필드로 보내는 부분이 있어 컬럼 추가
ALTER TABLE career_calculations ADD COLUMN IF NOT EXISTS national_pension INTEGER DEFAULT 0;
ALTER TABLE career_calculations ADD COLUMN IF NOT EXISTS private_pension INTEGER DEFAULT 0;
ALTER TABLE career_calculations ADD COLUMN IF NOT EXISTS target_salary INTEGER DEFAULT 0;
ALTER TABLE career_calculations ADD COLUMN IF NOT EXISTS career_score INTEGER DEFAULT 0;
ALTER TABLE career_calculations ADD COLUMN IF NOT EXISTS health_status TEXT;
ALTER TABLE career_calculations ADD COLUMN IF NOT EXISTS life_mode TEXT;
ALTER TABLE career_calculations ADD COLUMN IF NOT EXISTS skill_portfolio_score INTEGER DEFAULT 0;
ALTER TABLE career_calculations ADD COLUMN IF NOT EXISTS severance_pay INTEGER DEFAULT 0;
ALTER TABLE career_calculations ADD COLUMN IF NOT EXISTS debt INTEGER DEFAULT 0;
ALTER TABLE career_calculations ADD COLUMN IF NOT EXISTS calculation_result JSONB;
ALTER TABLE career_calculations ADD COLUMN IF NOT EXISTS age INTEGER;
ALTER TABLE career_calculations ADD COLUMN IF NOT EXISTS age_group TEXT;

-- =====================================================
-- 6. 기존 데이터 마이그레이션 (구 카테고리 → 새 카테고리)
-- =====================================================

-- 기존 데이터의 industry 값을 새 카테고리로 업데이트 (선택적)
-- 주의: 기존 데이터가 있는 경우에만 실행
UPDATE professional_requests SET industry = 'it_ict' WHERE industry = 'tech_development';
UPDATE professional_requests SET industry = 'finance_insurance' WHERE industry = 'finance_consulting';
UPDATE professional_requests SET industry = 'marketing_sales' WHERE industry = 'marketing_planning';
UPDATE professional_requests SET industry = 'hr_education' WHERE industry = 'public_education';
UPDATE professional_requests SET industry = 'service_support' WHERE industry = 'service_retail';
UPDATE professional_requests SET industry = 'media_content' WHERE industry = 'media_creative';
UPDATE professional_requests SET industry = 'healthcare_bio' WHERE industry = 'healthcare';
UPDATE professional_requests SET industry = 'manufacturing' WHERE industry = 'construction_real_estate';

-- category도 동기화
UPDATE professional_requests SET category = industry WHERE category IS NULL OR category != industry;

-- =====================================================
-- 7. 확인
-- =====================================================
SELECT 'professional_requests 컬럼 목록:' as info;
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'professional_requests'
ORDER BY ordinal_position;

SELECT 'career_calculations 컬럼 목록:' as info;
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'career_calculations'
ORDER BY ordinal_position;

SELECT '✅ 마이그레이션 완료!' as status;
