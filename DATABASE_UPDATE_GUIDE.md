# 📊 Supabase 데이터베이스 스키마 업데이트 가이드

> **인사이드잡 서비스 개선을 위한 안전한 DB 스키마 변경 방법론**

## 🎯 **문서 목적**
- Supabase에서 기존 DB에 새로운 스키마를 안전하게 적용
- 데이터 손실 없이 테이블/정책/트리거 업데이트
- 반복적인 스키마 변경 시 발생하는 오류 사전 방지

---

## ⚠️ **주요 오류 패턴 및 해결책**

### 1. **테이블/인덱스 중복 생성 오류**
```sql
-- ❌ 문제: 기존 테이블이 있을 때 오류 발생
CREATE TABLE user_profiles (...);

-- ✅ 해결: IF NOT EXISTS 사용
CREATE TABLE IF NOT EXISTS user_profiles (...);
CREATE INDEX IF NOT EXISTS idx_user_profiles_role ON user_profiles(role);
```

### 2. **RLS 정책 중복 생성 오류**
```sql
-- ❌ 문제: 같은 이름의 정책이 이미 존재
CREATE POLICY "Users can view own profile" ON user_profiles ...;

-- ✅ 해결: 먼저 삭제 후 생성
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
CREATE POLICY "Users can view own profile" ON user_profiles ...;
```

### 3. **존재하지 않는 테이블에 정책 삭제 시도**
```sql
-- ❌ 문제: 테이블이 없는데 정책 삭제 시도
DROP POLICY IF EXISTS "policy_name" ON non_existing_table;

-- ✅ 해결: 테이블 존재 여부 확인
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'table_name') THEN
        DROP POLICY IF EXISTS "policy_name" ON table_name;
    END IF;
END $$;
```

### 4. **UUID 타입 불일치 오류**
```sql
-- ❌ 문제: NULL이 TEXT로 인식되어 UUID 컬럼에 삽입 불가
INSERT INTO announcements (author_id) VALUES (NULL);

-- ✅ 해결: 명시적 UUID 캐스팅
INSERT INTO announcements (author_id) VALUES (NULL::UUID);
-- 또는 VALUES 구문에서
SELECT author_id::UUID FROM (VALUES (NULL)) AS t(author_id);
```

### 5. **데이터 중복 삽입 방지**
```sql
-- ❌ 문제: 스키마 재실행 시 중복 데이터 삽입
INSERT INTO system_settings (setting_key, setting_value) VALUES 
('key1', 'value1');

-- ✅ 해결 1: ON CONFLICT 사용 (UNIQUE 제약조건 있을 때)
INSERT INTO system_settings (setting_key, setting_value) VALUES 
('key1', 'value1')
ON CONFLICT (setting_key) DO NOTHING;

-- ✅ 해결 2: NOT EXISTS 조건 사용
INSERT INTO announcements (title, content) 
SELECT 'New Announcement', 'Content'
WHERE NOT EXISTS (
    SELECT 1 FROM announcements WHERE title = 'New Announcement'
);
```

### 6. **트리거 의존성 순서 오류**
```sql
-- ❌ 문제: 함수가 삭제되기 전에 트리거 삭제 시도
DROP FUNCTION update_function();
DROP TRIGGER trigger_using_function ON table_name;

-- ✅ 해결: 올바른 삭제 순서
DROP TRIGGER IF EXISTS trigger_using_function ON table_name;
DROP FUNCTION IF EXISTS update_function();
```

---

## 🛡️ **안전한 스키마 업데이트 템플릿**

