# 🧮 인사이드잡 취업경쟁력 계산기 - 유연한 설계 문서

**개발사**: (주)오픈커넥트  
**설계 철학**: 지속적 개선과 변경을 전제로 한 유연한 아키텍처  
**기반**: 플랜비 계산기 구조 + 모듈화 + 설정 기반 동적 생성

---

## 🎯 **설계 원칙**

### **1. 변경 용이성 (Changeability)**
- ✅ **설정 파일 기반**: 계산 로직을 JSON 설정으로 외부화
- ✅ **모듈화 구조**: 각 단계를 독립적인 모듈로 분리
- ✅ **플러그인 방식**: 새로운 평가 항목을 쉽게 추가/제거
- ✅ **A/B 테스트 지원**: 서로 다른 계산 방식을 동시 운영

### **2. 확장성 (Extensibility)**
- ✅ **다양한 직군 지원**: IT, 금융, 마케팅, 제조업 등 직군별 특화
- ✅ **지역별 커스터마이징**: 서울, 부산, 해외 등 지역별 가중치
- ✅ **시대 변화 반영**: 새로운 기술, 트렌드에 맞는 평가 기준 추가

### **3. 데이터 기반 최적화 (Data-Driven Optimization)**
- ✅ **실시간 성과 분석**: 계산 정확도 추적 및 개선
- ✅ **사용자 피드백 반영**: 실제 취업 성과와 예측의 차이 분석
- ✅ **머신러닝 적용**: 누적 데이터로 예측 모델 지속 개선

---

## 🏗️ **모듈화 아키텍처**

### **핵심 구조도**
```
인사이드잡 계산기
├── 📊 ConfigManager          # 설정 관리 모듈
├── 🧩 StepModules            # 단계별 독립 모듈
│   ├── BasicInfoModule      # 1단계: 기본 정보
│   ├── SkillsModule         # 2단계: 스킬 역량  
│   ├── ExperienceModule     # 3단계: 경험 분석
│   ├── NetworkModule        # 4단계: 네트워크
│   ├── PreparationModule    # 5단계: 준비 현황
│   └── MarketModule         # 6단계: 시장 분석
├── 🧮 CalculationEngine      # 점수 계산 엔진
├── 🎨 ResultRenderer         # 결과 표시 모듈
└── 📈 AnalyticsTracker       # 성과 추적 모듈
```

### **설정 기반 동적 생성 시스템**

