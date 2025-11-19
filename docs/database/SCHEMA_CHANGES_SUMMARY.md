# Database Schema Changes Summary - v2.0

> **날짜**: 2025.10.27
> **작성자**: Database Architect Agent
> **마이그레이션**: `20251027000002` + `20251027000003` (rollback)

---

## 개요

Pickly 서비스의 데이터베이스 스키마를 v1.0에서 v2.0으로 업그레이드하였습니다.

### 핵심 변경사항

1. **신규 테이블**: `announcement_types` (공고 유형별 비용 정보)
2. **테이블 확장**: `announcement_sections` (커스텀 섹션 지원)
3. **헬퍼 뷰**: `v_announcements_with_types` (조인 최적화)

---

## 파일 목록

### 마이그레이션 파일

| 파일명 | 용도 | 라인 수 |
|--------|------|---------|
| `20251027000002_add_announcement_types_and_custom_content.sql` | 스키마 업그레이드 | ~300 lines |
| `20251027000003_rollback_announcement_types.sql` | 롤백 스크립트 | ~80 lines |

### 문서 파일

| 파일명 | 내용 |
|--------|------|
| `/docs/database/schema-v2.md` | 상세 스키마 문서 (11개 섹션) |
| `/docs/database/MIGRATION_GUIDE.md` | 마이그레이션 실행 가이드 |
| `/docs/database/SCHEMA_CHANGES_SUMMARY.md` | 이 문서 (변경 요약) |

---

## 신규 테이블: announcement_types

### 목적
각 공고의 평형별(유형별) 보증금/월세 정보를 관리합니다.

### 스키마

```sql
CREATE TABLE announcement_types (
  id uuid PRIMARY KEY,
  announcement_id uuid NOT NULL,  -- announcements 외래키
  type_name text NOT NULL,         -- "16A 청년", "26B 신혼부부"
  deposit bigint,                  -- 보증금 (원)
  monthly_rent integer,            -- 월세 (원)
  eligible_condition text,         -- 자격 조건
  order_index integer DEFAULT 0,  -- 표시 순서
  icon_url text,                   -- 아이콘 URL
  pdf_url text,                    -- PDF URL
  created_at timestamptz,
  updated_at timestamptz,
  UNIQUE(announcement_id, type_name)
);
```

### 사용 예시

```sql
-- 16A 청년 유형 추가
INSERT INTO announcement_types (
  announcement_id,
  type_name,
  deposit,
  monthly_rent,
  order_index
) VALUES (
  '123e4567-e89b-12d3-a456-426614174000',
  '16A 청년',
  20000000,   -- 2천만원
  150000,     -- 15만원
  1
);
```

### 인덱스

```sql
CREATE INDEX idx_announcement_types_announcement
  ON announcement_types(announcement_id, order_index);
```

---

## 테이블 확장: announcement_sections

### 변경사항

#### 1. 새로운 섹션 타입: `custom`

기존 6개 타입에 `custom` 추가:
```
basic_info, schedule, eligibility, housing_info, location, attachments, custom (🆕)
```

#### 2. 신규 컬럼

```sql
ALTER TABLE announcement_sections
  ADD COLUMN is_custom boolean DEFAULT false,
  ADD COLUMN custom_content jsonb;
```

#### 3. 제약 조건

```sql
-- is_custom=true이면 section_type='custom'이어야 함
CHECK (
  (is_custom = false) OR
  (is_custom = true AND section_type = 'custom')
)
```

### 사용 예시

```sql
-- 커스텀 섹션 추가
INSERT INTO announcement_sections (
  announcement_id,
  section_type,
  title,
  content,
  is_custom,
  custom_content,
  display_order
) VALUES (
  '123e4567-e89b-12d3-a456-426614174000',
  'custom',
  '특별 안내사항',
  '{}',
  true,
  '{"html": "<p>커스텀 내용</p>", "images": ["/img/notice.jpg"]}',
  10
);
```

---

## 헬퍼 뷰: v_announcements_with_types

