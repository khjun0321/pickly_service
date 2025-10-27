#!/bin/bash

# =====================================================
# Storage Setup Test Script
# =====================================================
# Tests the Supabase Storage configuration for Pickly
# =====================================================

set -e  # Exit on error

echo "🚀 Pickly Storage Setup Test"
echo "=============================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PROJECT_ROOT="/Users/kwonhyunjun/Desktop/pickly_service"
SUPABASE_DIR="$PROJECT_ROOT/supabase"

cd "$PROJECT_ROOT"

# =====================================================
# 1. Check Supabase CLI
# =====================================================
echo -e "${BLUE}Step 1: Checking Supabase CLI...${NC}"
if command -v supabase &> /dev/null; then
    SUPABASE_VERSION=$(supabase --version)
    echo -e "${GREEN}✓ Supabase CLI installed: $SUPABASE_VERSION${NC}"
else
    echo -e "${RED}✗ Supabase CLI not found. Install with: npm install -g supabase${NC}"
    exit 1
fi
echo ""

# =====================================================
# 2. Check if Supabase is running
# =====================================================
echo -e "${BLUE}Step 2: Checking Supabase status...${NC}"
if supabase status > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Supabase is running${NC}"
    supabase status
else
    echo -e "${YELLOW}⚠ Supabase is not running. Starting...${NC}"
    cd "$SUPABASE_DIR"
    supabase start
    cd "$PROJECT_ROOT"
fi
echo ""

# =====================================================
# 3. Apply storage migration
# =====================================================
echo -e "${BLUE}Step 3: Applying storage migration...${NC}"
cd "$SUPABASE_DIR"
if supabase db reset --debug; then
    echo -e "${GREEN}✓ Migration applied successfully${NC}"
else
    echo -e "${RED}✗ Migration failed${NC}"
    exit 1
fi
cd "$PROJECT_ROOT"
echo ""

# =====================================================
# 4. Check storage bucket exists
# =====================================================
echo -e "${BLUE}Step 4: Verifying storage bucket...${NC}"

STORAGE_CHECK_SQL="SELECT id, name, public FROM storage.buckets WHERE id = 'pickly-storage';"
BUCKET_INFO=$(supabase db execute --csv "$STORAGE_CHECK_SQL" 2>/dev/null || echo "")

if [[ -n "$BUCKET_INFO" ]]; then
    echo -e "${GREEN}✓ Storage bucket 'pickly-storage' exists${NC}"
    echo "$BUCKET_INFO"
else
    echo -e "${RED}✗ Storage bucket not found${NC}"
    exit 1
fi
echo ""

# =====================================================
# 5. Create test image
# =====================================================
echo -e "${BLUE}Step 5: Creating test image...${NC}"

STORAGE_DIR="$SUPABASE_DIR/storage"
mkdir -p "$STORAGE_DIR/banners/test"

# Create a simple test image using ImageMagick or base64
TEST_IMAGE_PATH="$STORAGE_DIR/banners/test/sample.jpg"

# Create a simple red square as a test image (base64 encoded minimal JPEG)
echo "/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAIBAQIBAQICAgICAgICAwUDAwMDAwYEBAMFBwYHBwcGBwcICQsJCAgKCAcHCg0KCgsMDAwMBwkODw0MDgsMDAz/2wBDAQICAgMDAwYDAwYMCAcIDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAz/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAr/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCwAA8A/9k=" | base64 -d > "$TEST_IMAGE_PATH"

if [ -f "$TEST_IMAGE_PATH" ]; then
    echo -e "${GREEN}✓ Test image created at: $TEST_IMAGE_PATH${NC}"
    ls -lh "$TEST_IMAGE_PATH"
else
    echo -e "${YELLOW}⚠ Test image creation failed, but continuing...${NC}"
fi
echo ""

# =====================================================
# 6. Check folder structure metadata
# =====================================================
echo -e "${BLUE}Step 6: Checking folder structure...${NC}"

FOLDERS_SQL="SELECT path, description FROM storage_folders ORDER BY path;"
FOLDERS=$(supabase db execute --csv "$FOLDERS_SQL" 2>/dev/null || echo "")