#### **계산기 설정 파일 (calculator-config.json)**
```json
{
  "version": "1.0",
  "metadata": {
    "name": "인사이드잡 취업경쟁력 진단",
    "description": "현직자 멘토링 플랫폼을 위한 구직자 역량 평가",
    "lastUpdated": "2025-08-29",
    "updateReason": "초기 버전 생성"
  },
  "globalSettings": {
    "maxScore": 100,
    "minScore": 0,
    "allowPartialCompletion": true,
    "autoSaveInterval": 30,
    "progressTracking": true
  },
  "steps": [
    {
      "id": "basic_info",
      "name": "기본 정보",
      "icon": "📋",
      "order": 1,
      "required": true,
      "estimatedTime": "3분",
      "weight": 0.15,
      "fields": [
        {
          "id": "age",
          "type": "number",
          "label": "만 나이",
          "required": true,
          "validation": {
            "min": 18,
            "max": 65,
            "errorMessage": "18세 이상 65세 이하만 입력 가능합니다"
          },
          "scoring": {
            "ranges": [
              {"min": 18, "max": 25, "score": 20, "label": "신입 적령기"},
              {"min": 26, "max": 35, "score": 25, "label": "경력 발전기"},
              {"min": 36, "max": 45, "score": 20, "label": "전문성 심화기"},
              {"min": 46, "max": 65, "score": 15, "label": "경험 활용기"}
            ]
          }
        },
        {
          "id": "education",
          "type": "select",
          "label": "최종 학력",
          "required": true,
          "options": [
            {"value": "high_school", "label": "고등학교 졸업", "score": 10},
            {"value": "college", "label": "전문대 졸업", "score": 15},
            {"value": "university", "label": "대학교 졸업", "score": 20},
            {"value": "graduate", "label": "대학원 졸업", "score": 25}
          ]
        }
      ]
    },
    {
      "id": "skills",
      "name": "스킬 역량",
      "icon": "🛠️",
      "order": 2,
      "required": true,
      "weight": 0.30,
      "customizable": true,
      "industrySpecific": {
        "it_development": {
          "name": "IT/개발",
          "additionalFields": [
            {
              "id": "programming_languages",
              "type": "multiselect",
              "label": "프로그래밍 언어",
              "options": [
                {"value": "python", "label": "Python", "score": 5},
                {"value": "java", "label": "Java", "score": 5},
                {"value": "javascript", "label": "JavaScript", "score": 4},
                {"value": "react", "label": "React", "score": 4},
                {"value": "nodejs", "label": "Node.js", "score": 4}
              ]
            }
          ]
        },
        "finance": {
          "name": "금융/재무",
          "additionalFields": [
            {
              "id": "finance_certifications",
              "type": "multiselect", 
              "label": "금융 자격증",
              "options": [
                {"value": "cfa", "label": "CFA", "score": 8},
                {"value": "frm", "label": "FRM", "score": 6},
                {"value": "afpk", "label": "AFPK", "score": 4}
              ]
            }
          ]
        }
      }
    }
  ],
  "calculationRules": {
    "weightingMethod": "weighted_average",
    "bonusFactors": [
      {
        "condition": "certifications.length >= 3",
        "bonus": 5,
        "description": "다양한 자격증 보유"
      },
      {
        "condition": "experience_months >= 12",
        "bonus": 10,
        "description": "1년 이상 실무 경험"
      }
    ],
    "penaltyFactors": [
      {
        "condition": "employment_gap_months > 12", 
        "penalty": -8,
        "description": "1년 이상 공백 기간"
      }
    ]
  },
  "resultConfiguration": {
    "gradeSystem": [
      {"min": 90, "max": 100, "grade": "S+", "label": "최상위 1%", "color": "#gold"},
      {"min": 85, "max": 89, "grade": "S", "label": "상위 5%", "color": "#silver"},
      {"min": 80, "max": 84, "grade": "A+", "label": "상위 10%", "color": "#bronze"},
      {"min": 75, "max": 79, "grade": "A", "label": "상위 20%", "color": "#blue"},
      {"min": 70, "max": 74, "grade": "B+", "label": "상위 30%", "color": "#green"},
      {"min": 60, "max": 69, "grade": "B", "label": "상위 50%", "color": "#yellow"},
      {"min": 50, "max": 59, "grade": "C", "label": "평균", "color": "#orange"},
      {"min": 0, "max": 49, "grade": "D", "label": "하위권", "color": "#red"}
    ]
  }
}
```

### **동적 계산기 생성 엔진**

#### **ConfigManager 모듈**
```javascript
// 설정 기반으로 계산기를 동적 생성하는 핵심 모듈
class ConfigManager {
    constructor() {
        this.config = null;
        this.cache = new Map();
        this.version = null;
    }
    
    // 설정 파일 로드 (캐싱 지원)
    async loadConfig(version = 'latest') {
        const cacheKey = `config_${version}`;
        
        if (this.cache.has(cacheKey)) {
            return this.cache.get(cacheKey);
        }
        
        try {
            // Supabase에서 설정 로드 또는 로컬 파일
            const configData = await this.fetchConfigFromDatabase(version) 
                || await fetch(`./configs/calculator-config-${version}.json`).then(r => r.json());
            
            this.config = configData;
            this.version = version;
            this.cache.set(cacheKey, configData);
            
            return configData;
        } catch (error) {
            console.error('Config loading failed:', error);
            return this.getDefaultConfig();
        }
    }
    
    // A/B 테스트용 설정 선택
    getConfigForUser(userId) {
        const testGroup = this.getABTestGroup(userId);
        
        switch(testGroup) {
            case 'A': return this.loadConfig('v1.0');
            case 'B': return this.loadConfig('v1.1-experimental');
            default: return this.loadConfig('latest');
        }
    }
    
    // 설정 유효성 검증
    validateConfig(config) {
        const requiredFields = ['version', 'steps', 'calculationRules'];
        
        for (const field of requiredFields) {
            if (!config[field]) {
                throw new Error(`Missing required config field: ${field}`);
            }
        }
        
        return true;
    }
    
    // 설정 실시간 업데이트 (관리자용)
    async updateConfig(newConfig, reason) {
        this.validateConfig(newConfig);
        
        // 버전 증가
        const currentVersion = parseFloat(this.config?.version || '1.0');
        newConfig.version = (currentVersion + 0.1).toFixed(1);
        newConfig.metadata.lastUpdated = new Date().toISOString();
        newConfig.metadata.updateReason = reason;
        
        // 데이터베이스 저장
        await this.saveConfigToDatabase(newConfig);
        
        // 캐시 무효화
        this.cache.clear();
        
        // 실시간 업데이트 알림
        this.notifyConfigUpdate(newConfig.version);
    }
}
```