### **표준 SQL 파일 구조**
```sql
-- 1. 파일 헤더 (버전 정보)
-- 인사이드잡 DB 스키마 v4.0
-- 업데이트: 2025년 XX월 XX일
-- 변경사항: 새로운 기능 추가

-- 2. 기존 객체 정리 (역순으로 삭제)
-- 2-1. 존재하지 않을 수 있는 테이블의 정책
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'new_table') THEN
        DROP POLICY IF EXISTS "policy_name" ON new_table;
    END IF;
END $$;

-- 2-2. 기존 테이블 정책 삭제
DROP POLICY IF EXISTS "existing_policy" ON existing_table;

-- 2-3. 새 테이블 삭제 (CASCADE로 관련 객체도 함께)
DROP TABLE IF EXISTS new_table CASCADE;

-- 2-4. 트리거 삭제
DROP TRIGGER IF EXISTS trigger_name ON table_name;

-- 2-5. 함수 삭제
DROP FUNCTION IF EXISTS function_name();

-- 3. 새 객체 생성
-- 3-1. 함수 생성
CREATE OR REPLACE FUNCTION function_name() ...;

-- 3-2. 테이블 생성 (중복 방지)
CREATE TABLE IF NOT EXISTS new_table (...);

-- 3-3. 인덱스 생성 (중복 방지)
CREATE INDEX IF NOT EXISTS idx_name ON table_name(column);

-- 3-4. RLS 활성화
ALTER TABLE new_table ENABLE ROW LEVEL SECURITY;

-- 3-5. 정책 생성
CREATE POLICY "policy_name" ON new_table ...;

-- 3-6. 트리거 생성
CREATE TRIGGER trigger_name ...;

-- 4. 초기 데이터 삽입 (중복 방지)
INSERT INTO table_name (columns) 
SELECT values FROM (VALUES (...)) AS t(columns)
WHERE NOT EXISTS (SELECT 1 FROM table_name WHERE condition);

-- 5. 테이블 설명 추가
COMMENT ON TABLE new_table IS '테이블 설명';

-- 6. 스키마 버전 기록
INSERT INTO announcements (title, content, category) 
SELECT 'DB 스키마 v4.0', '변경 내용 설명', 'system_update'
WHERE NOT EXISTS (
    SELECT 1 FROM announcements WHERE title = 'DB 스키마 v4.0'
);
```

---

## 🔧 **실무 체크리스트**

### **SQL 실행 전 확인사항**
- [ ] **백업 완료**: 중요한 데이터가 있다면 수동 백업
- [ ] **버전 관리**: 현재 스키마 버전 확인 및 새 버전 번호 결정
- [ ] **의존성 분석**: 새 테이블/컬럼이 기존 코드에 미치는 영향 검토
- [ ] **RLS 정책**: 보안 정책이 올바르게 설정되었는지 확인

### **SQL 실행 중 확인사항**
- [ ] **단계별 실행**: 전체 스크립트를 한번에 실행하지 말고 단계별로 실행
- [ ] **오류 모니터링**: 각 단계에서 오류 발생 시 즉시 중단하고 원인 분석
- [ ] **데이터 확인**: 새 테이블 생성 후 샘플 데이터 확인

### **SQL 실행 후 확인사항**
- [ ] **테이블 구조 검증**: `\d table_name`으로 테이블 구조 확인
- [ ] **정책 확인**: `\d+ table_name`으로 RLS 정책 확인
- [ ] **샘플 쿼리**: 새 기능이 정상적으로 작동하는지 테스트
- [ ] **인덱스 성능**: 새 인덱스가 쿼리 성능에 미치는 영향 확인

---

## 🚨 **응급상황 대응방법**

### **스키마 실행 중 오류 발생 시**
1. **즉시 중단**: 나머지 스크립트 실행 중단
2. **오류 분석**: 정확한 에러 메시지와 라인 번호 확인
3. **롤백 판단**: 데이터 손실 위험이 있다면 즉시 롤백
4. **수정 후 재실행**: 오류 수정 후 처음부터 다시 실행

### **롤백 방법**
```sql
-- 새로 생성된 테이블 삭제
DROP TABLE IF EXISTS new_table CASCADE;

-- 변경된 데이터 복구 (백업이 있는 경우)
-- 또는 이전 버전 스키마 재실행
```

### **일반적인 복구 패턴**
```sql
-- 1. 문제 있는 객체들 정리
DROP TABLE IF EXISTS problematic_table CASCADE;
DROP FUNCTION IF EXISTS problematic_function() CASCADE;

-- 2. 이전 상태로 복구
-- (이전 버전 SQL 스크립트 실행)

-- 3. 애플리케이션 재시작
-- (필요시 서버 재시작)
```

---

## 📝 **스키마 변경 이력 관리**

### **버전 네이밍 규칙**
- **Major.Minor.Patch** 형식 사용
- **Major**: 호환성이 깨지는 큰 변경 (v3.0 → v4.0)
- **Minor**: 새 기능 추가 (v3.0 → v3.1)  
- **Patch**: 버그 수정, 작은 개선 (v3.1 → v3.1.1)

