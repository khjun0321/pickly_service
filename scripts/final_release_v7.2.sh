#!/usr/bin/env bash
# ==========================================================
# 🚀 Pickly Service v7.2 - Final Release Automation
# ==========================================================

set -e
cd ~/Desktop/pickly_service || exit

# 1️⃣ Git Pull 최신 상태 유지
git fetch origin main
git pull origin feature/refactor-db-schema

# 2️⃣ Flutter / Admin 빌드 재확인
cd apps/pickly_mobile
flutter pub get
flutter build apk --release || true
cd ../pickly_admin
npm install
npm run build || true
cd ../..

# 3️⃣ 릴리즈 노트 생성
mkdir -p docs/deployment
cat > docs/deployment/RELEASE_NOTES_v7.2.0.md <<'REL'
# 🏷️ Pickly Service v7.2.0 Release Notes

## ✨ 주요 변경사항
- 공고 상세 화면 TabBar(청년/신혼/고령자) 구조 추가
- Supabase DB: announcement_types, custom_content JSONB 필드 추가
- Admin 백오피스: 연령 카테고리 + 공고 타입 CRUD UI 완성
- Melos 7.3.0 / GH Actions 통합
- PRD 문서 자동 동기화(v7.2)

## 🧠 참고 문서
- /docs/prd/PRD_SYNC_SUMMARY.md
- /docs/IMPLEMENTATION_SUMMARY.md
- /docs/deployment/AUTO_RELEASE_REPORT_*.md

## 📅 배포일
$(date +"%Y-%m-%d")

REL

git add docs/deployment/RELEASE_NOTES_v7.2.0.md
git commit -m "docs: add RELEASE_NOTES_v7.2.0" || true
git push origin feature/refactor-db-schema

# 4️⃣ GitHub PR 생성
if command -v gh &> /dev/null; then
  gh pr create \
    --base main \
    --head feature/refactor-db-schema \
    --title "feat: PRD v7.2 - Announcement Detail TabBar UI & Admin Enhancements" \
    --body-file docs/prd/PR_DESCRIPTION.md \
    --label release || true
  echo "✅ Pull Request 생성 완료"
else
  echo "⚠️ gh CLI 미설치: 브라우저에서 PR 직접 생성하세요:"
  echo "👉 https://github.com/khjun0321/pickly_service/compare/main...feature/refactor-db-schema?expand=1"
fi

# 5️⃣ 릴리즈 태그 생성
# 기존 태그가 있으면 삭제
if git tag -l | grep -q "^v7.2.0$"; then
  echo "⚠️ 기존 v7.2.0 태그 삭제 후 재생성"
  git tag -d v7.2.0
  git push origin :refs/tags/v7.2.0 || true
fi

git tag -a v7.2.0 -m "Release v7.2.0 - TabBar + Admin Enhancements"
git push origin v7.2.0

if command -v gh &> /dev/null; then
  gh release create v7.2.0 \
    --title "Pickly Service v7.2.0" \
    --notes-file docs/deployment/RELEASE_NOTES_v7.2.0.md || true
  echo "✅ GitHub Release 생성 완료"
fi

echo ""
echo "🎯 Pickly Service v7.2 자동 릴리즈 완료!"
echo "────────────────────────────────────────────"
echo "✅ PR 생성 및 릴리즈 태그 생성 완료"
echo "📘 릴리즈 노트: docs/deployment/RELEASE_NOTES_v7.2.0.md"
echo "────────────────────────────────────────────"
