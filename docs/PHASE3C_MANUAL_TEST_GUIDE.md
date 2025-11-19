# Phase 3C - Manual Test Execution Guide
## Flutter Realtime Stream Verification (PRD v9.6.1)

**Date**: 2025-11-02
**Purpose**: Step-by-step guide to verify `announcement_tabs` realtime stream
**Analogy**: 💧 "Turn on the water faucet and check if warm water flows"

---

## 🚀 Quick Start (Automated)

```bash
# Navigate to project
cd /Users/kwonhyunjun/Desktop/pickly_service

# Run automated test script
./scripts/test_realtime_stream.sh
```

**Expected Output**:
```
✅ Supabase is running
✅ Found container: supabase-db-pickly_service
✅ Table exists with 5 row(s)
✅ UPDATE executed successfully
```

Then check Flutter console for realtime logs.

---

## 📋 Manual Test Procedure

### Pre-Test Setup (Do Once)

#### 1. Start Supabase

```bash
cd /Users/kwonhyunjun/Desktop/pickly_service
npx supabase start
```

**Wait for**:
```
Started supabase local development setup.

         API URL: http://127.0.0.1:54321
          DB URL: postgresql://postgres:postgres@127.0.0.1:54322/postgres
      Studio URL: http://127.0.0.1:54323
```

#### 2. Verify Database Has Data

```bash
# Find Postgres container
docker ps | grep supabase

# Check announcement_tabs
docker exec -it <container-name> psql -U postgres -d postgres -c \
  "SELECT COUNT(*) FROM announcement_tabs;"
```

**Expected**: At least 1 row

**If empty**, insert test data:
```sql
INSERT INTO announcement_tabs (
  id, announcement_id, tab_name, display_order
) VALUES (
  gen_random_uuid(),
  (SELECT id FROM announcements LIMIT 1),
  '테스트 탭',
  1
);
```

#### 3. Start Flutter App

```bash
cd apps/pickly_mobile
flutter run
```

**Choose device**: Select simulator or connected device

**Wait for**: App to fully load and show home screen

---

### Test Execution (Main Test)

#### Step 1: Navigate to Announcement Detail

**In Flutter App**:
1. Open "혜택" (Benefits) tab
2. Tap any announcement card
3. Navigate to detail screen

**Expected Console Log**:
```
✅ Realtime: announcement_tabs stream attached for announcement <uuid>
```

**Screenshot location**: Take screenshot of detail screen

---

#### Step 2: Execute Database Update

**Option A: Using Test Script**
```bash
./scripts/test_realtime_stream.sh
```

**Option B: Manual SQL (Supabase Studio)**
1. Open http://127.0.0.1:54323
2. Go to SQL Editor
3. Execute:
```sql
UPDATE announcement_tabs
SET tab_name = '테스트 수정 - ' || NOW()::TEXT
WHERE id = (SELECT id FROM announcement_tabs LIMIT 1);
```

**Option C: Direct Docker Command**
```bash
docker exec -it <container-name> psql -U postgres -d postgres -c \
  "UPDATE announcement_tabs
   SET tab_name = '테스트 수정 - ' || NOW()::TEXT
   WHERE id = (SELECT id FROM announcement_tabs LIMIT 1);"
```

---

#### Step 3: Observe Flutter Console

**Expected Logs** (within 1-2 seconds):
```
✅ Realtime: announcement_tabs updated - 3 tabs received
```

**Log Breakdown**:
- `✅ Realtime:` - Realtime event received
- `announcement_tabs updated` - Data source
- `3 tabs received` - Number of tabs after update

---

#### Step 4: Verify UI Update

**Check Flutter App UI**:
- Tab name should update automatically
- No manual refresh needed
- New tab name: "테스트 수정 - 2025-11-02 20:XX:XX..."

**Screenshot location**: Take screenshot showing updated tab name

---

### Test Results Documentation

#### Test Log Template

```markdown
### Phase 3C Test Execution - [Date/Time]

**Tester**: [Your Name]
**Device**: [iOS Simulator / Android Emulator / Real Device]
**Flutter Version**: [flutter --version]
**Supabase Version**: [npx supabase --version]

---

#### Pre-Test Checks
- [ ] Supabase running (API URL: http://127.0.0.1:54321)
- [ ] announcement_tabs has data (_____ rows)
- [ ] Flutter app running on device
- [ ] Console logs visible

#### Test Execution
- [ ] Navigated to announcement detail screen
- [ ] Saw "stream attached" log
- [ ] Executed UPDATE query
- [ ] Saw "tabs updated" log within 2 seconds
- [ ] UI refreshed automatically

#### Timing Measurements
- Time from UPDATE to log: _____ seconds
- Time from log to UI update: _____ ms

#### Screenshots
- [x] Before update: [file path]
- [x] After update: [file path]
- [x] Console logs: [file path]

#### Issues Encountered
- [ ] None - All passed ✅
- [ ] Issue 1: [Description]
- [ ] Issue 2: [Description]

#### Overall Result
- [ ] ✅ PASS - Realtime stream working perfectly
- [ ] ⚠️  PARTIAL - Some issues but functional
- [ ] ❌ FAIL - Critical issues found

**Notes**:
[Additional observations, edge cases tested, etc.]
```

---

## 🧪 Additional Test Scenarios

### Scenario A: Insert New Tab

