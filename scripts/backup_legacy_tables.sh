#!/bin/bash

# =====================================================
# Legacy Tables Backup Script
# =====================================================
# Purpose: Backup legacy database tables before cleanup
# Date: 2025-11-03
# Usage: ./backup_legacy_tables.sh
# =====================================================

set -e  # Exit on error

# Configuration
BACKUP_DIR="docs/history/db_backup_legacy_20251103"
CONTAINER_NAME="supabase_db_pickly_service"
DB_USER="postgres"
DB_NAME="postgres"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =====================================================
# Helper functions
# =====================================================

log_info() {
  echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
  echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
  echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
  echo -e "${RED}❌ $1${NC}"
}

# =====================================================
# Check prerequisites
# =====================================================

log_info "Checking prerequisites..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
  log_error "Docker is not running. Please start Docker first."
  exit 1
fi

# Check if Supabase container exists
if ! docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  log_error "Supabase container '${CONTAINER_NAME}' not found."
  log_info "Available containers:"
  docker ps -a --format 'table {{.Names}}\t{{.Status}}'
  exit 1
fi

# Check if container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  log_warning "Container '${CONTAINER_NAME}' is not running. Starting it..."
  docker start "${CONTAINER_NAME}"
  sleep 3
fi

log_success "Prerequisites check passed"

# =====================================================
# Create backup directory
# =====================================================

log_info "Creating backup directory: ${BACKUP_DIR}"
mkdir -p "${BACKUP_DIR}"
log_success "Backup directory created"

# =====================================================
# Check which tables exist
# =====================================================

log_info "Checking which legacy tables exist..."

check_table_exists() {
  local table_name=$1
  docker exec "${CONTAINER_NAME}" psql -U "${DB_USER}" -d "${DB_NAME}" -tAc \
    "SELECT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = '${table_name}');"
}

# Check tables
BENEFIT_ANNOUNCEMENTS_EXISTS=$(check_table_exists "benefit_announcements")
HOUSING_ANNOUNCEMENTS_EXISTS=$(check_table_exists "housing_announcements")
DISPLAY_ORDER_HISTORY_EXISTS=$(check_table_exists "display_order_history")

echo ""
log_info "Table existence check:"
echo "  benefit_announcements: ${BENEFIT_ANNOUNCEMENTS_EXISTS}"
echo "  housing_announcements: ${HOUSING_ANNOUNCEMENTS_EXISTS}"
echo "  display_order_history: ${DISPLAY_ORDER_HISTORY_EXISTS}"
echo ""

# =====================================================
# Backup function
# =====================================================

backup_table() {
  local table_name=$1
  local exists=$2

  if [ "${exists}" = "t" ]; then
    log_info "Backing up table: ${table_name}"

    # Get row count
    local row_count=$(docker exec "${CONTAINER_NAME}" psql -U "${DB_USER}" -d "${DB_NAME}" -tAc \
      "SELECT COUNT(*) FROM ${table_name};")
    log_info "  Rows to backup: ${row_count}"

    # Export data to CSV
    log_info "  Exporting data to CSV..."
    docker exec "${CONTAINER_NAME}" psql -U "${DB_USER}" -d "${DB_NAME}" -c \
      "COPY ${table_name} TO '/tmp/${table_name}_backup.csv' DELIMITER ',' CSV HEADER;" > /dev/null

    # Copy CSV from container to host
    docker cp "${CONTAINER_NAME}:/tmp/${table_name}_backup.csv" "${BACKUP_DIR}/"

    # Export schema
    log_info "  Exporting schema..."
    docker exec "${CONTAINER_NAME}" pg_dump -U "${DB_USER}" -d "${DB_NAME}" \
      --schema-only --table="${table_name}" > "${BACKUP_DIR}/${table_name}_schema.sql"

    # Calculate MD5 checksum
    if command -v md5sum &> /dev/null; then
      local checksum=$(md5sum "${BACKUP_DIR}/${table_name}_backup.csv" | cut -d' ' -f1)
    elif command -v md5 &> /dev/null; then
      local checksum=$(md5 -q "${BACKUP_DIR}/${table_name}_backup.csv")
    else
      local checksum="N/A"
    fi

    log_success "  Backup complete!"
    log_info "  Files:"
    log_info "    - ${BACKUP_DIR}/${table_name}_backup.csv (${row_count} rows)"
    log_info "    - ${BACKUP_DIR}/${table_name}_schema.sql"
    log_info "    - MD5: ${checksum}"
    echo ""

    # Return checksum for manifest
    echo "${checksum}"
  else
    log_warning "Table ${table_name} does not exist. Skipping backup."
    echo ""
    echo "N/A"
  fi
}

# =====================================================
# Backup all legacy tables
# =====================================================

log_info "Starting backup process..."
echo ""

BENEFIT_ANNOUNCEMENTS_MD5=$(backup_table "benefit_announcements" "${BENEFIT_ANNOUNCEMENTS_EXISTS}")
HOUSING_ANNOUNCEMENTS_MD5=$(backup_table "housing_announcements" "${HOUSING_ANNOUNCEMENTS_EXISTS}")
DISPLAY_ORDER_HISTORY_MD5=$(backup_table "display_order_history" "${DISPLAY_ORDER_HISTORY_EXISTS}")

# =====================================================
# Create backup manifest
# =====================================================

