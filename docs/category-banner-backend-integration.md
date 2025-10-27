# Category Banner Backend Integration Guide

## 개요

각 카테고리별로 다른 광고 배너를 표시하고 백오피스(Admin Panel)에서 관리할 수 있는 시스템입니다.

## 현재 구현 상태

### ✅ 완료된 항목

1. **데이터 모델** (`CategoryBanner`)
   - 파일: `lib/features/benefits/models/category_banner.dart`
   - 필드: id, categoryId, title, subtitle, imageUrl, backgroundColor, actionUrl, displayOrder, isActive

2. **Mock 데이터 Provider**
   - 파일: `lib/features/benefits/providers/mock_banner_data.dart`
   - 9개 카테고리별 mock 데이터 제공

3. **Riverpod Provider**
   - 파일: `lib/features/benefits/providers/category_banner_provider.dart`
   - 카테고리별 배너 필터링 지원
   - 캐싱 및 상태 관리

4. **UI 통합**
   - `PopularCategoryContent` - 인기 탭
   - `HousingCategoryContent` - 주거 탭
   - PageView로 여러 배너 스와이프 가능

## 지원되는 카테고리

| Category ID | 한글명 | Mock 배너 수 |
|------------|--------|--------------|
| `popular` | 인기 | 3개 |
| `housing` | 주거 | 3개 |
| `education` | 교육 | 2개 |
| `support` | 지원 | 3개 |
| `transportation` | 교통 | 2개 |
| `welfare` | 복지 | 3개 |

## 백오피스 통합을 위한 Supabase 스키마

### 1. 테이블 생성

```sql
-- Category Banners Table
CREATE TABLE category_banners (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id TEXT NOT NULL,
  title TEXT NOT NULL,
  subtitle TEXT NOT NULL,
  image_url TEXT NOT NULL,
  background_color TEXT NOT NULL DEFAULT '#074D43',
  action_url TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_category_banners_category ON category_banners(category_id);
CREATE INDEX idx_category_banners_active ON category_banners(is_active);
CREATE INDEX idx_category_banners_order ON category_banners(display_order);

-- RLS (Row Level Security)
ALTER TABLE category_banners ENABLE ROW LEVEL SECURITY;

-- Public read access (anyone can view active banners)
CREATE POLICY "Anyone can view active banners"
  ON category_banners FOR SELECT
  USING (is_active = true);

-- Admin write access (only authenticated admins can modify)
CREATE POLICY "Admins can manage banners"
  ON category_banners FOR ALL
  USING (auth.role() = 'authenticated');
```

### 2. 초기 데이터 삽입 (선택사항)

```sql
-- 인기 카테고리 배너
INSERT INTO category_banners (category_id, title, subtitle, image_url, background_color, action_url, display_order)
VALUES
  ('popular', '청년도약계좌', '월 최대 70만원 저축 시 정부지원금 최대 6천만원', 'https://your-cdn.com/banners/youth-account.png', '#2196F3', '/policies/youth-account', 1),
  ('popular', '국민취업지원제도', '구직활동 지원금 월 최대 50만원', 'https://your-cdn.com/banners/employment.png', '#4CAF50', '/policies/employment-support', 2);

-- 주거 카테고리 배너
INSERT INTO category_banners (category_id, title, subtitle, image_url, background_color, action_url, display_order)
VALUES
  ('housing', '청년전세대출', '최대 1억원, 연 1.8% 저금리', 'https://your-cdn.com/banners/jeonse.png', '#9C27B0', '/policies/jeonse-loan', 1),
  ('housing', '신혼부부 행복주택', '시세 60-80% 공공임대주택', 'https://your-cdn.com/banners/happy-house.png', '#E91E63', '/policies/happy-house', 2);

-- 추가 카테고리 배너들도 동일한 방식으로 삽입
```

## App 코드 수정 사항 (Supabase 연동)

### 1. Repository 생성

`lib/features/benefits/repositories/category_banner_repository.dart` 파일 생성:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pickly_mobile/features/benefits/models/category_banner.dart';

class CategoryBannerRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all active banners
  Future<List<CategoryBanner>> fetchActiveBanners() async {
    final response = await _supabase
        .from('category_banners')
        .select()
        .eq('is_active', true)
        .order('display_order', ascending: true);

    return (response as List)
        .map((json) => CategoryBanner.fromJson(json))
        .toList();
  }

  /// Fetch banners for specific category
  Future<List<CategoryBanner>> fetchBannersByCategory(String categoryId) async {
    final response = await _supabase
        .from('category_banners')
        .select()
        .eq('category_id', categoryId)
        .eq('is_active', true)
        .order('display_order', ascending: true);

    return (response as List)
        .map((json) => CategoryBanner.fromJson(json))
        .toList();
  }
}
```

### 2. Provider 수정

`lib/features/benefits/providers/category_banner_provider.dart`에서 mock 데이터 대신 Supabase 사용:

```dart
// Line 32-42 교체
Future<List<CategoryBanner>> _fetchBanners() async {
  try {
    // Supabase에서 실제 데이터 가져오기
    final repository = CategoryBannerRepository();
    final banners = await repository.fetchActiveBanners();

    debugPrint('✅ Loaded ${banners.length} category banners from Supabase');
    return banners;
  } catch (e, stackTrace) {
    debugPrint('❌ Error fetching banners: $e');
    // Fallback to mock data if Supabase fails
    return MockBannerData.getAllBanners();
  }
}
```

## 백오피스 Admin Panel 기능 요구사항

### 필수 기능

1. **배너 목록 관리**
   - 모든 배너 조회 (카테고리별 필터링)
   - 활성/비활성 상태 토글
   - 정렬 순서 변경 (Drag & Drop)

2. **배너 생성/수정**
   - 카테고리 선택 (dropdown)
   - 제목, 부제 입력
   - 이미지 업로드 (CDN 연동)
   - 배경색 선택 (color picker)
   - 액션 URL 입력
   - 표시 순서 설정
   - 활성화 여부 체크박스

3. **배너 삭제**
   - Soft delete (is_active = false) 권장
   - 또는 Hard delete (완전 삭제)

4. **미리보기**
   - 실제 앱 화면처럼 배너 렌더링

### 선택 기능 (Phase 2)

1. **스케줄링**
   - 시작일/종료일 설정
   - 자동 활성화/비활성화

2. **분석**
   - 배너 클릭률 (CTR)
   - 노출수 (Impressions)
   - 카테고리별 성과 분석

3. **A/B 테스팅**
   - 여러 버전 배너 동시 테스트
   - 성과 기반 자동 전환

## 이미지 관리

### 권장 사양
- **크기**: 400x200px (2:1 비율)
- **포맷**: PNG, JPG, WebP
- **용량**: 200KB 이하
- **저장소**: Supabase Storage 또는 CDN

### Supabase Storage 설정

```sql
-- Storage bucket 생성
INSERT INTO storage.buckets (id, name, public)
VALUES ('category-banners', 'category-banners', true);

-- Public access policy
CREATE POLICY "Public banner images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'category-banners');

-- Admin upload policy
CREATE POLICY "Admins can upload banners"
  ON storage.objects FOR INSERT
  USING (bucket_id = 'category-banners' AND auth.role() = 'authenticated');
```

## 테스트 방법

### 1. Mock 데이터로 테스트 (현재)
```dart
final banners = MockBannerData.getBannersByCategory('popular');
// 3개의 mock 배너 반환
```

### 2. Supabase 연동 후 테스트
```bash
# Supabase 로컬 환경 시작
supabase start

# 테이블 생성
supabase db reset

# 앱 실행
flutter run
```

## 배포 체크리스트

- [ ] Supabase 프로젝트 생성
- [ ] `category_banners` 테이블 생성
- [ ] RLS 정책 설정
- [ ] Storage bucket 생성
- [ ] Admin panel 구축
- [ ] 초기 배너 데이터 삽입
- [ ] App에서 Repository 통합
- [ ] 테스트 (각 카테고리별 배너 확인)
- [ ] 운영 배포

## 문의 사항

기술적 문의나 추가 기능 요청은 개발팀에 문의해주세요.
