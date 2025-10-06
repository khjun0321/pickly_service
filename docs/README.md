# Pickly 문서

> **프로젝트 문서 허브**

---

## 📚 문서 목록

### 개발 가이드
- [온보딩 화면 개발 가이드](development/onboarding-development-guide.md) ⭐
  - 공통 에이전트 + 설정 기반 개발 방식
  - 새 화면 추가 방법
  - UI 타입별 설정

### 아키텍처
- [공통 에이전트 아키텍처](architecture/common-agent-architecture.md) ⭐
  - 재사용 가능한 구조
  - 에이전트 목록
  - 워크플로우 설명

### API & 스키마
- [화면 설정 파일 스키마](api/screen-config-schema.md) ⭐
  - JSON 설정 정의
  - 타입별 옵션
  - 전체 예시

### 프로젝트 문서
- [PRD (Product Requirements Document)](PRD.md)
  - 제품 요구사항 정의
  - 기능 목록
  - 로드맵

---

## 🚀 빠른 시작

### 새 온보딩 화면 추가하기

1. **설정 파일 작성**
```bash
nano .claude/screens/006-new-screen.json
```

2. **워크플로우 등록**
```yaml
# .claude/workflows/onboarding-universal.yml
screens:
  - id: "006"
    config: ".claude/screens/006-new-screen.json"
```

3. **실행**
```bash
claude-flow orchestrate \
  --workflow .claude/workflows/onboarding-universal.yml \
  --screen 006
```

자세한 내용은 [온보딩 화면 개발 가이드](development/onboarding-development-guide.md) 참고!

---

## 📖 학습 경로

### 초보자
1. [온보딩 개발 가이드](development/onboarding-development-guide.md) 읽기
2. 003 화면 설정 파일 분석
3. 새 화면 하나 만들어보기

### 중급자
1. [공통 에이전트 아키텍처](architecture/common-agent-architecture.md) 이해
2. 커스텀 UI 타입 추가
3. 에이전트 로직 확장

### 고급자
1. 새 에이전트 작성
2. 워크플로우 최적화
3. 병렬 처리 개선

---

## 🔗 외부 링크

- [GitHub Repository](https://github.com/kwonhyunjun/pickly-service)
- [Figma Design](https://www.figma.com/design/xOpx8v3FiYmCxSLkj9sgcu/pickly)
- [Supabase Docs](https://supabase.com/docs)
- [Claude Flow](https://docs.anthropic.com/claude/docs/claude-flow)

---

## 💡 기여하기

문서 개선 아이디어가 있으신가요?

1. 이슈 생성
2. PR 제출
3. 또는 팀에 직접 제안

모든 기여를 환영합니다! 🎉
