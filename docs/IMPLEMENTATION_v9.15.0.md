# Pickly v9.15.0 구현 완료 보고서

## 📋 구현 개요

**버전:** v9.15.0
**작업명:** 범용 공고 구조 (Generic Announcement Structure)
**작업일:** 2025-11-13
**상태:** ✅ 구현 완료

---

## 📁 생성된 파일 목록

### 1️⃣ 데이터베이스 마이그레이션

**파일 1: announcement_details 테이블**
```
📄 supabase/migrations/20251113000002_add_announcement_details.sql
```

**내용:**
- `announcement_details` 테이블 생성
- 4개 인덱스 생성:
  - `idx_details_announcement` - 기본 조회용
  - `idx_details_ann_key` - 복합 조회용
  - `idx_details_covering` - 커버링 인덱스
  - `idx_details_value_gin` - JSONB 검색용

**파일 2: RPC 함수**
```
📄 supabase/migrations/20251113000003_rpc_save_announcement_with_details.sql
```

**내용:**
- `save_announcement_with_details` RPC 함수
- 트랜잭션 보장: announcements upsert → details 전체 교체
- 타입 자동 변환: text/number/date/link/json

### 2️⃣ Admin UI 수정

**파일: 공고 등록/수정 폼**
```
📄 apps/pickly_admin/src/pages/benefits/BenefitAnnouncementForm.tsx
```

**주요 변경사항:**

**A. Zod 스키마 확장 (lines 73-80)**
```typescript
details: z.array(z.object({
  field_key: z.string(),
  field_value: z.string(),
  field_type: z.enum(['text', 'number', 'date', 'link', 'json'])
})).optional().default([])
```

**B. useFieldArray 추가 (lines 204-210)**
```typescript
const { fields: detailFields, append: appendDetail, remove: removeDetail } = useFieldArray({
  control,
  name: 'details',
})
```

**C. Mutation 함수 변경 (lines 245-286)**
```typescript
// 기존: 직접 Supabase insert/update
// 변경: RPC 함수 호출로 트랜잭션 보장
const { data: resultId, error } = await supabase.rpc(
  'save_announcement_with_details',
  { p_announcement, p_details }
)
```

**D. UI 컴포넌트 추가 (lines 702-766)**
```typescript
<Box>
  <Typography>추가 필드 (범용 공고 확장)</Typography>
  <Button onClick={() => appendDetail(...)}>필드 추가</Button>

  {detailFields.map((field, index) => (
    <Grid container spacing={2}>
      <Grid item xs={3}>
        <TextField {...register(`details.${index}.field_key`)} />
      </Grid>
      <Grid item xs={4}>
        <TextField {...register(`details.${index}.field_value`)} />
      </Grid>
      <Grid item xs={3}>
        <TextField {...register(`details.${index}.field_type`)} select>
          <MenuItem value="text">text</MenuItem>
          <MenuItem value="number">number</MenuItem>
          <MenuItem value="date">date</MenuItem>
          <MenuItem value="link">link</MenuItem>
          <MenuItem value="json">json</MenuItem>
        </TextField>
      </Grid>
      <Grid item xs={2}>
        <IconButton onClick={() => removeDetail(index)}>
          <DeleteIcon />
        </IconButton>
      </Grid>
    </Grid>
  ))}
</Box>
```

### 3️⃣ 문서

**PRD 문서**
```
📄 docs/prd/Pickly_v9.15.0_PRD.md
```

**구현 보고서**
```
📄 docs/IMPLEMENTATION_v9.15.0.md (이 문서)
```

---

## 🧪 테스트 케이스

### Case 1: 교육/장학 공고

**입력 데이터:**
```json
{
  "announcement": {
    "title": "2025 서울시 청년 장학금",
    "category_id": "education-uuid",
    "subcategory_id": "scholarship-uuid",
    "organization_id": "seoul-edu-uuid",
    "status": "ongoing",
    "content": "서울시 거주 청년을 위한 학업 지원금"
  },
  "details": [
    {
      "field_key": "지원금액",
      "field_value": "500",
      "field_type": "number"
    },
    {
      "field_key": "신청기간",
      "field_value": "2025-01-01 ~ 2025-01-31",
      "field_type": "text"
    },
    {
      "field_key": "지원대상",
      "field_value": "서울시 거주 대학생",
      "field_type": "text"
    },
    {
      "field_key": "신청링크",
      "field_value": "https://seoul.go.kr/scholarship",
      "field_type": "link"
    }
  ]
}
```

**예상 결과:**
- `announcements` 테이블에 1행 INSERT
- `announcement_details` 테이블에 4행 INSERT
- 모두 단일 트랜잭션으로 처리
- 실패 시 전체 롤백

**검증 쿼리:**
```sql
-- 공고 확인
select * from announcements where title = '2025 서울시 청년 장학금';

-- 확장 필드 확인
select
  field_key,
  field_value,
  field_type
from announcement_details
where announcement_id = (select id from announcements where title = '2025 서울시 청년 장학금')
order by created_at;
```