#### **DynamicCalculator 엔진**
```javascript
// 설정을 읽어서 계산기를 동적으로 생성
class DynamicCalculator {
    constructor(configManager) {
        this.configManager = configManager;
        this.currentConfig = null;
        this.stepModules = new Map();
    }
    
    // 사용자별 맞춤 계산기 생성
    async createCalculator(userId, targetIndustry) {
        this.currentConfig = await this.configManager.getConfigForUser(userId);
        
        // 업계별 특화 설정 적용
        if (targetIndustry && this.currentConfig.steps) {
            this.currentConfig = this.applyIndustryCustomization(this.currentConfig, targetIndustry);
        }
        
        // 단계별 모듈 생성
        this.generateStepModules();
        
        return this;
    }
    
    // 업계별 맞춤 설정 적용
    applyIndustryCustomization(config, industry) {
        return config.steps.map(step => {
            if (step.industrySpecific && step.industrySpecific[industry]) {
                const industryConfig = step.industrySpecific[industry];
                
                return {
                    ...step,
                    name: `${step.name} (${industryConfig.name} 특화)`,
                    fields: [
                        ...step.fields,
                        ...industryConfig.additionalFields
                    ]
                };
            }
            return step;
        });
    }
    
    // 설정 기반 단계 렌더링
    renderStep(stepId) {
        const stepConfig = this.currentConfig.steps.find(s => s.id === stepId);
        
        if (!stepConfig) {
            throw new Error(`Step not found: ${stepId}`);
        }
        
        return React.createElement('div', {
            className: 'calculator-step',
            'data-step-id': stepId
        }, [
            this.renderStepHeader(stepConfig),
            this.renderStepFields(stepConfig.fields),
            this.renderStepProgress(stepConfig)
        ]);
    }
    
    // 동적 필드 렌더링
    renderStepFields(fields) {
        return fields.map(field => {
            const FieldComponent = this.getFieldComponent(field.type);
            
            return React.createElement(FieldComponent, {
                key: field.id,
                config: field,
                value: this.getFieldValue(field.id),
                onChange: (value) => this.updateFieldValue(field.id, value),
                onValidate: (value) => this.validateField(field, value)
            });
        });
    }
    
    // 필드 타입별 컴포넌트 매핑
    getFieldComponent(fieldType) {
        const components = {
            'text': TextFieldComponent,
            'number': NumberFieldComponent,
            'select': SelectFieldComponent,
            'multiselect': MultiSelectFieldComponent,
            'slider': SliderFieldComponent,
            'checkbox': CheckboxFieldComponent
        };
        
        return components[fieldType] || TextFieldComponent;
    }
    
    // 설정 기반 점수 계산
    calculateScore(formData) {
        let totalScore = 0;
        let totalWeight = 0;
        
        // 각 단계별 점수 계산
        for (const step of this.currentConfig.steps) {
            const stepScore = this.calculateStepScore(step, formData);
            totalScore += stepScore * step.weight;
            totalWeight += step.weight;
        }
        
        // 가중 평균 계산
        const baseScore = totalWeight > 0 ? totalScore / totalWeight : 0;
        
        // 보너스/패널티 적용
        const adjustedScore = this.applyBonusAndPenalties(baseScore, formData);
        
        return {
            totalScore: Math.round(Math.max(0, Math.min(100, adjustedScore))),
            breakdown: this.getScoreBreakdown(formData),
            grade: this.calculateGrade(adjustedScore),
            recommendations: this.generateRecommendations(formData, adjustedScore)
        };
    }
    
    // 실시간 설정 업데이트 수신
    onConfigUpdate(newVersion) {
        this.configManager.loadConfig(newVersion).then(newConfig => {
            this.currentConfig = newConfig;
            this.regenerateCalculator();
            this.notifyUserOfUpdate();
        });
    }
}
```