### 목적
공고와 유형 정보를 조인하여 한 번에 조회합니다.

### 스키마

```sql
CREATE VIEW v_announcements_with_types AS
SELECT
  a.*,
  json_agg(
    json_build_object(
      'id', at.id,
      'type_name', at.type_name,
      'deposit', at.deposit,
      'monthly_rent', at.monthly_rent,
      'eligible_condition', at.eligible_condition,
      'order_index', at.order_index,
      'icon_url', at.icon_url,
      'pdf_url', at.pdf_url
    ) ORDER BY at.order_index
  ) FILTER (WHERE at.id IS NOT NULL) as types
FROM announcements a
LEFT JOIN announcement_types at ON a.id = at.announcement_id
GROUP BY a.id;
```

### 사용 예시

```sql
-- 공고 + 유형 정보 한 번에 조회
SELECT * FROM v_announcements_with_types
WHERE id = '123e4567-e89b-12d3-a456-426614174000';
```

---

## RLS (Row Level Security)

### announcement_types

```sql
ALTER TABLE announcement_types ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read access"
  ON announcement_types FOR SELECT
  USING (true);
```

### announcement_sections (기존 유지)

커스텀 섹션도 동일한 정책 적용:
```sql
CREATE POLICY "Public read access"
  ON announcement_sections FOR SELECT
  USING (true);
```

---

## 트리거

### updated_at 자동 갱신

```sql
CREATE TRIGGER update_announcement_types_updated_at
  BEFORE UPDATE ON announcement_types
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

---

## 마이그레이션 실행 방법

### 로컬 환경

```bash
cd /Users/kwonhyunjun/Desktop/pickly_service

# Supabase 로컬 개발 환경
supabase db reset

# 또는
supabase migration up
```

### 프로덕션 환경

```bash
# Supabase 프로젝트 배포
supabase db push

# 또는 직접 실행
psql -h [HOST] -U [USER] -d [DB] \
  -f backend/supabase/migrations/20251027000002_add_announcement_types_and_custom_content.sql
```

### 롤백 (필요 시)

```bash
psql -h [HOST] -U [USER] -d [DB] \
  -f backend/supabase/migrations/20251027000003_rollback_announcement_types.sql
```

**⚠️ 주의**: 롤백 시 `announcement_types` 테이블의 모든 데이터가 삭제됩니다!

---

## 백오피스 코드 변경 요약

### TypeScript 타입

```typescript
interface AnnouncementType {
  id: string;
  announcement_id: string;
  type_name: string;
  deposit: number | null;
  monthly_rent: number | null;
  eligible_condition: string | null;
  order_index: number;
  icon_url: string | null;
  pdf_url: string | null;
  created_at: string;
  updated_at: string;
}

