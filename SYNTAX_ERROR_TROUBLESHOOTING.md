# 인사이드잡 JavaScript 구문 오류 해결 가이드

**작성일**: 2025년 1월 14일  
**최종 업데이트**: 구문 오류 완전 해결  
**목적**: 향후 JavaScript/React 구문 오류 발생 시 빠른 진단 및 해결

---

## 🚨 발생한 구문 오류 유형들

### 1. **'return' outside of function** 오류
```
SyntaxError: 'return' outside of function. (12818:28)
```

**원인**: React 컴포넌트 함수가 끝난 후에 return 문이 있었음
```javascript
const ExpertFinderComponent = () => {
    return <div>...</div>;
}; // 함수 끝

// ❌ 문제: 함수 밖에 있는 return 문
if (loading) {
    return <div>Loading...</div>; // 오류 발생!
}
```

### 2. **Invalid hook call** 오류
```
Warning: Invalid hook call. Hooks can only be called inside of the body of a function component.
```

**원인**: React hooks(useState, useEffect 등)가 컴포넌트 함수 밖에서 호출됨
```javascript
const ExpertFinderComponent = () => {
    return <div>...</div>;
}; // 함수 끝

// ❌ 문제: 함수 밖에서 hooks 호출
useEffect(() => {  // 오류 발생!
    loadData();
}, []);
```

### 3. **Unexpected token** JSX 파싱 오류
```
SyntaxError: Unexpected token (13000:33)
```

**원인**: JavaScript 주석 `/* */` 내부에 JSX 구문이 있어서 Babel이 파싱 시도
```javascript
/* 
  이 주석 안에 JSX가 있으면 Babel이 파싱하려고 함
  <div className="test">  // ❌ 오류 발생!
    {/* JSX 주석도 파싱됨 */}
  </div>
*/
```

### 4. **Unterminated comment** 오류
```
SyntaxError: Unterminated comment. (12969:8)
```

**원인**: JavaScript 주석 `/*`가 시작되었지만 `*/`로 제대로 닫히지 않음

---

## 🔧 구문 오류 원인 분석

### 근본 원인: **React 컴포넌트 구조 파괴**

원래 정상적인 구조:
```javascript
const ExpertFinderComponent = ({ props }) => {
    const [state, setState] = useState();  // ✅ 함수 내부
    
    useEffect(() => {  // ✅ 함수 내부
        loadData();
    }, []);
    
    if (loading) {  // ✅ 함수 내부
        return <div>Loading...</div>;
    }
    
    return <div>Main content</div>;  // ✅ 함수 내부
};
```

문제가 된 구조:
```javascript
const ExpertFinderComponent = ({ props }) => {
    return <div>Simple content</div>;
};  // ✅ 함수 정상 종료

// ❌ 아래 코드들이 함수 밖에 위치
const [state, setState] = useState();  // 오류!
useEffect(() => { loadData(); }, []);  // 오류!
if (loading) { return <div>...</div>; }  // 오류!
```

### 왜 이런 구조가 되었나?

1. **대용량 컴포넌트 리팩토링 과정에서 실수**
2. **코드 이동 중 함수 경계 혼동**
3. **주석 처리 과정에서 구조 파괴**

---

## ⚡ 빠른 진단 체크리스트

### 1. **'return' outside of function** 오류 시
```bash
# 함수 밖 return문 찾기
grep -n "return" index.html | head -20
```

**체크 포인트**:
- React 컴포넌트 함수가 제대로 닫혔는지 확인 (`};`)
- return 문이 모두 함수 내부에 있는지 확인
- 조건문 안의 return도 함수 내부인지 확인

### 2. **Invalid hook call** 오류 시
```bash
# 함수 밖 hooks 찾기
grep -n "useEffect\|useState\|useRef" index.html
```

**체크 포인트**:
- 모든 hooks가 React 컴포넌트 함수 내부에 있는지
- hooks가 조건문이나 반복문 내부에 있지 않은지
- 컴포넌트 함수 경계가 올바른지

### 3. **JSX 파싱 오류** 시
```bash
# JavaScript 주석 내 JSX 찾기
grep -A5 -B5 "/\*" index.html | grep "className\|<div\|{/\*"
```

**체크 포인트**:
- JavaScript 주석 `/* */` 내부에 JSX가 있는지
- JSX 주석 `{/* */}`가 JavaScript 주석 내부에 있는지

---

