#!/bin/bash
# Seed Data Protection Script
# Prevents accidental overwriting of production tables

set -e

SEED_FILE="backend/supabase/seed.sql"
PROTECTED_TABLES=(
  "age_categories"
  "benefit_categories"
  "category_banners"
  "announcements"
  "benefit_announcements"
)

echo "🔒 Protecting seed.sql from overwriting production tables..."

if [ ! -f "$SEED_FILE" ]; then
  echo "⚠️  Warning: $SEED_FILE not found!"
  exit 0
fi

# Create backup
BACKUP_FILE="${SEED_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
cp "$SEED_FILE" "$BACKUP_FILE"
echo "📦 Backup created: $BACKUP_FILE"

# Check and remove protected table references
for table in "${PROTECTED_TABLES[@]}"; do
  if grep -q "$table" "$SEED_FILE" 2>/dev/null; then
    echo "⚠️  Found $table in seed.sql — removing for safety."

    # Remove lines containing the table name
    if [[ "$OSTYPE" == "darwin"* ]]; then
      # macOS
      sed -i '' "/$table/d" "$SEED_FILE"
    else
      # Linux
      sed -i "/$table/d" "$SEED_FILE"
    fi
  else
    echo "✅ $table - no references found"
  fi
done

echo ""
echo "✅ Seed protection complete!"
echo "📁 Protected tables: ${PROTECTED_TABLES[*]}"
echo "💾 Backup location: $BACKUP_FILE"
