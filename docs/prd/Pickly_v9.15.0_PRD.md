# Pickly v9.15.0 PRD - 범용 공고 구조 (Generic Announcement Structure)

## 🎯 개요

### 목적
기존 `announcements` 테이블의 고정 컬럼 구조를 유지하면서, 카테고리별 특수 필드를 확장 가능한 key-value 구조로 저장하는 시스템 구축.

### 핵심 목표
| 항목 | 기존 | 개선 후 |
|------|------|---------|
| **확장성** | 카테고리별 새 컬럼 추가 필요 | key-value로 무한 확장 |
| **유지보수** | 스키마 변경 시 마이그레이션 | 런타임 필드 추가 가능 |
| **타입 안정성** | 고정 타입만 가능 | text/number/date/link/json 지원 |
| **트랜잭션** | 별도 API 호출 → 실패 위험 | RPC 단일 트랜잭션 보장 |

---

## 📊 스키마 설계

### 1️⃣ announcement_details 테이블

```sql
create table if not exists public.announcement_details (
  id uuid primary key default gen_random_uuid(),
  announcement_id uuid not null references public.announcements(id) on delete cascade,
  field_key text not null,
  field_value jsonb not null,
  field_type text not null check (field_type in ('text','number','date','link','json')),
  created_at timestamptz not null default now()
);
```

**컬럼 설명:**
- `announcement_id`: 공고 FK (CASCADE 삭제)
- `field_key`: 필드 키 (예: "지원금액", "교육기간", "카드유형")
- `field_value`: JSONB 형식의 값 (타입별 자동 변환)
- `field_type`: 값 타입 (text/number/date/link/json)

### 2️⃣ 인덱스 최적화

```sql
-- 기본 인덱스 (announcement_id로 필터링)
create index idx_details_announcement
on announcement_details(announcement_id);

-- 복합 인덱스 (특정 공고의 특정 필드 조회)
create index idx_details_ann_key
on announcement_details(announcement_id, field_key);

-- 커버링 인덱스 (테이블 액세스 없이 인덱스에서 바로 반환)
create index idx_details_covering
on announcement_details(announcement_id, field_key)
include (field_value, field_type);

-- GIN 인덱스 (JSONB 값 검색용)
create index idx_details_value_gin
on announcement_details using gin(field_value);
```

**성능 예상:**
- 특정 공고의 모든 필드 조회: `idx_details_covering` → **O(log n)** + index-only scan
- JSONB 값 검색 (예: "금액 >= 100만원"): `idx_details_value_gin` → **O(1)** + bitmap scan

---

## 🔄 RPC 함수 - save_announcement_with_details

### 함수 시그니처

```sql
create or replace function public.save_announcement_with_details(
  p_announcement jsonb,
  p_details jsonb[] default array[]::jsonb[]
) returns uuid
```

### 트랜잭션 플로우

```
1. BEGIN TRANSACTION
   ↓
2. announcements UPSERT (id 있으면 UPDATE, 없으면 INSERT)
   ↓
3. announcement_details DELETE (기존 필드 전체 삭제)
   ↓
4. announcement_details INSERT (새 필드 일괄 삽입)
   ↓
5. COMMIT (성공) / ROLLBACK (실패 시)
```

### 타입 자동 변환

```sql
case
  when field_type = 'number' then to_jsonb((field_value)::numeric)
  when field_type = 'date' then to_jsonb((field_value)::date)
  when field_type = 'json' then (field_value)::jsonb
  else to_jsonb(field_value)  -- text, link
end
```

**장점:**
- ✅ 단일 API 호출로 모든 데이터 저장
- ✅ 부분 실패 방지 (전체 롤백)
- ✅ 타입 안정성 보장
- ✅ 확장 필드 중복 제거 (DELETE → INSERT)

---

## 💻 Admin UI 구현

### 1️⃣ Zod 스키마 확장

