# 🧮 취업경쟁력 계산기 상세 설계

**기반**: 플랜비 은퇴생활비 계산기 → 취업경쟁력 계산기 변환  
**개발 방식**: React.createElement 패턴 (JSX 호환성 문제 해결)  
**데이터 구조**: JSON 기반 입력/결과 저장 (플랜비와 동일)

---

## 📊 **6단계 진단 시스템 설계**

### **1단계: 기본 정보 수집**
```javascript
const step1BasicInfo = {
    // 플랜비의 기본정보 → 구직자 기본정보 변환
    name: '',
    age: null,          // 플랜비: 현재나이 → 나이
    education: '',      // 신규: 고등학교/전문대/대학교/대학원
    major: '',          // 신규: 전공 분야
    targetIndustry: '', // 신규: 희망 업계
    targetJob: '',      // 신규: 희망 직무
    location: '',       // 신규: 희망 근무 지역
    salaryExpectation: null // 신규: 희망 연봉 (만원)
};
```

**UI 구조** (플랜비 1단계 기본정보 패턴 활용):
```javascript
const renderStep1BasicInfo = () => {
    return React.createElement('div', {
        className: 'space-y-6'
    }, [
        // 플랜비와 동일한 카드 레이아웃
        React.createElement('div', {
            key: 'basic-card',
            className: 'card'
        }, [
            React.createElement('h3', {
                key: 'title',
                className: 'text-xl font-semibold mb-4'
            }, '📋 기본 정보'),
            
            // 나이 입력 (플랜비 패턴)
            React.createElement('div', {
                key: 'age-group',
                className: 'mb-4'
            }, [
                React.createElement('label', {
                    key: 'age-label',
                    className: 'block text-sm font-medium text-gray-700 mb-2'
                }, '나이'),
                React.createElement('input', {
                    key: 'age-input',
                    type: 'number',
                    value: formData.age || '',
                    onChange: (e) => updateFormData('age', parseInt(e.target.value)),
                    className: 'w-full px-3 py-2 border border-gray-300 rounded-lg',
                    placeholder: '만 나이를 입력하세요'
                })
            ]),
            
            // 학력 선택 (신규)
            React.createElement('div', {
                key: 'education-group',
                className: 'mb-4'
            }, [
                React.createElement('label', {
                    key: 'education-label',
                    className: 'block text-sm font-medium text-gray-700 mb-2'
                }, '최종 학력'),
                React.createElement('select', {
                    key: 'education-select',
                    value: formData.education || '',
                    onChange: (e) => updateFormData('education', e.target.value),
                    className: 'w-full px-3 py-2 border border-gray-300 rounded-lg'
                }, [
                    React.createElement('option', { key: 'edu-empty', value: '' }, '선택하세요'),
                    React.createElement('option', { key: 'edu-high', value: 'high_school' }, '고등학교 졸업'),
                    React.createElement('option', { key: 'edu-college', value: 'college' }, '전문대 졸업'),
                    React.createElement('option', { key: 'edu-university', value: 'university' }, '대학교 졸업'),
                    React.createElement('option', { key: 'edu-graduate', value: 'graduate' }, '대학원 졸업')
                ])
            ])
        ])
    ]);
};
```

---

### **2단계: 스킬 역량 분석**
```javascript
const step2SkillAnalysis = {
    // 플랜비 자산현황 → 스킬 자산 변환
    technicalSkills: [],    // 기술 스택 (다중 선택)
    certifications: [],     // 자격증 리스트
    languages: {           // 어학 능력
        english: '',       // TOEIC/OPIC/없음
        others: []         // 기타 언어
    },
    portfolioCount: 0,     // 포트폴리오/프로젝트 수
    specialSkills: []      // 특기/기타 역량
};
```

