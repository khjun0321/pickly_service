# Database Schema v2.0 - Announcement Types & Custom Content

> **업데이트**: 2025.10.27
> **마이그레이션**: `20251027000002_add_announcement_types_and_custom_content.sql`

---

## 개요

이번 스키마 업데이트는 공고 시스템에 **유형별 정보**(보증금/월세)와 **커스텀 섹션** 기능을 추가합니다.

### 주요 변경사항

1. **신규 테이블**: `announcement_types` (공고 유형별 비용 정보)
2. **기능 확장**: `announcement_sections` (커스텀 섹션 지원)
3. **헬퍼 뷰**: `v_announcements_with_types` (조인 뷰)

---

## 1. announcement_types (신규)

### 목적
각 공고의 평형별(유형별) 보증금/월세 정보를 관리합니다.

### 스키마

```sql
CREATE TABLE announcement_types (
  id uuid PRIMARY KEY,
  announcement_id uuid REFERENCES announcements(id) ON DELETE CASCADE NOT NULL,

  -- 유형 정보
  type_name text NOT NULL,                    -- "16A 청년", "26B 신혼부부"

  -- 비용 정보
  deposit bigint,                              -- 보증금 (원)
  monthly_rent integer,                        -- 월세 (원)

  -- 자격 조건
  eligible_condition text,

  -- 순서
  order_index integer NOT NULL DEFAULT 0,

  -- 첨부
  icon_url text,
  pdf_url text,

  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),

  UNIQUE(announcement_id, type_name)
);
```

### 필드 설명

| 필드 | 타입 | 설명 | 예시 |
|------|------|------|------|
| `type_name` | text | 유형명 | "16A 청년", "26B 신혼부부" |
| `deposit` | bigint | 보증금 (원 단위) | 20000000 (2천만원) |
| `monthly_rent` | integer | 월세 (원 단위) | 150000 (15만원) |
| `eligible_condition` | text | 자격 조건 텍스트 | "대학생 또는 청년" |
| `order_index` | integer | 표시 순서 | 1, 2, 3... |
| `icon_url` | text | 아이콘 URL (선택) | "/icons/16a.svg" |
| `pdf_url` | text | 관련 PDF URL (선택) | "/files/16a-details.pdf" |

### 인덱스

```sql
CREATE INDEX idx_announcement_types_announcement
  ON announcement_types(announcement_id, order_index);
```

### 사용 예시

```sql
-- 공고에 유형별 정보 추가
INSERT INTO announcement_types (
  announcement_id,
  type_name,
  deposit,
  monthly_rent,
  order_index
) VALUES (
  '123e4567-e89b-12d3-a456-426614174000',
  '16A 청년',
  20000000,
  150000,
  1
);

-- 공고의 모든 유형 조회
SELECT * FROM announcement_types
WHERE announcement_id = '123e4567-e89b-12d3-a456-426614174000'
ORDER BY order_index;
```

---

## 2. announcement_sections (확장)

### 변경사항

#### 신규 섹션 타입: `custom`

기존 6개 섹션 타입에 `custom` 추가:

```sql
CHECK (section_type IN (
  'basic_info',      -- 기본 정보
  'schedule',        -- 일정
  'eligibility',     -- 신청 자격
  'housing_info',    -- 단지 정보
  'location',        -- 위치
  'attachments',     -- 첨부 파일
  'custom'           -- 🆕 커스텀 섹션
))
```

#### 신규 컬럼

```sql
ALTER TABLE announcement_sections
  ADD COLUMN is_custom boolean DEFAULT false,
  ADD COLUMN custom_content jsonb;
```

| 필드 | 타입 | 설명 |
|------|------|------|
| `is_custom` | boolean | 커스텀 섹션 여부 |
| `custom_content` | jsonb | 커스텀 섹션 내용 (자유 형식) |

### 제약 조건

```sql
-- is_custom=true면 section_type='custom' 이어야 함
CHECK (
  (is_custom = false) OR
  (is_custom = true AND section_type = 'custom')
)
```