### **유연한 필드 컴포넌트 시스템**

#### **범용 필드 컴포넌트**
```javascript
// 설정 기반으로 다양한 입력 필드를 생성하는 범용 컴포넌트
const DynamicFieldComponent = ({ config, value, onChange, onValidate }) => {
    const [localValue, setLocalValue] = useState(value || config.defaultValue || '');
    const [validationError, setValidationError] = useState(null);
    const [isFocused, setIsFocused] = useState(false);
    
    // 실시간 유효성 검증
    const validateValue = (newValue) => {
        if (!config.validation) return true;
        
        const { min, max, pattern, required, custom } = config.validation;
        
        if (required && !newValue) {
            setValidationError(config.validation.errorMessage || '필수 입력 항목입니다');
            return false;
        }
        
        if (config.type === 'number') {
            if (min !== undefined && newValue < min) {
                setValidationError(`${min} 이상의 값을 입력하세요`);
                return false;
            }
            if (max !== undefined && newValue > max) {
                setValidationError(`${max} 이하의 값을 입력하세요`);
                return false;
            }
        }
        
        if (pattern && !new RegExp(pattern).test(newValue)) {
            setValidationError(config.validation.errorMessage || '형식이 올바르지 않습니다');
            return false;
        }
        
        // 커스텀 검증 함수
        if (custom && typeof custom === 'function') {
            const customResult = custom(newValue);
            if (customResult !== true) {
                setValidationError(customResult);
                return false;
            }
        }
        
        setValidationError(null);
        return true;
    };
    
    // 값 변경 핸들러
    const handleValueChange = (newValue) => {
        setLocalValue(newValue);
        
        if (validateValue(newValue)) {
            onChange(newValue);
            
            // 스코어 미리보기 (선택사항)
            if (config.showPreviewScore) {
                const previewScore = calculateFieldScore(config, newValue);
                setFieldPreviewScore(config.id, previewScore);
            }
        }
    };
    
    // 필드 타입별 렌더링
    const renderFieldByType = () => {
        const commonProps = {
            className: `field-input ${validationError ? 'error' : ''} ${isFocused ? 'focused' : ''}`,
            value: localValue,
            onFocus: () => setIsFocused(true),
            onBlur: () => setIsFocused(false)
        };
        
        switch (config.type) {
            case 'select':
                return React.createElement('select', {
                    ...commonProps,
                    onChange: (e) => handleValueChange(e.target.value)
                }, [
                    React.createElement('option', { key: 'empty', value: '' }, '선택하세요'),
                    ...config.options.map(option => 
                        React.createElement('option', {
                            key: option.value,
                            value: option.value
                        }, option.label)
                    )
                ]);
                
            case 'multiselect':
                return React.createElement('div', {
                    className: 'multiselect-container'
                }, config.options.map(option =>
                    React.createElement('label', {
                        key: option.value,
                        className: 'multiselect-option'
                    }, [
                        React.createElement('input', {
                            type: 'checkbox',
                            checked: (localValue || []).includes(option.value),
                            onChange: (e) => {
                                const currentValues = localValue || [];
                                const newValues = e.target.checked
                                    ? [...currentValues, option.value]
                                    : currentValues.filter(v => v !== option.value);
                                handleValueChange(newValues);
                            }
                        }),
                        option.label
                    ])
                ));
                
            case 'slider':
                return React.createElement('div', {
                    className: 'slider-container'
                }, [
                    React.createElement('input', {
                        type: 'range',
                        min: config.min || 0,
                        max: config.max || 100,
                        step: config.step || 1,
                        value: localValue,
                        onChange: (e) => handleValueChange(parseInt(e.target.value)),
                        className: 'slider'
                    }),
                    React.createElement('div', {
                        className: 'slider-value'
                    }, `${localValue}${config.unit || ''}`)
                ]);
                
            default:
                return React.createElement('input', {
                    ...commonProps,
                    type: config.type || 'text',
                    placeholder: config.placeholder,
                    onChange: (e) => handleValueChange(e.target.value)
                });
        }
    };
    
    return React.createElement('div', {
        className: 'dynamic-field'
    }, [
        React.createElement('label', {
            key: 'label',
            className: 'field-label'
        }, [
            config.label,
            config.required ? React.createElement('span', { className: 'required' }, ' *') : null
        ]),
        
        renderFieldByType(),
        
        validationError ? React.createElement('div', {
            key: 'error',
            className: 'field-error'
        }, validationError) : null,
        
        config.helpText ? React.createElement('div', {
            key: 'help',
            className: 'field-help'
        }, config.helpText) : null
    ]);
};
```

