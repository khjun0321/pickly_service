# Migration Guide - Schema v2.0

> **대상**: 개발자 및 데이터베이스 관리자
> **업데이트**: 2025.10.27
> **마이그레이션**: `20251027000002`

---

## 빠른 시작

### 1. 마이그레이션 적용

```bash
cd /Users/kwonhyunjun/Desktop/pickly_service

# Supabase 로컬 개발 환경
supabase db reset

# 또는 직접 실행 (프로덕션)
supabase db push
```

### 2. 검증

```sql
-- 테이블 생성 확인
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name = 'announcement_types';

-- 컬럼 추가 확인
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'announcement_sections'
  AND column_name IN ('is_custom', 'custom_content');

-- 뷰 생성 확인
SELECT viewname
FROM pg_views
WHERE schemaname = 'public'
  AND viewname = 'v_announcements_with_types';
```

---

## 주요 변경사항

### 신규 테이블

#### announcement_types
- **목적**: 공고별 유형 정보 (보증금/월세)
- **예시**: "16A 청년" → 보증금 2,000만원, 월세 15만원
- **관계**: `announcements` (1:N)

### 테이블 확장

#### announcement_sections
- **신규 컬럼**:
  - `is_custom` (boolean): 커스텀 섹션 여부
  - `custom_content` (jsonb): 커스텀 내용
- **신규 타입**: `section_type = 'custom'`

### 헬퍼 뷰

#### v_announcements_with_types
- 공고 + 유형 정보 조인
- JSON 집계 (`json_agg`)
- 읽기 전용 뷰

---

## 데이터 마이그레이션

### 기존 데이터가 있는 경우

#### announcement_tabs → announcement_types 변환

기존 `announcement_tabs` 테이블의 데이터를 `announcement_types`로 마이그레이션:

```sql
-- 1. 기존 데이터 백업
CREATE TABLE announcement_tabs_backup AS
SELECT * FROM announcement_tabs;

-- 2. announcement_types로 변환
INSERT INTO announcement_types (
  announcement_id,
  type_name,
  deposit,
  monthly_rent,
  eligible_condition,
  order_index
)
SELECT
  announcement_id,
  tab_name,                                    -- type_name
  NULL,                                         -- deposit (수동 입력 필요)
  NULL,                                         -- monthly_rent (수동 입력 필요)
  income_conditions::text,                      -- eligible_condition
  display_order                                 -- order_index
FROM announcement_tabs;

-- 3. 수동으로 deposit/monthly_rent 업데이트 필요!
-- UPDATE announcement_types
-- SET deposit = 20000000, monthly_rent = 150000
-- WHERE type_name = '16A 청년';
```

**⚠️ 중요**: `deposit`와 `monthly_rent`는 수동으로 입력해야 합니다!

---

## 백오피스 코드 변경

### TypeScript 타입 정의

```typescript
// types/database.types.ts
export interface AnnouncementType {
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

export interface AnnouncementSection {
  id: string;
  announcement_id: string;
  section_type: 'basic_info' | 'schedule' | 'eligibility' | 'housing_info' | 'location' | 'attachments' | 'custom';
  title: string | null;
  content: Record<string, unknown>;
  display_order: number;
  is_visible: boolean;
  is_custom: boolean;  // 🆕
  custom_content: Record<string, unknown> | null;  // 🆕
  created_at: string;
  updated_at: string;
}
```

### Supabase 클라이언트 사용

```typescript
// repositories/announcementRepository.ts
export class AnnouncementRepository {
  async getAnnouncementTypes(announcementId: string) {
    const { data, error } = await supabase
      .from('announcement_types')
      .select('*')
      .eq('announcement_id', announcementId)
      .order('order_index');

    if (error) throw error;
    return data as AnnouncementType[];
  }

  async createAnnouncementType(type: Omit<AnnouncementType, 'id' | 'created_at' | 'updated_at'>) {
    const { data, error } = await supabase
      .from('announcement_types')
      .insert(type)
      .select()
      .single();

    if (error) throw error;
    return data as AnnouncementType;
  }

  async updateAnnouncementType(id: string, updates: Partial<AnnouncementType>) {
    const { data, error } = await supabase
      .from('announcement_types')
      .update(updates)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return data as AnnouncementType;
  }

  async deleteAnnouncementType(id: string) {
    const { error } = await supabase
      .from('announcement_types')
      .delete()
      .eq('id', id);

    if (error) throw error;
  }

  // 뷰 사용 (조인 쿼리)
  async getAnnouncementWithTypes(announcementId: string) {
    const { data, error } = await supabase
      .from('v_announcements_with_types')
      .select('*')
      .eq('id', announcementId)
      .single();

    if (error) throw error;
    return data;
  }
}
```

---

## 모바일 앱 코드 변경

### Dart 모델 정의

```dart
// lib/contexts/benefit/models/announcement_type.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'announcement_type.freezed.dart';
part 'announcement_type.g.dart';

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

### Repository 구현

```dart
// lib/contexts/benefit/repositories/announcement_repository.dart
class AnnouncementRepository {
  final SupabaseClient _client;

  const AnnouncementRepository(this._client);

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

