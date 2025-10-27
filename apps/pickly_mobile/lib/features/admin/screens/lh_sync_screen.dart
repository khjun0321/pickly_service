import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../contexts/housing/providers/lh_sync_provider.dart';

/// LH API 동기화 화면 (관리자용)
class LhSyncScreen extends ConsumerWidget {
  const LhSyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LH API 동기화'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'LH 공고 데이터 가져오기',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '최신 LH 공고를 가져와서 Supabase에 자동으로 저장합니다.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildSyncButton(context, ref, count: 10, label: '10개 가져오기'),
            const SizedBox(height: 12),
            _buildSyncButton(context, ref, count: 50, label: '50개 가져오기'),
            const SizedBox(height: 12),
            _buildSyncButton(context, ref, count: 100, label: '100개 가져오기'),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '가져온 데이터는 자동으로 변환되어 저장됩니다.\n백오피스에서 세부 정보를 수정할 수 있습니다.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncButton(
    BuildContext context,
    WidgetRef ref, {
    required int count,
    required String label,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          // 동기화 시작
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );

          try {
            final result = await ref.read(lhSyncProvider(count).future);

            if (context.mounted) {
              Navigator.pop(context); // 로딩 닫기

              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('✅ 동기화 완료'),
                  content: Text('$result개의 공고를 저장했습니다.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('확인'),
                    ),
                  ],
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              Navigator.pop(context); // 로딩 닫기

              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('❌ 동기화 실패'),
                  content: Text('$e'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('확인'),
                    ),
                  ],
                ),
              );
            }
          }
        },
        icon: const Icon(Icons.sync),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
