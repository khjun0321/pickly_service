/// Mock Category Banner Data
///
/// Provides mock banner data for development and testing.
/// Contains sample banners for all benefit categories.
library;

import 'package:pickly_mobile/features/benefits/models/category_banner.dart';

/// Mock banner data provider for development.
///
/// Contains realistic sample banners for each benefit category:
/// - 인기 (popular)
/// - 주거 (housing)
/// - 교육 (education)
/// - 지원 (support)
/// - 교통 (transportation)
/// - 복지 (welfare)
class MockBannerData {
  /// Private constructor to prevent instantiation
  MockBannerData._();

  /// Get mock banners for all categories
  static List<CategoryBanner> getAllBanners() {
    final now = DateTime.now();

    return [
      // Popular Category Banners (인기) - Test images
      CategoryBanner(
        id: 'mock-popular-1',
        categoryId: 'popular',
        title: '핫 배너 테스트 1',
        subtitle: '테스트 배너 이미지 1',
        imageUrl: 'assets/images/test/hot_banner_test_01.png',
        backgroundColor: '#2196F3',
        actionUrl: '/policies/test-banner-1',
        displayOrder: 1,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryBanner(
        id: 'mock-popular-2',
        categoryId: 'popular',
        title: '핫 배너 테스트 2',
        subtitle: '테스트 배너 이미지 2',
        imageUrl: 'assets/images/test/hot_banner_test_02.png',
        backgroundColor: '#4CAF50',
        actionUrl: '/policies/test-banner-2',
        displayOrder: 2,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryBanner(
        id: 'mock-popular-3',
        categoryId: 'popular',
        title: '핫 배너 테스트 3',
        subtitle: '테스트 배너 이미지 3',
        imageUrl: 'assets/images/test/hot_banner_test_03.png',
        backgroundColor: '#FF9800',
        actionUrl: '/policies/test-banner-3',
        displayOrder: 3,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      // Housing Category Banners (주거) - Test images
      CategoryBanner(
        id: 'mock-housing-1',
        categoryId: 'housing',
        title: '주거 배너 테스트 1',
        subtitle: '테스트 배너 이미지 1',
        imageUrl: 'assets/images/test/house_banner_test_01.png',
        backgroundColor: '#9C27B0',
        actionUrl: '/policies/housing-test-1',
        displayOrder: 1,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryBanner(
        id: 'mock-housing-2',
        categoryId: 'housing',
        title: '주거 배너 테스트 2',
        subtitle: '테스트 배너 이미지 2',
        imageUrl: 'assets/images/test/house_banner_test_02.png',
        backgroundColor: '#E91E63',
        actionUrl: '/policies/housing-test-2',
        displayOrder: 2,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryBanner(
        id: 'mock-housing-3',
        categoryId: 'housing',
        title: '주거 배너 테스트 3',
        subtitle: '테스트 배너 이미지 3',
        imageUrl: 'assets/images/test/house_banner_test_03.png',
        backgroundColor: '#3F51B5',
        actionUrl: '/policies/housing-test-3',
        displayOrder: 3,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      // Education Category Banners (교육)
      CategoryBanner(
        id: 'mock-education-1',
        categoryId: 'education',
        title: '국가장학금',
        subtitle: '학기당 최대 350만원 장학금',
        imageUrl: 'https://via.placeholder.com/400x200/00BCD4/FFFFFF?text=Scholarship',
        backgroundColor: '#00BCD4',
        actionUrl: '/policies/national-scholarship',
        displayOrder: 1,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryBanner(
        id: 'mock-education-2',
        categoryId: 'education',
        title: '첫째아이 대학등록금 전액 지원',
        subtitle: '2025년 신입생부터 등록금 전액 무상 지원',
        imageUrl: 'https://via.placeholder.com/400x200/8BC34A/FFFFFF?text=First+Child+Support',
        backgroundColor: '#8BC34A',
        actionUrl: '/policies/first-child-education',
        displayOrder: 2,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      // Support Category Banners (지원)
      CategoryBanner(
        id: 'mock-support-1',
        categoryId: 'support',
        title: '청년일자리도약장려금',
        subtitle: '중소기업 청년 채용 시 월 80만원 3년간 지원',
        imageUrl: 'https://via.placeholder.com/400x200/FF5722/FFFFFF?text=Job+Incentive',
        backgroundColor: '#FF5722',
        actionUrl: '/policies/job-incentive',
        displayOrder: 1,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryBanner(
        id: 'mock-support-2',
        categoryId: 'support',
        title: '청년창업지원',
        subtitle: '사업화 자금 최대 1억원',
        imageUrl: 'https://via.placeholder.com/400x200/607D8B/FFFFFF?text=Startup+Support',
        backgroundColor: '#607D8B',
        actionUrl: '/policies/startup-support',
        displayOrder: 2,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryBanner(
        id: 'mock-support-3',
        categoryId: 'support',
        title: '근로장려금',
        subtitle: '소득에 따라 최대 330만원 지급',
        imageUrl: 'https://via.placeholder.com/400x200/795548/FFFFFF?text=EITC',
        backgroundColor: '#795548',
        actionUrl: '/policies/eitc',
        displayOrder: 3,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      // Transportation Category Banners (교통)
      CategoryBanner(
        id: 'mock-transportation-1',
        categoryId: 'transportation',
        title: '청년 교통비 지원',
        subtitle: '월 대중교통비 최대 5만원 지원',
        imageUrl: 'https://via.placeholder.com/400x200/009688/FFFFFF?text=Transit+Support',
        backgroundColor: '#009688',
        actionUrl: '/policies/transit-support',
        displayOrder: 1,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryBanner(
        id: 'mock-transportation-2',
        categoryId: 'transportation',
        title: 'K-패스 출시',
        subtitle: '대중교통 할인율 최대 53%',
        imageUrl: 'https://via.placeholder.com/400x200/673AB7/FFFFFF?text=K-Pass',
        backgroundColor: '#673AB7',
        actionUrl: '/policies/k-pass',
        displayOrder: 2,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      // Welfare Category Banners (복지)
      CategoryBanner(
        id: 'mock-welfare-1',
        categoryId: 'welfare',
        title: '기초생활보장',
        subtitle: '생계·의료·주거·교육급여 지원',
        imageUrl: 'https://via.placeholder.com/400x200/F44336/FFFFFF?text=Basic+Livelihood',
        backgroundColor: '#F44336',
        actionUrl: '/policies/basic-livelihood',
        displayOrder: 1,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryBanner(
        id: 'mock-welfare-2',
        categoryId: 'welfare',
        title: '아동수당',
        subtitle: '만 8세 미만 아동 월 10만원',
        imageUrl: 'https://via.placeholder.com/400x200/FFEB3B/000000?text=Child+Allowance',
        backgroundColor: '#FFEB3B',
        actionUrl: '/policies/child-allowance',
        displayOrder: 2,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryBanner(
        id: 'mock-welfare-3',
        categoryId: 'welfare',
        title: '어르신 지원',
        subtitle: '기초연금 월 최대 32만원',
        imageUrl: 'https://via.placeholder.com/400x200/9E9E9E/FFFFFF?text=Senior+Pension',
        backgroundColor: '#9E9E9E',
        actionUrl: '/policies/senior-pension',
        displayOrder: 3,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  /// Get banners for a specific category
  ///
  /// Returns list of active banners sorted by displayOrder.
  /// Returns empty list if categoryId is not found.
  ///
  /// Example:
  /// ```dart
  /// final popularBanners = MockBannerData.getBannersByCategory('popular');
  /// ```
  static List<CategoryBanner> getBannersByCategory(String categoryId) {
    return getAllBanners()
        .where((banner) => banner.categoryId == categoryId && banner.isActive)
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
  }

  /// Get all available category IDs
  static List<String> getAvailableCategories() {
    return [
      'popular',
      'housing',
      'education',
      'support',
      'transportation',
      'welfare',
    ];
  }

  /// Get count of banners for a specific category
  static int getBannerCount(String categoryId) {
    return getBannersByCategory(categoryId).length;
  }
}
