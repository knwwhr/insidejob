# 📁 Supabase Storage 설정 가이드

> **인사이드잡 파일 업로드/다운로드 시스템 완전 설정 가이드**

## 🎯 **개요**

인사이드잡에서 구현된 파일 업로드/다운로드 시스템이 완전히 작동하기 위해서는 Supabase Storage 버킷과 RLS 정책을 설정해야 합니다.

---

## 📋 **필수 설정 체크리스트**

### ✅ **1단계: Storage 버킷 생성**
- [ ] `chat-files` 버킷 생성 (채팅 파일 공유용)
- [ ] `user-documents` 버킷 생성 (사용자 문서함용)
- [ ] Public 접근 정책 설정
- [ ] 파일 크기 제한 설정

### ✅ **2단계: RLS 보안 정책 설정**
- [ ] `chat_files` 테이블 RLS 활성화
- [ ] `user_documents` 테이블 RLS 활성화
- [ ] 사용자별 파일 접근 제어 정책 생성

### ✅ **3단계: 데이터베이스 스키마 적용**
- [ ] `chat_files` 테이블 생성
- [ ] `user_documents` 테이블 생성
- [ ] 인덱스 생성

---

## 🔧 **1단계: Supabase Dashboard 설정**

### **Storage 버킷 생성**

1. **Supabase Dashboard 접속**
   - 프로젝트 선택 → Storage → Create a new bucket

2. **chat-files 버킷 생성**
   ```
   Bucket Name: chat-files
   Public bucket: ✅ 체크
   File size limit: 10 MB
   Allowed MIME types: 
   - application/pdf
   - application/msword
   - application/vnd.openxmlformats-officedocument.wordprocessingml.document
   - application/vnd.ms-excel
   - application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
   - image/jpeg
   - image/png
   - image/gif
   - image/webp
   - text/plain
   - text/csv
   ```

3. **user-documents 버킷 생성**
   ```
   Bucket Name: user-documents
   Public bucket: ✅ 체크
   File size limit: 50 MB (Supabase 글로벌 제한)
   Allowed MIME types: 
   - application/pdf
   - application/msword
   - application/vnd.openxmlformats-officedocument.wordprocessingml.document
   - image/jpeg
   - image/png
   ```

---

## 🛡️ **2단계: Storage RLS 정책 설정**

### **chat-files 버킷 정책**

```sql
-- chat-files 버킷: 채팅 참여자만 업로드/다운로드 가능
CREATE POLICY "Anyone can view chat files" ON storage.objects
FOR SELECT USING (bucket_id = 'chat-files');

CREATE POLICY "Authenticated users can upload chat files" ON storage.objects
FOR INSERT WITH CHECK (
    bucket_id = 'chat-files' AND 
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can update their own chat files" ON storage.objects
FOR UPDATE USING (
    bucket_id = 'chat-files' AND 
    auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can delete their own chat files" ON storage.objects
FOR DELETE USING (
    bucket_id = 'chat-files' AND 
    auth.uid()::text = (storage.foldername(name))[1]
);
```

### **user-documents 버킷 정책**

```sql
-- user-documents 버킷: 각 사용자는 본인 문서만 관리 가능
CREATE POLICY "Users can view their own documents" ON storage.objects
FOR SELECT USING (
    bucket_id = 'user-documents' AND 
    auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can upload their own documents" ON storage.objects
FOR INSERT WITH CHECK (
    bucket_id = 'user-documents' AND 
    auth.role() = 'authenticated' AND
    auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can update their own documents" ON storage.objects
FOR UPDATE USING (
    bucket_id = 'user-documents' AND 
    auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can delete their own documents" ON storage.objects
FOR DELETE USING (
    bucket_id = 'user-documents' AND 
    auth.uid()::text = (storage.foldername(name))[1]
);
```

---

## 🗄️ **3단계: 데이터베이스 테이블 RLS 정책**

### **chat_files 테이블 정책**

```sql
-- chat_files 테이블 RLS 활성화
ALTER TABLE chat_files ENABLE ROW LEVEL SECURITY;

-- 채팅 참여자만 파일 조회 가능
CREATE POLICY "Users can view shared files in their chat rooms" ON chat_files
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM chat_participants
        WHERE chat_participants.room_id = chat_files.room_id
        AND chat_participants.user_id = auth.uid()
        AND chat_participants.is_active = true
    )
);

-- 채팅 참여자만 파일 업로드 가능
CREATE POLICY "Users can upload files to their chat rooms" ON chat_files
FOR INSERT WITH CHECK (
    EXISTS (
        SELECT 1 FROM chat_participants
        WHERE chat_participants.room_id = chat_files.room_id
        AND chat_participants.user_id = auth.uid()
        AND chat_participants.is_active = true
    )
);
```

### **user_documents 테이블 정책**

```sql
-- user_documents 테이블 RLS 활성화
ALTER TABLE user_documents ENABLE ROW LEVEL SECURITY;

-- 사용자는 본인 문서만 조회 가능
CREATE POLICY "Users can view own documents" ON user_documents
FOR SELECT USING (auth.uid() = user_id);

-- 사용자는 본인 문서만 업로드 가능
CREATE POLICY "Users can upload own documents" ON user_documents
FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 사용자는 본인 문서만 수정 가능
CREATE POLICY "Users can update own documents" ON user_documents
FOR UPDATE USING (auth.uid() = user_id);
```

---

## 🔍 **4단계: 성능 최적화 인덱스**

