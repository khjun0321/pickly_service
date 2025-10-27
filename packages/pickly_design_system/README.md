# Pickly Design System

Pickly 서비스를 위한 종합 디자인 시스템 패키지입니다. Figma에서 추출한 디자인 토큰과 재사용 가능한 컴포넌트를 제공합니다.

## Features

- 🎨 **디자인 토큰**: 브랜드 컬러, 타이포그래피, 간격, 그림자 등
- 🧩 **재사용 가능한 위젯**: 버튼, 카드, 탭, 입력 필드 등
- 📐 **일관된 레이아웃**: 통일된 디자인 시스템
- 🚀 **Flutter 3.0+ 지원**

## Installation

`pubspec.yaml`에 추가:

```yaml
dependencies:
  pickly_design_system:
    path: ../../packages/pickly_design_system
```

## Usage

### 디자인 토큰 사용

```dart
import 'package:pickly_design_system/pickly_design_system.dart';

// 브랜드 컬러
Container(
  color: BrandColors.primary,
  child: Text(
    'Hello Pickly',
    style: PicklyTypography.titleLarge.copyWith(
      color: TextColors.inverse,
    ),
  ),
)

// 간격
Padding(
  padding: EdgeInsets.all(Spacing.lg),
  child: ...,
)

// 모서리
Container(
  decoration: BoxDecoration(
    borderRadius: PicklyBorderRadius.radiusMd,
  ),
)
```

### Typography (타이포그래피)

Figma Variables에서 추출한 정확한 타이포그래피 토큰:

```dart
// Title 스타일
Text('큰 제목', style: PicklyTypography.titleLarge);    // 22px, Bold
Text('중간 제목', style: PicklyTypography.titleMedium);  // 18px, Bold
Text('작은 제목', style: PicklyTypography.titleSmall);   // 17px, Bold ✨ NEW

// Body 스타일
Text('본문 대', style: PicklyTypography.bodyLarge);      // 16px, SemiBold
Text('본문 중', style: PicklyTypography.bodyMedium);     // 15px, SemiBold
Text('본문 소', style: PicklyTypography.bodySmall);      // 14px, SemiBold

// Caption 스타일
Text('캡션 대', style: PicklyTypography.captionLarge);   // 16px, SemiBold
Text('캡션 중', style: PicklyTypography.captionMidium);  // 14px, SemiBold ✨ NEW
Text('캡션 소', style: PicklyTypography.captionSmall);   // 12px, SemiBold

// Button 스타일
Text('버튼 대', style: PicklyTypography.buttonLarge);    // 16px, Bold
Text('버튼 중', style: PicklyTypography.buttonMedium);   // 14px, Bold
Text('버튼 소', style: PicklyTypography.buttonSmall);    // 12px, SemiBold
```

### 컴포넌트 사용

```dart
import 'package:pickly_design_system/pickly_design_system.dart';

// Primary Button
PrimaryButton(
  onPressed: () {},
  text: '확인',
)

// 정책 카드
PolicyListCard(
  title: '청년 주거 지원',
  organization: 'LH 한국토지주택공사',
  daysLeft: 15,
  viewCount: 1234,
  onTap: () {},
)

// 탭
FilterTab(
  label: '전체',
  isSelected: true,
  onTap: () {},
)
```

### 색상 시스템

```dart
// 브랜드 컬러
BrandColors.primary     // #27B473 (녹색 메인)
BrandColors.secondary   // #327DFF (파란색)

// 텍스트 컬러
TextColors.primary      // #3E3E3E (기본 텍스트)
TextColors.secondary    // #828282 (보조 텍스트)
TextColors.active       // #27B473 (활성 텍스트)

// 배경 컬러
BackgroundColors.app    // #F4F4F4 (앱 배경)
BackgroundColors.surface // #FFFFFF (표면)

// 테두리 컬러
BorderColors.subtle     // #EBEBEB (미묘한 테두리)
BorderColors.active     // #27B473 (활성 테두리)
```

### 간격 (Spacing)

```dart
Spacing.xs      // 4px
Spacing.sm      // 8px
Spacing.md      // 12px
Spacing.lg      // 16px
Spacing.xl      // 20px
Spacing.xxl     // 24px
Spacing.xxxl    // 32px
```

### 모서리 (Border Radius)

```dart
PicklyBorderRadius.radiusSm    // 4px
PicklyBorderRadius.radiusMd    // 8px
PicklyBorderRadius.radiusLg    // 13.5px
PicklyBorderRadius.radiusXl    // 16px
PicklyBorderRadius.radiusFull  // 9999px (완전한 원)
```

## Typography Details

### 새로 추가된 타이포그래피 (2024-10-24)

#### title/small
- **Font**: Pretendard Bold
- **Size**: 17px
- **Line Height**: 24px
- **용도**: 중간 크기의 제목, 섹션 헤더

#### caption/midium
- **Font**: Pretendard SemiBold
- **Size**: 14px
- **Line Height**: 20px
- **용도**: 본문보다 작은 설명 텍스트, 메타 정보

## 편의 클래스 - PicklyTokens

모든 토큰을 하나의 네임스페이스로 접근:

```dart
PicklyTokens.brand.primary
PicklyTokens.typography.titleSmall
PicklyTokens.spacing.lg
PicklyTokens.borderRadius.radiusMd
PicklyTokens.shadows.card
```

## 개발 가이드

### 새 컴포넌트 추가

1. `lib/widgets/` 아래 적절한 카테고리에 파일 생성
2. `lib/pickly_design_system.dart`에 export 추가
3. 예제 작성

### 디자인 토큰 업데이트

1. Figma Variables에서 최신 값 확인
2. `lib/tokens/design_tokens.dart` 업데이트
3. 문서 업데이트

## Additional Information

- **개발자**: Pickly Team
- **버전**: 1.0.0
- **Flutter SDK**: >=3.9.0 <4.0.0
- **라이선스**: MIT

### 이슈 및 기여

문제 발견 시 GitHub Issues에 등록해주세요.

### 업데이트 내역

- **2024-10-24**: titleSmall, captionMidium 타이포그래피 추가
- **2024-09-28**: 초기 디자인 시스템 구축
