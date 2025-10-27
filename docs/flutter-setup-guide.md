# Flutter 앱 설정 가이드 - LH API 통합

## 📦 필요한 패키지 추가

`apps/pickly_mobile/pubspec.yaml`에 다음 패키지를 추가하세요:

```yaml
dependencies:
  # 기존 패키지들...

  # 상태 관리
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # 데이터 모델
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

  # 날짜/시간 포맷
  intl: ^0.19.0

  # URL 런처 (외부 링크)
  url_launcher: ^6.3.0

  # Supabase (이미 있을 수 있음)
  supabase_flutter: ^2.5.6

dev_dependencies:
  # 기존 dev 패키지들...

  # 코드 생성
  build_runner: ^2.4.11
  freezed: ^2.5.2
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.0
```

## 🔧 설치 및 코드 생성

### 1. 패키지 설치
```bash
cd apps/pickly_mobile
flutter pub get
```

### 2. 코드 생성 (필수!)
```bash
# 모든 *.g.dart 및 *.freezed.dart 파일 생성
dart run build_runner build --delete-conflicting-outputs
```

**예상 생성 파일**:
- `lib/contexts/benefit/models/announcement.freezed.dart`
- `lib/contexts/benefit/models/announcement.g.dart`
- `lib/contexts/benefit/repositories/announcement_repository.g.dart`
- `lib/features/benefit/providers/announcement_provider.g.dart`

### 3. 코드 생성 감시 모드 (개발 중 사용)
```bash
# 파일 변경 시 자동 재생성
dart run build_runner watch --delete-conflicting-outputs
```

## 🚀 사용 방법

### 1. Supabase 초기화 확인

`lib/main.dart`에서 Supabase가 초기화되어 있는지 확인:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(const ProviderScope(child: MyApp()));
}
```

### 2. 공고 목록 화면 사용

```dart
import 'package:pickly_mobile/features/benefit/screens/announcement_list_screen.dart';

// 주거 카테고리 공고 목록 화면
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => AnnouncementListScreen(
      categoryId: 'housing-category-uuid',
      categoryName: '주거',
    ),
  ),
);
```

### 3. 인기 공고 위젯 사용

```dart
import 'package:pickly_mobile/features/benefit/providers/announcement_provider.dart';
import 'package:pickly_mobile/features/benefit/widgets/announcement_card.dart';

class PopularAnnouncementsWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popularAsync = ref.watch(
      popularAnnouncementsProvider(limit: 5),
    );

    return popularAsync.when(
      data: (announcements) => ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          return AnnouncementCard(
            announcement: announcements[index],
            onTap: () {
              // 상세 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AnnouncementDetailScreen(
                    announcementId: announcements[index].id,
                  ),
                ),
              );
            },
          );
        },
      ),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('오류: $err'),
    );
  }
}
```

### 4. 실시간 스트림 사용

```dart
import 'package:pickly_mobile/features/benefit/providers/announcement_provider.dart';

class RealtimeAnnouncementsScreen extends ConsumerWidget {
  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsStream = ref.watch(
      announcementsStreamProvider(categoryId),
    );

    return announcementsStream.when(
      data: (announcements) => ListView(
        children: announcements.map((a) =>
          ListTile(title: Text(a.title))
        ).toList(),
      ),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('오류: $err'),
    );
  }
}
```

## 🎨 커스터마이징

### 공고 카드 스타일 변경

`lib/features/benefit/widgets/announcement_card.dart`를 수정하여 원하는 디자인 적용

### 상태별 색상 변경

`lib/contexts/benefit/models/announcement.dart`의 `AnnouncementStatus` enum에서 `colorHex` 값 수정

## 🐛 트러블슈팅

### 1. "Target of URI hasn't been generated" 에러

**원인**: 코드 생성이 되지 않음

**해결**:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 2. "The imported package 'xxx' isn't a dependency" 에러

**원인**: `pubspec.yaml`에 패키지 미추가

**해결**:
```bash
flutter pub add freezed_annotation
flutter pub add riverpod_annotation
flutter pub add intl
flutter pub add url_launcher
flutter pub add --dev build_runner
flutter pub add --dev freezed
flutter pub add --dev riverpod_generator
flutter pub get
```

### 3. Supabase 연결 오류

**원인**: Supabase URL/Key 미설정

**해결**:
```dart
// .env 파일 또는 main.dart에서 확인
await Supabase.initialize(
  url: 'http://127.0.0.1:54321', // 로컬 개발
  anonKey: 'YOUR_ANON_KEY',
);
```

## 📱 테스트

### 단위 테스트 실행
```bash
flutter test
```

### 통합 테스트
```bash
flutter test integration_test
```

### 앱 실행
```bash
flutter run
```

## 📚 참고 자료

- [Riverpod 문서](https://riverpod.dev/)
- [Freezed 문서](https://pub.dev/packages/freezed)
- [Supabase Flutter 문서](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)

---

**마지막 업데이트**: 2024-10-24
