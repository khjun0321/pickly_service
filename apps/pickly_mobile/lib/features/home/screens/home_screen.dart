import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pickly_design_system/pickly_design_system.dart';
import 'package:pickly_mobile/core/router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  // 애니메이션 임계값
  static const double _headerFadeThreshold = 60.0;
  static const double _birdFadeThreshold = 80.0;
  static const double _searchBarTransformEnd = 100.0;

  // 고정 블러 영역 높이 (스크롤 시) - SafeArea + 검색바 영역
  static const double _blurRegionHeight = 155.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset.clamp(0.0, _searchBarTransformEnd);
    });
  }

  // 헤더 투명도
  double get _headerOpacity {
    if (_scrollOffset >= _headerFadeThreshold) return 0.0;
    return 1.0 - (_scrollOffset / _headerFadeThreshold);
  }

  // 헤더 높이
  double get _headerHeight {
    return 60.0 * _headerOpacity;
  }

  // 새 캐릭터 투명도
  double get _birdOpacity {
    if (_scrollOffset >= _birdFadeThreshold) return 0.0;
    return 1.0 - (_scrollOffset / _birdFadeThreshold);
  }

  // 새 캐릭터 스케일
  double get _birdScale {
    return 1.0 - (0.2 * (_scrollOffset / _birdFadeThreshold).clamp(0.0, 1.0));
  }

  // 검색바 변형 진행도
  double get _searchBarProgress {
    return (_scrollOffset / _searchBarTransformEnd).clamp(0.0, 1.0);
  }

  // 검색바 너비 (343 → 240)
  double get _searchBarWidth {
    return 343.0 - (103.0 * _searchBarProgress);
  }

  bool get _isSearchBarCompact => _scrollOffset >= _searchBarTransformEnd;

  // 상단 고정 영역 전체 높이 (스크롤 전)
  double get _totalHeaderHeight {
    // SafeArea + 헤더(60) + 56(헤더 아래 여백) + 새(60) + 서치바(48) + 12(여백)
    return _headerHeight + 56.0 + (60.0 * (_birdOpacity > 0 ? 1.0 : 0.0)) + 60.0;
  }

  @override
  Widget build(BuildContext context) {
    // SafeArea top padding
    final safeAreaTop = MediaQuery.of(context).padding.top;

    return GestureDetector(
      onTap: () {
        // 키보드 외부 터치 시 키보드 내리기
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        body: Stack(
        children: [
          // 메인 스크롤 컨텐츠
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // 상단 여백: SafeArea + 헤더 + 56 + 새 + 서치바 + 80 (카드 간격)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: safeAreaTop + 60 + 56 + 60 + 48 + 80,
                ),
              ),


              // 정책 카드 리스트
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildPolicyCard(),
                    ),
                    childCount: 10,
                  ),
                ),
              ),

              // 하단 여백
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
            ],
          ),

          // 상단 고정 영역 (블러 효과 포함)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _scrollOffset >= _searchBarTransformEnd
              ? _blurRegionHeight
              : null,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: _scrollOffset > 0 ? 3.0 : 0.0,
                  sigmaY: _scrollOffset > 0 ? 3.0 : 0.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFF4F4F4).withOpacity(0.95),
                        const Color(0xFFF4F4F4).withOpacity(0),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // SafeArea
                      SizedBox(height: safeAreaTop),

                      // 헤더 (페이드아웃)
                      if (_headerOpacity > 0)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: _headerHeight,
                          child: AnimatedOpacity(
                            opacity: _headerOpacity,
                            duration: const Duration(milliseconds: 200),
                            child: AppHeader.home(
                              onMenuTap: () {
                                // TODO: 메뉴 기능 구현
                              },
                            ),
                          ),
                        ),

                      // 헤더 아래 56px 여백 + 새 캐릭터
                      if (_birdOpacity > 0)
                        Column(
                          children: [
                            // 헤더 아래 56px 여백
                            SizedBox(height: 56.0 * _headerOpacity),

                            // 새 캐릭터 (우측 정렬)
                            Padding(
                              padding: const EdgeInsets.only(right: 56),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: AnimatedOpacity(
                                  opacity: _birdOpacity,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOut,
                                  child: AnimatedScale(
                                    scale: _birdScale,
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeOut,
                                    child: _buildBirdCharacter(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                      // 검색바 (애니메이션) - 항상 표시
                      Padding(
                        padding: EdgeInsets.only(
                          top: _scrollOffset >= _searchBarTransformEnd ? 20 : 0,
                          bottom: _scrollOffset >= _searchBarTransformEnd ? 20 : 12,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          width: _searchBarWidth,
                          child: PicklySearchBar(
                            placeholder: _isSearchBarCompact ? '검색어 입력...' : '검색어를 입력해주세요.',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        ),
        bottomNavigationBar: PicklyBottomNavigationBar(
          currentIndex: 0, // Home is active
          items: PicklyNavigationItems.defaults,
          onTap: (index) {
            switch (index) {
              case 0:
                // Already on home screen
                break;
              case 1:
                // Navigate to benefits
                context.go(Routes.benefits);
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
      ),
    );
  }

  // 새 캐릭터 (Mr. Pick)
  Widget _buildBirdCharacter() {
    return SvgPicture.asset(
      'assets/images/mr_pick.svg',
      package: 'pickly_design_system',
      width: 48,
      height: 48,
    );
  }

  // 정책 카드 (디자인 시스템 컴포넌트 사용)
  // TODO: 백오피스 개발 후 이미지는 서버에서 관리
  // Currently using dummy image as placeholder
  Widget _buildPolicyCard() {
    return PopularPolicyCard(
      imageWidget: Image.asset(
        'assets/images/placeholders/policy_dummy.png',
        package: 'pickly_design_system',
        fit: BoxFit.cover,
        alignment: Alignment.center,
      ),
      onTap: () {
        // TODO: 정책 상세 화면으로 이동
      },
    );
  }
}
