# Figma Assets Integration Guide

> **Figma 디자인 → Flutter 에셋 연동 가이드**

---

## 🎨 개요

Pickly는 Figma 디자인 시스템의 아이콘과 이미지를 `pickly_design_system` 패키지로 관리합니다.
Claude Flow 에이전트가 자동으로 올바른 경로를 사용하도록 설정되어 있습니다.

---

## 📁 에셋 구조

```
packages/pickly_design_system/
├── assets/
│   ├── images/               # 로고, 일러스트
│   │   ├── mr_pick_logo.svg
│   │   └── pickly_logo_text.svg
│   │
│   └── icons/                # 카테고리별 아이콘
│       └── age_categories/   # 연령/세대 아이콘
│           ├── young_man.svg      # 청년
│           ├── bride.svg          # 신혼부부
│           ├── baby.svg           # 육아 부모
│           ├── kinder.svg         # 다자녀
│           ├── old_man.svg        # 어르신
│           └── wheel_chair.svg    # 장애인
│
└── pubspec.yaml
```

---

## 🔧 에셋 등록 방법

### 1. Figma에서 SVG 내보내기

1. Figma에서 아이콘 선택
2. **Export** → **SVG** 선택
3. **Include "id" attribute** 체크 해제
4. 다운로드

### 2. 파일명 규칙

- **소문자 + 언더스코어** 사용
- 의미있는 이름 (e.g., `young_man.svg`, `bride.svg`)
- Figma 컴포넌트 이름과 매칭

### 3. 에셋 추가

```bash
# 적절한 폴더에 저장
cp ~/Downloads/icon.svg packages/pickly_design_system/assets/icons/age_categories/

# pubspec.yaml 업데이트 (필요 시)
vim packages/pickly_design_system/pubspec.yaml
```

### 4. pubspec.yaml 확인

```yaml
flutter:
  uses-material-design: true

  assets:
    - assets/images/
    - assets/icons/age_categories/
```

---

## 🎯 Flutter에서 사용

### 방법 1: SelectionCard/SelectionListItem 사용

```dart
SelectionListItem(
  iconUrl: 'packages/pickly_design_system/assets/icons/age_categories/young_man.svg',
  title: '청년',
  description: '만 19세-39세',
  isSelected: isSelected,
  onTap: onTap,
)
```

### 방법 2: 직접 SvgPicture 사용

```dart
import 'package:flutter_svg/flutter_svg.dart';

SvgPicture.asset(
  'packages/pickly_design_system/assets/icons/age_categories/bride.svg',
  width: 32,
  height: 32,
  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
)
```

---

## 📋 Claude Flow 설정 규칙

### 1. 화면 설정 JSON에 아이콘 매핑 추가

**파일**: `.claude/screens/003-age-category.json`

```json
{
  "id": "003",
  "name": "age-category",
  "title": "현재 연령 및 세대 기준을 선택해주세요",

  "dataSource": {
    "table": "age_categories",
    "type": "realtime"
  },

  "ui": {
    "type": "selection-list",
    "component": "SelectionListItem"
  },

  "figma": {
    "componentSet": "Age Categories",
    "iconPath": "packages/pickly_design_system/assets/icons/age_categories/",
    "iconMapping": {
      "youth": "young_man.svg",
      "newlywed": "bride.svg",
      "parenting": "baby.svg",
      "multi_child": "kinder.svg",
      "elderly": "old_man.svg",
      "disability": "wheel_chair.svg"
    }
  }
}
```

### 2. 데이터베이스 스키마

**age_categories 테이블**:

| 컬럼 | 타입 | 설명 |
|------|------|------|
| icon_component | text | Figma 컴포넌트 ID (e.g., "youth") |
| icon_url | text | SVG 경로 (nullable) |

```sql
-- Migration
CREATE TABLE age_categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  icon_component text NOT NULL,  -- Figma component ID
  icon_url text,                  -- Full SVG path
  min_age int,
  max_age int,
  sort_order int NOT NULL DEFAULT 0,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
```

### 3. Provider Mock 데이터

```dart
List<AgeCategory> _getMockCategories() {
  final now = DateTime.now();
  return [
    AgeCategory(
      id: 'mock-1',
      title: '청년',
      description: '만 19세-39세 대학생, 취업준비생, 직장인',
      iconComponent: 'youth',
      iconUrl: 'packages/pickly_design_system/assets/icons/age_categories/young_man.svg',
      minAge: 19,
      maxAge: 39,
      sortOrder: 1,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    ),
    // ... 나머지 카테고리
  ];
}
```

---

## 🤖 Claude Flow 에이전트 사용법

### Screen Builder 에이전트

**자동으로 수행하는 작업**:

1. JSON 설정의 `figma.iconMapping` 읽기
2. `iconComponent` → `iconUrl` 자동 변환
3. SelectionListItem에 올바른 경로 전달
4. Mock 데이터 생성 시 경로 포함

**에이전트 프롬프트 예시**:

```
화면 설정에 figma.iconMapping이 있으면:
1. iconComponent 값을 읽어서
2. iconMapping에서 파일명 찾기
3. iconPath + 파일명 = 전체 경로
4. iconUrl 필드에 저장
```

---

## 🚨 주의사항

### ✅ 올바른 경로

```dart
// ✅ 패키지 경로 사용
'packages/pickly_design_system/assets/icons/age_categories/young_man.svg'

// ❌ 상대 경로 사용 X
'assets/icons/age_categories/young_man.svg'

// ❌ 절대 경로 사용 X
'/Users/.../packages/pickly_design_system/...'
```

### 파일 확인

```bash
# 에셋 파일 존재 확인
ls -la packages/pickly_design_system/assets/icons/age_categories/

# Flutter가 인식하는지 확인
flutter pub get
flutter run
```

### 에러 해결

**에러**: `Unable to load asset`

```bash
# 1. pubspec.yaml 확인
cat packages/pickly_design_system/pubspec.yaml

# 2. 파일 존재 확인
ls packages/pickly_design_system/assets/icons/age_categories/young_man.svg

# 3. 클린 빌드
flutter clean
flutter pub get
flutter run
```

---

## 📊 에셋 매핑 예시

### 연령/세대 카테고리

| Figma 컴포넌트 | icon_component | SVG 파일 | 설명 |
|----------------|----------------|----------|------|
| Youth | youth | young_man.svg | 청년 |
| Bride | newlywed | bride.svg | 신혼부부 |
| Baby | parenting | baby.svg | 육아 부모 |
| Kinder | multi_child | kinder.svg | 다자녀 |
| Old Man | elderly | old_man.svg | 어르신 |
| Wheelchair | disability | wheel_chair.svg | 장애인 |

---

## 🔄 워크플로우

### 새 아이콘 추가 시

1. **Figma에서 내보내기** → SVG 다운로드
2. **파일명 정규화** → `young_man.svg`
3. **에셋 폴더에 저장** → `packages/pickly_design_system/assets/icons/age_categories/`
4. **JSON 설정 업데이트** → `figma.iconMapping` 추가
5. **데이터베이스 업데이트** → `icon_component`, `icon_url` 설정
6. **Claude Flow 실행** → 자동으로 올바른 경로 사용

---

## 📚 참고 문서

- [온보딩 개발 가이드](./onboarding-development-guide.md)
- [디자인 시스템 패키지](../../packages/pickly_design_system/)
- [Screen Config Schema](../api/screen-config-schema.md)
- [Figma 디자인](https://www.figma.com/design/xOpx8v3FiYmCxSLkj9sgcu/pickly)

---

✍️ 이 문서는 **Figma Assets Integration Guide**입니다.
