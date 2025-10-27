#!/bin/bash

# LH API 통합 Flutter 앱 설정 스크립트

set -e

echo "🚀 LH API 통합을 위한 Flutter 앱 설정을 시작합니다..."

# 현재 디렉토리 확인
if [ ! -f "apps/pickly_mobile/pubspec.yaml" ]; then
  echo "❌ 오류: pickly_service 프로젝트 루트 디렉토리에서 실행해주세요."
  exit 1
fi

cd apps/pickly_mobile

echo ""
echo "📦 1. Flutter 패키지 설치..."
flutter pub get

echo ""
echo "🔨 2. 코드 생성 (Freezed, Riverpod)..."
dart run build_runner build --delete-conflicting-outputs

echo ""
echo "✅ 설정 완료!"
echo ""
echo "📝 다음 단계:"
echo "  1. 백엔드 마이그레이션 적용: cd backend/supabase/supabase && supabase db reset"
echo "  2. Edge Function 배포: supabase functions deploy fetch-lh-announcements"
echo "  3. Flutter 앱 실행: flutter run"
echo ""
echo "📚 자세한 내용은 docs/flutter-setup-guide.md를 참고하세요."