**스킬 평가 로직**:
```javascript
const calculateSkillScore = (skillData) => {
    let score = 0;
    
    // 기술 스택 점수 (최대 40점)
    score += Math.min(skillData.technicalSkills.length * 5, 40);
    
    // 자격증 점수 (최대 25점)
    score += Math.min(skillData.certifications.length * 8, 25);
    
    // 어학 점수 (최대 20점)
    if (skillData.languages.english === 'toeic_high') score += 15;
    else if (skillData.languages.english === 'toeic_mid') score += 10;
    else if (skillData.languages.english === 'opic') score += 12;
    
    // 포트폴리오 점수 (최대 15점)
    score += Math.min(skillData.portfolioCount * 5, 15);
    
    return Math.min(score, 100);
};
```

---

### **3단계: 경험 분석**
```javascript
const step3ExperienceAnalysis = {
    // 플랜비 부채정보 → 경험 자산 변환
    internships: [],       // 인턴십 경험
    partTimeJobs: [],      // 아르바이트 경험
    projects: [],          // 프로젝트 경험
    activities: [],        // 동아리/봉사활동
    awards: [],           // 수상 경력
    totalExperienceMonths: 0 // 총 경험 개월 수
};
```

**경험 점수 계산** (플랜비 부채 계산 로직 변환):
```javascript
const calculateExperienceScore = (expData) => {
    let score = 0;
    
    // 인턴십 경험 (최대 30점)
    score += Math.min(expData.internships.length * 15, 30);
    
    // 프로젝트 경험 (최대 25점)  
    score += Math.min(expData.projects.length * 8, 25);
    
    // 활동 경험 (최대 20점)
    score += Math.min(expData.activities.length * 5, 20);
    
    // 총 경험 기간 (최대 25점)
    score += Math.min(expData.totalExperienceMonths * 2, 25);
    
    return Math.min(score, 100);
};
```

---

### **4단계: 네트워크 현황**
```javascript
const step4NetworkAnalysis = {
    // 플랜비 연금정보 → 네트워크 자산 변환
    industryConnections: 0,    // 업계 인맥 수
    referralPossibility: '',   // 추천서 가능성
    mentorExists: false,       // 멘토 보유 여부
    networkingActivities: [],  // 네트워킹 활동
    socialMedia: {            // SNS 활동
        linkedin: false,
        github: false,
        blog: false
    }
};
```

---

### **5단계: 준비 현황**
```javascript
const step5PreparationStatus = {
    // 플랜비 지출계획 → 취업 준비 현황 변환
    resumeStatus: '',          // 이력서 완성도
    coverLetterStatus: '',     // 자기소개서 준비도
    interviewPreparation: '',  // 면접 준비 상태
    applicationCount: 0,       // 지원 회사 수
    studyGroups: [],          // 스터디/준비 모임
    preparationMonths: 0       // 준비 기간 (개월)
};
```

---

### **6단계: 시장 분석**
```javascript
const step6MarketAnalysis = {
    // 플랜비 건강수명 → 시장성 분석 변환
    industryGrowth: '',        // 업계 성장성
    jobDemand: '',            // 직무 수요도
    competitionLevel: '',     // 경쟁 강도
    salaryRange: {            // 연봉 범위
        min: 0,
        max: 0,
        average: 0
    },
    locationAdvantage: ''     // 지역적 이점
};
```

---

## 🎯 **종합 점수 계산 알고리즘**

### **플랜비 은퇴생활비 계산 → 취업경쟁력 점수 계산 변환**

