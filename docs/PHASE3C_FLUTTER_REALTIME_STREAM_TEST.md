# Phase 3C Test Report
## Flutter Realtime Stream Test (announcement_tabs, PRD v9.6.1)

**Test Date**: 2025-11-02 21:00 KST (Documentation)
**Test Execution**: Pending (Automated test script ready)
**PRD Version**: v9.6.1 - Pickly Integrated System
**Status**: 🧪 **TEST TOOLS READY - AWAITING SUPABASE START**

### 🚀 Quick Start

**Automated Test** (Recommended):
```bash
cd /Users/kwonhyunjun/Desktop/pickly_service
./scripts/test_realtime_stream.sh
```

**Manual Test Guide**: See `docs/PHASE3C_MANUAL_TEST_GUIDE.md`

---

## 🎯 Purpose & PRD Reference

**Purpose**: Verify that the realtime stream implementation for `announcement_tabs` (added in Phase 3B) actually works in practice by testing the Supabase → Flutter data flow.

**Analogy**: "Testing if the hot water pipe actually flows warm water" - we built the pipe in Phase 3B, now we verify it works.

**PRD References**:
- Section 3.1 - Flutter Integration
- Section 4.4.2 - Scheduled Automation (reference only)

**Dependencies**:
- Phase 3A: Field mapping fixes (completed)
- Phase 3B: Realtime stream implementation (completed)

---

## 🧱 Test Scenarios

### Prerequisite Setup

**Required Components**:
1. ✅ Supabase local instance running
   ```bash
   cd /Users/kwonhyunjun/Desktop/pickly_service
   npx supabase start
   ```

2. ✅ Flutter app running on simulator/device
   ```bash
   cd apps/pickly_mobile
   flutter run
   ```

3. ✅ Terminal window to view Flutter logs
   ```bash
   # Logs will show:
   # "✅ Realtime: announcement_tabs stream attached..."
   ```

4. ✅ Supabase Studio or SQL console access
   - URL: http://127.0.0.1:54323 (default Supabase Studio)
   - Or use SQL console for direct queries

---

### Test Scenario 1: Basic Realtime Update ✅

**Objective**: Verify Admin → Flutter realtime data flow works

**Step 1: Navigate to Announcement Detail**
```dart
// In Flutter app:
1. Open any announcement that has tabs
2. Navigate to detail screen
3. Check terminal logs for:
   "✅ Realtime: announcement_tabs stream attached for announcement <id>"
```

**Step 2: Update Tab Data in Supabase**
```sql
-- SQL Console (Supabase Studio → SQL Editor):
UPDATE announcement_tabs
SET tab_name = '테스트 수정 - ' || NOW()
WHERE id = (SELECT id FROM announcement_tabs LIMIT 1);
```

**Step 3: Verify Flutter Receives Update**

**Expected Log Output**:
```
✅ Realtime: announcement_tabs stream attached for announcement abc-123
✅ Realtime: announcement_tabs updated - 3 tabs received
```

**Expected UI Behavior**:
- Tab name updates automatically (no manual refresh)
- Updated tab shows new name "테스트 수정 - 2025-11-02..."

**Pass Criteria**:
- ✅ Stream attachment log appears on detail screen load
- ✅ Update log appears within 1-2 seconds of SQL UPDATE
- ✅ UI refreshes automatically with new tab name
- ✅ No app crash or error logs

---

### Test Scenario 2: Insert New Tab ✅

**Objective**: Verify realtime stream handles INSERT operations

**Setup**:
```sql
-- Get existing announcement ID
SELECT id, title FROM announcements LIMIT 1;
-- Copy the ID (e.g., 'ann-456')
```

**Test Query**:
```sql
INSERT INTO announcement_tabs (
  id,
  announcement_id,
  tab_name,
  display_order
) VALUES (
  gen_random_uuid(),
  'ann-456',  -- Use actual announcement ID from above
  '신규 탭 테스트',
  999
);
```

**Expected Behavior**:
```
✅ Realtime: announcement_tabs updated - 4 tabs received
```
- Tab count increases by 1
- New tab appears at end (display_order = 999)
- UI adds new tab to list automatically

**Pass Criteria**:
- ✅ New tab appears without page refresh
- ✅ Tab count in log increases
- ✅ No duplicate tabs or UI glitches

---

### Test Scenario 3: Delete Tab ✅

**Objective**: Verify realtime stream handles DELETE operations

