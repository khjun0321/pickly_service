import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pickly_design_system/pickly_design_system.dart';
import 'package:pickly_mobile/core/router.dart';

/// 온보딩 시작 화면
///
/// 피클리 앱에 처음 진입한 사용자를 환영하고
/// 온보딩 프로세스를 시작하도록 안내합니다.
class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColors.app,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Spacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 상단 여백
              const SizedBox(height: Spacing.xl),

              // 환영 메시지
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '피클리에 오신 것을 환영합니다',
                    style: PicklyTypography.titleLarge.copyWith(
                      color: BrandColors.primary,
                    ),
                  ),
                  SizedBox(height: Spacing.md),
                  Text(
                    '나에게 딱 맞는 정책과 혜택을\n쉽고 빠르게 찾아보세요',
                    style: PicklyTypography.bodyLarge.copyWith(
                      color: TextColors.secondary,
                    ),
                  ),
                ],
              ),

              // 하단 버튼
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push(Routes.personalInfo);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BrandColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        '시작하기',
                        style: PicklyTypography.buttonLarge.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: Spacing.md),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