```javascript
const calculateCareerCompetitiveness = (allStepData) => {
    // 플랜비의 단계별 가중치 구조 활용
    const weights = {
        skills: 0.30,      // 스킬 역량 30%
        experience: 0.25,  // 경험 25%  
        preparation: 0.20, // 준비도 20%
        network: 0.15,     // 네트워크 15%
        market: 0.10       // 시장성 10%
    };
    
    const scores = {
        skills: calculateSkillScore(allStepData.step2),
        experience: calculateExperienceScore(allStepData.step3),
        preparation: calculatePreparationScore(allStepData.step5),
        network: calculateNetworkScore(allStepData.step4),
        market: calculateMarketScore(allStepData.step6)
    };
    
    // 가중 평균 계산
    const totalScore = Object.keys(weights).reduce((total, key) => {
        return total + (scores[key] * weights[key]);
    }, 0);
    
    return {
        totalScore: Math.round(totalScore),
        breakdown: scores,
        grade: getGrade(totalScore),
        recommendations: generateRecommendations(scores)
    };
};

const getGrade = (score) => {
    if (score >= 90) return 'S급 (최상위 1%)';
    if (score >= 80) return 'A급 (상위 10%)';
    if (score >= 70) return 'B급 (상위 30%)';
    if (score >= 60) return 'C급 (상위 50%)';
    if (score >= 50) return 'D급 (상위 70%)';
    return 'F급 (하위 30%)';
};
```

---

## 📈 **결과 표시 시스템** (플랜비 결과 화면 기반)

### **메인 결과 카드**
```javascript
const renderMainResult = (result) => {
    return React.createElement('div', {
        className: 'card bg-gradient-to-r from-blue-50 to-indigo-50'
    }, [
        React.createElement('div', {
            key: 'score-display',
            className: 'text-center mb-6'
        }, [
            React.createElement('h2', {
                key: 'title',
                className: 'text-3xl font-bold text-gray-800 mb-2'
            }, '🎯 취업경쟁력 진단 결과'),
            
            React.createElement('div', {
                key: 'score-circle',
                className: 'relative inline-block'
            }, [
                // 플랜비와 동일한 원형 점수 표시
                React.createElement('div', {
                    key: 'circle',
                    className: 'w-32 h-32 rounded-full border-8 border-blue-200 flex items-center justify-center bg-white'
                }, [
                    React.createElement('div', {
                        key: 'score-text',
                        className: 'text-center'
                    }, [
                        React.createElement('div', {
                            key: 'score-number',
                            className: 'text-4xl font-bold text-blue-600'
                        }, result.totalScore),
                        React.createElement('div', {
                            key: 'score-max',
                            className: 'text-sm text-gray-500'
                        }, '/ 100')
                    ])
                ])
            ]),
            
            React.createElement('div', {
                key: 'grade',
                className: 'mt-4 text-xl font-semibold text-indigo-600'
            }, result.grade)
        ])
    ]);
};
```

### **상세 분석 차트** (플랜비 차트 구조 활용)
```javascript
const renderDetailedAnalysis = (breakdown) => {
    return React.createElement('div', {
        className: 'card'
    }, [
        React.createElement('h3', {
            key: 'title',
            className: 'text-xl font-semibold mb-4'
        }, '📊 영역별 상세 분석'),
        
        // 플랜비와 동일한 바 차트 구조
        Object.keys(breakdown).map((key, index) => {
            const labels = {
                skills: '🛠️ 스킬 역량',
                experience: '💼 경험',
                preparation: '📝 준비도',
                network: '🤝 네트워크',
                market: '📈 시장성'
            };
            
            return React.createElement('div', {
                key: key,
                className: 'mb-4'
            }, [
                React.createElement('div', {
                    key: 'label',
                    className: 'flex justify-between mb-2'
                }, [
                    React.createElement('span', {
                        key: 'name',
                        className: 'font-medium'
                    }, labels[key]),
                    React.createElement('span', {
                        key: 'score',
                        className: 'font-semibold text-blue-600'
                    }, `${breakdown[key]}점`)
                ]),
                
                React.createElement('div', {
                    key: 'bar-container',
                    className: 'w-full bg-gray-200 rounded-full h-3'
                }, [
                    React.createElement('div', {
                        key: 'bar-fill',
                        className: 'bg-blue-500 h-3 rounded-full transition-all duration-1000',
                        style: { width: `${breakdown[key]}%` }
                    })
                ])
            ]);
        })
    ]);
};
```

---