### 인덱스

```sql
CREATE INDEX idx_announcement_sections_custom
  ON announcement_sections(announcement_id, is_custom)
  WHERE is_custom = true;
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
  '{"html": "<p>이 공고는 특별 조건이 있습니다.</p>", "images": ["/img/notice.jpg"]}',
  10
);
```

---

## 3. v_announcements_with_types (헬퍼 뷰)

### 목적
공고와 유형별 정보를 조인하여 한 번에 조회할 수 있는 뷰를 제공합니다.

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

-- 결과:
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "title": "행복주택 공고",
  ...
  "types": [
    {
      "id": "...",
      "type_name": "16A 청년",
      "deposit": 20000000,
      "monthly_rent": 150000,
      "order_index": 1
    },
    {
      "id": "...",
      "type_name": "26B 신혼부부",
      "deposit": 30000000,
      "monthly_rent": 200000,
      "order_index": 2
    }
  ]
}
```

---

## 4. RLS (Row Level Security)

### announcement_types

```sql
ALTER TABLE announcement_types ENABLE ROW LEVEL SECURITY;

-- 모든 사용자 읽기 가능
CREATE POLICY "Public read access"
  ON announcement_types FOR SELECT
  USING (true);
```

### announcement_sections (기존 유지)

커스텀 섹션도 동일한 RLS 정책 적용:

```sql
CREATE POLICY "Public read access"
  ON announcement_sections FOR SELECT
  USING (true);
```

---

## 5. 마이그레이션 실행

### 적용

```bash
# Supabase CLI 사용
supabase db push

# 또는 SQL 직접 실행
psql -f backend/supabase/migrations/20251027000002_add_announcement_types_and_custom_content.sql
```

### 롤백

```bash
# 롤백이 필요한 경우
psql -f backend/supabase/migrations/20251027000003_rollback_announcement_types.sql
```

**⚠️ 주의**: 롤백 시 `announcement_types` 테이블의 모든 데이터가 삭제됩니다!

---

## 6. 백오피스 연동 가이드

### 공고 유형 관리

#### 유형 추가

```typescript
// TypeScript 타입 정의
interface AnnouncementType {
  id: string;
  announcement_id: string;
  type_name: string;
  deposit: number;
  monthly_rent: number;
  eligible_condition?: string;
  order_index: number;
  icon_url?: string;
  pdf_url?: string;
}

// Supabase 클라이언트로 추가
const { data, error } = await supabase
  .from('announcement_types')
  .insert({
    announcement_id: announcementId,
    type_name: '16A 청년',
    deposit: 20000000,
    monthly_rent: 150000,
    order_index: 1
  });
```

#### 유형 목록 조회

```typescript
const { data, error } = await supabase
  .from('announcement_types')
  .select('*')
  .eq('announcement_id', announcementId)
  .order('order_index');
```

### 커스텀 섹션 관리

#### 커스텀 섹션 추가

```typescript
const { data, error } = await supabase
  .from('announcement_sections')
  .insert({
    announcement_id: announcementId,
    section_type: 'custom',
    title: '특별 안내',
    content: {},
    is_custom: true,
    custom_content: {
      html: '<p>커스텀 내용</p>',
      images: ['/img/custom.jpg']
    },
    display_order: 10
  });
```

---

## 7. 모바일 앱 연동 가이드

### Dart 모델 정의

```dart
// announcement_type.dart
class AnnouncementType {
  final String id;
  final String announcementId;
  final String typeName;
  final int deposit;
  final int monthlyRent;
  final String? eligibleCondition;
  final int orderIndex;
  final String? iconUrl;
  final String? pdfUrl;

  const AnnouncementType({
    required this.id,
    required this.announcementId,
    required this.typeName,
    required this.deposit,
    required this.monthlyRent,
    this.eligibleCondition,
    required this.orderIndex,
    this.iconUrl,
    this.pdfUrl,
  });

