#!/bin/bash
set -e
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
echo -e "${BLUE}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      🚨 Supabase LOCAL Recovery Script      ║${NC}"
echo -e "${BLUE}║         (LOCAL 환경 전용 / 안전 모드)        ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════╝${NC}"
echo ""
PROJECT_ROOT="/Users/kwonhyunjun/Desktop/pickly_service"
SUPABASE_DIR="$PROJECT_ROOT/supabase"
MIGRATIONS_DIR="$SUPABASE_DIR/migrations"
if [ ! -d "$SUPABASE_DIR" ]; then echo "missing supabase directory"; exit 1; fi
if [ ! -d "$MIGRATIONS_DIR" ]; then echo "missing migrations directory"; exit 1; fi
cd "$SUPABASE_DIR"
supabase stop || true
docker ps -a --format '{{.ID}}\t{{.Names}}' | grep supabase | awk '{print $1}' | xargs -r docker rm -f || true
docker volume ls --format '{{.Name}}' | grep supabase | xargs -r docker volume rm || true
cd "$MIGRATIONS_DIR"
BACKUP_DIR="$MIGRATIONS_DIR/.backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
find "$MIGRATIONS_DIR" -maxdepth 1 -name "*.disabled" -exec mv {} "$BACKUP_DIR/" \; || true
find "$MIGRATIONS_DIR" -maxdepth 1 -name "*.sql" ! -name "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_*.sql" -exec mv {} "$BACKUP_DIR/" \; || true
cd "$SUPABASE_DIR"
cat > seed.sql << 'SEEDEOF'
-- Pickly Supabase local seed file (LOCAL ONLY)
-- Admin account is created via migration 20251108000001_seed_admin_user.sql
SEEDEOF
supabase start
echo "checking auth columns…"
docker exec supabase_db_pickly_service psql -U postgres -d postgres -c "SELECT column_name FROM information_schema.columns WHERE table_schema='auth' AND table_name='users';"
echo "checking admin user…"
docker exec supabase_db_pickly_service psql -U postgres -d postgres -c "SELECT email FROM auth.users WHERE email='admin@pickly.com';"
docker exec supabase_db_pickly_service psql -U postgres -d postgres -c "UPDATE auth.users SET confirmation_token='', recovery_token='', email_change_token_new='', email_change_token_current='', reauthentication_token='' WHERE email='admin@pickly.com';" || true
echo "checking buckets…"
docker exec supabase_db_pickly_service psql -U postgres -d postgres -c "SELECT name FROM storage.buckets;"
echo "checking rpc…"
docker exec supabase_db_pickly_service psql -U postgres -d postgres -c "SELECT proname FROM pg_proc WHERE proname='save_announcement_with_details';"
echo "DONE"
supabase status