```sql
INSERT INTO announcement_tabs (
  id, announcement_id, tab_name, display_order
) VALUES (
  gen_random_uuid(),
  '<announcement-id>',
  '신규 탭 테스트',
  999
);
```

**Expected**:
- Log: "tabs updated - N+1 tabs received"
- UI: New tab appears at end

---

### Scenario B: Delete Tab

```sql
DELETE FROM announcement_tabs
WHERE id = (
  SELECT id FROM announcement_tabs
  ORDER BY display_order DESC
  LIMIT 1
);
```

**Expected**:
- Log: "tabs updated - N-1 tabs received"
- UI: Tab disappears

---

### Scenario C: Bulk Update

```sql
UPDATE announcement_tabs
SET tab_name = tab_name || ' [수정됨]'
WHERE announcement_id = '<announcement-id>';
```

**Expected**:
- Log: Single "tabs updated" event
- UI: All tabs show suffix

---

### Scenario D: Empty Result

```sql
DELETE FROM announcement_tabs
WHERE announcement_id = '<announcement-id>';
```

**Expected**:
- Log: "tabs updated - 0 tabs received"
- UI: Empty state message (no crash)

---

## 🔍 Troubleshooting

### Issue: No "stream attached" log

**Possible Causes**:
1. Flutter app not using `watchAnnouncementTabs()` method
2. Detail screen not mounted
3. Logs filtered out

**Solution**:
```bash
# Check if using stream method
cd apps/pickly_mobile
grep -r "watchAnnouncementTabs" lib/
```

---

### Issue: No "tabs updated" log after UPDATE

**Possible Causes**:
1. Wrong `announcement_id` in filter
2. Supabase realtime not enabled for table
3. Network issue

**Solution**:
```sql
-- Check if announcement_id matches
SELECT announcement_id, COUNT(*)
FROM announcement_tabs
GROUP BY announcement_id;

-- Verify realtime enabled
SELECT schemaname, tablename
FROM pg_publication_tables
WHERE tablename = 'announcement_tabs';
```

---

### Issue: Log appears but UI doesn't update

**Possible Causes**:
1. UI widget not listening to stream
2. State management issue
3. Riverpod not rebuilding

**Solution**:
- Check if widget uses `StreamBuilder` or Riverpod `AsyncValue`
- Verify `setState()` or `ref.watch()` is called
- Add debug print in widget build method

---

## 📊 Performance Benchmarks

### Target Metrics

| Metric | Target | Acceptable | Poor |
|--------|--------|------------|------|
| **Latency** (UPDATE → Log) | < 1s | < 2s | > 3s |
| **UI Refresh** (Log → UI) | < 300ms | < 500ms | > 1s |
| **Memory Impact** | < 20MB | < 50MB | > 100MB |

### How to Measure

**Latency**:
```bash
# Before UPDATE
date +%s.%N

# Execute UPDATE
docker exec ... psql -c "UPDATE ..."

# Check Flutter console timestamp
# Calculate difference
```

**Memory**:
- iOS: Xcode Instruments Memory Profiler
- Android: Android Studio Profiler
- Check before and after 100 updates

---

## ✅ Success Criteria

**Minimum Requirements (MUST PASS)**:
- [x] Stream attaches on detail screen load
- [x] Updates logged within 2 seconds
- [x] UI refreshes without manual reload
- [x] No crashes on edge cases

**Ideal Performance (SHOULD PASS)**:
- [ ] Latency < 1 second
- [ ] UI refresh < 300ms
- [ ] Memory usage stable

**Production Ready (NICE TO HAVE)**:
- [ ] Works on real device (not just simulator)
- [ ] Handles network interruption gracefully
- [ ] Scales to 10+ tabs per announcement

---

## 📝 Test Report Template (Final)

```markdown
# Phase 3C Test Report - EXECUTED
**Date**: 2025-11-0X
**Status**: ✅ PASS / ⚠️ PARTIAL / ❌ FAIL

## Summary
- Tests Executed: X/7
- Tests Passed: X
- Tests Failed: X
- Overall Result: PRODUCTION READY / NEEDS FIXES

## Detailed Results

### Scenario 1: Basic Update
- Result: PASS/FAIL
- Latency: X.XX seconds
- Notes: [...]

### Scenario 2: Insert Tab
- Result: PASS/FAIL
- Notes: [...]

[... continue for all scenarios ...]

## Issues Found
1. [Issue description]
   - Severity: CRITICAL / HIGH / MEDIUM / LOW
   - Workaround: [...]
   - Fix needed: [...]

## Recommendations
1. [...]
2. [...]

## Conclusion
[Final assessment of realtime stream readiness]
```

---

## 🎯 Quick Reference

### Essential Commands

```bash
# Start Supabase
npx supabase start

# Run automated test
./scripts/test_realtime_stream.sh

# Start Flutter
cd apps/pickly_mobile && flutter run

# Check logs in real-time
# (Logs appear in terminal where flutter run was executed)

# Stop Supabase
npx supabase stop
```

### Key Files

- Test Script: `scripts/test_realtime_stream.sh`
- Implementation: `apps/pickly_mobile/lib/contexts/benefit/repositories/announcement_repository.dart:157-177`
- Documentation: `docs/PHASE3C_FLUTTER_REALTIME_STREAM_TEST.md`
- This Guide: `docs/PHASE3C_MANUAL_TEST_GUIDE.md`

---

**Ready to test!** Follow the steps above and document your results. 🧪
