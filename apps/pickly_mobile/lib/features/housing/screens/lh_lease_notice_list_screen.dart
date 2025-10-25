import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/lh_provider.dart';

/// LH 공고 목록 화면
///
/// 한국토지주택공사의 분양/임대 공고를 표시합니다.
class LhLeaseNoticeListScreen extends ConsumerStatefulWidget {
  const LhLeaseNoticeListScreen({super.key});

  @override
  ConsumerState<LhLeaseNoticeListScreen> createState() =>
      _LhLeaseNoticeListScreenState();
}

class _LhLeaseNoticeListScreenState
    extends ConsumerState<LhLeaseNoticeListScreen> {
  String? selectedRegion;
  String? selectedHousingSector;

  @override
  Widget build(BuildContext context) {
    final params = LhNoticeParams(
      region: selectedRegion,
      housingSector: selectedHousingSector,
    );

    final noticesAsync = ref.watch(lhLeaseNoticesProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: const Text('LH 주거 공고'),
        actions: [
          // 필터 버튼
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: noticesAsync.when(
        data: (response) {
          if (!response.isSuccess) {
            return Center(
              child: Text('오류: ${response.resultMsg}'),
            );
          }

          if (response.items.isEmpty) {
            return const Center(
              child: Text('공고가 없습니다.'),
            );
          }

          return Column(
            children: [
              // 결과 요약
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '총 ${response.totalCount}개 공고',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),

              // 공고 리스트
              Expanded(
                child: ListView.builder(
                  itemCount: response.items.length,
                  itemBuilder: (context, index) {
                    final notice = response.items[index];
                    return _buildNoticeCard(notice);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('오류: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(lhLeaseNoticesProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 공고 카드 위젯
  Widget _buildNoticeCard(notice) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // 상세 화면으로 이동
          if (notice.noticeId != null) {
            Navigator.of(context).pushNamed(
              '/housing/detail',
              arguments: notice.noticeId,
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              Text(
                notice.noticeTitle ?? '제목 없음',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // 주택 구분
              if (notice.housingSector != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    notice.housingSector!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[900],
                    ),
                  ),
                ),
              const SizedBox(height: 8),

              // 지역
              if (notice.region != null)
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      notice.region!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 4),

              // 신청 기간
              if (notice.applyStartDate != null && notice.applyEndDate != null)
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '신청: ${notice.applyStartDate} ~ ${notice.applyEndDate}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),

              // 총 공급 호수
              if (notice.totalSupply != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.home, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '공급: ${notice.totalSupply}호',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 필터 다이얼로그 표시
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('필터'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 지역 필터
            DropdownButtonFormField<String>(
              value: selectedRegion,
              decoration: const InputDecoration(labelText: '지역'),
              items: const [
                DropdownMenuItem(value: null, child: Text('전체')),
                DropdownMenuItem(value: '서울특별시', child: Text('서울특별시')),
                DropdownMenuItem(value: '경기도', child: Text('경기도')),
                DropdownMenuItem(value: '인천광역시', child: Text('인천광역시')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedRegion = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // 주택 구분 필터
            DropdownButtonFormField<String>(
              value: selectedHousingSector,
              decoration: const InputDecoration(labelText: '주택 구분'),
              items: const [
                DropdownMenuItem(value: null, child: Text('전체')),
                DropdownMenuItem(value: '행복주택', child: Text('행복주택')),
                DropdownMenuItem(value: '국민임대', child: Text('국민임대')),
                DropdownMenuItem(value: '영구임대', child: Text('영구임대')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedHousingSector = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                selectedRegion = null;
                selectedHousingSector = null;
              });
              Navigator.of(context).pop();
            },
            child: const Text('초기화'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('적용'),
          ),
        ],
      ),
    );
  }
}
