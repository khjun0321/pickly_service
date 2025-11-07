#!/bin/bash

# Pickly Supabase Seed Data Automation
# Purpose: Execute all seed scripts in correct order
# PRD: v9.9.7 Seed Automation
# Date: 2025-11-07
#
# Usage:
#   chmod +x run_all.sh
#   ./run_all.sh
#   OR from parent directory: bash seed/run_all.sh

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Database connection info (default Supabase local)
DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-54322}"
DB_NAME="${DB_NAME:-postgres}"
DB_USER="${DB_USER:-postgres}"
DB_PASSWORD="${DB_PASSWORD:-postgres}"

# Container name (for docker exec)
CONTAINER_NAME="${CONTAINER_NAME:-supabase_db_supabase}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}🌱 Pickly Seed Data Automation${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if running inside Docker or locally
if [ -f /.dockerenv ]; then
    echo -e "${YELLOW}📦 Running inside Docker container${NC}"
    PSQL_CMD="psql -U ${DB_USER} -d ${DB_NAME}"
else
    echo -e "${YELLOW}💻 Running on host machine${NC}"

    # Check if docker container exists
    if docker ps --filter "name=${CONTAINER_NAME}" --format "{{.Names}}" | grep -q "${CONTAINER_NAME}"; then
        echo -e "${GREEN}✓ Found Docker container: ${CONTAINER_NAME}${NC}"
        PSQL_CMD="docker exec ${CONTAINER_NAME} psql -U ${DB_USER} -d ${DB_NAME}"
    else
        echo -e "${RED}✗ Docker container '${CONTAINER_NAME}' not found${NC}"
        echo -e "${YELLOW}→ Trying local psql connection...${NC}"
        PSQL_CMD="PGPASSWORD=${DB_PASSWORD} psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME}"
    fi
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}📊 Database Connection Test${NC}"
echo -e "${BLUE}========================================${NC}"

if $PSQL_CMD -c "SELECT version();" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Database connection successful${NC}"
else
    echo -e "${RED}✗ Database connection failed${NC}"
    echo -e "${YELLOW}Please check your database configuration${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}🚀 Running Seed Scripts${NC}"
echo -e "${BLUE}========================================${NC}"

# Execute seed scripts in order
seed_scripts=(
    "01_age_categories.sql"
    "02_benefit_categories.sql"
    "03_benefit_subcategories.sql"
)

for script in "${seed_scripts[@]}"; do
    script_path="${SCRIPT_DIR}/${script}"

    echo ""
    echo -e "${YELLOW}📄 Executing: ${script}${NC}"

    if [ ! -f "$script_path" ]; then
        echo -e "${RED}✗ File not found: ${script}${NC}"
        exit 1
    fi

    if [ -f /.dockerenv ]; then
        # Inside Docker: use psql directly
        if $PSQL_CMD -f "$script_path"; then
            echo -e "${GREEN}✓ ${script} completed successfully${NC}"
        else
            echo -e "${RED}✗ ${script} failed${NC}"
            exit 1
        fi
    else
        # Outside Docker: pipe to docker exec
        if docker ps --filter "name=${CONTAINER_NAME}" --format "{{.Names}}" | grep -q "${CONTAINER_NAME}"; then
            if cat "$script_path" | docker exec -i ${CONTAINER_NAME} psql -U ${DB_USER} -d ${DB_NAME}; then
                echo -e "${GREEN}✓ ${script} completed successfully${NC}"
            else
                echo -e "${RED}✗ ${script} failed${NC}"
                exit 1
            fi
        else
            # Local psql
            if PGPASSWORD=${DB_PASSWORD} psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -f "$script_path"; then
                echo -e "${GREEN}✓ ${script} completed successfully${NC}"
            else
                echo -e "${RED}✗ ${script} failed${NC}"
                exit 1
            fi
        fi
    fi
done

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}📊 Final Verification${NC}"
echo -e "${BLUE}========================================${NC}"

# Verification query
VERIFY_QUERY="
SELECT
  '✅ Seed Complete' as status,
  (SELECT COUNT(*) FROM public.age_categories) as age_categories_count,
  (SELECT COUNT(*) FROM public.benefit_categories WHERE is_active = true) as benefit_categories_count;
"

echo -e "${YELLOW}Running verification query...${NC}"
$PSQL_CMD -c "$VERIFY_QUERY"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ All seed scripts completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Verify data in Supabase Studio"
echo -e "  2. Test Flutter app data loading"
echo -e "  3. Check icon display in simulator"
echo ""
