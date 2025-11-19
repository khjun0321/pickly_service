# 🚀 Organizations 마이그레이션 빠른 시작 가이드

## ✅ 작업 완료된 것들

| 항목 | 파일 | 상태 |
|------|------|------|
| **마이그레이션 SQL** | `supabase/migrations/20251113000001_add_organizations.sql` | ✅ 생성됨 |
| **롤백 스크립트** | `supabase/migrations/20251113000001_add_organizations_rollback.sql` | ✅ 생성됨 |
| **PRD 문서** | `docs/prd/Pickly_v9.14.0_PRD.md` | ✅ 작성됨 |

---

## 🎯 다음에 해야 할 일

### 1️⃣ 마이그레이션 적용 (로컬)

**방법 A: Supabase Studio (권장)**
```
1. http://127.0.0.1:54323 접속
2. SQL Editor 탭 선택
3. supabase/migrations/20251113000001_add_organizations.sql 파일 내용 복사
4. Paste & Run
```

**방법 B: 전체 리셋 (나중에)**
```bash
# 기존 마이그레이션 에러 수정 후
npx supabase db reset --local
```

---

### 2️⃣ 타입 재생성

```bash
cd /Users/kwonhyunjun/Desktop/pickly_service

# 타입 생성
npx supabase gen types typescript --local > apps/pickly_admin/src/types/database.ts

# 확인
grep -A 5 "organization_id" apps/pickly_admin/src/types/database.ts
```

**예상 결과:**
```typescript
organization_id: string | null  // ✅ 추가됨
```

---

### 3️⃣ Admin 코드 수정

#### **A. 기관 드롭다운 추가**
```typescript
// pages/announcements/AnnouncementForm.tsx

const { data: organizations } = useQuery({
  queryKey: ['organizations'],
  queryFn: async () => {
    const { data } = await supabase
      .from('organizations')
      .select('id, name')
      .order('name');
    return data;
  }
});

// 폼에 추가
<FormControl fullWidth>
  <InputLabel>기관</InputLabel>
  <Select
    value={form.organization_id ?? ''}
    onChange={(e) => setForm({ ...form, organization_id: e.target.value })}
  >
    <MenuItem value="">선택 안 함</MenuItem>
    {organizations?.map((org) => (
      <MenuItem key={org.id} value={org.id}>
        {org.name}
      </MenuItem>
    ))}
  </Select>
</FormControl>
```

#### **B. 리스트에 기관명 표시**
```typescript
// pages/announcements/AnnouncementList.tsx

const { data } = await supabase
  .from('announcements')
  .select('*, organizations(name)')
  .order('created_at', { ascending: false });

// 테이블 컬럼 추가
<TableCell>{announcement.organizations?.name || '-'}</TableCell>
```

#### **C. 필터 추가**
```typescript
// 기관 필터
if (orgId) {
  query = query.eq('organization_id', orgId);
}
```

---

### 4️⃣ Flutter 코드 수정

```dart
// lib/features/benefits/data/announcements_repository.dart

Future<List<Announcement>> getAnnouncementsBySubcategory(String subcategoryId) async {
  final response = await supabase
    .from('announcements')
    .select('''
      id,
      thumbnail_url,
      title,
      status,
      created_at,
      organizations(name),
      benefit_subcategories(name)
    ''')
    .eq('subcategory_id', subcategoryId)
    .order('status')
    .order('created_at', ascending: false);

  return (response as List)
    .map((json) => Announcement.fromJson(json))
    .toList();
}
```

**모델 수정:**
```dart
class Announcement {
  final String id;
  final String? thumbnailUrl;
  final String title;
  final String status;
  final String? organizationName;  // ✅ 추가
  final String? subcategoryName;

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'],
      thumbnailUrl: json['thumbnail_url'],
      title: json['title'],
      status: json['status'],
      organizationName: json['organizations']?['name'],  // ✅ 추가
      subcategoryName: json['benefit_subcategories']?['name'],
    );
  }
}
```

---

### 5️⃣ 테스트 체크리스트

#### **Admin 테스트**
```
□ 기관 생성 (Organizations CRUD)
  □ LH공사 생성
  □ SH공사 생성
  □ 로고 업로드 (선택)

□ 공고 생성/수정
  □ 기관 드롭다운 작동
  □ 기관 선택 후 저장
  □ 리스트에 기관명 표시

□ 필터링
  □ 기관별 필터
  □ 하위분류별 필터
  □ 상태별 필터
```

#### **Flutter 테스트**
```
□ 리스트 조회
  □ 행복주택 카테고리 선택
  □ 카드에 기관명 표시
  □ 썸네일 표시

□ 정렬 확인
  □ 모집중 공고 최상단
  □ 모집예정 공고 중간
  □ 마감 공고 최하단

□ 성능 확인
  □ 조회 속도 <200ms
  □ 스크롤 부드러움
```

---

## 📊 성능 개선 예상

| 작업 | 기존 | 개선 후 |
|------|------|---------|
| 기관 필터 | `LIKE '%LH%'` (Seq Scan) | `FK = uuid` (Index Scan) |
| 속도 | ~500ms | **~50ms (10x)** |
| 복합 필터 | 4개 단일 인덱스 | 1개 복합 인덱스 |
| 속도 | ~300ms | **~100ms (3x)** |

---

## 🔄 롤백 방법

**문제 발생 시:**
```bash
# Studio SQL Editor에서 실행
# 또는
psql -f supabase/migrations/20251113000001_add_organizations_rollback.sql
```

---

## 📞 참고 문서

- **PRD 전체:** `docs/prd/Pickly_v9.14.0_PRD.md`
- **마이그레이션:** `supabase/migrations/20251113000001_add_organizations.sql`
- **롤백:** `supabase/migrations/20251113000001_add_organizations_rollback.sql`

---

## 🎉 완료 기준

**✅ 마이그레이션 성공:**
- organizations 테이블 생성 확인
- announcements.organization_id 컬럼 추가 확인
- 기존 데이터 이관 확인

**✅ Admin 작동:**
- 기관 드롭다운 작동
- 리스트에 기관명 표시
- 필터 작동

**✅ Flutter 작동:**
- 리스트 조회 성공
- 카드에 기관명 표시
- 정렬 정상 작동

---

**작성일:** 2025-11-13
**버전:** v9.14.0
**다음:** Admin UI 완성 + Flutter 통합