```typescript
// apps/pickly_admin/src/pages/benefits/BenefitAnnouncementForm.tsx

const formSchema = z.object({
  // ... 기존 필드들
  details: z.array(z.object({
    field_key: z.string(),
    field_value: z.string(),
    field_type: z.enum(['text', 'number', 'date', 'link', 'json'])
  })).optional().default([])
})
```

### 2️⃣ useFieldArray 동적 필드 관리

```typescript
const { fields: detailFields, append: appendDetail, remove: removeDetail } = useFieldArray({
  control,
  name: 'details',
})
```

### 3️⃣ 저장 로직 (RPC 호출)

```typescript
mutationFn: async (data: FormData) => {
  const { details, ...baseData } = data

  const p_announcement = {
    ...(isEdit ? { id } : {}),
    ...baseData
  }

  const p_details = (details || []).map(d => ({
    field_key: d.field_key,
    field_value: d.field_value,
    field_type: d.field_type,
  }))

  const { data: resultId, error } = await supabase.rpc(
    'save_announcement_with_details',
    { p_announcement, p_details }
  )

  if (error) throw error
  return resultId
}
```

### 4️⃣ UI 컴포넌트 (동적 필드 배열)

```tsx
<Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2, mt: 3 }}>
  <Typography variant="subtitle1">추가 필드 (범용 공고 확장)</Typography>
  <Button onClick={() => appendDetail({
    field_key: '',
    field_value: '',
    field_type: 'text'
  })}>
    필드 추가
  </Button>
</Box>

{detailFields.map((field, index) => (
  <Grid container spacing={2} key={field.id}>
    <Grid item xs={12} md={3}>
      <TextField
        {...register(`details.${index}.field_key`)}
        label="필드 키"
        placeholder="예: 지원금액"
      />
    </Grid>
    <Grid item xs={12} md={4}>
      <TextField
        {...register(`details.${index}.field_value`)}
        label="값"
        multiline
      />
    </Grid>
    <Grid item xs={12} md={3}>
      <TextField
        {...register(`details.${index}.field_type`)}
        select
        label="타입"
      >
        <MenuItem value="text">text</MenuItem>
        <MenuItem value="number">number</MenuItem>
        <MenuItem value="date">date</MenuItem>
        <MenuItem value="link">link</MenuItem>
        <MenuItem value="json">json</MenuItem>
      </TextField>
    </Grid>
    <Grid item xs={12} md={2}>
      <IconButton onClick={() => removeDetail(index)}>
        <DeleteIcon />
      </IconButton>
    </Grid>
  </Grid>
))}
```

---

## 📝 사용 예시

### Case 1: 교육/장학 공고