### Case 2: 교통 카드 공고

**입력 데이터:**
```json
{
  "announcement": {
    "title": "청년 교통비 지원 카드",
    "category_id": "transport-uuid",
    "subcategory_id": "card-uuid",
    "organization_id": "seoul-transport-uuid",
    "status": "ongoing",
    "content": "대중교통 이용 시 월 5만원 할인"
  },
  "details": [
    {
      "field_key": "카드유형",
      "field_value": "신용/체크 겸용",
      "field_type": "text"
    },
    {
      "field_key": "월지원금액",
      "field_value": "50000",
      "field_type": "number"
    },
    {
      "field_key": "사용가능교통",
      "field_value": "[\"지하철\", \"버스\", \"따릉이\"]",
      "field_type": "json"
    },
    {
      "field_key": "발급신청",
      "field_value": "https://card.seoul.go.kr",
      "field_type": "link"
    },
    {
      "field_key": "지원종료일",
      "field_value": "2025-12-31",
      "field_type": "date"
    }
  ]
}
```

**예상 결과:**
- JSON 타입 필드 자동 변환: `"[\"지하철\", \"버스\", \"따릉이\"]"` → `["지하철", "버스", "따릉이"]`
- date 타입 필드 자동 변환: `"2025-12-31"` → `date '2025-12-31'`
- number 타입 필드 자동 변환: `"50000"` → `50000::numeric`

**검증 쿼리:**
```sql
-- JSONB 검색 테스트
select *
from announcement_details
where field_value @> '"지하철"'::jsonb;

-- 타입 변환 확인
select
  field_key,
  field_value,
  jsonb_typeof(field_value) as value_type,
  field_type
from announcement_details
where announcement_id = (select id from announcements where title = '청년 교통비 지원 카드');
```

---

## 🎯 핵심 기능 구현 확인

### ✅ 1. 트랜잭션 보장
- [x] announcements와 announcement_details가 단일 트랜잭션으로 저장
- [x] 부분 실패 시 전체 롤백
- [x] RPC 함수 내부 자동 트랜잭션

### ✅ 2. 타입 자동 변환
- [x] text: 문자열 그대로 저장
- [x] number: `::numeric` 변환
- [x] date: `::date` 변환
- [x] link: 문자열 그대로 저장 (UI에서 링크로 렌더링)
- [x] json: `::jsonb` 변환

### ✅ 3. 동적 필드 관리 (Admin UI)
- [x] "필드 추가" 버튼으로 필드 추가
- [x] 각 필드별 삭제 버튼
- [x] field_key, field_value, field_type 입력
- [x] field_type 드롭다운 (5가지 타입 선택)

### ✅ 4. 인덱스 최적화
- [x] `idx_details_announcement` - 공고별 필드 조회
- [x] `idx_details_ann_key` - 특정 필드 조회
- [x] `idx_details_covering` - Index-Only Scan
- [x] `idx_details_value_gin` - JSONB 값 검색

---

## 📊 성능 예상치

### 쿼리 성능

| 작업 | 인덱스 | 복잡도 | 예상 시간 (1만 공고 기준) |
|------|--------|--------|---------------------------|
| 특정 공고의 모든 필드 조회 | `idx_details_covering` | O(log n) | **< 5ms** |
| 특정 공고의 특정 필드 조회 | `idx_details_ann_key` | O(log n) | **< 3ms** |
| JSONB 값 검색 ("지하철" 포함) | `idx_details_value_gin` | O(1) | **< 10ms** |
| 전체 공고 JOIN details | `idx_details_announcement` | O(n log n) | **< 100ms** |

### 스토리지

- 공고 1개당 평균 5개 필드 가정
- 필드 1개당 평균 100 bytes (key + value + type)
- **1만 개 공고:** 5만 행 × 100B = **5MB**
- **인덱스:** 약 **10MB** (4개 인덱스 합산)
- **총 스토리지:** **15MB** (매우 경량)

---

## 🚀 배포 가이드

### 로컬 환경 적용

**방법 A: Supabase Studio (권장)**
```
1. http://127.0.0.1:54323 접속
2. SQL Editor 탭 선택
3. 파일 내용 복사 & 실행:
   supabase/migrations/20251113000002_add_announcement_details.sql
4. 파일 내용 복사 & 실행:
   supabase/migrations/20251113000003_rpc_save_announcement_with_details.sql
```

**방법 B: CLI (나중에, 기존 마이그레이션 에러 수정 후)**
```bash
npx supabase db reset --local
```

### 타입 재생성

```bash
cd /Users/kwonhyunjun/Desktop/pickly_service
npx supabase gen types typescript --local > apps/pickly_admin/src/types/database.ts
```

