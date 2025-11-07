#!/bin/bash
# Phase 3C - Flutter Realtime Stream Test Script
# Purpose: Verify announcement_tabs realtime stream works
# PRD: v9.6.1 Section 3.1 Flutter Integration

set -e

echo "🧪 Phase 3C - Flutter Realtime Stream Test"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Check Supabase is running
echo "📋 Step 1: Checking Supabase status..."
if npx supabase status &> /dev/null; then
    echo -e "${GREEN}✅ Supabase is running${NC}"
    npx supabase status | grep "API URL"
else
    echo -e "${RED}❌ Supabase is NOT running${NC}"
    echo ""
    echo "Please start Supabase first:"
    echo "  cd /Users/kwonhyunjun/Desktop/pickly_service"
    echo "  npx supabase start"
    exit 1
fi

echo ""

# Step 2: Find Postgres container
echo "📋 Step 2: Finding Supabase Postgres container..."
CONTAINER=$(docker ps --filter "name=supabase-db" --format "{{.Names}}" | head -1)

if [ -z "$CONTAINER" ]; then
    # Try alternative name pattern
    CONTAINER=$(docker ps --filter "name=db" --format "{{.Names}}" | grep supabase | head -1)
fi

if [ -z "$CONTAINER" ]; then
    echo -e "${RED}❌ Supabase Postgres container not found${NC}"
    echo "Available containers:"
    docker ps --format "table {{.Names}}\t{{.Status}}"
    exit 1
fi

echo -e "${GREEN}✅ Found container: $CONTAINER${NC}"
echo ""

# Step 3: Check announcement_tabs table exists and has data
echo "📋 Step 3: Checking announcement_tabs table..."
TAB_COUNT=$(docker exec "$CONTAINER" psql -U postgres -d postgres -t -c \
    "SELECT COUNT(*) FROM announcement_tabs;" 2>&1 | tr -d ' ')

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Table exists with $TAB_COUNT row(s)${NC}"

    if [ "$TAB_COUNT" -eq 0 ]; then
        echo -e "${YELLOW}⚠️  Warning: No data in announcement_tabs table${NC}"
        echo "   You may need to insert test data first"
    fi
else
    echo -e "${RED}❌ Failed to query announcement_tabs table${NC}"
    exit 1
fi

echo ""

# Step 4: Show current tab data
echo "📋 Step 4: Current announcement_tabs data (first 3 rows):"
docker exec "$CONTAINER" psql -U postgres -d postgres -c \
    "SELECT id, tab_name, announcement_id, display_order FROM announcement_tabs ORDER BY display_order LIMIT 3;" \
    2>&1 || echo -e "${YELLOW}⚠️  Could not display data${NC}"

echo ""

# Step 5: Execute test update
echo "📋 Step 5: Executing test UPDATE query..."
echo -e "${YELLOW}🔄 Updating first tab with timestamp...${NC}"

UPDATE_RESULT=$(docker exec "$CONTAINER" psql -U postgres -d postgres -c \
    "UPDATE announcement_tabs
     SET tab_name = '테스트 수정 - ' || NOW()::TEXT
     WHERE id = (SELECT id FROM announcement_tabs ORDER BY display_order LIMIT 1)
     RETURNING id, tab_name;" 2>&1)

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ UPDATE executed successfully${NC}"
    echo "$UPDATE_RESULT"
else
    echo -e "${RED}❌ UPDATE failed${NC}"
    echo "$UPDATE_RESULT"
    exit 1
fi

echo ""
echo "=========================================="
echo -e "${GREEN}✅ Test query executed successfully!${NC}"
echo ""
echo "📱 Now check your Flutter app console for:"
echo "   ✅ Realtime: announcement_tabs stream attached for announcement <id>"
echo "   ✅ Realtime: announcement_tabs updated - N tabs received"
echo ""
echo "🔍 If you see these logs, the realtime stream is working!"
echo ""
echo "📊 To verify the UI updated:"
echo "   1. Check the Flutter app shows the new tab name"
echo "   2. Tab should show: '테스트 수정 - 2025-11-02...'"
echo "   3. No manual refresh should be needed"
echo ""
echo "=========================================="
