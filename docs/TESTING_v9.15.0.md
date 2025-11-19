# Pickly v9.15.0 RPC Integration 테스트 가이드

## ✅ 구현 완료 확인

### 1️⃣ BenefitAnnouncementForm.tsx 통합 상태

**Zod 스키마 (lines 76-80):**
```typescript
details: z.array(z.object({
  field_key: z.string(),
  field_value: z.string(),
  field_type: z.enum(['text', 'number', 'date', 'link', 'json'])
})).optional().default([])
```
✅ **상태:** 구현 완료

**useFieldArray 훅 (lines 205-209):**
```typescript
const { fields: detailFields, append: appendDetail, remove: removeDetail } = useFieldArray({
  control,
  name: 'details',
})
```
✅ **상태:** 구현 완료

**RPC 함수 호출 (lines 246-271):**
```typescript
const mutation = useMutation({
  mutationFn: async (data: FormData) => {
    const { details, ...baseData } = data

    const p_announcement = {
      ...(isEdit ? { id } : {}),
      ...baseData,
    }

    const p_details = (details || []).map(d => ({
      field_key: d.field_key,
      field_value: d.field_value,
      field_type: d.field_type,
    }))

    const { data: resultId, error } = await supabase.rpc('save_announcement_with_details', {
      p_announcement,
      p_details,
    })

    if (error) throw error
    return resultId
  },
  // ...
})
```
✅ **상태:** 구현 완료

**UI 컴포넌트 (lines 702-766):**
```typescript
<Grid item xs={12}>
  <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2, mt: 3 }}>
    <Typography variant="subtitle1">추가 필드 (범용 공고 확장)</Typography>
    <Button onClick={() => appendDetail({ field_key: '', field_value: '', field_type: 'text' })}>
      필드 추가
    </Button>
  </Box>
  {detailFields.map((field, index) => (
    <Grid container spacing={2} key={field.id}>
      <Grid item xs={12} md={3}>
        <TextField {...register(`details.${index}.field_key`)} label="필드 키" />
      </Grid>
      <Grid item xs={12} md={4}>
        <TextField {...register(`details.${index}.field_value`)} label="값" multiline />
      </Grid>
      <Grid item xs={12} md={3}>
        <TextField {...register(`details.${index}.field_type`)} select label="타입">
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
</Grid>
```
✅ **상태:** 구현 완료

---

## 🧪 테스트 시나리오

### Test Case 1: 교육/장학 공고 생성

**테스트 목적:** 기본 필드 + 확장 필드 동시 저장 검증

**단계:**
1. Admin 로그인 후 `/benefits/new` 이동
2. 기본 정보 입력:
   - 제목: "2025 서울시 청년 장학금"
   - 카테고리: 교육/장학
   - 상태: 모집중
3. "추가 필드" 섹션에서 "필드 추가" 버튼 클릭 (4회)
4. 아래 필드 입력:
   ```
   필드 1: field_key="지원금액", field_value="500", field_type="number"
   필드 2: field_key="신청기간", field_value="2025-01-01 ~ 2025-01-31", field_type="text"
   필드 3: field_key="지원대상", field_value="서울시 거주 대학생", field_type="text"
   필드 4: field_key="신청링크", field_value="https://seoul.go.kr/scholarship", field_type="link"
   ```
5. "저장" 버튼 클릭

**예상 결과:**
- ✅ "공고가 등록되었습니다" 토스트 메시지
- ✅ `/benefits` 페이지로 리다이렉트
- ✅ 리스트에 새 공고 표시

**DB 검증 (Supabase Studio):**
```sql
-- announcements 테이블 확인
SELECT id, title, status, category_id
FROM announcements
WHERE title = '2025 서울시 청년 장학금';

-- announcement_details 테이블 확인 (결과: 4행)
SELECT
  field_key,
  field_value,
  field_type,
  jsonb_typeof(field_value) as value_json_type
FROM announcement_details
WHERE announcement_id = (
  SELECT id FROM announcements WHERE title = '2025 서울시 청년 장학금'
)
ORDER BY created_at;
```

**예상 DB 결과:**
```
field_key    | field_value                      | field_type | value_json_type
-------------+----------------------------------+------------+-----------------
지원금액      | 500                              | number     | number
신청기간      | "2025-01-01 ~ 2025-01-31"        | text       | string
지원대상      | "서울시 거주 대학생"               | text       | string
신청링크      | "https://seoul.go.kr/scholarship" | link       | string
```

