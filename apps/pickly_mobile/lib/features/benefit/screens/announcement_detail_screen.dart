import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pickly_design_system/pickly_design_system.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pickly_mobile/core/router.dart';
import '../widgets/income_section_widget.dart';

/// 공고 상세 화면
/// SafeArea + Column 레이아웃 구조로 온보딩 화면과 동일한 스타일 적용
/// 소득 기준 섹션은 IncomeSectionWidget을 사용하여 특별한 UI로 표시
class AnnouncementDetailScreen extends StatefulWidget {
  final String announcementId;

  const AnnouncementDetailScreen({
    super.key,
    required this.announcementId,
  });

  @override
  State<AnnouncementDetailScreen> createState() =>
      _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  bool isBookmarked = false;

  void _onShare() {
    // TODO: 공유 기능 구현
    debugPrint('Share announcement: ${widget.announcementId}');
  }

  void _onBookmark() {
    setState(() {
      isBookmarked = !isBookmarked;
    });
    // TODO: 북마크 API 호출
    debugPrint('🔖 Bookmark toggled: $isBookmarked');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColors.app, // #F4F4F4
      body: SafeArea(
        child: Column(
          children: [
            // Header - Portal type with bookmark and share
            AppHeader.portal(
              title: '하남미사 C3BL 행복주택',
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(Routes.benefits);
                }
              },
              onBookmark: _onBookmark,
              onShare: _onShare,
              isBookmarked: isBookmarked,
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: Spacing.xl),
                    // 마감 알림 배너
                    const _DeadlineBanner(
                      daysLeft: 3,
                      status: '모집중',
                    ),
                    const SizedBox(height: Spacing.lg),
                    // 기본 정보 섹션
                    _SectionCard(
                      title: '기본 정보',
                      children: const [
                        _InfoItem(
                          icon: '🏠',
                          label: '공급 기관',
                          value: 'LH 행복 주택',
                        ),
                        _InfoItem(
                          icon: '',
                          label: '카테고리',
                          value: '행복주택',
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.md),
                    // 일정 섹션
                    _SectionCard(
                      title: '일정',
                      children: const [
                        _InfoItem(
                          icon: '📅',
                          label: '접수 기간',
                          value: '2025.09.30(월) - 2025.11.30(화)',
                        ),
                        _InfoItem(
                          icon: '',
                          label: '서류 대상자 발표 일정',
                          value: '2025.12.25',
                        ),
                        _InfoItem(
                          icon: '',
                          label: '당첨자 발표일',
                          value: '2025.02.04',
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.md),
                    // 신청 자격 섹션
                    _SectionCard(
                      title: '신청 자격',
                      children: const [
                        _InfoItem(
                          icon: '👤',
                          label: '조건',
                          value: '만 19세 - 39세\n'
                              '경기도 6개월 이상 거주\n'
                              '월 소득 300만원 이하\n'
                              '무주택 세대주\n'
                              '대학생 / 사회초년생',
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.md),
                    // 소득 기준 섹션 (특별 UI)
                    IncomeSectionWidget(
                      description: '전년도 도시근로자 가구당 월평균 소득 기준',
                      fields: const [
                        IncomeField(
                          label: '가구 소득',
                          value: '전년도 도시근로자 월평균 소득 100% 이하',
                          detail: '1인 가구: 4,445,807원',
                        ),
                        IncomeField(
                          label: '본인 소득',
                          value: '전년도 도시근로자 월평균 소득 70% 이하',
                          detail: '1인 가구: 3,112,065원',
                        ),
                        IncomeField(
                          label: '자산',
                          value: '총자산 2억 8,800만원 이하',
                          detail: '부동산, 금융자산 등 합산',
                        ),
                        IncomeField(
                          label: '자동차',
                          value: '자동차 가액 3,683만원 이하',
                          detail: '차량 1대 기준',
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.md),
                    // 단지 정보 섹션
                    const _ComplexInfoCard(),
                    const SizedBox(height: Spacing.md),
                    // 평형 정보 (탭)
                    const _UnitTypesSection(),
                    const SizedBox(height: Spacing.xl),
                  ],
                ),
              ),
            ),

            // Bottom button - matches onboarding style
            Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: PicklyButton.primary(
                  onPressed: () async {
                    const url = 'https://www.lh.or.kr';
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  text: '공고문 보러가기',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 마감 알림 배너
class _DeadlineBanner extends StatelessWidget {
  final int daysLeft;
  final String status;

  const _DeadlineBanner({
    required this.daysLeft,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFF2E2E2E),
        borderRadius: PicklyBorderRadius.radiusXl,
      ),
      child: Row(
        children: [
          // 시계 아이콘
          SvgPicture.asset(
            'assets/icons/timer.svg',
            package: 'pickly_design_system',
            width: 20,
            height: 20,
          ),
          const SizedBox(width: Spacing.md),
          // 텍스트
          Expanded(
            child: Text(
              '공고 마감까지 $daysLeft일 남았어요',
              style: PicklyTypography.bodyMedium.copyWith(
                color: TextColors.inverse,
                fontWeight: FontWeight.w700,
                height: 1.20,
              ),
            ),
          ),
          // 상태 뱃지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: const Color(0xFFC6ECFF),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Text(
              status,
              style: PicklyTypography.captionSmall.copyWith(
                color: const Color(0xFF5090FF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 섹션 카드
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: SurfaceColors.base,
        border: Border.all(
          color: BorderColors.subtle,
          width: 1,
        ),
        borderRadius: PicklyBorderRadius.radiusXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: PicklyTypography.titleSmall.copyWith(
              color: TextColors.primary,
            ),
          ),
          const SizedBox(height: Spacing.xl),
          ...children,
        ],
      ),
    );
  }
}

/// 정보 항목
class _InfoItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아이콘 (있는 경우)
          if (icon.isNotEmpty) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFF4ECE0),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: Spacing.md),
          ],
          // 레이블과 값
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: PicklyTypography.captionMidium.copyWith(
                    color: TextColors.secondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: PicklyTypography.bodyMedium.copyWith(
                    color: TextColors.primary,
                    height: 1.60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 단지 정보 카드
class _ComplexInfoCard extends StatelessWidget {
  const _ComplexInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: SurfaceColors.base,
        border: Border.all(
          color: BorderColors.subtle,
          width: 1,
        ),
        borderRadius: PicklyBorderRadius.radiusXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '단지 정보',
            style: PicklyTypography.titleSmall.copyWith(
              color: TextColors.primary,
            ),
          ),
          const SizedBox(height: Spacing.lg),
          // 단지 이미지
          Center(
            child: Container(
              width: 142,
              height: 142,
              decoration: BoxDecoration(
                color: BackgroundColors.muted,
                borderRadius: PicklyBorderRadius.radiusMd,
              ),
              child: const Icon(
                Icons.apartment,
                size: 64,
                color: TextColors.tertiary,
              ),
            ),
          ),
          const SizedBox(height: Spacing.xl),
          // 정보 항목들
          const _DetailRow(label: '단지명', value: '하남미사 C3BL 행복주택'),
          const _DetailRow(label: '공사', value: '경기도 하남시 미사강변한강로 290-3 (망월동)'),
          const _DetailRow(label: '건설호수', value: '4개동 1,492호'),
          const _DetailRow(label: '최초입주', value: '2028.09.XX'),
          const _DetailRow(label: '모집 구분', value: '예비입주자 모집'),
        ],
      ),
    );
  }
}

/// 상세 정보 행
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: PicklyTypography.captionMidium.copyWith(
              color: TextColors.secondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: PicklyTypography.bodyMedium.copyWith(
              color: TextColors.primary,
              height: 1.60,
            ),
          ),
        ],
      ),
    );
  }
}

