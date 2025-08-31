# 📁 인사이드잡 Supabase Storage 간소화 설정 가이드

> **전문가 인증용 파일 업로드만 지원하는 최적화된 설정**

## 🎯 **변경된 방향**

**AS-IS (이전 복잡한 구조):**
- 채팅 파일 공유 + 사용자 문서함 + 전문가 인증
- 여러 버킷 관리, 복잡한 RLS 정책
- 용량 관리 부담

**TO-BE (현재 간소화된 구조):**
- ✅ **전문가 인증용 파일 업로드만 지원**
- ✅ **단일 버킷 관리**: `expert-verification` 
- ✅ **관리자 검토 전용**: 용량 제어 및 보안 강화
- ✅ **상담 시 자료 공유**: 이메일 등 외부 채널 권장

---

## 📋 **필수 설정 체크리스트**

### ✅ **1단계: Storage 버킷 생성**
- [ ] `expert-verification` 버킷 생성 (전문가 인증 서류 전용)
- [ ] Private 접근 정책 설정 (관리자만 조회)
- [ ] 파일 크기 제한: 5MB (재직증명서, 자격증 등)

### ✅ **2단계: RLS 보안 정책 설정**
- [ ] 전문가 신청자만 업로드 가능
- [ ] 관리자만 조회/다운로드 가능
- [ ] 개인정보 보호 강화

### ✅ **3단계: 데이터베이스 스키마 정리**
- [ ] `chat_files` 테이블 제거
- [ ] `user_documents` 테이블 제거  
- [ ] `professional_requests` 테이블만 유지

---

## 🔧 **1단계: Supabase Dashboard 설정**

### **expert-verification 버킷 생성**

```
Bucket Name: expert-verification
Public bucket: ❌ 체크 해제 (관리자만 접근)
File size limit: 5 MB
Allowed MIME types: 
- application/pdf
- image/jpeg
- image/png
- application/msword
- application/vnd.openxmlformats-officedocument.wordprocessingml.document
```

---

## 🛡️ **2단계: Storage RLS 정책 설정**

### **expert-verification 버킷 정책**

```sql
-- 관리자만 모든 파일 조회 가능
CREATE POLICY "Admins can view all expert verification files" ON storage.objects
FOR SELECT USING (
    bucket_id = 'expert-verification' AND 
    EXISTS (
        SELECT 1 FROM user_profiles 
        WHERE user_profiles.user_id = auth.uid() 
        AND user_profiles.role IN ('admin', 'super_admin')
    )
);

-- 전문가 신청자는 본인 파일만 업로드 가능
CREATE POLICY "Expert applicants can upload their verification files" ON storage.objects
FOR INSERT WITH CHECK (
    bucket_id = 'expert-verification' AND 
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

-- 본인 파일 삭제 가능 (신청 취소 시)
CREATE POLICY "Users can delete their own verification files" ON storage.objects
FOR DELETE USING (
    bucket_id = 'expert-verification' AND 
    auth.uid()::text = (storage.foldername(name))[1]
);
```

---

## 🗄️ **3단계: 간소화된 데이터베이스 스키마**

### **professional_requests 테이블에 파일 정보 추가**

```sql
-- 기존 professional_requests 테이블에 파일 필드 추가
ALTER TABLE professional_requests 
ADD COLUMN IF NOT EXISTS verification_files JSONB DEFAULT '[]'::jsonb;

-- 파일 정보 구조 예시:
-- verification_files: [
--   {
--     "type": "business_license",
--     "filename": "사업자등록증.pdf", 
--     "storage_path": "user_id/timestamp_filename.pdf",
--     "file_size": 1024000,
--     "uploaded_at": "2025-08-31T10:00:00.000Z"
--   }
-- ]

-- 전문가 인증 상태 추가
ALTER TABLE professional_requests 
ADD COLUMN IF NOT EXISTS verification_status TEXT DEFAULT 'pending' 
CHECK (verification_status IN ('pending', 'documents_required', 'under_review', 'approved', 'rejected'));

-- 관리자 메모 필드 추가  
ALTER TABLE professional_requests 
ADD COLUMN IF NOT EXISTS admin_notes TEXT;
```

---

## 🧪 **4단계: 설정 확인 및 테스트**

### **전문가 파일 업로드 테스트**