**Test Query**:
```sql
DELETE FROM announcement_tabs
WHERE id = (
  SELECT id FROM announcement_tabs
  ORDER BY display_order DESC
  LIMIT 1
);
```

**Expected Behavior**:
```
✅ Realtime: announcement_tabs updated - 3 tabs received
```
- Tab count decreases by 1
- Deleted tab disappears from UI
- Remaining tabs re-render correctly

**Pass Criteria**:
- ✅ Tab disappears immediately
- ✅ No orphaned UI elements
- ✅ Tab list reorders correctly

---

### Test Scenario 4: Update Multiple Tabs ✅

**Objective**: Test realtime with bulk updates

**Test Query**:
```sql
UPDATE announcement_tabs
SET tab_name = tab_name || ' [수정됨]'
WHERE announcement_id = 'ann-456';
```

**Expected Behavior**:
```
✅ Realtime: announcement_tabs updated - 3 tabs received
```
- All tabs for the announcement update
- Each tab shows " [수정됨]" suffix
- Only one realtime event (not 3 separate events)

**Pass Criteria**:
- ✅ Single log entry for bulk update
- ✅ All affected tabs update
- ✅ No performance degradation

---

### Test Scenario 5: Error Handling - Empty Result ✅

**Objective**: Test null-safe behavior with no tabs

**Setup**:
```sql
-- Delete all tabs for an announcement
DELETE FROM announcement_tabs
WHERE announcement_id = 'ann-789';
```

**Expected Behavior**:
```
✅ Realtime: announcement_tabs stream attached for announcement ann-789
✅ Realtime: announcement_tabs updated - 0 tabs received
```

**UI Behavior**:
- Shows empty state message
- No crash or null pointer errors
- Graceful degradation

**Pass Criteria**:
- ✅ Log shows "0 tabs received"
- ✅ App doesn't crash
- ✅ Empty state UI displays

---

### Test Scenario 6: Error Handling - Network Interruption ⚠️

**Objective**: Test stream reconnection behavior

**Test Procedure**:
```bash
# Stop Supabase while app is running
npx supabase stop

# Wait 5 seconds

# Restart Supabase
npx supabase start
```

**Expected Behavior**:
```
⚠️ Realtime: announcement_tabs stream error - <connection error>
✅ Realtime: announcement_tabs stream attached...  (after reconnect)
```

**Pass Criteria**:
- ✅ Error logged but app doesn't crash
- ✅ Stream automatically reconnects
- ✅ Data syncs after reconnection

**Note**: Supabase Flutter SDK handles reconnection automatically

---

### Test Scenario 7: Performance - High Frequency Updates ⚠️

**Objective**: Test stream performance with rapid updates

**Test Query** (run rapidly):
```sql
DO $$
BEGIN
  FOR i IN 1..10 LOOP
    UPDATE announcement_tabs
    SET tab_name = 'Stress Test ' || i
    WHERE id = (SELECT id FROM announcement_tabs LIMIT 1);
    PERFORM pg_sleep(0.1);  -- 100ms delay
  END LOOP;
END $$;
```

**Expected Behavior**:
- Multiple update logs in quick succession
- UI updates smoothly without lag
- Final state matches database

**Pass Criteria**:
- ✅ All 10 updates logged
- ✅ No UI freezing or lag
- ✅ Memory usage stays stable

---

## 📄 Test Execution Checklist

### Pre-Test Setup ☐

```bash
# 1. Start Supabase
cd /Users/kwonhyunjun/Desktop/pickly_service
npx supabase start

# 2. Verify Supabase is running
npx supabase status
# Should show: API URL: http://127.0.0.1:54321

# 3. Check announcement_tabs has data
docker exec -it $(docker ps --filter "name=db" -q) \
  psql -U postgres -d postgres -c \
  "SELECT COUNT(*) FROM announcement_tabs;"

# 4. Start Flutter app
cd apps/pickly_mobile
flutter run

# 5. Open terminal for logs
# Logs appear in console where `flutter run` was executed
```

### During Testing ☐

**For Each Scenario**:
1. ☐ Execute SQL query in Supabase Studio
2. ☐ Observe Flutter console logs
3. ☐ Check UI updates in app
4. ☐ Record results (pass/fail)
5. ☐ Take screenshot if needed

### Post-Test Cleanup ☐

