#!/bin/bash

# Pickly Admin v9.12.0 - Schema Reload Verification Script
# This script compares Before/After states and generates a report

echo "🔍 Pickly Admin v9.12.0 - Schema Reload Verification"
echo "════════════════════════════════════════════════════"
echo ""
echo "⏳ Waiting 10 seconds for PostgREST to reload schema cache..."
sleep 10
echo "✅ Wait complete"
echo ""

echo "📋 Running verification check..."
node check-production-db.cjs > /tmp/schema_check_after.log 2>&1

echo ""
echo "════════════════════════════════════════════════════"
echo "📊 BEFORE vs AFTER COMPARISON"
echo "════════════════════════════════════════════════════"
echo ""

# Extract key status from Before log
echo "🔴 BEFORE (Schema Cache Outdated):"
echo "────────────────────────────────────────────────────"
grep "announcements table:" /tmp/schema_check_before.log || echo "   announcements table: ❌ Not accessible"
grep "benefit_categories table:" /tmp/schema_check_before.log || echo "   benefit_categories table: ❌ Not accessible"
grep "age_categories table:" /tmp/schema_check_before.log || echo "   age_categories table: ❌ Not accessible"
echo ""

# Extract key status from After log
echo "🟢 AFTER (After NOTIFY pgrst, 'reload schema'):"
echo "────────────────────────────────────────────────────"
grep "announcements table:" /tmp/schema_check_after.log
grep "benefit_categories table:" /tmp/schema_check_after.log
grep "age_categories table:" /tmp/schema_check_after.log
echo ""

echo "════════════════════════════════════════════════════"
echo "📝 FULL VERIFICATION RESULTS:"
echo "════════════════════════════════════════════════════"
cat /tmp/schema_check_after.log
echo ""

# Check if fix was successful
if grep -q "✅ ALL CHECKS PASSED" /tmp/schema_check_after.log; then
    echo "════════════════════════════════════════════════════"
    echo "🎉 SUCCESS! Schema cache reload completed!"
    echo "════════════════════════════════════════════════════"
    echo ""
    echo "✅ All tables are now accessible"
    echo "✅ PostgREST schema cache is up to date"
    echo "✅ Admin UI should work correctly now"
    echo ""
    echo "🚀 Next Steps:"
    echo "1. Open http://localhost:5180 in browser"
    echo "2. Press F12 → Console"
    echo "3. Look for '🟢 Supabase connection: READY'"
    echo "4. Try logging in with admin@pickly.com"
    echo ""
else
    echo "════════════════════════════════════════════════════"
    echo "⚠️  WARNING: Some tables still not accessible"
    echo "════════════════════════════════════════════════════"
    echo ""
    echo "Possible reasons:"
    echo "1. Didn't wait long enough (try waiting 30 seconds)"
    echo "2. NOTIFY didn't execute successfully"
    echo "3. Need to use Dashboard 'Restart API' instead"
    echo ""
    echo "🔧 Recommended action:"
    echo "Go to: https://supabase.com/dashboard/project/vymxxpjxrorpywfmqpuk/settings/api"
    echo "Click 'Restart API' button"
    echo "Then run this script again"
    echo ""
fi

echo "📁 Logs saved:"
echo "   Before: /tmp/schema_check_before.log"
echo "   After:  /tmp/schema_check_after.log"
echo ""