```json
{
  "announcement": {
    "title": "2025 서울시 청년 장학금",
    "category_id": "education-uuid",
    "subcategory_id": "scholarship-uuid",
    "organization_id": "seoul-edu-uuid",
    "status": "ongoing"
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

### Case 2: 교통 카드 공고

```json
{
  "announcement": {
    "title": "청년 교통비 지원 카드",
    "category_id": "transport-uuid",
    "subcategory_id": "card-uuid",
    "organization_id": "seoul-transport-uuid",
    "status": "ongoing"
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
      "field_value": ["지하철", "버스", "따릉이"],
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

---

## 🔍 조회 패턴

### Flutter에서 조회

```dart
// 공고 기본 정보 + 확장 필드 함께 조회
final response = await supabase
  .from('announcements')
  .select('''
    *,
    announcement_details (
      field_key,
      field_value,
      field_type
    )
  ''')
  .eq('id', announcementId)
  .single();

// 모델 변환
class AnnouncementDetail {
  final String fieldKey;
  final dynamic fieldValue;
  final String fieldType;

  factory AnnouncementDetail.fromJson(Map<String, dynamic> json) {
    return AnnouncementDetail(
      fieldKey: json['field_key'],
      fieldValue: json['field_value'],
      fieldType: json['field_type'],
    );
  }

  // 타입별 값 추출
  String? get asText => fieldType == 'text' ? fieldValue : null;
  num? get asNumber => fieldType == 'number' ? fieldValue : null;
  DateTime? get asDate => fieldType == 'date' ? DateTime.parse(fieldValue) : null;
  String? get asLink => fieldType == 'link' ? fieldValue : null;
  Map? get asJson => fieldType == 'json' ? fieldValue : null;
}
```

### Admin에서 조회

```typescript
const { data } = await supabase
  .from('announcements')
  .select('*, announcement_details(*)')
  .eq('id', id)
  .single();

// details 배열로 변환
const details = (data.announcement_details || []).map((d: any) => ({
  field_key: d.field_key,
  field_value: String(d.field_value),
  field_type: d.field_type,
}));
```

---

## 🎨 UI/UX 가이드

### 카드 표시 전략

**기본 정보 (모든 공고 공통):**
- 썸네일
- 제목
- 기관명
- 상태 배지

**확장 정보 (카테고리별 차별화):**

```typescript
// 교육/장학: 지원금액, 신청기간 강조
if (category === 'education') {
  return (
    <>
      <Typography variant="h6">
        {getDetail('지원금액')}만원
      </Typography>
      <Typography variant="body2">
        {getDetail('신청기간')}
      </Typography>
    </>
  );
}

// 교통: 카드유형, 월지원금액 강조
if (category === 'transport') {
  return (
    <>
      <Chip label={getDetail('카드유형')} />
      <Typography>
        월 {getDetail('월지원금액')}원
      </Typography>
    </>
  );
}
```

---

## 📦 파일 구조

```
pickly_service/
├── supabase/migrations/
│   ├── 20251113000002_add_announcement_details.sql       # ✅ 생성됨
│   └── 20251113000003_rpc_save_announcement_with_details.sql  # ✅ 생성됨
├── apps/pickly_admin/src/pages/benefits/
│   └── BenefitAnnouncementForm.tsx                       # ✅ 수정됨
└── docs/prd/
    └── Pickly_v9.15.0_PRD.md                            # ✅ 이 문서
```

---

## 🧪 테스트 시나리오

### Admin 테스트

1. **교육 공고 생성**
   - 기본 정보 입력 (제목, 카테고리, 기관 등)
   - "필드 추가" 버튼 클릭
   - 지원금액(number), 신청기간(text), 신청링크(link) 추가
   - 저장 후 DB 확인:
     ```sql
     select * from announcements where title = '2025 서울시 청년 장학금';
     select * from announcement_details where announcement_id = (방금 생성된 id);
     ```

2. **교통 공고 생성**
   - 카드유형(text), 월지원금액(number), 사용가능교통(json) 추가
   - JSON 필드 테스트: `["지하철", "버스", "따릉이"]`
   - 저장 후 JSONB 검색 테스트:
     ```sql
     select * from announcement_details
     where field_value @> '"지하철"'::jsonb;
     ```

3. **필드 수정/삭제**
   - 기존 공고 수정 모드 진입
   - 필드 삭제 (DELETE 버튼)
   - 새 필드 추가
   - 저장 → 트랜잭션 확인 (기존 필드 삭제 + 새 필드 삽입)

### Flutter 테스트 (향후)

1. **리스트 조회**
   - 카테고리별 필터링
   - 확장 필드 표시 확인

2. **상세 페이지**
   - 기본 정보 + 확장 필드 통합 표시
   - 타입별 렌더링 (링크 클릭 가능, 날짜 포맷 등)

---

## 📊 성능 분석

### 인덱스 활용도

| 쿼리 | 인덱스 | 예상 성능 |
|------|--------|-----------|
| `WHERE announcement_id = ?` | `idx_details_announcement` | **O(log n)** Index Scan |
| `WHERE announcement_id = ? AND field_key = ?` | `idx_details_ann_key` | **O(log n)** Index Scan |
| `SELECT field_value WHERE announcement_id = ?` | `idx_details_covering` | **O(log n)** Index-Only Scan |
| `WHERE field_value @> '{"amount": 500}'` | `idx_details_value_gin` | **O(1)** Bitmap Index Scan |

### 스토리지 예상

- 공고 1개당 평균 5개 필드
- 필드 1개당 평균 100 bytes
- 1만 개 공고: 5만 행 × 100B = **5MB**
- 인덱스: 약 **10MB** (4개 인덱스 합산)
- 총: **15MB** (매우 경량)

---

## 🔄 마이그레이션 가이드

### 로컬 적용 (권장: Studio SQL Editor)

```
1. http://127.0.0.1:54323 접속
2. SQL Editor 탭 선택
3. 파일 내용 복사 & 실행:
   - supabase/migrations/20251113000002_add_announcement_details.sql
   - supabase/migrations/20251113000003_rpc_save_announcement_with_details.sql
```

### 타입 재생성

```bash
cd /Users/kwonhyunjun/Desktop/pickly_service
npx supabase gen types typescript --local > apps/pickly_admin/src/types/database.ts
```

### 프로덕션 배포

```bash
# 마이그레이션 자동 적용
npx supabase db push

# 또는 수동 실행
psql -h <prod-db-host> -U postgres -d postgres -f supabase/migrations/20251113000002_add_announcement_details.sql
psql -h <prod-db-host> -U postgres -d postgres -f supabase/migrations/20251113000003_rpc_save_announcement_with_details.sql
```

---

## 🚨 주의사항

### RLS (Row Level Security)

**현재 상태:** RLS 비활성화 (개발 환경)

**프로덕션 적용 시:**
```sql
-- announcements RLS 활성화
alter table public.announcements enable row level security;

-- announcement_details RLS 활성화
alter table public.announcement_details enable row level security;

-- Admin 유저 풀 액세스 정책
create policy "Admin full access"
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
create policy "Public read access"
on public.announcement_details
for select
to public
using (true);
```

### 트랜잭션 안정성

- RPC 함수 내부는 **자동 트랜잭션**
- 부분 실패 시 **전체 롤백** 보장
- 동시성 이슈 없음 (announcement_id 기준 잠금)

---

## 🎯 다음 단계 (v9.16.0)

1. **Flutter 앱 통합**
   - announcement_details 모델 추가
   - 카테고리별 카드 렌더링 로직
   - 상세 페이지 확장 필드 표시

2. **Admin 기능 강화**
   - 카테고리별 필드 템플릿 (자주 쓰는 필드 자동 생성)
   - 필드 검증 (예: 금액은 숫자만, 날짜 포맷 체크)
   - 필드 순서 변경 (드래그 앤 드롭)

3. **검색 최적화**
   - JSONB 값 기반 필터링 (예: "지원금액 100만원 이상")
   - Full-text search 확장 (제목 + 확장 필드)

4. **통계/분석**
   - 카테고리별 평균 지원금액
   - 인기 필드 분석 (어떤 필드가 많이 쓰이는지)

---

## 📝 요약

**✅ 완료된 작업:**
- announcement_details 테이블 생성 (4개 인덱스)
- save_announcement_with_details RPC 함수 생성
- Admin 폼 스키마 확장 (details 필드)
- Admin UI 동적 필드 관리 구현
- 트랜잭션 안정성 보장

**✅ 핵심 가치:**
- 카테고리별 확장 필드 무한 추가 가능
- 타입 안정성 보장 (text/number/date/link/json)
- 단일 트랜잭션으로 데이터 정합성 보장
- 성능 최적화 (4개 인덱스 + 커버링 인덱스)

**📅 작성일:** 2025-11-13
**📌 버전:** v9.15.0
**✅ 상태:** 구현 완료 (마이그레이션 + Admin UI)
**🚀 다음:** Flutter 앱 통합 + 검색 최적화 (v9.16.0)