log_info "Creating backup manifest..."

cat > "${BACKUP_DIR}/BACKUP_MANIFEST.md" << EOF
# Legacy Tables Backup Manifest
**Date**: $(date +"%Y-%m-%d %H:%M:%S")
**Backup Location**: /${BACKUP_DIR}/
**Container**: ${CONTAINER_NAME}
**Database**: ${DB_NAME}

---

## Backed Up Tables

### benefit_announcements
- **Exists**: ${BENEFIT_ANNOUNCEMENTS_EXISTS}
- **Rows Backed Up**: $([ "${BENEFIT_ANNOUNCEMENTS_EXISTS}" = "t" ] && docker exec "${CONTAINER_NAME}" psql -U "${DB_USER}" -d "${DB_NAME}" -tAc "SELECT COUNT(*) FROM benefit_announcements;" || echo "N/A")
- **Files**:
  - \`benefit_announcements_backup.csv\` - Data dump
  - \`benefit_announcements_schema.sql\` - Schema definition
- **MD5 Checksum**: ${BENEFIT_ANNOUNCEMENTS_MD5}
- **Reason**: Legacy table, possibly replaced by \`announcements\`

### housing_announcements
- **Exists**: ${HOUSING_ANNOUNCEMENTS_EXISTS}
- **Rows Backed Up**: $([ "${HOUSING_ANNOUNCEMENTS_EXISTS}" = "t" ] && docker exec "${CONTAINER_NAME}" psql -U "${DB_USER}" -d "${DB_NAME}" -tAc "SELECT COUNT(*) FROM housing_announcements;" || echo "N/A")
- **Files**:
  - \`housing_announcements_backup.csv\` - Data dump
  - \`housing_announcements_schema.sql\` - Schema definition
- **MD5 Checksum**: ${HOUSING_ANNOUNCEMENTS_MD5}
- **Reason**: Legacy table, possibly old name before v7.3 renaming

### display_order_history
- **Exists**: ${DISPLAY_ORDER_HISTORY_EXISTS}
- **Rows Backed Up**: $([ "${DISPLAY_ORDER_HISTORY_EXISTS}" = "t" ] && docker exec "${CONTAINER_NAME}" psql -U "${DB_USER}" -d "${DB_NAME}" -tAc "SELECT COUNT(*) FROM display_order_history;" || echo "N/A")
- **Files**:
  - \`display_order_history_backup.csv\` - Data dump
  - \`display_order_history_schema.sql\` - Schema definition
- **MD5 Checksum**: ${DISPLAY_ORDER_HISTORY_MD5}
- **Reason**: Audit trail, may be archived

---

## Restoration Procedure

If cleanup causes issues, restore with:

\`\`\`bash
# 1. Restore schema
docker exec -i ${CONTAINER_NAME} psql -U ${DB_USER} -d ${DB_NAME} < \\
  ${BACKUP_DIR}/[table_name]_schema.sql

# 2. Copy CSV to container
docker cp ${BACKUP_DIR}/[table_name]_backup.csv ${CONTAINER_NAME}:/tmp/

# 3. Restore data
docker exec ${CONTAINER_NAME} psql -U ${DB_USER} -d ${DB_NAME} -c \\
  "COPY [table_name] FROM '/tmp/[table_name]_backup.csv' DELIMITER ',' CSV HEADER;"
\`\`\`

---

## Verification

\`\`\`bash
# Verify row count matches backup
docker exec ${CONTAINER_NAME} psql -U ${DB_USER} -d ${DB_NAME} -c \\
  "SELECT COUNT(*) FROM [table_name];"

# Verify data integrity
docker exec ${CONTAINER_NAME} psql -U ${DB_USER} -d ${DB_NAME} -c \\
  "SELECT * FROM [table_name] LIMIT 10;"
\`\`\`

---

**Backup completed**: $(date +"%Y-%m-%d %H:%M:%S")
EOF

log_success "Backup manifest created: ${BACKUP_DIR}/BACKUP_MANIFEST.md"

# =====================================================
# Summary
# =====================================================

echo ""
echo "╔════════════════════════════════════════════════════╗"
echo "║  Backup Complete!                                  ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""
log_info "Backup Summary:"
echo "  📁 Location: ${BACKUP_DIR}/"
echo "  📋 Tables backed up:"
[ "${BENEFIT_ANNOUNCEMENTS_EXISTS}" = "t" ] && echo "    ✅ benefit_announcements" || echo "    ⚠️  benefit_announcements (does not exist)"
[ "${HOUSING_ANNOUNCEMENTS_EXISTS}" = "t" ] && echo "    ✅ housing_announcements" || echo "    ⚠️  housing_announcements (does not exist)"
[ "${DISPLAY_ORDER_HISTORY_EXISTS}" = "t" ] && echo "    ✅ display_order_history" || echo "    ⚠️  display_order_history (does not exist)"
echo ""
log_info "Next steps:"
echo "  1. Review backup manifest: ${BACKUP_DIR}/BACKUP_MANIFEST.md"
echo "  2. Review cleanup report: docs/DB_LEGACY_CLEANUP_REPORT.md"
echo "  3. Update Flutter code if benefit_announcements exists"
echo "  4. Regenerate TypeScript types"
echo "  5. Execute cleanup migration"
echo ""
log_success "All done! 🎉"