---

## 🔄 **지속적 개선 시스템**

### **A/B 테스트 프레임워크**
```javascript
// 서로 다른 계산 로직을 동시에 테스트하는 시스템
class ABTestManager {
    constructor() {
        this.testConfigs = new Map();
        this.userAssignments = new Map();
    }
    
    // 사용자를 테스트 그룹에 할당
    assignUserToTest(userId, testId) {
        const hash = this.hashUserId(userId);
        const group = hash % 2 === 0 ? 'A' : 'B';
        
        this.userAssignments.set(`${testId}_${userId}`, group);
        
        // 분석을 위한 이벤트 로깅
        this.logTestAssignment(userId, testId, group);
        
        return group;
    }
    
    // 테스트 성과 분석
    async analyzeTestResults(testId) {
        const results = await this.getTestResults(testId);
        
        return {
            groupA: {
                completionRate: results.A.completed / results.A.total,
                averageScore: results.A.totalScore / results.A.completed,
                satisfactionRate: results.A.satisfaction / results.A.completed
            },
            groupB: {
                completionRate: results.B.completed / results.B.total,
                averageScore: results.B.totalScore / results.B.completed,
                satisfactionRate: results.B.satisfaction / results.B.completed
            },
            significance: this.calculateSignificance(results.A, results.B)
        };
    }
}
```

### **실시간 성과 모니터링**
```javascript
// 계산기 성과를 실시간으로 추적하고 개선점을 찾는 시스템
class PerformanceAnalyzer {
    constructor() {
        this.metrics = new Map();
        this.thresholds = {
            completionRate: 0.75,
            averageTime: 600, // 10분
            errorRate: 0.05
        };
    }
    
    // 실시간 메트릭 수집
    trackCalculatorUsage(event) {
        const timestamp = Date.now();
        
        switch (event.type) {
            case 'step_start':
                this.trackStepStart(event.stepId, timestamp);
                break;
            case 'step_complete':
                this.trackStepComplete(event.stepId, timestamp);
                break;
            case 'calculator_complete':
                this.trackCalculatorComplete(event.userId, timestamp);
                break;
            case 'calculator_abandon':
                this.trackCalculatorAbandon(event.stepId, timestamp);
                break;
        }
        
        // 임계값 체크 및 알림
        this.checkThresholds();
    }
    
    // 개선 권장사항 자동 생성
    generateImprovementSuggestions() {
        const suggestions = [];
        const currentMetrics = this.getCurrentMetrics();
        
        if (currentMetrics.completionRate < this.thresholds.completionRate) {
            suggestions.push({
                type: 'completion_rate',
                message: '계산기 완료율이 낮습니다. 단계 수를 줄이거나 필수 필드를 최소화하세요.',
                priority: 'high',
                action: 'review_step_complexity'
            });
        }
        
        if (currentMetrics.averageStepTime > 120) { // 2분 초과
            suggestions.push({
                type: 'step_duration',
                message: '단계별 소요 시간이 깁니다. 필드 수나 복잡도를 검토하세요.',
                priority: 'medium',
                action: 'simplify_fields'
            });
        }
        
        return suggestions;
    }
}
```