---

### Test Case 2: 교통 카드 공고 (JSON 타입 테스트)

**테스트 목적:** JSON 타입 필드의 자동 변환 검증

**단계:**
1. `/benefits/new` 이동
2. 기본 정보 입력:
   - 제목: "청년 교통비 지원 카드"
   - 카테고리: 교통/카드
   - 상태: 모집중
3. "추가 필드" 섹션에서 필드 추가:
   ```
   필드 1: field_key="카드유형", field_value="신용/체크 겸용", field_type="text"
   필드 2: field_key="월지원금액", field_value="50000", field_type="number"
   필드 3: field_key="사용가능교통", field_value='["지하철", "버스", "따릉이"]', field_type="json"
   필드 4: field_key="발급신청", field_value="https://card.seoul.go.kr", field_type="link"
   필드 5: field_key="지원종료일", field_value="2025-12-31", field_type="date"
   ```
4. "저장" 버튼 클릭

**DB 검증:**
```sql
-- JSON 배열 파싱 테스트
SELECT
  field_key,
  field_value,
  field_type,
  jsonb_typeof(field_value) as value_type,
  field_value->0 as first_item  -- JSON 배열의 첫 요소
FROM announcement_details
WHERE announcement_id = (
  SELECT id FROM announcements WHERE title = '청년 교통비 지원 카드'
)
AND field_key = '사용가능교통';
```

**예상 결과:**
```
field_key    | field_value                     | field_type | value_type | first_item
-------------+---------------------------------+------------+------------+------------
사용가능교통 | ["지하철", "버스", "따릉이"]      | json       | array      | "지하철"
```

**JSONB 검색 테스트:**
```sql
-- "지하철"을 포함하는 공고 찾기
SELECT a.title, d.field_value
FROM announcements a
JOIN announcement_details d ON d.announcement_id = a.id
WHERE d.field_value @> '"지하철"'::jsonb;
```

---

### Test Case 3: 필드 수정 (트랜잭션 테스트)

**테스트 목적:** 기존 확장 필드 전체 교체 로직 검증

**단계:**
1. Test Case 1에서 생성한 공고 수정 모드 진입
2. 기존 필드 중 2개 삭제 (지원대상, 신청링크)
3. 새 필드 1개 추가:
   ```
   field_key="제출서류", field_value="주민등록등본, 재학증명서", field_type="text"
   ```
4. "저장" 버튼 클릭

**예상 동작:**
1. 기존 4개 필드 **전체 삭제** (DELETE)
2. 새로운 3개 필드 **일괄 삽입** (INSERT)
3. 모두 단일 트랜잭션으로 처리

**DB 검증:**
```sql
-- 필드 개수 확인 (결과: 3행)
SELECT COUNT(*) as field_count
FROM announcement_details
WHERE announcement_id = (
  SELECT id FROM announcements WHERE title = '2025 서울시 청년 장학금'
);

-- 필드 목록 확인
SELECT field_key, field_value
FROM announcement_details
WHERE announcement_id = (
  SELECT id FROM announcements WHERE title = '2025 서울시 청년 장학금'
)
ORDER BY created_at;
```

**예상 결과:**
```
field_key    | field_value
-------------+----------------------------------
지원금액      | 500
신청기간      | "2025-01-01 ~ 2025-01-31"
제출서류      | "주민등록등본, 재학증명서"
```

---

### Test Case 4: 빈 필드 배열 (확장 필드 없는 공고)

**테스트 목적:** 확장 필드가 없는 공고도 정상 저장되는지 검증

**단계:**
1. `/benefits/new` 이동
2. 기본 정보만 입력:
   - 제목: "일반 공고 (확장 필드 없음)"
   - 상태: 모집중
3. "추가 필드" 섹션에서 아무 필드도 추가하지 않음
4. "저장" 버튼 클릭

**예상 결과:**
- ✅ 정상 저장
- ✅ announcements 테이블에 1행 INSERT
- ✅ announcement_details 테이블에 0행 (빈 배열이므로 INSERT 안 됨)

**DB 검증:**
```sql
-- 확장 필드 개수 확인 (결과: 0)
SELECT COUNT(*) as field_count
FROM announcement_details
WHERE announcement_id = (
  SELECT id FROM announcements WHERE title = '일반 공고 (확장 필드 없음)'
);
```