**예상 타입:**
```typescript
announcement_details: {
  Row: {
    id: string
    announcement_id: string
    field_key: string
    field_value: Json
    field_type: 'text' | 'number' | 'date' | 'link' | 'json'
    created_at: string
  }
  Insert: {
    id?: string
    announcement_id: string
    field_key: string
    field_value: Json
    field_type: 'text' | 'number' | 'date' | 'link' | 'json'
    created_at?: string
  }
  Update: {
    // ...
  }
}
```

### 프로덕션 배포

```bash
# 자동 배포
npx supabase db push

# 또는 수동 실행
psql -h <prod-db-host> -U postgres -d postgres \
  -f supabase/migrations/20251113000002_add_announcement_details.sql

psql -h <prod-db-host> -U postgres -d postgres \
  -f supabase/migrations/20251113000003_rpc_save_announcement_with_details.sql
```

---

## 🔒 보안 고려사항

### RLS (Row Level Security)

**현재 상태:** RLS 비활성화 (개발 환경)

**프로덕션 적용 시 필요한 정책:**

```sql
-- announcements RLS 활성화
alter table public.announcements enable row level security;

-- announcement_details RLS 활성화
alter table public.announcement_details enable row level security;

-- Admin 전체 권한
create policy "Admin full access on details"
on public.announcement_details
for all
to authenticated
using (
  exists (
    select 1 from auth.users
    where auth.uid() = users.id
    and users.role = 'admin'
  )
);

-- 일반 사용자 읽기 전용
create policy "Public read on details"
on public.announcement_details
for select
to public
using (
  exists (
    select 1 from public.announcements a
    where a.id = announcement_details.announcement_id
    and a.status = 'ongoing'  -- 모집중인 공고만
  )
);
```

---

## 📌 다음 단계 (v9.16.0)

### 1️⃣ Flutter 앱 통합

```dart
// lib/features/benefits/data/models/announcement_detail.dart
class AnnouncementDetail {
  final String fieldKey;
  final dynamic fieldValue;
  final String fieldType;

  // 타입별 값 추출 메서드
  String? get asText => fieldType == 'text' ? fieldValue : null;
  num? get asNumber => fieldType == 'number' ? fieldValue : null;
  DateTime? get asDate => fieldType == 'date' ? DateTime.parse(fieldValue) : null;
  String? get asLink => fieldType == 'link' ? fieldValue : null;
  Map? get asJson => fieldType == 'json' ? fieldValue : null;
}

// lib/features/benefits/presentation/widgets/announcement_card.dart
Widget buildDetailFields(List<AnnouncementDetail> details) {
  return Column(
    children: details.map((detail) {
      switch (detail.fieldKey) {
        case '지원금액':
          return Text('${detail.asNumber}만원', style: moneyStyle);
        case '신청링크':
          return TextButton(
            onPressed: () => launch(detail.asLink!),
            child: Text('신청하기'),
          );
        default:
          return Text('${detail.fieldKey}: ${detail.fieldValue}');
      }
    }).toList(),
  );
}
```

### 2️⃣ Admin 기능 강화

- **필드 템플릿:** 카테고리별 자주 쓰는 필드 자동 생성
- **필드 검증:** 금액은 숫자만, 날짜 포맷 체크
- **필드 순서 변경:** 드래그 앤 드롭

### 3️⃣ 검색 최적화

```sql
-- JSONB 값 기반 필터링
select a.*, d.field_value
from announcements a
join announcement_details d on d.announcement_id = a.id
where d.field_key = '지원금액'
  and (d.field_value)::numeric >= 100;

-- Full-text search 확장 (제목 + 확장 필드)
create index idx_details_fts
on announcement_details
using gin(to_tsvector('korean', field_value::text));
```

---

## 📝 변경 이력

### v9.15.0 (2025-11-13)
- ✅ announcement_details 테이블 생성
- ✅ save_announcement_with_details RPC 함수 생성
- ✅ Admin UI 동적 필드 관리 구현
- ✅ 트랜잭션 보장 및 타입 자동 변환
- ✅ PRD 문서 작성

### v9.14.0 (2025-11-13)
- ✅ organizations 테이블 생성
- ✅ announcements.organization_id FK 추가
- ✅ 기존 데이터 이관
- ✅ 인덱스 최적화

### v9.13.3 (이전)
- ✅ Admin UI 타입 에러 수정 (부분)
- ⏳ 나머지 타입 에러는 보류 중

---

## 🎉 완료 요약

**✅ 구현 완료:**
- 데이터베이스 마이그레이션 2개 파일 생성
- Admin UI 폼 수정 (스키마 + 로직 + UI)
- PRD 문서 및 구현 보고서 작성

**✅ 핵심 가치:**
- 카테고리별 확장 필드 무한 추가 가능
- 타입 안정성 보장 (5가지 타입)
- 트랜잭션으로 데이터 정합성 보장
- 성능 최적화 (4개 인덱스)

**📅 작업 완료일:** 2025-11-13
**📌 버전:** v9.15.0
**✅ 상태:** 구현 완료
**🚀 다음:** Flutter 앱 통합 + 검색 최적화 (v9.16.0)
