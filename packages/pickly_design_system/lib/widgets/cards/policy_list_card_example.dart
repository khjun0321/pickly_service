import 'package:flutter/material.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

/// Example usage of PolicyListCard widget
class PolicyListCardExample extends StatelessWidget {
  const PolicyListCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColors.app,
      appBar: AppBar(
        title: const Text('Policy List Card Example'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Policy List Cards',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),

            // Recruiting status card
            PolicyListCard(
              imageUrl: 'assets/images/test/list_sample.png',
              title: '화성동탄2 A93 동탄호수공...',
              organization: '장기전세주택(GH)',
              postedDate: '2025/04/12',
              status: RecruitmentStatus.recruiting,
              onTap: () {
                debugPrint('Policy card tapped');
              },
            ),
            const SizedBox(height: 16),

            // Closed status card
            PolicyListCard(
              imageUrl: 'assets/images/test/list_sample.png',
              title: '서울시 청년 월세 지원 사업',
              organization: '서울시청',
              postedDate: '2025/03/15',
              status: RecruitmentStatus.closed,
              onTap: () {
                debugPrint('Policy card tapped');
              },
            ),
            const SizedBox(height: 16),

            // Long title example
            PolicyListCard(
              imageUrl: 'assets/images/test/list_sample.png',
              title: '이것은 아주 긴 제목의 예시입니다 말줄임표가 제대로 표시되는지 확인합니다',
              organization: '한국토지주택공사(LH)',
              postedDate: '2025/02/20',
              status: RecruitmentStatus.recruiting,
              onTap: () {
                debugPrint('Policy card tapped');
              },
            ),
            const SizedBox(height: 16),

            // Network image example
            PolicyListCard(
              imageUrl: 'https://picsum.photos/72/72',
              title: '청년 주거 지원 프로그램',
              organization: '국토교통부',
              postedDate: '2025/01/10',
              status: RecruitmentStatus.recruiting,
              onTap: () {
                debugPrint('Policy card tapped');
              },
            ),
            const SizedBox(height: 32),

            const Text(
              'In ListView Context',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            // Example in ListView with dividers
            Container(
              height: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                separatorBuilder: (context, index) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  return PolicyListCard(
                    imageUrl: 'assets/images/test/list_sample.png',
                    title: '화성동탄2 A93 동탄호수공... ${index + 1}',
                    organization: '장기전세주택(GH)',
                    postedDate: '2025/04/12',
                    status: index % 2 == 0
                        ? RecruitmentStatus.recruiting
                        : RecruitmentStatus.closed,
                    onTap: () {
                      debugPrint('Card $index tapped');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