---

## 🚨 에러 케이스 테스트

### Error Case 1: 필수 필드 누락

**단계:**
1. 제목 없이 저장 시도

**예상 결과:**
- ❌ "제목은 필수입니다" 에러 메시지
- ❌ 폼 제출 차단

### Error Case 2: 잘못된 JSON 형식

**단계:**
1. JSON 타입 필드에 잘못된 JSON 입력:
   ```
   field_key="잘못된JSON", field_value="{invalid}", field_type="json"
   ```
2. 저장 시도

**예상 결과:**
- ❌ PostgreSQL에서 JSON 파싱 에러 발생
- ❌ "저장 실패" 토스트 메시지
- ❌ 트랜잭션 롤백 (announcements도 저장 안 됨)

### Error Case 3: 네트워크 오류 시뮬레이션

**단계:**
1. 개발자 도구 → Network 탭 → Offline 모드
2. 저장 시도

**예상 결과:**
- ❌ "저장 실패" 토스트 메시지
- ❌ 폼 데이터 유지 (재시도 가능)

---

## 📊 성능 테스트

### 대량 필드 저장 테스트

**목적:** 10개 이상 확장 필드 저장 시 성능 확인

**단계:**
1. 공고 생성 시 확장 필드 15개 추가
2. 저장 시간 측정 (브라우저 Network 탭)

**예상 성능:**
- ✅ RPC 호출 1회만 발생
- ✅ 응답 시간 < 500ms
- ✅ 트랜잭션으로 원자성 보장

---

## ✅ 체크리스트

**기능 테스트:**
- [ ] Test Case 1: 교육/장학 공고 생성
- [ ] Test Case 2: JSON 타입 필드 테스트
- [ ] Test Case 3: 필드 수정 (트랜잭션)
- [ ] Test Case 4: 빈 필드 배열

**에러 처리:**
- [ ] Error Case 1: 필수 필드 누락
- [ ] Error Case 2: 잘못된 JSON 형식
- [ ] Error Case 3: 네트워크 오류

**DB 검증:**
- [ ] announcements 테이블 정상 삽입
- [ ] announcement_details 테이블 정상 삽입
- [ ] FK 관계 정상 작동 (cascade delete)
- [ ] 인덱스 활용 확인 (`EXPLAIN ANALYZE`)
- [ ] 타입 자동 변환 확인 (number/date/json)

**UI/UX:**
- [ ] "필드 추가" 버튼 작동
- [ ] 각 필드 삭제 버튼 작동
- [ ] field_type 드롭다운 작동
- [ ] 저장 성공 시 토스트 메시지
- [ ] 저장 실패 시 에러 메시지

---

## 🔧 디버깅 팁

### RPC 함수 직접 테스트 (Supabase Studio SQL Editor)

```sql
-- 테스트 공고 생성
SELECT save_announcement_with_details(
  '{"title": "RPC 직접 테스트", "status": "draft"}'::jsonb,
  ARRAY[
    '{"field_key": "테스트필드1", "field_value": "값1", "field_type": "text"}'::jsonb,
    '{"field_key": "테스트필드2", "field_value": "123", "field_type": "number"}'::jsonb
  ]::jsonb[]
);

-- 결과 확인
SELECT * FROM announcements WHERE title = 'RPC 직접 테스트';
SELECT * FROM announcement_details
WHERE announcement_id = (SELECT id FROM announcements WHERE title = 'RPC 직접 테스트');
```

### 브라우저 콘솔에서 RPC 호출 확인

```javascript
// 개발자 도구 → Console 탭
// Network 탭에서 "/rest/v1/rpc/save_announcement_with_details" 요청 확인

// Request Payload:
{
  "p_announcement": {
    "title": "...",
    "status": "..."
  },
  "p_details": [
    {"field_key": "...", "field_value": "...", "field_type": "..."}
  ]
}

// Response:
"uuid-string"  // 생성된 announcement_id
```

---

## 📝 완료 보고

**테스트 완료 시 체크:**
- [ ] 모든 Test Case 통과
- [ ] DB에 정상 저장 확인
- [ ] RPC 함수 정상 작동 확인
- [ ] UI 동작 정상 확인
- [ ] 에러 처리 정상 확인

**작성일:** 2025-11-13
**버전:** v9.15.0
**담당자:** Claude Code