interface AnnouncementSection {
  // ... 기존 필드
  is_custom: boolean;              // 🆕
  custom_content: Record<string, unknown> | null;  // 🆕
}
```

### Repository 메서드

```typescript
class AnnouncementRepository {
  async getAnnouncementTypes(announcementId: string): Promise<AnnouncementType[]>
  async createAnnouncementType(type: Omit<AnnouncementType, 'id' | 'created_at' | 'updated_at'>): Promise<AnnouncementType>
  async updateAnnouncementType(id: string, updates: Partial<AnnouncementType>): Promise<AnnouncementType>
  async deleteAnnouncementType(id: string): Promise<void>
  async getAnnouncementWithTypes(announcementId: string): Promise<AnnouncementWithTypes>
}
```

---

## 모바일 앱 코드 변경 요약

### Dart 모델

```dart
@freezed
class AnnouncementType with _$AnnouncementType {
  const factory AnnouncementType({
    required String id,
    required String announcementId,
    required String typeName,
    int? deposit,
    int? monthlyRent,
    String? eligibleCondition,
    required int orderIndex,
    String? iconUrl,
    String? pdfUrl,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AnnouncementType;

  factory AnnouncementType.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementTypeFromJson(json);
}
```

### Repository 메서드

```dart
class AnnouncementRepository {
  Future<List<AnnouncementType>> getAnnouncementTypes(String announcementId)
  Future<AnnouncementWithTypes> getAnnouncementWithTypes(String announcementId)
}
```

### Provider (Riverpod 2.x)

```dart
@riverpod
Future<List<AnnouncementType>> announcementTypes(
  AnnouncementTypesRef ref,
  String announcementId,
) async {
  final repository = ref.watch(announcementRepositoryProvider);
  return repository.getAnnouncementTypes(announcementId);
}
```

---

## 테스트 체크리스트

### 데이터베이스 레벨

- [x] 테이블 생성 확인 (`announcement_types`)
- [x] 컬럼 추가 확인 (`is_custom`, `custom_content`)
- [x] 인덱스 생성 확인
- [x] RLS 정책 적용 확인
- [x] 트리거 동작 확인
- [x] 뷰 생성 확인 (`v_announcements_with_types`)

### 백오피스

- [ ] 유형 정보 CRUD 테스트
- [ ] 커스텀 섹션 CRUD 테스트
- [ ] 뷰를 통한 조회 테스트
- [ ] 에러 처리 테스트

### 모바일 앱

- [ ] 유형 정보 조회 테스트
- [ ] 커스텀 섹션 렌더링 테스트
- [ ] Provider 상태 관리 테스트
- [ ] 에러 처리 테스트

---

## 성능 영향 분석

### 인덱스 추가

- `idx_announcement_types_announcement`: 공고별 유형 조회 최적화
- `idx_announcement_sections_custom`: 커스텀 섹션 필터링 최적화

### 예상 성능 향상

- **유형 조회**: ~50% 빠름 (인덱스 사용)
- **조인 쿼리**: 뷰 사용으로 코드 간소화
- **커스텀 섹션**: 부분 인덱스로 메모리 절약

---

## 데이터 마이그레이션 가이드

### 기존 announcement_tabs 데이터 변환

```sql
-- 1. 백업
CREATE TABLE announcement_tabs_backup AS
SELECT * FROM announcement_tabs;

-- 2. 변환 (deposit/monthly_rent는 수동 입력 필요)
INSERT INTO announcement_types (
  announcement_id,
  type_name,
  eligible_condition,
  order_index
)
SELECT
  announcement_id,
  tab_name,
  income_conditions::text,
  display_order
FROM announcement_tabs;

-- 3. 수동으로 비용 정보 업데이트
UPDATE announcement_types
SET deposit = 20000000, monthly_rent = 150000
WHERE type_name = '16A 청년';
```

---

## 알려진 제한사항

1. **deposit/monthly_rent 자동 추출 불가**: Phase 1에서는 수동 입력만 지원
2. **커스텀 섹션 검증 부재**: `custom_content` JSONB 구조 검증 없음
3. **관리자 권한 미구현**: RLS 정책은 모든 사용자 읽기만 허용

---

## 다음 단계 (Phase 2)

### AI 자동 분석

- [ ] PDF 파싱 → `announcement_types` 자동 생성
- [ ] OCR 통한 평면도 정보 추출
- [ ] 자격 조건 자동 파싱

### 백오피스 UI/UX

- [ ] 유형 정보 입력 폼 개선
- [ ] 커스텀 섹션 WYSIWYG 에디터
- [ ] 드래그 앤 드롭 순서 변경

### 모바일 앱 기능

- [ ] 유형별 필터링
- [ ] 보증금/월세 범위 검색
- [ ] 커스텀 섹션 렌더러

---

## 관련 문서

- [Schema v2.0 상세 문서](/docs/database/schema-v2.md)
- [Migration Guide](/docs/database/MIGRATION_GUIDE.md)
- [PRD v7.0](/PRD.md)

---

## 변경 이력

- **2025.10.27**: v2.0 초안 작성 (Database Architect Agent)

---

**문의**: 문제 발생 시 Database Architect Agent에게 연락하세요.