  factory AnnouncementType.fromJson(Map<String, dynamic> json) {
    return AnnouncementType(
      id: json['id'] as String,
      announcementId: json['announcement_id'] as String,
      typeName: json['type_name'] as String,
      deposit: json['deposit'] as int,
      monthlyRent: json['monthly_rent'] as int,
      eligibleCondition: json['eligible_condition'] as String?,
      orderIndex: json['order_index'] as int,
      iconUrl: json['icon_url'] as String?,
      pdfUrl: json['pdf_url'] as String?,
    );
  }
}
```

### Repository 구현

```dart
// announcement_repository.dart
class AnnouncementRepository {
  final SupabaseClient _client;

  Future<List<AnnouncementType>> getAnnouncementTypes(String announcementId) async {
    final response = await _client
      .from('announcement_types')
      .select()
      .eq('announcement_id', announcementId)
      .order('order_index');

    return (response as List)
      .map((json) => AnnouncementType.fromJson(json))
      .toList();
  }
}
```

---

## 8. 테스트 시나리오

### 유형 정보 CRUD

```sql
-- 1. 생성
INSERT INTO announcement_types (announcement_id, type_name, deposit, monthly_rent, order_index)
VALUES ('test-id', '16A 청년', 20000000, 150000, 1);

-- 2. 조회
SELECT * FROM announcement_types WHERE announcement_id = 'test-id';

-- 3. 수정
UPDATE announcement_types
SET deposit = 25000000
WHERE announcement_id = 'test-id' AND type_name = '16A 청년';

-- 4. 삭제
DELETE FROM announcement_types
WHERE announcement_id = 'test-id' AND type_name = '16A 청년';
```

### 뷰 테스트

```sql
-- 공고 + 유형 정보 조회
SELECT id, title, types
FROM v_announcements_with_types
LIMIT 5;
```

---

## 9. 성능 최적화

### 권장 인덱스

```sql
-- 이미 생성됨
CREATE INDEX idx_announcement_types_announcement
  ON announcement_types(announcement_id, order_index);

CREATE INDEX idx_announcement_sections_custom
  ON announcement_sections(announcement_id, is_custom)
  WHERE is_custom = true;
```

### 쿼리 최적화 팁

1. **뷰 사용**: 복잡한 조인은 `v_announcements_with_types` 뷰 활용
2. **필터링**: `WHERE` 절에 인덱스 컬럼 사용
3. **배치 조회**: 여러 공고의 유형 정보를 한 번에 조회 (`WHERE announcement_id IN (...)`)

---

## 10. 문제 해결

### Q1: 유형명 중복 오류

**증상**: `UNIQUE violation: announcement_id + type_name`

**해결**:
```sql
-- 기존 데이터 확인
SELECT announcement_id, type_name, COUNT(*)
FROM announcement_types
GROUP BY announcement_id, type_name
HAVING COUNT(*) > 1;

-- 중복 제거 후 재시도
```

### Q2: 커스텀 섹션이 표시되지 않음

**증상**: `is_custom=true` 인데 앱에서 안 보임

**해결**:
```sql
-- is_custom과 section_type 일치 확인
SELECT id, section_type, is_custom
FROM announcement_sections
WHERE is_custom = true AND section_type != 'custom';

-- 불일치 데이터 수정
UPDATE announcement_sections
SET section_type = 'custom'
WHERE is_custom = true;
```

---

## 11. 다음 단계

### Phase 2 계획

- [ ] AI 자동 분석 (PDF → announcement_types 자동 생성)
- [ ] 북마크 시스템 연동
- [ ] 푸시 알림 (새 유형 추가 시)

---

## 참고 자료

- [PRD v7.0](/PRD.md)
- [기존 스키마 v1.0](/docs/database/schema-diagram.md)
- [Supabase Docs - JSONB](https://www.postgresql.org/docs/current/datatype-json.html)
- [PostgreSQL Triggers](https://www.postgresql.org/docs/current/sql-createtrigger.html)

---

**변경 이력**:
- 2025.10.27: 초안 작성 (v2.0)
