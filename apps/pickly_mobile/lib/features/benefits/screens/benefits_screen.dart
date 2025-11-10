import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pickly_design_system/pickly_design_system.dart';
import 'package:pickly_mobile/core/router.dart';
import 'package:pickly_mobile/core/utils/media_resolver.dart';
import 'package:pickly_mobile/features/onboarding/providers/onboarding_storage_provider.dart';
import 'package:pickly_mobile/features/onboarding/providers/region_provider.dart';
import 'package:pickly_mobile/features/onboarding/providers/age_category_provider.dart';
import 'package:pickly_mobile/features/benefits/widgets/popular_category_content.dart';
import 'package:pickly_mobile/features/benefits/widgets/housing_category_content.dart';
import 'package:pickly_mobile/features/benefits/widgets/education_category_content.dart';
import 'package:pickly_mobile/features/benefits/widgets/support_category_content.dart';
import 'package:pickly_mobile/features/benefits/widgets/transportation_category_content.dart';
import 'package:pickly_mobile/features/benefits/widgets/filter_bottom_sheet.dart';
import 'package:pickly_mobile/features/benefits/providers/category_banner_provider.dart';
import 'package:pickly_mobile/features/benefits/providers/category_id_provider.dart';
import 'package:pickly_mobile/features/benefits/providers/benefit_category_provider.dart';

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

  /// Get category index from category slug (now uses dynamic data from stream)
  int? _getCategoryIndexFromId(String categorySlug) {
    final categories = ref.read(categoriesStreamListProvider);
    for (int i = 0; i < categories.length; i++) {
      if (categories[i].slug == categorySlug) {
        return i;
      }
    }
    return null;
  }

  /// PRD v9.10.0: Removed _getIconForProgramType() - icons now loaded from database via FilterBottomSheet

  // PRD v9.10.0: Removed hardcoded _programTypesByCategory map
  // Subcategory filters now loaded dynamically from database via FilterBottomSheet

  // NOTE: Categories are now loaded dynamically from database via benefitCategoriesStreamProvider
  // This enables realtime updates when Admin modifies categories (PRD v9.6.1 Phase 3)

  /// Get category slug by index (now uses dynamic data from stream)
  String? _getCategorySlug(int index) {
    final categories = ref.read(categoriesStreamListProvider);
    if (index >= 0 && index < categories.length) {
      return categories[index].slug;
    }
    return null;
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

            // Category tabs (horizontal scroll) - Realtime stream from database
            SizedBox(
              height: 72,
              child: Consumer(
                builder: (context, ref, child) {
                  // Watch categories from realtime stream (PRD v9.6.1 Phase 3)
                  final categoriesAsync = ref.watch(benefitCategoriesStreamProvider);

                  return categoriesAsync.when(
                    data: (categories) {
                      if (categories.isEmpty) {
                        return const Center(
                          child: Text(
                            '카테고리를 불러오는 중...',
                            style: TextStyle(
                              color: Color(0xFF828282),
                              fontSize: 14,
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.only(left: Spacing.lg),
                        scrollDirection: Axis.horizontal,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: categories.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isActive = _selectedCategoryIndex == index;

                          // PRD v9.9.4: Flexible icon loading - handles filename/URL/asset
                          return FutureBuilder<String?>(
                            future: resolveSvgUrlOrAssetFlexible(
                              category.iconUrl,
                              bucket: 'benefit-icons',
                              folder: 'icons',
                            ),
                            builder: (context, snapshot) {
                              // Determine the resolved path
                              String resolvedIconPath;

                              if (snapshot.hasData && snapshot.data != null) {
                                final resolvedUrl = snapshot.data!;

                                // If it's a network URL, use it directly
                                if (resolvedUrl.startsWith('http://') ||
                                    resolvedUrl.startsWith('https://')) {
                                  resolvedIconPath = resolvedUrl;
                                } else {
                                  // Local asset path - add asset:// prefix for TabCircleWithLabel
                                  resolvedIconPath = 'asset://$resolvedUrl';
                                }
                              } else {
                                // Fallback to placeholder while loading or on error
                                resolvedIconPath = 'asset://packages/pickly_design_system/assets/icons/placeholder.svg';
                              }

                              return TabCircleWithLabel(
                                iconPath: resolvedIconPath,
                                label: category.title,
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
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (error, stack) => Center(
                      child: Text(
                        '카테고리를 불러올 수 없습니다',
                        style: TextStyle(
                          color: TextColors.secondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
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
                        // Get banners for the currently selected category (using slug from realtime stream)
                        final categorySlug = _getCategorySlug(_selectedCategoryIndex);
                        if (categorySlug == null) {
                          return const SizedBox.shrink();
                        }
                        final banners = ref.watch(bannersByCategoryProvider(categorySlug));

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
                              key: ValueKey(categorySlug), // Reset PageView when category changes
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

                    // PRD v9.10.2: Filter pills with divider - Figma spec layout
                    // Layout: (region)(age) | (subcategory chips with horizontal scroll)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                      child: SizedBox(
                        height: 40,
                        child: Row(
                          children: [
                            // Region filter chip
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

                            // Age category filter chip
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

                            // Vertical divider (if region or age selected AND subcategories exist)
                            Consumer(
                              builder: (context, ref, child) {
                                final categories = ref.watch(categoriesStreamListProvider);

                                if (_selectedCategoryIndex >= 0 && _selectedCategoryIndex < categories.length) {
                                  final currentCategory = categories[_selectedCategoryIndex];
                                  final subcategoriesAsync = ref.watch(subcategoriesStreamProvider(currentCategory.id));

                                  return subcategoriesAsync.when(
                                    data: (subcategories) {
                                      // Show divider if region/age selected AND subcategories exist
                                      if ((selectedRegion != null || selectedAgeCategory != null) && subcategories.isNotEmpty) {
                                        return Row(
                                          children: [
                                            // Divider: 1px width, 24px height, #EBEBEB
                                            Container(
                                              width: 1,
                                              height: 24,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFEBEBEB),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                    loading: () => const SizedBox.shrink(),
                                    error: (_, __) => const SizedBox.shrink(),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),

                            // Subcategory chips (horizontal scrollable)
                            Expanded(
                              child: Consumer(
                                builder: (context, ref, child) {
                                  final categories = ref.watch(categoriesStreamListProvider);

                                  if (_selectedCategoryIndex >= 0 && _selectedCategoryIndex < categories.length) {
                                    final currentCategory = categories[_selectedCategoryIndex];
                                    // Use selectedSubcategoriesForCategoryProvider to get full objects with iconUrl
                                    final selectedSubcategories = ref.watch(selectedSubcategoriesForCategoryProvider(currentCategory.id));
                                    final subcategoriesAsync = ref.watch(subcategoriesStreamProvider(currentCategory.id));

                                    return subcategoriesAsync.when(
                                      data: (subcategories) {
                                        if (subcategories.isEmpty) {
                                          return const SizedBox.shrink();
                                        }

                                        // Build subcategory chip widgets
                                        final chipWidgets = <Widget>[];

                                        if (selectedSubcategories.isNotEmpty) {
                                          // Show each selected subcategory as a chip with its iconUrl preserved
                                          for (final subcategory in selectedSubcategories) {
                                            debugPrint('🎨 [BenefitScreen] Rendering chip for: ${subcategory.name}');
                                            debugPrint('   iconUrl: ${subcategory.iconUrl}');
                                            chipWidgets.add(
                                              FutureBuilder<String?>(
                                                future: resolveSvgUrlOrAssetFlexible(
                                                  subcategory.iconUrl,
                                                  bucket: 'benefit-icons',
                                                  folder: 'icons',
                                                ),
                                                builder: (context, snapshot) {
                                                  // Determine the resolved path
                                                  String resolvedIconPath;

                                                  debugPrint('🔍 [Icon Resolve] ${subcategory.name}: hasData=${snapshot.hasData}, data=${snapshot.data}');

                                                  if (snapshot.hasData && snapshot.data != null) {
                                                    final resolvedUrl = snapshot.data!;

                                                    // Handle different URL formats
                                                    if (resolvedUrl.startsWith('http://') ||
                                                        resolvedUrl.startsWith('https://')) {
                                                      // Network SVG → use directly
                                                      resolvedIconPath = resolvedUrl;
                                                      debugPrint('   ✅ Using network URL: $resolvedIconPath');
                                                    } else if (resolvedUrl.startsWith('asset://')) {
                                                      // Local asset with asset:// prefix (already formatted)
                                                      resolvedIconPath = resolvedUrl;
                                                      debugPrint('   ✅ Using local asset (prefixed): $resolvedIconPath');
                                                    } else {
                                                      // Local asset path - add asset:// prefix for TabPill
                                                      resolvedIconPath = 'asset://$resolvedUrl';
                                                      debugPrint('   ✅ Adding asset prefix: $resolvedIconPath');
                                                    }
                                                  } else {
                                                    // Fallback to all.svg while loading or on error
                                                    resolvedIconPath = 'asset://packages/pickly_design_system/assets/icons/all.svg';
                                                    debugPrint('   ⚠️ Fallback to all.svg (error: ${snapshot.error})');
                                                  }

                                                  debugPrint('   🎯 Final iconPath: $resolvedIconPath');

                                                  return TabPill.default_(
                                                    iconPath: resolvedIconPath,
                                                    text: subcategory.name,
                                                    onTap: () async {
                                                      await showModalBottomSheet(
                                                        context: context,
                                                        isScrollControlled: true,
                                                        backgroundColor: Colors.transparent,
                                                        builder: (context) => FilterBottomSheet(category: currentCategory),
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            );
                                            chipWidgets.add(const SizedBox(width: 8));
                                          }
                                        } else {
                                          // Show "전체" chip when no subcategories selected
                                          chipWidgets.add(
                                            TabPill.default_(
                                              iconPath: 'assets/icons/all.svg',
                                              text: '전체',
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  backgroundColor: Colors.transparent,
                                                  builder: (context) => FilterBottomSheet(category: currentCategory),
                                                );
                                              },
                                            ),
                                          );
                                        }

                                        // Horizontal scrollable list of chips
                                        return SizedBox(
                                          height: 36,
                                          child: ListView(
                                            scrollDirection: Axis.horizontal,
                                            children: chipWidgets,
                                          ),
                                        );
                                      },
                                      loading: () => const SizedBox.shrink(),
                                      error: (_, __) => const SizedBox.shrink(),
                                    );
                                  }

                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ],
                        ),
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

  /// PRD v9.10.0: Removed _showProgramTypeSelector() - replaced by FilterBottomSheet

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

  /// PRD v9.10.0: Removed _buildProgramTypeItem() - UI now in FilterBottomSheet widget
}
