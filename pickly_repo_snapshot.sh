#!/usr/bin/env bash
set -euo pipefail

OUT_DIR=".pickly_snapshot"
rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

# A. 폴더 트리 & 파일 목록
command -v tree >/dev/null 2>&1 && tree -L 4 > "$OUT_DIR/structure_tree.txt" || true
git ls-tree -r --name-only HEAD > "$OUT_DIR/filelist_git.txt" || true
find . -maxdepth 3 -type d | sort > "$OUT_DIR/folders_maxdepth3.txt"

# B. 핵심 구성 파일 수집
mkdir -p "$OUT_DIR/configs"
for f in melos.yaml melos.yml pubspec.yaml README.md; do
  [ -f "$f" ] && cp "$f" "$OUT_DIR/configs/" || true
done

# 모든 pubspec.yaml 모으기
mkdir -p "$OUT_DIR/pubspecs"
find . -name "pubspec.yaml" -print0 | xargs -0 -I{} sh -c 'mkdir -p "$(dirname "$OUT_DIR/pubspecs/{}")"; cp "{}" "$OUT_DIR/pubspecs/{}"' || true

# .claude, .github/workflows, scripts 등 수집
mkdir -p "$OUT_DIR/dots"
[ -d ".claude" ] && rsync -a --exclude="node_modules" .claude "$OUT_DIR/dots/" || true
[ -d ".github/workflows" ] && rsync -a .github/workflows "$OUT_DIR/dots/.github/" || true
[ -d "scripts" ] && rsync -a scripts "$OUT_DIR/" || true

# C. Git 상태/로그
git status -sb > "$OUT_DIR/git_status.txt" || true
git branch -vv > "$OUT_DIR/git_branches.txt" || true
git log --oneline -n 50 > "$OUT_DIR/git_log_last50.txt" || true
git remote -v > "$OUT_DIR/git_remotes.txt" || true

# D. Flutter/Melos 환경(가능하면)
{
  echo "flutter --version:"; flutter --version 2>/dev/null || true
  echo; echo "dart --version:"; dart --version 2>/dev/null || true
  echo; echo "melos --version:"; melos --version 2>/dev/null || true
} > "$OUT_DIR/tool_versions.txt"

# E. 압축
ZIP_NAME="pickly_repo_snapshot_$(date +%Y%m%d_%H%M%S).zip"
rm -f "$ZIP_NAME"
zip -r "$ZIP_NAME" "$OUT_DIR" > /dev/null

echo
echo "✅ 스냅샷 생성 완료: $ZIP_NAME"
echo "   업로드 경로: $(pwd)/$ZIP_NAME"
