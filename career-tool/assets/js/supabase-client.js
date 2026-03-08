/**
 * Supabase Client - 커리어 도구 데이터베이스 연동
 * insidejob 통합 Supabase 프로젝트 사용
 */

// Supabase 설정 (insidejob 통합 프로젝트)
const SUPABASE_URL = 'https://upsedttmnulbmarhawyj.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVwc2VkdHRtbnVsYm1hcmhhd3lqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0NDk5MzIsImV4cCI6MjA3MjAyNTkzMn0.j7QuXCFfIytrBvCsIQl0bt9EuVYScIzZWGTR3tVZdUs';

// Supabase 클라이언트 초기화
let supabaseClient = null;

/**
 * Supabase 클라이언트 초기화
 */
function initializeSupabase() {
    try {
        if (typeof supabase !== 'undefined') {
            supabaseClient = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
            console.log('[Career Tool] Supabase 클라이언트 초기화 완료 (통합 프로젝트)');
            return true;
        } else {
            console.error('[Career Tool] Supabase 라이브러리가 로드되지 않음');
            return false;
        }
    } catch (error) {
        console.error('[Career Tool] Supabase 초기화 실패:', error);
        return false;
    }
}

/**
 * 현재 로그인된 insidejob 사용자 확인
 */
async function getCurrentUser() {
    try {
        if (!supabaseClient) return null;
        const { data: { user } } = await supabaseClient.auth.getUser();
        return user;
    } catch (error) {
        console.log('[Career Tool] 비로그인 상태');
        return null;
    }
}

/**
 * 사용자 기본정보 저장
 */
async function saveUserProfile(userInfo) {
    try {
        if (!supabaseClient) {
            throw new Error('Supabase 클라이언트가 초기화되지 않음');
        }

        const currentUser = await getCurrentUser();

        const { data, error } = await supabaseClient
            .from('career_guest_profiles')
            .insert([{
                name: userInfo.name,
                gender: userInfo.gender,
                phone: userInfo.phone,
                age_group: userInfo.age_group,
                privacy_consent: true,
                user_id: currentUser?.id || null
            }])
            .select();

        if (error) throw error;

        console.log('[Career Tool] 사용자 정보 저장 완료:', data[0].id);
        return { success: true, userId: data[0].id, data: data[0] };

    } catch (error) {
        console.error('[Career Tool] 사용자 정보 저장 실패:', error);
        return { success: false, error: error.message };
    }
}

/**
 * 진단 결과 저장
 */
async function saveAssessmentResult(userId, assessmentData) {
    try {
        if (!supabaseClient) {
            throw new Error('Supabase 클라이언트가 초기화되지 않음');
        }

        const currentUser = await getCurrentUser();

        const { data, error } = await supabaseClient
            .from('career_assessments')
            .insert([{
                guest_profile_id: userId,
                user_id: currentUser?.id || null,
                step1_responses: assessmentData.step1,
                step2_responses: assessmentData.step2,
                step3_responses: assessmentData.step3,
                recommended_jobs: assessmentData.recommendedJobs,
                riasec_scores: assessmentData.riasecScores,
                action_plan: assessmentData.actionPlan,
                is_completed: true,
                completed_at: new Date().toISOString()
            }])
            .select();

        if (error) throw error;

        console.log('[Career Tool] 진단 결과 저장 완료:', data[0].id);
        return { success: true, assessmentId: data[0].id, data: data[0] };

    } catch (error) {
        console.error('[Career Tool] 진단 결과 저장 실패:', error);
        return { success: false, error: error.message };
    }
}

/**
 * 진단 통계 조회
 */
async function getAssessmentStats() {
    try {
        if (!supabaseClient) {
            throw new Error('Supabase 클라이언트가 초기화되지 않음');
        }

        const { count: totalCount, error: totalError } = await supabaseClient
            .from('career_assessments')
            .select('*', { count: 'exact', head: true })
            .eq('is_completed', true);

        if (totalError) throw totalError;

        const { data: ageGroupStats, error: ageError } = await supabaseClient
            .from('career_guest_profiles')
            .select('age_group')
            .order('age_group');

        if (ageError) throw ageError;

        const { data: genderStats, error: genderError } = await supabaseClient
            .from('career_guest_profiles')
            .select('gender')
            .order('gender');

        if (genderError) throw genderError;

        return {
            success: true,
            stats: { total: totalCount, ageGroups: ageGroupStats, genders: genderStats }
        };

    } catch (error) {
        console.error('[Career Tool] 통계 조회 실패:', error);
        return { success: false, error: error.message };
    }
}

// 전역 함수 등록
window.initializeSupabase = initializeSupabase;
window.saveUserProfile = saveUserProfile;
window.saveAssessmentResult = saveAssessmentResult;
window.getAssessmentStats = getAssessmentStats;
window.getCurrentUser = getCurrentUser;
window.supabaseClient = null;

console.log('[Career Tool] Supabase 클라이언트 스크립트 로드 완료 (insidejob 통합)');