```sql
-- Restore original data if needed
UPDATE announcement_tabs
SET tab_name = '원본 탭 이름'
WHERE tab_name LIKE '%테스트%' OR tab_name LIKE '%수정%';
```

---

## 🧩 Expected vs Actual Results

### Test Matrix

| Scenario | Expected Log | Expected UI | Status | Notes |
|----------|--------------|-------------|--------|-------|
| **1. Basic Update** | "✅ tabs updated - N" | Tab name changes | ☐ PENDING | - |
| **2. Insert Tab** | "✅ tabs updated - N+1" | New tab appears | ☐ PENDING | - |
| **3. Delete Tab** | "✅ tabs updated - N-1" | Tab disappears | ☐ PENDING | - |
| **4. Bulk Update** | Single log entry | All tabs update | ☐ PENDING | - |
| **5. Empty Result** | "0 tabs received" | Empty state UI | ☐ PENDING | - |
| **6. Network Error** | "⚠️ stream error" | Reconnects | ☐ PENDING | Manual |
| **7. Stress Test** | 10 log entries | Smooth updates | ☐ PENDING | Optional |

### Automated Test Command

**Quick Smoke Test**:
```bash
# Create test script: test_realtime_stream.sh
cat > test_realtime_stream.sh << 'EOF'
#!/bin/bash
echo "🧪 Testing announcement_tabs realtime stream..."

# Get container ID
CONTAINER=$(docker ps --filter "name=db" -q)

if [ -z "$CONTAINER" ]; then
  echo "❌ Supabase not running. Run 'npx supabase start' first."
  exit 1
fi

echo "✅ Supabase container found: $CONTAINER"

# Test 1: Get baseline count
echo "📊 Current tab count:"
docker exec $CONTAINER psql -U postgres -d postgres -c \
  "SELECT COUNT(*) FROM announcement_tabs;"

# Test 2: Update a tab
echo "🔄 Updating tab..."
docker exec $CONTAINER psql -U postgres -d postgres -c \
  "UPDATE announcement_tabs SET tab_name = '테스트 - ' || NOW() WHERE id = (SELECT id FROM announcement_tabs LIMIT 1);"

echo "✅ Test query executed. Check Flutter logs for:"
echo "   '✅ Realtime: announcement_tabs updated - N tabs received'"
EOF

chmod +x test_realtime_stream.sh
./test_realtime_stream.sh
```

---

## 📊 Verification Logs

### Code Locations to Monitor

**File**: `apps/pickly_mobile/lib/contexts/benefit/repositories/announcement_repository.dart`

**Lines 160-177**: `watchAnnouncementTabs()` method

**Key Log Points**:

1. **Stream Attachment** (Line 160):
   ```dart
   print('✅ Realtime: announcement_tabs stream attached for announcement $announcementId');
   ```
   **When**: Stream `.listen()` is called
   **Indicates**: Subscription established

2. **Data Update** (Line 170):
   ```dart
   print('✅ Realtime: announcement_tabs updated - ${tabs.length} tabs received');
   ```
   **When**: Supabase sends realtime event
   **Indicates**: Data successfully received and parsed

3. **Error Handling** (Line 174):
   ```dart
   print('⚠️ Realtime: announcement_tabs stream error - $error');
   ```
   **When**: Stream encounters error
   **Indicates**: Connection issue or data problem

### Log Interpretation Guide

**✅ Good Patterns**:
```
✅ Realtime: announcement_tabs stream attached for announcement abc-123
✅ Realtime: announcement_tabs updated - 3 tabs received
✅ Realtime: announcement_tabs updated - 4 tabs received  (after INSERT)
```

**⚠️ Warning Patterns**:
```
⚠️ Realtime: announcement_tabs stream error - Connection closed
✅ Realtime: announcement_tabs stream attached...  (auto-reconnect)
```

**❌ Error Patterns** (Should Not Occur):
```
❌ No log appears when navigating to detail screen
   → Stream not being subscribed

❌ Update log never appears after SQL UPDATE
   → Realtime not working or wrong announcement_id

❌ "stream error" followed by app crash
   → Error handling broken
```

---

## 🚀 Production Readiness Indicators

### Success Criteria

**All Must Pass**:
- ✅ Stream attaches on detail screen load
- ✅ Updates appear within 2 seconds of database change
- ✅ UI refreshes without manual reload
- ✅ No crashes on edge cases (empty data, errors)
- ✅ Memory usage stable during prolonged use

### Performance Benchmarks