/// 평형 타입 섹션
class _UnitTypesSection extends StatefulWidget {
  const _UnitTypesSection();

  @override
  State<_UnitTypesSection> createState() => _UnitTypesSectionState();
}

class _UnitTypesSectionState extends State<_UnitTypesSection> {
  int selectedIndex = 0;
  final List<String> unitTypes = [
    '청년 16A',
    '청년 26C',
    '청년 32C',
    '신혼 부부 36A',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: SurfaceColors.base,
        border: Border.all(
          color: BorderColors.subtle,
          width: 1,
        ),
        borderRadius: PicklyBorderRadius.radiusXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '16㎡ (약 5평)',
            style: PicklyTypography.titleSmall.copyWith(
              color: TextColors.primary,
            ),
          ),
          const SizedBox(height: Spacing.lg),
          // 평형 도면 (2개)
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 148,
                  decoration: BoxDecoration(
                    color: SurfaceColors.base,
                    border: Border.all(color: BorderColors.subtle),
                    borderRadius: PicklyBorderRadius.radiusMd,
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    size: 48,
                    color: TextColors.tertiary,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Container(
                  height: 148,
                  decoration: BoxDecoration(
                    color: SurfaceColors.base,
                    border: Border.all(color: BorderColors.subtle),
                    borderRadius: PicklyBorderRadius.radiusMd,
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    size: 48,
                    color: TextColors.tertiary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xl),
          // 공급 호수
          const _DetailRow(label: '공급 호수', value: '200호'),
          // 임대 조건
          const _DetailRow(
            label: '임대 조건',
            value: '대학생: 보증금 3,284만원 / 월세 13.8만원\n'
                '청년 (소득有): 보증금 3,477만원 / 월세 14.6만원',
          ),
          // 지도
          Container(
            height: 253,
            decoration: BoxDecoration(
              color: BackgroundColors.muted,
              border: Border.all(color: BorderColors.subtle),
              borderRadius: PicklyBorderRadius.radiusMd,
            ),
            child: const Center(
              child: Icon(
                Icons.map_outlined,
                size: 64,
                color: TextColors.tertiary,
              ),
            ),
          ),
          const SizedBox(height: Spacing.lg),
          // 위치
          const _DetailRow(label: '위치', value: '경기도 하남시 미사강변한강로 290-3 (망월동)'),
        ],
      ),
    );
  }
}