```javascript
// 전문가 인증 파일 업로드 테스트
const testExpertFileUpload = async () => {
    try {
        // 1. 테스트 파일 생성
        const testContent = 'Expert verification document';
        const blob = new Blob([testContent], { type: 'application/pdf' });
        const file = new File([blob], '재직증명서.pdf', { type: 'application/pdf' });
        
        // 2. Storage에 업로드
        const fileName = `${auth.user.id}/business/${Date.now()}_재직증명서.pdf`;
        const { data, error } = await supabase.storage
            .from('expert-verification')
            .upload(fileName, file);
            
        if (error) throw error;
        console.log('✅ 전문가 파일 업로드 성공:', data);
        
        // 3. DB에 파일 정보 업데이트
        const fileInfo = {
            type: 'business_license',
            filename: '재직증명서.pdf',
            storage_path: fileName,
            file_size: file.size,
            uploaded_at: new Date().toISOString()
        };
        
        const { error: dbError } = await supabase
            .from('professional_requests')
            .update({
                verification_files: [fileInfo],
                verification_status: 'under_review'
            })
            .eq('user_id', auth.user.id);
            
        if (dbError) throw dbError;
        console.log('✅ DB 업데이트 성공');
        
    } catch (error) {
        console.error('❌ 테스트 실패:', error);
    }
};
```

---

## 📊 **5단계: 관리자 대시보드 기능**

### **관리자용 파일 조회 쿼리**

```sql
-- 관리자가 모든 전문가 인증 파일 조회
SELECT 
    pr.id,
    pr.name,
    pr.email,
    pr.verification_status,
    pr.verification_files,
    pr.created_at,
    pr.admin_notes
FROM professional_requests pr
WHERE pr.verification_status IN ('pending', 'documents_required', 'under_review')
ORDER BY pr.created_at DESC;

-- 특정 전문가의 파일 다운로드 링크 생성 (관리자만)
SELECT 
    storage_path,
    filename
FROM professional_requests pr,
     jsonb_array_elements(pr.verification_files) as files
WHERE pr.id = $1;
```

---

## 💡 **운영 방식**

### **전문가 신청 프로세스**
1. **신청자**: 전문가 등록 폼 작성 + 인증서류 업로드
2. **시스템**: 파일을 `expert-verification` 버킷에 저장
3. **관리자**: 관리자 대시보드에서 서류 검토
4. **승인/반려**: 관리자가 인증 상태 업데이트
5. **정리**: 승인/반려 후 일정 기간 후 파일 삭제

### **상담 시 자료 공유**
- ❌ **기존**: 채팅에서 파일 업로드
- ✅ **개선**: 현직자가 구직자에게 이메일 요청
- 📧 **예시**: "포트폴리오를 example@gmail.com으로 보내주세요"
- 🔒 **장점**: 개인정보 보호, 용량 절약, 관리 간소화

---

## 🚨 **마이그레이션 가이드**

### **기존 설정에서 간소화로 변경 시**

```sql
-- 1. 기존 불필요한 테이블 제거
DROP TABLE IF EXISTS chat_files CASCADE;
DROP TABLE IF EXISTS user_documents CASCADE;

-- 2. 기존 Storage 정책 제거
DROP POLICY IF EXISTS "Users can view shared files in their chat rooms" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload files to their chat rooms" ON storage.objects;
DROP POLICY IF EXISTS "Users can view their own documents" ON storage.objects;

-- 3. 불필요한 버킷 제거 (데이터 확인 후)
-- Supabase Dashboard에서 수동 삭제:
-- - chat-files 버킷
-- - user-documents 버킷
```

---

## 📈 **예상 효과**

### **용량 관리**
- 📉 **용량 사용량**: 90% 감소 예상
- 🎯 **관리 포인트**: 전문가 인증 파일만 집중 관리
- 🗂️ **예상 크기**: 전문가 1명당 평균 5MB 이하

### **운영 효율성**
- ⏱️ **관리 시간**: 80% 단축
- 🔒 **보안 강화**: 민감한 인증 서류만 플랫폼 보관
- 💰 **비용 절약**: Storage 비용 대폭 절약

### **사용자 경험**
- ✅ **전문가**: 간단한 인증 서류만 업로드
- ✅ **구직자**: 추가 파일 업로드 부담 없음
- ✅ **관리자**: 체계적인 인증 관리 가능

---

**🎯 결론**: 파일 업로드를 전문가 인증용으로만 제한하여 용량 관리를 최적화하고, 상담 시 자료 공유는 이메일 등 외부 채널을 활용하는 것이 더 효율적이고 안전합니다.

📞 **문의**: 추가 설정이 필요하시면 DATABASE_UPDATE_GUIDE.md를 참고해주세요.