---

## 📈 **변경 관리 프로세스**

### **1. 변경 요청 워크플로**
1. **요구사항 수집**: 사용자 피드백, 데이터 분석, 비즈니스 요구
2. **영향도 분석**: 변경이 미칠 영향 범위 평가
3. **설정 파일 수정**: JSON 설정으로 변경사항 반영
4. **A/B 테스트**: 소규모 사용자군 대상 테스트
5. **성과 분석**: 변경 전후 메트릭 비교
6. **전체 적용**: 성과 검증 후 전체 사용자 적용

### **2. 변경사항 버전 관리**
```json
{
  "versionHistory": [
    {
      "version": "1.0",
      "date": "2025-08-29",
      "changes": "초기 버전 - 기본 6단계 구조",
      "author": "개발팀"
    },
    {
      "version": "1.1",
      "date": "2025-09-15",
      "changes": "IT 업계 특화 필드 추가, 스킬 가중치 조정",
      "author": "제품팀",
      "abTestResults": {
        "completionRate": "+12%",
        "satisfactionScore": "+0.3"
      }
    }
  ]
}
```

### **3. 롤백 시스템**
```javascript
// 문제 발생시 이전 버전으로 즉시 롤백
class RollbackManager {
    async rollbackToVersion(targetVersion, reason) {
        try {
            const previousConfig = await this.loadConfigVersion(targetVersion);
            
            // 현재 버전 백업
            await this.backupCurrentVersion(reason);
            
            // 설정 롤백
            await this.applyConfig(previousConfig);
            
            // 사용자 알림
            this.notifyRollback(targetVersion, reason);
            
            return true;
        } catch (error) {
            console.error('Rollback failed:', error);
            return false;
        }
    }
}
```

---

## 🎯 **실제 활용 시나리오**

### **시나리오 1: 새로운 직군 추가**
```json
// 디자이너 직군 추가 요청 시
{
  "id": "design",
  "name": "디자인",
  "industrySpecific": {
    "design": {
      "name": "UI/UX 디자인",
      "additionalFields": [
        {
          "id": "design_tools",
          "type": "multiselect",
          "label": "디자인 도구 숙련도",
          "options": [
            {"value": "figma", "label": "Figma", "score": 5},
            {"value": "sketch", "label": "Sketch", "score": 4},
            {"value": "adobe_xd", "label": "Adobe XD", "score": 4},
            {"value": "photoshop", "label": "Photoshop", "score": 3}
          ]
        },
        {
          "id": "portfolio_quality",
          "type": "slider",
          "label": "포트폴리오 완성도",
          "min": 0,
          "max": 10,
          "scoring": {
            "multiplier": 3
          }
        }
      ]
    }
  }
}
```

### **시나리오 2: 가중치 실시간 조정**
```javascript
// 데이터 분석 결과 스킬 역량의 중요도가 높다고 판단될 때
const adjustWeights = async () => {
    const currentConfig = await configManager.loadConfig();
    
    // 스킬 가중치 30% → 35% 증가
    const updatedSteps = currentConfig.steps.map(step => {
        if (step.id === 'skills') {
            return { ...step, weight: 0.35 };
        } else if (step.id === 'basic_info') {
            return { ...step, weight: 0.10 }; // 15% → 10% 감소
        }
        return step;
    });
    
    await configManager.updateConfig({
        ...currentConfig,
        steps: updatedSteps
    }, '스킬 역량 중요도 증가로 인한 가중치 조정');
};
```

---

**💡 결론**: 설정 기반 모듈화 아키텍처로 **비즈니스 요구 변화에 빠르게 대응**하고, **데이터 기반 지속 개선**이 가능한 유연한 계산기 시스템 구축