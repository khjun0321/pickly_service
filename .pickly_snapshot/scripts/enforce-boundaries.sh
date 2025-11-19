#!/usr/bin/env bash
set -euo pipefail
BAD_F2F_REL=$(grep -R -nE "import\s+['\"][.]{2}/.*/features/" apps/pickly_mobile/lib/features || true)
BAD_C2F=$(grep -R -nE "import\s+['\"].*/features/" apps/pickly_mobile/lib/contexts || true)
if [ -n "$BAD_F2F_REL$BAD_C2F" ]; then
  echo "[BOUNDARY] 경계 위반 발견"; 
  [ -n "$BAD_F2F_REL" ] && echo "$BAD_F2F_REL";
  [ -n "$BAD_C2F" ] && echo "$BAD_C2F";
  exit 1;
fi
echo "[BOUNDARY] OK"
