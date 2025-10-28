import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pickly_design_system/pickly_design_system.dart';
import 'package:pickly_mobile/core/router.dart';
import 'package:pickly_mobile/features/onboarding/providers/onboarding_storage_provider.dart';
import 'package:pickly_mobile/features/onboarding/providers/region_provider.dart';
import 'package:pickly_mobile/features/onboarding/providers/age_category_provider.dart';
import 'package:pickly_mobile/features/benefits/widgets/popular_category_content.dart';
import 'package:pickly_mobile/features/benefits/widgets/housing_category_content.dart';
import 'package:pickly_mobile/features/benefits/widgets/education_category_content.dart';
import 'package:pickly_mobile/features/benefits/widgets/support_category_content.dart';
import 'package:pickly_mobile/features/benefits/widgets/transportation_category_content.dart';
import 'package:pickly_mobile/features/benefits/providers/category_banner_provider.dart';
import 'package:pickly_mobile/features/benefits/providers/category_id_provider.dart';

/// Benefits screen (혜택 화면)
///
/// Displays available benefits and promotions for users
class BenefitsScreen extends ConsumerStatefulWidget {
  const BenefitsScreen({super.key});

  @override
  ConsumerState<BenefitsScreen> createState() => _BenefitsScreenState();
}

class _BenefitsScreenState extends ConsumerState<BenefitsScreen> {
  int _selectedCategoryIndex = 0; // 0 = 인기 탭
  final Map<int, List<String>> _selectedProgramTypes = {}; // 탭별 선택된 공고 타입 (여러 개 가능)

