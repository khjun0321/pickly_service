# Provider 문서 인덱스

이 디렉토리는 Pickly Mobile 앱의 Provider 패턴에 대한 완벽한 문서를 포함합니다.

## 📚 문서 목록

### 1. [Age Category Provider 완벽 가이드](./age_category_provider_guide.md)
**대상**: 개발자 (초급~중급)

**포함 내용**:
- ✅ Provider 구조 상세 설명
- ✅ 데이터 흐름 다이어그램
- ✅ 실제 사용 예제 (5가지 패턴)
- ✅ 테스트 가이드
- ✅ 디버깅 팁
- ✅ 성능 최적화 방법

**언제 읽어야 하나요?**
- Age Category Provider를 처음 사용할 때
- 비슷한 Provider를 새로 만들 때
- 에러 처리나 상태 관리 패턴을 배우고 싶을 때

---

### 2. [Age Category Provider 검증 보고서](./age_category_provider_verification_report.md)
**대상**: 리뷰어, 시니어 개발자, QA

**포함 내용**:
- ✅ 7가지 검증 항목 상세 분석
- ✅ 발견된 문제점과 해결 방법
- ✅ 테스트 커버리지 분석
- ✅ 추가 개선 제안
- ✅ 최종 평가 점수 (95.7/100)

**언제 읽어야 하나요?**
- 코드 리뷰를 진행할 때
- 프로덕션 배포 전 품질 확인
- 아키텍처 개선 계획 수립 시

---

### 3. [Age Category Provider 아키텍처](./age_category_provider_architecture.md)
**대상**: 아키텍트, 시니어 개발자

**포함 내용**:
- ✅ 전체 시스템 아키텍처 다이어그램
- ✅ 데이터 흐름 시퀀스 (3가지 시나리오)
- ✅ Provider 사용 패턴 맵
- ✅ 의존성 그래프
- ✅ 성능 최적화 포인트
- ✅ 메모리 안전성 분석

**언제 읽어야 하나요?**
- 시스템 전체 구조를 이해하고 싶을 때
- 새로운 기능 추가 전 설계 검토
- 성능 문제 디버깅 시

---

## 🎯 빠른 참조 가이드

### "나는 이것을 알고 싶다..."

| 궁금한 내용 | 추천 문서 | 섹션 |
|------------|----------|------|
| Provider 어떻게 사용하나요? | 가이드 | 사용 예제 |
| 로딩/에러 처리는? | 가이드 | 예제 1, 2 |
| Pull-to-refresh 구현은? | 가이드 | 예제 2 |
| 특정 ID로 조회는? | 가이드 | 예제 4 |
| 테스트 작성 방법은? | 가이드 | 테스트 가이드 |
| 코드 품질이 괜찮나요? | 검증 보고서 | 검증 결과 요약 |
| 어떤 문제가 있나요? | 검증 보고서 | 발견된 문제점 |
| 전체 구조가 궁금해요 | 아키텍처 | 시스템 아키텍처 |
| 데이터는 어떻게 흐르나요? | 아키텍처 | 데이터 흐름 |
| 성능 최적화 팁은? | 아키텍처 | 성능 최적화 |

---

## 📖 학습 경로

### 초급 개발자
1. **시작**: [가이드](./age_category_provider_guide.md) - "Provider 구조" 섹션
2. **다음**: [가이드](./age_category_provider_guide.md) - "사용 예제" 섹션
3. **마지막**: [가이드](./age_category_provider_guide.md) - "디버깅 팁" 섹션

### 중급 개발자
1. **시작**: [아키텍처](./age_category_provider_architecture.md) - "전체 시스템 아키텍처"
2. **다음**: [가이드](./age_category_provider_guide.md) - "데이터 흐름" 섹션
3. **마지막**: [가이드](./age_category_provider_guide.md) - "성능 최적화" 섹션

### 시니어 개발자 / 리뷰어
1. **시작**: [검증 보고서](./age_category_provider_verification_report.md) - "검증 결과 요약"
2. **다음**: [검증 보고서](./age_category_provider_verification_report.md) - "발견된 문제점"
3. **마지막**: [아키텍처](./age_category_provider_architecture.md) - 전체 문서

---

## 🔧 코드 위치

실제 구현 코드는 다음 위치에 있습니다:

```
apps/pickly_mobile/
├── lib/
│   ├── features/onboarding/providers/
│   │   └── age_category_provider.dart        # ⭐ 메인 Provider
│   └── contexts/user/
│       ├── models/
│       │   └── age_category.dart              # 모델
│       └── repositories/
│           └── age_category_repository.dart   # Repository
└── test/
    └── features/onboarding/providers/
        └── age_category_provider_test.dart    # 테스트
```

---

## 📋 체크리스트

### Provider를 새로 만들 때 확인사항

- [ ] AsyncNotifier 패턴 사용
- [ ] `ref.onDispose()`로 리소스 정리
- [ ] Realtime 구독 설정 (필요 시)
- [ ] 우아한 에러 처리 (fallback 데이터)
- [ ] Convenience providers 제공
- [ ] DartDoc 주석 작성
- [ ] 테스트 작성 (최소 70% 커버리지)
- [ ] 성능 최적화 (rebuild 최소화)

### Provider를 사용할 때 확인사항

- [ ] 올바른 Provider 선택 (List vs Async vs Loading)
- [ ] `ref.watch()` vs `ref.read()` 구분
- [ ] 에러 처리 구현
- [ ] 로딩 상태 처리
- [ ] 필요시 `.select()` 사용
- [ ] Build 메서드에서 side effect 피하기

---

## 🆘 도움이 필요하신가요?

### 자주 묻는 질문 (FAQ)

**Q: Provider가 데이터를 가져오지 않아요**
A: [가이드 - 디버깅 팁](./age_category_provider_guide.md#-디버깅-팁) 참조

**Q: 에러가 발생해도 mock 데이터만 보여요**
A: 정상입니다. [검증 보고서 - 에러 처리](./age_category_provider_verification_report.md#3-error-handling-) 참조

**Q: Realtime 업데이트가 작동하지 않아요**
A: [아키텍처 - Realtime 업데이트 시퀀스](./age_category_provider_architecture.md#2-realtime-업데이트-시퀀스) 참조

**Q: 성능이 느려요 (너무 많이 rebuild돼요)**
A: [아키텍처 - 성능 최적화](./age_category_provider_architecture.md#-성능-최적화-포인트) 참조

---

## 📝 문서 업데이트 이력

| 날짜 | 변경 사항 | 작성자 |
|------|-----------|--------|
| 2025-10-11 | 초기 문서 작성 (가이드, 검증 보고서, 아키텍처) | Claude Code |

---

## 🔗 관련 리소스

- [Riverpod 공식 문서](https://riverpod.dev)
- [Flutter 상태 관리 가이드](https://docs.flutter.dev/data-and-backend/state-mgmt/options)
- [Supabase Realtime 문서](https://supabase.com/docs/guides/realtime)
- [AsyncNotifier 마이그레이션 가이드](https://riverpod.dev/docs/migration/from_state_notifier)

---

**마지막 업데이트**: 2025-10-11
**문서 버전**: 1.0.0
**Provider 버전**: 95.7/100 (프로덕션 준비 완료)