## 🎯 **액션 플랜 생성** (플랜비 권장사항 로직 활용)

### **개선 권장사항 자동 생성**
```javascript
const generateRecommendations = (scores) => {
    const recommendations = [];
    
    // 플랜비의 부족액 대응 방안 → 부족 역량 개선 방안
    if (scores.skills < 70) {
        recommendations.push({
            category: '스킬 개발',
            priority: 'high',
            actions: [
                '희망 직무 필수 기술 스택 학습',
                '온라인 강의 수강 및 자격증 취득',
                '개인 프로젝트를 통한 실무 경험 쌓기'
            ]
        });
    }
    
    if (scores.experience < 60) {
        recommendations.push({
            category: '경험 보완', 
            priority: 'high',
            actions: [
                '인턴십 또는 현장실습 지원',
                '사이드 프로젝트 또는 창업 동아리 참여',
                '봉사활동이나 대외활동으로 리더십 경험'
            ]
        });
    }
    
    if (scores.network < 50) {
        recommendations.push({
            category: '네트워킹',
            priority: 'medium', 
            actions: [
                'LinkedIn 프로필 완성 및 업계 전문가 연결',
                '취업 스터디 그룹이나 멘토링 프로그램 참여',
                '업계 컨퍼런스나 네트워킹 이벤트 참석'
            ]
        });
    }
    
    return recommendations;
};
```

---

## 💾 **데이터 저장/복원** (플랜비 패턴 완전 동일)

### **계산 결과 저장**
```javascript
const saveCalculationResult = async (resultData) => {
    try {
        if (currentUser.isGuest) {
            // 게스트: localStorage 저장 (플랜비 패턴)
            localStorage.setItem('career_calculation_guest', JSON.stringify(resultData));
        } else {
            // 회원: Supabase 저장 (플랜비 패턴) 
            const { error } = await supabase
                .from('career_calculations')
                .insert({
                    user_id: currentUser.id,
                    calculation_data: resultData,
                    total_score: resultData.totalScore,
                    grade: resultData.grade
                });
                
            if (error) throw error;
        }
        
        setShowSaveSuccess(true);
    } catch (error) {
        setShowSaveError(true);
    }
};
```

### **게스트 → 회원 데이터 마이그레이션** (플랜비 완전 동일)
```javascript
const migrateGuestData = async (newUserId) => {
    try {
        const guestData = localStorage.getItem('career_calculation_guest');
        if (guestData) {
            const parsedData = JSON.parse(guestData);
            
            await supabase
                .from('career_calculations')
                .insert({
                    user_id: newUserId,
                    calculation_data: parsedData,
                    total_score: parsedData.totalScore,
                    grade: parsedData.grade,
                    migrated_from_guest: true
                });
                
            localStorage.removeItem('career_calculation_guest');
        }
    } catch (error) {
        console.error('Guest data migration failed:', error);
    }
};
```

---

## 🚀 **개발 우선순위**

### **1단계 (1주차): 기본 구조**
- [ ] 6단계 입력 폼 UI 구현 (플랜비 구조 복사)
- [ ] React.createElement 패턴으로 안정적 렌더링
- [ ] 단계별 데이터 상태 관리

### **2단계 (2주차): 계산 로직**
- [ ] 각 단계별 점수 계산 알고리즘 구현
- [ ] 종합 점수 및 등급 산출
- [ ] 결과 화면 및 차트 렌더링

### **3단계 (3주차): 데이터 처리**
- [ ] 계산 결과 저장/복원 기능
- [ ] 게스트 데이터 마이그레이션  
- [ ] 이전 결과와 비교 기능

### **4단계 (4주차): 고도화**
- [ ] 액션 플랜 자동 생성
- [ ] 또래 비교 통계
- [ ] 결과 공유 기능

---

**💡 핵심: 플랜비의 검증된 6단계 계산 구조와 React.createElement 패턴을 그대로 활용하여 안정적이고 빠른 개발 진행**