  @override
  void initState() {
    super.initState();
    // 저장된 공고 타입 불러오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedProgramTypes();
    });
  }

  /// Load saved program types from storage
  void _loadSavedProgramTypes() {
    final storage = ref.read(onboardingStorageServiceProvider);
    final savedTypes = storage.getAllSelectedProgramTypes();

    setState(() {
      // Convert category IDs to indices and populate the map
      for (final entry in savedTypes.entries) {
        final categoryId = entry.key;
        final programTypes = entry.value;

        // Find the index for this category ID
        final index = _getCategoryIndexFromId(categoryId);
        if (index != null) {
          _selectedProgramTypes[index] = programTypes;
        }
      }
    });
  }

  /// Get category index from category ID
  int? _getCategoryIndexFromId(String categoryId) {
    switch (categoryId) {
      case 'popular': return 0;
      case 'housing': return 1;
      case 'education': return 2;
      case 'health': return 3;
      case 'transportation': return 4;
      case 'welfare': return 5;
      case 'employment': return 6;
      case 'support': return 7;
      case 'culture': return 8;
      default: return null;
    }
  }

  /// Get icon path for a selected program type
  String _getIconForProgramType(String programTypeName) {
    final programTypes = _programTypesByCategory[_selectedCategoryIndex] ?? [];

    for (final type in programTypes) {
      if (type['title'] == programTypeName) {
        return type['icon'] ?? 'assets/icons/all.svg';
      }
    }

    return 'assets/icons/all.svg'; // fallback
  }

  // 탭별 공고 타입 목록
  final Map<int, List<Map<String, String>>> _programTypesByCategory = {
    0: [], // 인기: 공고 선택 없음 (전체만)
    1: [ // 주거
      {'icon': 'assets/icons/happy_apt.svg', 'title': '행복주택'},
      {'icon': 'assets/icons/apt.svg', 'title': '국민임대주택'},
      {'icon': 'assets/icons/home2.svg', 'title': '영구임대주택'},
      {'icon': 'assets/icons/building.svg', 'title': '공공임대주택'},
      {'icon': 'assets/icons/buy.svg', 'title': '매입임대주택'},
      {'icon': 'assets/icons/ring.svg', 'title': '신혼희망타운'},
    ],
    2: [ // 교육
      {'icon': 'assets/icons/school.svg', 'title': '학자금 지원'},
      {'icon': 'assets/icons/education.svg', 'title': '교육비 지원'},
    ],
    3: [ // 건강
      {'icon': 'assets/icons/health.svg', 'title': '건강 지원'},
    ],
    4: [ // 교통
      {'icon': 'assets/icons/transportation.svg', 'title': '교통비 지원'},
    ],
    5: [ // 복지
      {'icon': 'assets/icons/happy_apt.svg', 'title': '복지 혜택'},
    ],
    6: [ // 취업
      {'icon': 'assets/icons/dollar.svg', 'title': '취업 지원'},
    ],
    7: [ // 지원
      {'icon': 'assets/icons/dollar.svg', 'title': '면접비'},
      {'icon': 'assets/icons/buy.svg', 'title': '창업지원금'},
    ],
    8: [ // 문화
      {'icon': 'assets/icons/speaker.svg', 'title': '문화 지원'},
    ],
  };

  final List<Map<String, String>> _categories = [
    {'label': '인기', 'icon': 'assets/icons/popular.svg'},
    {'label': '주거', 'icon': 'assets/icons/housing.svg'},
    {'label': '교육', 'icon': 'assets/icons/education.svg'},
    {'label': '건강', 'icon': 'assets/icons/health.svg'},
    {'label': '교통', 'icon': 'assets/icons/transportation.svg'},
    {'label': '복지', 'icon': 'assets/icons/heart.svg'},
    {'label': '취업', 'icon': 'assets/icons/employment.svg'},
    {'label': '지원', 'icon': 'assets/icons/support.svg'},
    {'label': '문화', 'icon': 'assets/icons/culture.svg'},
  ];

  /// Get category ID by index for banner provider
  String _getCategoryId(int index) {
    switch (index) {
      case 0: return 'popular';
      case 1: return 'housing';
      case 2: return 'education';
      case 3: return 'health';
      case 4: return 'transportation';
      case 5: return 'welfare';
      case 6: return 'employment';
      case 7: return 'support';
      case 8: return 'culture';
      default: return 'popular';
    }
  }

  /// Build banner image widget (supports both network and asset images)
  Widget _buildBannerImage(String imageUrl) {
    final isAsset = imageUrl.startsWith('assets/');

    if (isAsset) {
      return Image.asset(
        imageUrl,
        package: 'pickly_design_system',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFFF5F5F5),
            child: const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 48,
                color: Color(0xFFDDDDDD),
              ),
            ),
          );
        },
      );
    } else {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFFF5F5F5),
            child: const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 48,
                color: Color(0xFFDDDDDD),
              ),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: const Color(0xFFF5F5F5),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = ref.watch(onboardingStorageServiceProvider);
    final ageCategoryId = storage.getSelectedAgeCategoryId();
    final regionIds = storage.getSelectedRegionIds();

    // Get actual names from providers
    final selectedRegion = regionIds.isNotEmpty
        ? ref.watch(regionByIdProvider(regionIds.first))
        : null;
    final selectedAgeCategory = ageCategoryId != null
        ? ref.watch(ageCategoryByIdProvider(ageCategoryId))
        : null;

    return Scaffold(
      backgroundColor: BackgroundColors.app,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            SizedBox(
              height: 60,
              child: Align(
                alignment: Alignment.center,
                child: AppHeader.home(
                  onMenuTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('메뉴 기능 준비 중')),
                    );
                  },
                ),
              ),
            ),

            // Spacing from top: SafeArea(~44) + Header(60) + SizedBox(12) = 116px
            const SizedBox(height: 12),

            // Category tabs (horizontal scroll)
            SizedBox(
              height: 72,
              child: ListView.separated(
                padding: const EdgeInsets.only(left: Spacing.lg),
                scrollDirection: Axis.horizontal,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isActive = _selectedCategoryIndex == index;

                  return TabCircleWithLabel(
                    iconPath: category['icon']!,
                    label: category['label']!,
                    state: isActive
                        ? TabCircleWithLabelState.active
                        : TabCircleWithLabelState.default_,
                    onTap: () {
                      setState(() {
                        _selectedCategoryIndex = index;
                      });
                    },
                  );
                },
              ),
            ),

            // Content - Scrollable area (banner + filter + content)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Image banner (swipeable in fixed container, category-specific)
                    Consumer(
                      builder: (context, ref, child) {
                        // Get banners for the currently selected category
                        final categoryId = _getCategoryId(_selectedCategoryIndex);
                        final banners = ref.watch(bannersByCategoryProvider(categoryId));

                        if (banners.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        // Fixed container with swipeable banner inside
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            height: 80,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: PageView.builder(
                              key: ValueKey(categoryId), // Reset PageView when category changes
                              itemCount: banners.length,
                              padEnds: false, // Don't add padding at the ends
                              clipBehavior: Clip.hardEdge, // Ensure proper clipping
                              pageSnapping: true, // Snap to pages
                              itemBuilder: (context, index) {
                                final banner = banners[index];
                                return GestureDetector(
                                  onTap: () {
                                    debugPrint('Banner tapped: ${banner.linkTarget}');
                                  },
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      // Banner image (fills the container)
                                      _buildBannerImage(banner.imageUrl),
                                      // Badge indicator
                                      if (banners.length > 1)
                                        Positioned(
                                          right: 16,
                                          bottom: 16,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0x66242424),
                                              borderRadius: BorderRadius.circular(100),
                                            ),
                                            child: Text(
                                              '${index + 1}/${banners.length}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontFamily: 'Pretendard',
                                                fontWeight: FontWeight.w600,
                                                height: 1.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Filter pills (horizontal scrollable)
                    SizedBox(
                      height: 40,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                        scrollDirection: Axis.horizontal,
                        children: [
                          // Region filter (location)
                          if (selectedRegion != null) ...[
                            TabPill.default_(
                              iconPath: 'assets/icons/location.svg',
                              text: selectedRegion.name,
                              onTap: () {
                                _showRegionSelector(context);
                              },
                            ),
                            const SizedBox(width: 8),
                          ],

                          // Age category filter (condition)
                          if (selectedAgeCategory != null) ...[
                            TabPill.default_(
                              iconPath: 'assets/icons/condition.svg',
                              text: selectedAgeCategory.title,
                              onTap: () {
                                _showAgeCategorySelector(context);
                              },
                            ),
                            const SizedBox(width: 8),
                          ],

                          // Vertical divider if there are program type selections
                          if ((_programTypesByCategory[_selectedCategoryIndex]?.isNotEmpty ?? false) &&
                              (selectedRegion != null || selectedAgeCategory != null)) ...[
                            Center(
                              child: Container(
                                height: 20,
                                width: 1,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                color: const Color(0xFFEBEBEB),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],

                          // Program type filters (multiple selections possible)
                          if (_programTypesByCategory[_selectedCategoryIndex]?.isNotEmpty ?? false)
                            ...(_selectedProgramTypes[_selectedCategoryIndex] ?? []).map((type) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: TabPill.default_(
                                  iconPath: _getIconForProgramType(type),
                                  text: type,
                                  onTap: () {
                                    _showProgramTypeSelector(context);
                                  },
                                ),
                              );
                            }),

                          // Show "전체" if no program types selected but category has program types
                          if ((_programTypesByCategory[_selectedCategoryIndex]?.isNotEmpty ?? false) &&
                              (_selectedProgramTypes[_selectedCategoryIndex]?.isEmpty ?? true))
                            TabPill.default_(
                              iconPath: 'assets/icons/all.svg',
                              text: '전체',
                              onTap: () {
                                _showProgramTypeSelector(context);
                              },
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Content - Category-specific content
                    _getCategoryContent(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: PicklyBottomNavigationBar(
        currentIndex: 1, // Benefits is active
        items: PicklyNavigationItems.defaults,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go(Routes.home);
              break;
            case 1:
              // Already on benefits screen
              break;
            case 2:
              // TODO: Navigate to calendar
              break;
            case 3:
              // TODO: Navigate to AI
              break;
            case 4:
              // TODO: Navigate to my page
              break;
          }
        },
      ),
    );
  }

  /// Get category-specific content based on selected index
  Widget _getCategoryContent() {
    switch (_selectedCategoryIndex) {
      case 0: // 인기
        return const PopularCategoryContent();
      case 1: // 주거
        // Get housing category ID from provider
        final housingCategoryIdAsync = ref.watch(categoryIdBySlugProvider('housing'));
        return housingCategoryIdAsync.when(
          data: (categoryId) {
            if (categoryId == null) {
              return const Center(
                child: Text('카테고리를 찾을 수 없습니다'),
              );
            }
            return HousingCategoryContent(categoryId: categoryId);
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Text('에러: $error'),
          ),
        );
      case 2: // 교육
        return const EducationCategoryContent();
      case 3: // 건강
        return _buildComingSoonContent('건강');
      case 4: // 교통
        return const TransportationCategoryContent();
      case 5: // 복지
        return _buildComingSoonContent('복지');
      case 6: // 취업
        return _buildComingSoonContent('취업');
      case 7: // 지원
        return const SupportCategoryContent();
      case 8: // 문화
        return _buildComingSoonContent('문화');
      default:
        return const PopularCategoryContent();
    }
  }

  /// Build "coming soon" placeholder content
  Widget _buildComingSoonContent(String categoryName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction_outlined,
            size: 64,
            color: TextColors.secondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '$categoryName 카테고리',
            style: PicklyTypography.titleMedium.copyWith(
              color: TextColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '준비 중입니다',
            style: PicklyTypography.bodyMedium.copyWith(
              color: TextColors.secondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Show program type selector bottom sheet (category-specific, multiple selection)
  void _showProgramTypeSelector(BuildContext context) {
    final programTypes = _programTypesByCategory[_selectedCategoryIndex] ?? [];

    if (programTypes.isEmpty) return;

    // 현재 선택된 항목들을 임시 상태로 복사
    final currentSelections = List<String>.from(_selectedProgramTypes[_selectedCategoryIndex] ?? []);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (stateContext, setBottomSheetState) {
            // 전체 선택 여부
            final isAllSelected = currentSelections.isEmpty;

            return SafeArea(
              child: Container(
                height: 600,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.lg, Spacing.lg, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '주거 공고 선택',
                          style: PicklyTypography.titleMedium.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: TextColors.primary,
                          ),
                        ),
                        const SizedBox(height: Spacing.sm),
                        Text(
                          '해당 공고문을 안내해드립니다.',
                          style: PicklyTypography.bodyMedium.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: TextColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Scrollable program type list (expanded to fill available space)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                      child: Column(
                        children: [
                          // "전체 선택" option
                          _buildProgramTypeItem(
                            icon: 'assets/icons/all.svg',
                            title: '전체 선택',
                            subtitle: '모든 주거 공고',
                            isSelected: isAllSelected,
                            onTap: () {
                              setBottomSheetState(() {
                                currentSelections.clear(); // 전체 선택 = 빈 리스트
                              });
                            },
                          ),
                          const SizedBox(height: Spacing.md),

                          // Individual program types
                          ...programTypes.map((type) {
                            final isSelected = currentSelections.contains(type['title']);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: Spacing.md),
                              child: _buildProgramTypeItem(
                                icon: type['icon']!,
                                title: type['title']!,
                                subtitle: 'LH 행복주택',
                                isSelected: isSelected,
                                onTap: () {
                                  setBottomSheetState(() {
                                    if (isSelected) {
                                      // 선택 해제
                                      currentSelections.remove(type['title']);
                                    } else {
                                      // 선택 (전체 선택 상태가 아니라면)
                                      currentSelections.add(type['title']!);
                                    }
                                  });
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Save button (Figma: height 48px) - Matching onboarding layout
                  Padding(
                    padding: const EdgeInsets.all(Spacing.lg),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          final storage = ref.read(onboardingStorageServiceProvider);
                          final categoryId = _getCategoryId(_selectedCategoryIndex);

                          // Update main state
                          setState(() {
                            _selectedProgramTypes[_selectedCategoryIndex] = currentSelections;
                          });

                          // Save to storage
                          await storage.setSelectedProgramTypes(categoryId, currentSelections);

                          if (mounted) {
                            Navigator.pop(bottomSheetContext);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BrandColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 80),
                        ),
                        child: Text(
                          '저장',
                          style: PicklyTypography.bodyLarge.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            );
          },
        );
      },
    );
  }

  /// Show region selector bottom sheet
  void _showRegionSelector(BuildContext context) {
    final regions = ref.read(regionsListProvider);
    final storage = ref.read(onboardingStorageServiceProvider);
    final selectedRegionIds = storage.getSelectedRegionIds();
    String? selectedRegionId = selectedRegionIds.isNotEmpty ? selectedRegionIds.first : null;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (stateContext, setBottomSheetState) {
            return SafeArea(
              child: Container(
                height: 540,
                padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.xxl, Spacing.lg, Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      '관심 지역을 선택해주세요.',
                      style: PicklyTypography.titleMedium.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: TextColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '해당 지역의 공고를 안내해드립니다.',
                      style: PicklyTypography.bodyMedium.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: TextColors.secondary,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Region grid (expanded to fill available space)
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 2.0,
                        ),
                        itemCount: regions.length,
                        itemBuilder: (context, index) {
                          final region = regions[index];
                          final isSelected = selectedRegionId == region.id;
                          return SelectionChip(
                            label: region.name,
                            isSelected: isSelected,
                            size: ChipSize.small,
                            onTap: () {
                              setBottomSheetState(() {
                                selectedRegionId = region.id;
                              });
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: selectedRegionId != null
                            ? () async {
                                final storage = ref.read(onboardingStorageServiceProvider);
                                final ageCategoryId = storage.getSelectedAgeCategoryId();

                                // Save to storage
                                if (ageCategoryId != null) {
                                  await storage.saveOnboardingData(
                                    ageCategoryId: ageCategoryId,
                                    regionIds: [selectedRegionId!],
                                  );
                                }

                                if (mounted) {
                                  Navigator.pop(bottomSheetContext);
                                  // Refresh UI
                                  setState(() {});
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BrandColors.primary,
                          disabledBackgroundColor: BrandColors.primary.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 80),
                        ),
                        child: Text(
                          '저장',
                          style: PicklyTypography.bodyLarge.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Show age category selector bottom sheet
  void _showAgeCategorySelector(BuildContext context) {
    final categoriesAsync = ref.read(ageCategoryProvider);

    categoriesAsync.when(
      data: (categories) {
        final storage = ref.read(onboardingStorageServiceProvider);
        final ageCategoryId = storage.getSelectedAgeCategoryId();
        String? selectedCategoryId = ageCategoryId;

        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (bottomSheetContext) {
            return StatefulBuilder(
              builder: (stateContext, setBottomSheetState) {
                return SafeArea(
                  child: Container(
                    height: 540,
                    padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.xxl, Spacing.lg, Spacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Text(
                          '맞춤 혜택을 위해 내 상황을 알려주세요.',
                          style: PicklyTypography.titleMedium.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: TextColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '나에게 맞는 정책과 혜택에 대해 안내해드립니다.',
                          style: PicklyTypography.bodyMedium.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: TextColors.secondary,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Category list (expanded to fill available space)
                        Expanded(
                          child: ListView.separated(
                            itemCount: categories.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              final isSelected = selectedCategoryId == category.id;

                              return SelectionListItem(
                                iconUrl: category.iconUrl,
                                title: category.title,
                                description: category.description,
                                isSelected: isSelected,
                                onTap: () {
                                  setBottomSheetState(() {
                                    selectedCategoryId = category.id;
                                  });
                                },
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Save button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: selectedCategoryId != null
                                ? () async {
                                    final storage = ref.read(onboardingStorageServiceProvider);
                                    final regionIds = storage.getSelectedRegionIds();

                                    // Save to storage
                                    if (regionIds.isNotEmpty) {
                                      await storage.saveOnboardingData(
                                        ageCategoryId: selectedCategoryId!,
                                        regionIds: regionIds,
                                      );
                                    }

                                    if (mounted) {
                                      Navigator.pop(bottomSheetContext);
                                      // Refresh UI
                                      setState(() {});
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: BrandColors.primary,
                              disabledBackgroundColor: BrandColors.primary.withValues(alpha: 0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 80),
                            ),
                            child: Text(
                              '저장',
                              style: PicklyTypography.bodyLarge.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () {
        // Show loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('데이터를 불러오는 중...')),
        );
      },
      error: (error, stack) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터를 불러오는 데 실패했습니다: $error')),
        );
      },
    );
  }

  /// Build program type selection item
  Widget _buildProgramTypeItem({
    required String icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? BrandColors.primary : const Color(0xFFEBEBEB),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Icon
            SvgPicture.asset(
              icon,
              width: 32,
              height: 32,
              package: 'pickly_design_system',
            ),
            const SizedBox(width: 12),
            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF3E3E3E),
                      fontSize: 14,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                      height: 1.43,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF828282),
                      fontSize: 12,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      height: 1.50,
                    ),
                  ),
                ],
              ),
            ),
            // Checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? BrandColors.primary : const Color(0xFFDDDDDD),
                shape: BoxShape.circle,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
