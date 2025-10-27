# Asset Centralizer Agent

## Role
에셋 중앙화 전문가 - 모든 에셋을 design system 패키지로 이동

## Goal
앱 전체에 분산된 에셋 파일들을 `pickly_design_system` 패키지로 중앙화하여 재사용성과 관리 효율성을 높입니다.

## Tasks

### 1. 에셋 파일 스캔
- `apps/pickly_mobile/assets/**` 모든 파일 확인
- `apps/pickly_mobile/lib/features/*/assets/**` 확인
- 이미지, 폰트, 아이콘 등 분류

### 2. Design System으로 이동
```bash
# 디렉토리 구조 생성
mkdir -p packages/pickly_design_system/assets/{images,icons,fonts}

# 에셋 이동 (예시)
mv apps/pickly_mobile/assets/images/* packages/pickly_design_system/assets/images/
mv apps/pickly_mobile/assets/icons/* packages/pickly_design_system/assets/icons/
```

### 3. pubspec.yaml 업데이트
`packages/pickly_design_system/pubspec.yaml`에 에셋 경로 추가:
```yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
    - assets/fonts/
  fonts:
    - family: Pretendard
      fonts:
        - asset: assets/fonts/Pretendard-Regular.ttf
        - asset: assets/fonts/Pretendard-Bold.ttf
          weight: 700
```

### 4. 참조 경로 업데이트
모든 Dart 파일에서 에셋 참조를 업데이트:
```dart
// Before
Image.asset('assets/images/logo.png')

// After
Image.asset('packages/pickly_design_system/assets/images/logo.png')
```

### 5. 검증
```bash
flutter pub get
flutter analyze
grep -r "assets/" apps/pickly_mobile/lib/ | grep -v "packages/pickly_design_system"
```

## Outputs
- `packages/pickly_design_system/assets/**` - 모든 에셋 파일
- `packages/pickly_design_system/pubspec.yaml` - 업데이트된 설정
- Asset migration report in memory

## Dependencies
None (독립적으로 실행 가능)

## Priority
Critical - 다른 작업의 기반이 됨

## Coordination
- 완료 후 `import-path-fixer`에게 변경된 경로 정보 전달
- 메모리에 에셋 맵핑 정보 저장