| Metric | Target | Measurement Method |
|--------|--------|--------------------|
| **Latency** | < 2 seconds | Time from SQL UPDATE to log |
| **UI Refresh** | < 500ms | Time from log to UI update |
| **Memory** | < 50MB increase | Monitor over 100 updates |
| **Reconnect** | < 5 seconds | After network interruption |

### Known Limitations

**Supabase Realtime Constraints**:
- Maximum 100 concurrent subscriptions per client
- Filters must use indexed columns for performance
- Realtime only works for tables with `REPLICA IDENTITY` set

**Flutter SDK Behavior**:
- Reconnection handled automatically by Supabase client
- Backpressure handling: drops intermediate updates if UI can't keep up
- Stream disposal required to prevent memory leaks (handled by Riverpod)

---

## 📚 Reference Documents

### Code Implementation
- **Phase 3B Report**: `docs/PHASE3B_FLUTTER_REALTIME_AND_UI_SYNC_FIX.md`
  - Lines 157-177: `watchAnnouncementTabs()` implementation

### Database Schema
- **Table**: `announcement_tabs`
- **Columns**: `id`, `announcement_id`, `tab_name`, `display_order`, etc.
- **Migration**: `backend/supabase/migrations/20241030000000_create_announcements.sql`

### PRD
- **v9.6.1**: `docs/prd/PRD_v9.6_Pickly_Integrated_System_UPDATED_v9.6.1.md`
- Section 3.1: Flutter Integration Requirements

---

## 📝 Manual Test Execution Template

```markdown
### Test Execution Log - [Date]

**Tester**: [Name]
**Environment**: [Simulator/Device]
**Supabase Version**: [Check with `npx supabase --version`]
**Flutter Version**: [Check with `flutter --version`]

---

#### Scenario 1: Basic Update
- SQL Query Executed: ✅ / ❌
- Log "stream attached" seen: ✅ / ❌
- Log "tabs updated" seen: ✅ / ❌
- UI refreshed: ✅ / ❌
- Time to update: ____ seconds
- Screenshot: [attach if issues]
- Notes: ____

#### Scenario 2: Insert Tab
- SQL Query Executed: ✅ / ❌
- New tab appeared: ✅ / ❌
- Tab count correct: ✅ / ❌
- Notes: ____

[... continue for all scenarios ...]

---

**Overall Result**: PASS / FAIL
**Blockers**: [List any issues]
**Recommendations**: [Improvements needed]
```

---

## 🎯 Summary

### What This Test Validates

**Phase 3B Implementation**:
- ✅ `watchAnnouncementTabs()` method works correctly
- ✅ Supabase realtime subscription established
- ✅ Data flows from Admin → Database → Flutter
- ✅ UI updates automatically without refresh

**Production Readiness**:
- ✅ Error handling prevents crashes
- ✅ Null-safe for edge cases
- ✅ Performance acceptable for real-world use
- ✅ Logs provide debugging visibility

### What This Test Does NOT Cover

**Out of Scope**:
- ❌ Admin UI functionality (covered in Phase 2 tests)
- ❌ Database schema correctness (covered in Phase 2-3 verification)
- ❌ Field mapping (covered in Phase 3A)
- ❌ Other realtime streams (announcements, categories, etc.)

**Future Testing Needs**:
- End-to-end automated tests (Flutter integration tests)
- Load testing with many concurrent users
- Cross-device compatibility testing

---

## ✅ Completion Checklist

**Before Marking Complete**:
- ☐ Supabase started successfully
- ☐ Flutter app running on device/simulator
- ☐ At least Scenario 1 (Basic Update) tested manually
- ☐ All logs appeared as expected
- ☐ UI updated automatically
- ☐ No crashes or errors encountered
- ☐ Test results documented in this file
- ☐ Screenshots captured (if issues found)

**Status Options**:
- 📋 **DOCUMENTED** - Test procedure ready, awaiting execution
- 🧪 **IN PROGRESS** - Currently executing tests
- ✅ **PASSED** - All scenarios passed successfully
- ⚠️ **PARTIAL** - Some scenarios passed, some failed
- ❌ **FAILED** - Critical scenarios failed, issues found

**Current Status**: 📋 **DOCUMENTED - READY FOR EXECUTION**

---

**Test procedure documented. Execute when Supabase and Flutter app are running.** 📋

**Phase 3C - TEST DOCUMENTATION COMPLETE**

---

**End of Phase 3C Test Report**
