# API 통합 스펙 (Claude Flow Agent용)

> **목적**: 여러 외부 API를 도메인별로 체계적으로 관리하기 위한 통합 구조 정의
> **작성일**: 2025-10-25
> **버전**: 1.0

---

## 🎯 목표

1. **도메인별 API 그룹화**: 주거(housing), 복지(welfare), 교육(education), 취업(employment)
2. **공통 인프라 구축**: Dio 기반 HTTP 클라이언트, 에러 핸들링, 인터셉터
3. **확장 가능한 구조**: 새 API 추가 시 기존 코드 수정 최소화
4. **테스트 용이성**: Repository 패턴으로 단위 테스트 가능

---

## 📁 타겟 폴더 구조

```
apps/pickly_mobile/lib/
├── contexts/                     # 도메인 로직
│   ├── housing/                  # 주거 도메인 (새로 추가)
│   │   ├── models/
│   │   │   ├── lh_announcement.dart
│   │   │   └── sh_announcement.dart
│   │   └── repositories/
│   │       ├── lh_repository.dart
│   │       └── sh_repository.dart
│   │
│   ├── welfare/                  # 복지 도메인 (새로 추가)
│   │   ├── models/
│   │   │   └── welfare_policy.dart
│   │   └── repositories/
│   │       └── bokjiro_repository.dart
│   │
│   ├── education/                # 교육 도메인 (새로 추가)
│   │   ├── models/
│   │   └── repositories/
│   │
│   ├── employment/               # 취업 도메인 (새로 추가)
│   │   ├── models/
│   │   └── repositories/
│   │
│   └── user/                     # ⚠️ 기존 (절대 수정 안 함)
│
├── core/                         # 공통 인프라
│   ├── network/                  # 새로 추가
│   │   ├── api_client.dart      # Dio 클라이언트 팩토리
│   │   ├── api_config.dart      # 모든 API URL/Key 관리
│   │   └── api_interceptor.dart # 로깅/에러 변환
│   └── errors/                   # 새로 추가
│       └── api_exception.dart   # 커스텀 에러 클래스
│
└── features/                     # UI 레이어
    ├── housing/                  # 새로 추가
    ├── welfare/                  # 새로 추가
    ├── education/                # 새로 추가
    ├── employment/               # 새로 추가
    └── onboarding/               # ⚠️ 기존 (절대 수정 안 함)
```

---

## 🚫 기존 코드 보호 규칙

### ❌ 절대 수정하지 말아야 할 파일들:
```
contexts/user/**                  (온보딩용 사용자 관리)
features/onboarding/**            (온보딩 UI)
features/benefits/**              (혜택 화면 - 기존 작업)
core/router.dart                  (라우팅)
core/supabase_config.dart         (Supabase)
```

### ✅ 새로 추가할 파일만:
```
core/network/**        (완전히 새 폴더)
core/errors/**         (완전히 새 폴더)
contexts/housing/**    (완전히 새 폴더)
contexts/welfare/**    (완전히 새 폴더)
contexts/education/**  (완전히 새 폴더)
contexts/employment/** (완전히 새 폴더)
```

---

## 🔧 구현 우선순위

### Phase 1: 공통 인프라 (필수)
1. ✅ `core/network/api_config.dart` - API 엔드포인트 중앙 관리
2. ✅ `core/network/api_client.dart` - Dio 인스턴스 생성
3. ✅ `core/network/api_interceptor.dart` - 요청/응답 로깅
4. ✅ `core/errors/api_exception.dart` - 에러 타입 정의

### Phase 2: 주거 도메인 (LH API)
5. ✅ `contexts/housing/models/lh_announcement.dart`
6. ✅ `contexts/housing/repositories/lh_repository.dart`
7. ✅ `features/housing/providers/housing_provider.dart`
8. ✅ `features/housing/screens/housing_list_screen.dart`

### Phase 3: 다른 도메인 (나중에)
- `contexts/welfare/` 폴더 구조 복제
- `contexts/education/` 폴더 구조 복제
- `contexts/employment/` 폴더 구조 복제

---

## 📋 API 목록

### 1. 주거 도메인 (Housing)

#### LH 공사 API
- **베이스 URL**: `https://api.lh.or.kr`
- **인증**: API Key (Header)
- **엔드포인트**:
  - `GET /announcement/list` - 공고 목록
  - `GET /announcement/detail/{id}` - 공고 상세

**응답 예시** (LH API):
```json
{
  "dsList": [
    {
      "PAN_ID": "2024000001",
      "PAN_NM": "행복주택 입주자 모집",
      "CNP_CD_NM": "서울특별시",
      "RCRIT_PBLANC_DE": "2024-01-15",
      "SUBSCRPT_RCEPT_ENDDE": "2024-01-31"
    }
  ]
}
```

---

## 📦 필요한 패키지

### pubspec.yaml 추가 필요:
```yaml
dependencies:
  dio: ^5.4.0              # HTTP 클라이언트
  # 기존 패키지는 그대로 유지
```

---

## ✅ 검증 기준

### Phase 1 완료 기준:
- [ ] `flutter pub get` 성공
- [ ] 기존 온보딩 화면 정상 작동
- [ ] 기존 혜택 화면 정상 작동
- [ ] `flutter analyze` 에러 없음
- [ ] api_config.dart에 LH URL 정의됨
- [ ] api_client.dart가 Dio 인스턴스 생성 가능

### Phase 2 완료 기준:
- [ ] LH Repository가 API 호출 성공
- [ ] LhAnnouncement 모델이 JSON 파싱 성공
- [ ] housing_list_screen에서 데이터 표시
- [ ] 에러 발생 시 사용자 친화적 메시지 표시
- [ ] 기존 기능들 모두 정상 작동

---

## 🔗 참고 문서

- [Flutter Dio 패키지](https://pub.dev/packages/dio)
- [Repository 패턴](https://docs.flutter.dev/data-and-backend/state-mgmt/options#repository-pattern)
- [Pickly 카테고리 동기화 가이드](../category-sync-guide.md)
- [개발 베스트 프랙티스](../development-best-practices.md)

---

**작성자**: Claude Code
**검토자**: 개발팀
**승인일**: 2025-10-25