### **변경사항 문서화**
```sql
-- 스키마 변경 로그
INSERT INTO announcements (title, content, category) VALUES
('DB 스키마 v3.1', 'chat_files, user_documents 테이블 추가', 'system_update'),
('DB 스키마 v3.2', 'file_sharing_policies RLS 정책 개선', 'system_update'),
('DB 스키마 v4.0', 'payment 시스템 테이블 대폭 개편', 'system_update');
```

### **Git 커밋 메시지 규칙**
```bash
# 좋은 예시
git commit -m "feat(db): add chat_files table for file sharing system

- Add chat_files table with Supabase Storage integration
- Add user_documents table for resume/portfolio storage  
- Update RLS policies for file access control
- Schema version: v3.0 → v3.1"

# 나쁜 예시  
git commit -m "db update"
```

---

## 🎯 **성능 최적화 고려사항**

### **인덱스 전략**
```sql
-- 자주 검색되는 컬럼에 인덱스
CREATE INDEX IF NOT EXISTS idx_user_profiles_career_status 
ON user_profiles(career_status);

-- 복합 인덱스 (순서 중요)
CREATE INDEX IF NOT EXISTS idx_bookings_date_status 
ON consultation_bookings(scheduled_date, booking_status);

-- 부분 인덱스 (조건부)
CREATE INDEX IF NOT EXISTS idx_active_posts 
ON job_seeker_posts(created_at) WHERE is_active = true;
```

### **RLS 성능 고려사항**
```sql
-- ❌ 비효율적: 서브쿼리 중첩
CREATE POLICY "complex_policy" ON table_name FOR SELECT
USING (
    EXISTS (SELECT 1 FROM other_table WHERE complex_condition)
);

-- ✅ 효율적: 단순한 조건
CREATE POLICY "simple_policy" ON table_name FOR SELECT
USING (user_id = auth.uid());
```

---

## 🔍 **디버깅 및 모니터링**

### **유용한 확인 쿼리**
```sql
-- 테이블 목록 확인
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' ORDER BY table_name;

-- RLS 정책 확인
SELECT schemaname, tablename, policyname, cmd, qual 
FROM pg_policies WHERE tablename = 'your_table';

-- 인덱스 사용률 확인
SELECT schemaname, tablename, indexname, idx_scan, idx_tup_read
FROM pg_stat_user_indexes ORDER BY idx_scan DESC;

-- 테이블 크기 확인
SELECT 
    table_name,
    pg_size_pretty(pg_total_relation_size(quote_ident(table_name))) as size
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY pg_total_relation_size(quote_ident(table_name)) DESC;
```

### **성능 모니터링**
```sql
-- 느린 쿼리 확인 (Supabase Dashboard에서)
-- Settings → Database → Query Performance 확인

-- 활성 연결 수 확인
SELECT count(*) FROM pg_stat_activity WHERE state = 'active';
```

---

## 💡 **모범 사례 요약**

### **DO ✅**
- 항상 `IF NOT EXISTS` 또는 `IF EXISTS` 사용
- 타입 캐스팅 명시적으로 처리 (`::UUID`, `::INTEGER` 등)
- 중복 데이터 방지를 위한 `ON CONFLICT` 또는 `NOT EXISTS` 사용
- 단계별로 스크립트 실행하여 문제 지점 파악
- 스키마 버전 관리 및 변경사항 문서화
- RLS 정책은 단순하고 성능에 최적화하여 작성

### **DON'T ❌**
- 전체 스크립트를 한번에 실행하지 말기
- 백업 없이 프로덕션 DB 변경하지 말기
- 타입 불일치 무시하고 진행하지 말기
- 오류 메시지 제대로 읽지 않고 추측으로 수정하지 말기
- 테이블/인덱스 존재 여부 확인 없이 생성/삭제하지 말기

---

**🎯 목표**: 이 가이드를 따라하면 **데이터 손실 없이** 안전하고 효율적으로 인사이드잡 DB 스키마를 발전시킬 수 있습니다.

**📞 문제 발생 시**: 이 문서의 체크리스트와 해결방법을 먼저 확인하고, 그래도 해결되지 않으면 Supabase 공식 문서나 커뮤니티를 참조하세요.