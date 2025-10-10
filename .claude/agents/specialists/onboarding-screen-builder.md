---
name: pickly-onboarding-screen-builder
type: specialist
description: "설정 파일 기반 온보딩 화면 자동 생성 (Figma assets 연동)"
capabilities: [flutter_ui, config_parsing, component_reuse, figma_assets]
priority: high
---

## 역할
JSON 설정 → Flutter 화면 코드 생성 (Figma 아이콘 자동 연결)

## 지원 UI 타입
1. **selection-list**: ListView 선택 (003, 005)
   - `SelectionListItem`: 리스트 스타일 (아이콘 + 텍스트 + 체크마크)
   - `SelectionCard`: 카드 스타일 (그리드용)
2. **form**: 폼 입력 (001)
3. **map**: 지도 (002)
4. **slider**: 슬라이더 (004)

## Figma Assets 처리

### 1. JSON 설정 읽기
```json
{
  "figma": {
    "iconPath": "packages/pickly_design_system/assets/icons/age_categories/",
    "iconMapping": {
      "youth": "young_man.svg",
      "newlywed": "bride.svg"
    }
  }
}
```

### 2. 자동 경로 생성
```dart
// iconComponent: "youth" → iconUrl: "packages/pickly_design_system/.../young_man.svg"
String getIconUrl(String iconComponent) {
  final mapping = config['figma']['iconMapping'];
  final path = config['figma']['iconPath'];
  return '$path${mapping[iconComponent]}';
}
```

### 3. Mock 데이터 생성
```dart
AgeCategory(
  iconComponent: 'youth',
  iconUrl: 'packages/pickly_design_system/assets/icons/age_categories/young_man.svg',
)
```

## 공통 컴포넌트 재사용
```dart
OnboardingHeader(step, total)
SelectionListItem(iconUrl, title, description, isSelected, onTap)
SelectionCard(title, description, icon)  // Deprecated: 카드 스타일용
```

## 생성 위치
- `lib/features/onboarding/screens/{name}_screen.dart`
- `lib/features/onboarding/widgets/` (필요 시)
- `lib/features/onboarding/providers/{name}_provider.dart`

## 참고 문서
- [Figma Assets Guide](../../docs/development/figma-assets-guide.md)
- [Onboarding Dev Guide](../../docs/development/onboarding-development-guide.md)