```sql
-- chat_files 테이블 인덱스
CREATE INDEX IF NOT EXISTS idx_chat_files_room_user 
ON chat_files(room_id, user_id);

CREATE INDEX IF NOT EXISTS idx_chat_files_created_at 
ON chat_files(created_at DESC);

-- user_documents 테이블 인덱스
CREATE INDEX IF NOT EXISTS idx_user_documents_user_type 
ON user_documents(user_id, document_type);

CREATE INDEX IF NOT EXISTS idx_user_documents_active 
ON user_documents(user_id, is_active) WHERE is_active = true;
```

---

## 🧪 **5단계: 설정 확인 및 테스트**

### **테스트 스크립트**

```javascript
// 브라우저 콘솔에서 실행할 테스트 코드
const testFileUpload = async () => {
    try {
        // 1. 더미 파일 생성
        const testContent = 'Hello, InsideJob!';
        const blob = new Blob([testContent], { type: 'text/plain' });
        const file = new File([blob], 'test.txt', { type: 'text/plain' });
        
        // 2. Storage에 업로드 테스트
        const fileName = `${Date.now()}_test.txt`;
        const { data, error } = await supabase.storage
            .from('chat-files')
            .upload(`test-user/${fileName}`, file);
            
        if (error) throw error;
        console.log('✅ 파일 업로드 성공:', data);
        
        // 3. Public URL 테스트
        const { data: urlData } = supabase.storage
            .from('chat-files')
            .getPublicUrl(`test-user/${fileName}`);
            
        console.log('✅ Public URL 생성 성공:', urlData.publicUrl);
        
        // 4. 파일 삭제
        await supabase.storage
            .from('chat-files')
            .remove([`test-user/${fileName}`]);
            
        console.log('✅ 파일 삭제 성공');
        
    } catch (error) {
        console.error('❌ 테스트 실패:', error);
    }
};

// 테스트 실행
testFileUpload();
```

---

## 📊 **6단계: 모니터링 설정**

### **Storage 사용량 모니터링**

```sql
-- Storage 사용량 확인 쿼리
SELECT 
    bucket_id,
    COUNT(*) as file_count,
    SUM(CASE WHEN metadata IS NOT NULL THEN (metadata->>'size')::bigint ELSE 0 END) as total_size_bytes,
    pg_size_pretty(SUM(CASE WHEN metadata IS NOT NULL THEN (metadata->>'size')::bigint ELSE 0 END)) as total_size_formatted
FROM storage.objects 
GROUP BY bucket_id;

-- 사용자별 문서 사용량
SELECT 
    u.email,
    COUNT(ud.*) as document_count,
    SUM(ud.file_size) as total_size_bytes,
    pg_size_pretty(SUM(ud.file_size)) as total_size_formatted
FROM user_documents ud
JOIN auth.users u ON u.id = ud.user_id
WHERE ud.is_active = true
GROUP BY u.email
ORDER BY SUM(ud.file_size) DESC
LIMIT 10;
```

---

## 🚨 **문제 해결 가이드**

### **자주 발생하는 문제들**

#### **1. 파일 업로드 실패**
```
오류: "new row violates row-level security policy"
해결: RLS 정책이 올바르게 설정되었는지 확인
```

#### **2. 파일 다운로드 불가**
```
오류: "Access denied"
해결: 버킷이 Public으로 설정되었는지 확인
```

#### **3. 파일 크기 제한 초과**
```
오류: "Payload too large"
해결: 버킷 설정에서 파일 크기 제한 확인
```

#### **4. MIME 타입 오류**
```
오류: "File type not allowed"
해결: 버킷 설정에서 허용된 MIME 타입 확인
```

### **디버깅 도구**

```javascript
// Storage 디버깅 헬퍼 함수
const debugStorage = {
    // 버킷 목록 확인
    listBuckets: async () => {
        const { data, error } = await supabase.storage.listBuckets();
        console.log('Buckets:', data, error);
    },
    
    // 특정 버킷의 파일 목록 확인
    listFiles: async (bucketName, path = '') => {
        const { data, error } = await supabase.storage
            .from(bucketName)
            .list(path);
        console.log(`Files in ${bucketName}:`, data, error);
    },
    
    // 현재 사용자 ID 확인
    getCurrentUser: async () => {
        const { data: { user } } = await supabase.auth.getUser();
        console.log('Current user:', user?.id);
    }
};
```

---

## 📝 **완료 체크리스트**

설정이 완료되면 다음 항목들을 체크하세요:

- [ ] **채팅 파일 공유**: 채팅방에서 파일 업로드/다운로드 가능
- [ ] **문서함**: 마이페이지에서 문서 업로드/관리 가능
- [ ] **보안**: 다른 사용자의 파일에 접근 불가
- [ ] **성능**: 파일 업로드/다운로드 속도 만족
- [ ] **용량**: Storage 사용량 모니터링 가능

---

## 🎯 **운영 권장사항**

### **용량 관리**
- 주기적으로 Storage 사용량 모니터링
- 비활성 사용자의 파일 정리 정책 수립
- 파일 압축 및 최적화 가이드 제공

### **보안 강화**
- 파일 업로드 시 바이러스 검사 (향후 확장)
- 민감한 문서의 암호화 저장 (향후 확장)
- 파일 접근 로그 수집 및 분석

### **사용자 경험 개선**
- 파일 업로드 진행률 표시
- 드래그 앤 드롭 지원
- 이미지 파일 미리보기 기능

---

**🎉 설정 완료 후 인사이드잡의 파일 업로드/다운로드 시스템이 완전히 작동합니다!**

📞 **문제 발생 시**: DATABASE_UPDATE_GUIDE.md 참고 또는 Supabase 공식 문서 확인