## 🛠️ 해결 방법 패턴

### 패턴 1: 함수 밖 코드 → 함수 내부로 이동
```javascript
// ❌ 문제 상황
const Component = () => {
    return <div>Simple</div>;
};

const [state, setState] = useState();  // 함수 밖!

// ✅ 해결
const Component = () => {
    const [state, setState] = useState();  // 함수 내부로 이동
    return <div>Simple</div>;
};
```

### 패턴 2: 사용하지 않는 코드 → 주석 처리
```javascript
// ❌ 문제가 되는 코드는 주석 처리
// useEffect(() => { loadData(); }, []);
// if (loading) return <div>Loading</div>;
```

### 패턴 3: JSX 포함 대용량 코드 → HTML 주석
```javascript
</script>
<!-- 
JSX가 포함된 대용량 코드 블록
이렇게 HTML 주석으로 처리하면 Babel이 파싱하지 않음
<div className="test">{/* JSX 주석도 안전 */}</div>
-->
<script type="text/babel">
```

### 패턴 4: 긴급 수정용 임시 컴포넌트
```javascript
const BrokenComponent = () => {
    return (
        <div className="text-center p-8 bg-gray-50 rounded-lg">
            <h3 className="text-lg font-semibold mb-4">🔧 서비스 점검 중</h3>
            <p className="text-gray-600">잠시 후 다시 이용해주세요.</p>
        </div>
    );
};
```

---

## 📋 예방 수칙

### 1. **컴포넌트 구조 확인**
- 모든 React 컴포넌트 함수가 올바르게 시작(`const Component = () => {`)하고 끝나는지(`};`) 확인
- 컴포넌트 내부에만 hooks 사용
- return 문은 반드시 함수 내부에

### 2. **주석 처리 방법**
- **단순 코드**: `// 주석` 사용
- **JSX 포함 코드**: HTML 주석 `<!-- -->` 사용  
- **JavaScript 주석 `/* */`**: JSX가 없는 경우만 사용

### 3. **코드 리팩토링 시**
- 함수 경계를 명확히 표시하는 주석 추가
- 대용량 컴포넌트는 단계별로 분할
- 매번 배포 후 콘솔 오류 확인

---

## 🚀 빠른 해결 명령어

### 긴급 수정용 스크립트
```bash
# 1. 함수 밖 return문 찾기
grep -n "^\s*return\|^\s*if.*return" index.html

# 2. 함수 밖 hooks 찾기  
grep -n "^\s*use[A-Z]" index.html

# 3. 주석 내 JSX 찾기
grep -n "{/\*\|className\|<div.*>" index.html | head -10

# 4. 닫히지 않은 주석 찾기
grep -n "/\*" index.html | wc -l && grep -n "\*/" index.html | wc -l
```

### 임시 수정 템플릿
```javascript
// 문제가 되는 컴포넌트를 임시로 교체
const ProblematicComponent = () => {
    return React.createElement('div', {
        className: 'text-center p-8 bg-gray-50 rounded-lg'
    }, [
        React.createElement('h3', {
            key: 'title',
            className: 'text-lg font-semibold mb-4'
        }, '🔧 서비스 점검 중'),
        React.createElement('p', {
            key: 'desc',
            className: 'text-gray-600'
        }, '잠시 후 다시 이용해주세요.')
    ]);
};
```

---

## 📝 이번 사례 요약

**발생한 오류들**:
1. ExpertFinderComponent 함수 밖에 변수 선언, useEffect, return문 존재
2. JavaScript 주석 내부의 JSX 구문으로 인한 Babel 파싱 오류
3. 닫히지 않은 주석 블록

**해결한 방법들**:
1. 함수 밖 코드 모두 주석 처리
2. JavaScript 주석을 HTML 주석으로 변경
3. 임시 플레이스홀더 컴포넌트로 교체

**결과**: 
- ✅ 모든 구문 오류 해결
- ✅ 사이트 정상 작동
- ⚠️ ExpertFinderComponent는 리팩토링 필요 (기능적 제한)

---

**🎯 핵심 교훈**: React 컴포넌트에서는 **함수 경계**가 절대적이다!
- hooks는 컴포넌트 함수 내부에서만
- return문은 함수 내부에서만  
- JSX가 포함된 코드는 HTML 주석으로 처리

이 가이드를 통해 향후 동일한 구문 오류 발생 시 5분 내 해결 가능할 것입니다.