if [[ -n "$FOLDERS" ]]; then
    echo -e "${GREEN}✓ Folder structure configured:${NC}"
    echo "$FOLDERS"
else
    echo -e "${YELLOW}⚠ No folder structure found${NC}"
fi
echo ""

# =====================================================
# 7. Check storage policies
# =====================================================
echo -e "${BLUE}Step 7: Verifying storage policies...${NC}"

POLICIES_SQL="SELECT schemaname, tablename, policyname, permissive, roles, cmd FROM pg_policies WHERE tablename = 'objects' AND schemaname = 'storage';"
POLICIES=$(supabase db execute --csv "$POLICIES_SQL" 2>/dev/null || echo "")

if [[ -n "$POLICIES" ]]; then
    echo -e "${GREEN}✓ Storage policies configured:${NC}"
    echo "$POLICIES" | head -20
else
    echo -e "${YELLOW}⚠ No storage policies found${NC}"
fi
echo ""

# =====================================================
# 8. Test file tracking
# =====================================================
echo -e "${BLUE}Step 8: Checking file tracking system...${NC}"

FILES_SQL="SELECT file_type, storage_path, file_name, public_url FROM benefit_files;"
FILES=$(supabase db execute --csv "$FILES_SQL" 2>/dev/null || echo "")

if [[ -n "$FILES" ]]; then
    echo -e "${GREEN}✓ File tracking system working:${NC}"
    echo "$FILES"
else
    echo -e "${YELLOW}⚠ No tracked files found (this is normal for fresh setup)${NC}"
fi
echo ""

# =====================================================
# 9. Get storage statistics
# =====================================================
echo -e "${BLUE}Step 9: Storage statistics...${NC}"

STATS_SQL="SELECT * FROM v_storage_stats;"
STATS=$(supabase db execute --csv "$STATS_SQL" 2>/dev/null || echo "")

if [[ -n "$STATS" ]]; then
    echo -e "${GREEN}✓ Storage statistics:${NC}"
    echo "$STATS"
else
    echo -e "${YELLOW}⚠ No storage statistics available yet${NC}"
fi
echo ""

# =====================================================
# 10. Get Supabase project URL
# =====================================================
echo -e "${BLUE}Step 10: Getting project URLs...${NC}"

STATUS_OUTPUT=$(supabase status)
API_URL=$(echo "$STATUS_OUTPUT" | grep "API URL:" | awk '{print $3}')
STUDIO_URL=$(echo "$STATUS_OUTPUT" | grep "Studio URL:" | awk '{print $3}')

if [[ -n "$API_URL" ]]; then
    STORAGE_URL="${API_URL}/storage/v1"
    PUBLIC_URL="${API_URL}/storage/v1/object/public/pickly-storage"

    echo -e "${GREEN}✓ Project URLs:${NC}"
    echo "  API URL: $API_URL"
    echo "  Storage API: $STORAGE_URL"
    echo "  Public Storage: $PUBLIC_URL"
    echo "  Studio: $STUDIO_URL"
else
    echo -e "${YELLOW}⚠ Could not determine project URLs${NC}"
fi
echo ""

# =====================================================
# Summary
# =====================================================
echo ""
echo -e "${GREEN}=============================="
echo "✓ Storage Setup Complete!"
echo "==============================${NC}"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "1. Access Supabase Studio: $STUDIO_URL"
echo "2. Navigate to Storage section"
echo "3. Verify 'pickly-storage' bucket exists"
echo "4. Test file uploads via API or SDK"
echo ""
echo -e "${BLUE}Test Upload Command:${NC}"
echo "curl -X POST '$STORAGE_URL/object/pickly-storage/test/sample.jpg' \\"
echo "  -H 'Authorization: Bearer YOUR_ANON_KEY' \\"
echo "  -F 'file=@/path/to/image.jpg'"
echo ""
echo -e "${BLUE}Public URL Format:${NC}"
echo "$PUBLIC_URL/banners/test/sample.jpg"
echo ""