  Future<AnnouncementWithTypes> getAnnouncementWithTypes(String announcementId) async {
    final response = await _client
        .from('v_announcements_with_types')
        .select()
        .eq('id', announcementId)
        .single();

    return AnnouncementWithTypes.fromJson(response);
  }
}
```

### Provider 구현 (Riverpod 2.x)

```dart
// lib/contexts/benefit/providers/announcement_types_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'announcement_types_provider.g.dart';

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

## 테스트

### 단위 테스트

```dart
// test/contexts/benefit/repositories/announcement_repository_test.dart
void main() {
  group('AnnouncementRepository', () {
    late MockSupabaseClient mockClient;
    late AnnouncementRepository repository;

    setUp(() {
      mockClient = MockSupabaseClient();
      repository = AnnouncementRepository(mockClient);
    });

    test('getAnnouncementTypes returns list of types', () async {
      // Arrange
      when(() => mockClient.from('announcement_types'))
          .thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select())
          .thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.eq('announcement_id', any()))
          .thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.order('order_index'))
          .thenAnswer((_) async => [
                {
                  'id': 'test-id',
                  'announcement_id': 'announcement-id',
                  'type_name': '16A 청년',
                  'deposit': 20000000,
                  'monthly_rent': 150000,
                  'order_index': 1,
                },
              ]);

      // Act
      final result = await repository.getAnnouncementTypes('announcement-id');

      // Assert
      expect(result, hasLength(1));
      expect(result.first.typeName, '16A 청년');
      expect(result.first.deposit, 20000000);
    });
  });
}
```

### 통합 테스트

```sql
-- test_announcement_types.sql
BEGIN;

-- 테스트 데이터 삽입
INSERT INTO announcements (id, title, organization, status)
VALUES ('test-announcement-1', '테스트 공고', '테스트 기관', 'recruiting');

INSERT INTO announcement_types (announcement_id, type_name, deposit, monthly_rent, order_index)
VALUES
  ('test-announcement-1', '16A 청년', 20000000, 150000, 1),
  ('test-announcement-1', '26B 신혼부부', 30000000, 200000, 2);

-- 조회 테스트
SELECT * FROM announcement_types
WHERE announcement_id = 'test-announcement-1'
ORDER BY order_index;

-- 뷰 테스트
SELECT id, title, types
FROM v_announcements_with_types
WHERE id = 'test-announcement-1';

-- 롤백 (테스트 데이터 제거)
ROLLBACK;
```

---

## 롤백 가이드

### 언제 롤백하나요?

- 마이그레이션 중 오류 발생
- 프로덕션 환경에서 예기치 않은 문제 발생
- 데이터 손실 위험 감지

### 롤백 실행

```bash
# 로컬 환경
supabase db reset

# 프로덕션 (⚠️ 주의: 데이터 손실!)
psql -h [HOST] -U [USER] -d [DB] \
  -f backend/supabase/migrations/20251027000003_rollback_announcement_types.sql
```

### 롤백 후 복구

```sql
-- 백업 데이터 복구 (백업이 있는 경우)
INSERT INTO announcement_tabs
SELECT * FROM announcement_tabs_backup;
```

---

## 문제 해결

### Q1: 마이그레이션 실패 - "relation already exists"

**원인**: 테이블/뷰가 이미 존재함

**해결**:
```sql
-- 기존 객체 제거 후 재실행
DROP TABLE IF EXISTS announcement_types CASCADE;
DROP VIEW IF EXISTS v_announcements_with_types;
```

### Q2: RLS 정책 오류

**원인**: 권한 문제

**해결**:
```sql
-- RLS 임시 비활성화 (개발 환경만)
ALTER TABLE announcement_types DISABLE ROW LEVEL SECURITY;

-- 정책 재생성
DROP POLICY IF EXISTS "Public read access" ON announcement_types;
CREATE POLICY "Public read access" ON announcement_types FOR SELECT USING (true);
```

### Q3: 백오피스에서 데이터 안 보임

**원인**: RLS 정책 또는 권한 문제

**해결**:
```sql
-- 1. 데이터 존재 확인
SELECT COUNT(*) FROM announcement_types;

-- 2. RLS 정책 확인
SELECT * FROM pg_policies WHERE tablename = 'announcement_types';

-- 3. 권한 확인
GRANT SELECT ON announcement_types TO authenticated;
GRANT SELECT ON announcement_types TO anon;
```

---

## 체크리스트

마이그레이션 전:
- [ ] 데이터베이스 백업 완료
- [ ] 로컬 환경에서 테스트 완료
- [ ] 백오피스 코드 준비 완료
- [ ] 모바일 앱 코드 준비 완료

마이그레이션 후:
- [ ] 테이블 생성 확인
- [ ] 인덱스 생성 확인
- [ ] RLS 정책 적용 확인
- [ ] 뷰 동작 확인
- [ ] 기존 데이터 마이그레이션 (필요 시)
- [ ] 백오피스 CRUD 테스트
- [ ] 모바일 앱 조회 테스트

---

## 참고 자료

- [Schema v2.0 문서](/docs/database/schema-v2.md)
- [PRD v7.0](/PRD.md)
- [Supabase Migration Guide](https://supabase.com/docs/guides/database/migrations)
- [PostgreSQL JSONB](https://www.postgresql.org/docs/current/datatype-json.html)

---

**다음 단계**: Phase 2 - AI 자동 분석 (PDF → announcement_types)
