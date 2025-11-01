# PRD v8.1 Integration Guide

## 목적
PRD v8.1 혜택 통합관리 시스템의 각 컴포넌트 통합 가이드

---

## 1. 환경 설정

### Supabase 설정
```bash
cd backend
supabase start
supabase db reset --local
```

### Admin 설정
```bash
cd apps/pickly_admin
npm install
npm run dev
```

### Mobile 설정
```bash
cd apps/pickly_mobile
flutter pub get
flutter run
```

---

## 2. 데이터베이스 통합

### 마이그레이션 실행
```bash
# 로컬 개발
supabase db reset --local

# 프로덕션 배포
supabase db push
```

### 초기 데이터 확인
```sql
-- 카테고리 확인
SELECT * FROM benefit_categories ORDER BY sort_order;

-- 공고 확인
SELECT * FROM benefit_announcements
WHERE application_end_date > NOW()
ORDER BY created_at DESC;
```

---

## 3. Admin 통합

### API 클라이언트 설정
```typescript
// apps/pickly_admin/src/lib/supabase.ts
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseKey)
```

### 환경변수 (.env.local)
```env
VITE_SUPABASE_URL=http://127.0.0.1:54321
VITE_SUPABASE_ANON_KEY=your_anon_key_here
VITE_BYPASS_AUTH=true  # 개발용
```

### 라우팅 설정
```typescript
// apps/pickly_admin/src/App.tsx
import { BenefitManagementPage } from './pages/benefits/BenefitManagementPage'

<Route path="/benefits" element={<BenefitManagementPage />} />
```

---

## 4. Mobile 통합

### Supabase 클라이언트
```dart
// apps/pickly_mobile/lib/core/network/supabase_client.dart
import 'package:supabase_flutter/supabase_flutter.dart';

await Supabase.initialize(
  url: 'http://127.0.0.1:54321',
  anonKey: 'your_anon_key',
);

final supabase = Supabase.instance.client;
```

### Provider 등록
```dart
// apps/pickly_mobile/lib/main.dart
ProviderScope(
  overrides: [
    benefitCategoryProvider,
    benefitRealtimeStreamProvider,
  ],
  child: MyApp(),
);
```

### 화면 네비게이션
```dart
// 혜택 화면으로 이동
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const BenefitsScreen(),
  ),
);
```

---

## 5. 파일 업로드 통합

### Admin 업로드
```typescript
import { uploadBenefitBanner } from '@/utils/storage'

const handleUpload = async (file: File) => {
  try {
    const result = await uploadBenefitBanner(file)
    console.log('Uploaded:', result.url)
  } catch (error) {
    console.error('Upload failed:', error)
  }
}
```

### Storage 버킷 생성
```sql
-- Supabase Storage 버킷 설정
INSERT INTO storage.buckets (id, name, public)
VALUES
  ('benefit-banners', 'benefit-banners', true),
  ('benefit-thumbnails', 'benefit-thumbnails', true),
  ('benefit-icons', 'benefit-icons', true);
```

---

## 6. Realtime 통합

### Mobile 구독
```dart
final realtimeProvider = ref.watch(benefitRealtimeStreamProvider);

realtimeProvider.when(
  data: (announcements) => ListView.builder(
    itemCount: announcements.length,
    itemBuilder: (context, index) {
      return AnnouncementCard(announcement: announcements[index]);
    },
  ),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);
```

### Admin 알림
```typescript
// Realtime 변경 감지
supabase
  .channel('benefit_changes')
  .on('postgres_changes',
    { event: '*', schema: 'public', table: 'benefit_announcements' },
    (payload) => {
      console.log('Change detected:', payload)
      // UI 자동 업데이트
    }
  )
  .subscribe()
```

---

## 7. 테스트 통합

### Admin E2E 테스트
```typescript
// tests/e2e/benefit-management.spec.ts
describe('Benefit Management', () => {
  it('should create new announcement', async () => {
    await page.goto('/benefits')
    await page.click('[data-testid="new-announcement"]')
    await page.fill('[name="title"]', 'Test Announcement')
    await page.click('[type="submit"]')

    await expect(page.locator('text=Test Announcement')).toBeVisible()
  })
})
```

### Mobile Widget 테스트
```dart
// test/features/benefits/announcement_card_test.dart
void main() {
  testWidgets('AnnouncementCard displays data correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AnnouncementCard(
          announcement: testAnnouncement,
        ),
      ),
    );

    expect(find.text('Test Title'), findsOneWidget);
  });
}
```

---

## 8. 배포 통합

### Supabase 프로덕션
```bash
# 프로덕션 마이그레이션
supabase db push --project-ref your-project-ref

# Storage 정책 확인
supabase storage policies list
```

### Admin 배포 (Vercel)
```bash
npm run build
vercel --prod
```

### Mobile 배포
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

---

## 9. 모니터링 통합

### Supabase Dashboard
- 테이블 데이터 확인: https://app.supabase.com/project/your-project/editor
- Realtime 모니터링: https://app.supabase.com/project/your-project/database/realtime
- Storage 사용량: https://app.supabase.com/project/your-project/storage

### 로그 수집
```typescript
// Admin
import * as Sentry from '@sentry/react'

Sentry.captureException(error)
```

```dart
// Mobile
import 'package:sentry_flutter/sentry_flutter.dart';

await Sentry.captureException(error);
```

---

## 10. 트러블슈팅

### 401 Unauthorized
```bash
# Supabase anon key 확인
supabase status | grep anon

# .env 파일 재확인
cat apps/pickly_admin/.env.local
```

### Realtime 연결 실패
```typescript
// Realtime 연결 상태 확인
const channel = supabase.channel('test')
channel.subscribe((status) => {
  console.log('Realtime status:', status)
})
```

### 파일 업로드 실패
```typescript
// Storage 버킷 권한 확인
const { data, error } = await supabase.storage
  .from('benefit-banners')
  .list()

if (error) console.error('Storage error:', error)
```

---

## 참고 자료
- [Supabase Documentation](https://supabase.com/docs)
- [React Query Guide](https://tanstack.com/query/latest/docs/react/overview)
- [Riverpod Documentation](https://riverpod.dev)
- [Flutter Supabase Integration](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
