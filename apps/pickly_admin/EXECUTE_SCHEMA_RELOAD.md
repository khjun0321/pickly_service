# 🔧 PostgREST Schema Cache Reload - Step-by-Step Guide

**Project**: vymxxpjxrorpywfmqpuk
**Issue**: PGRST205 - Schema cache outdated
**Solution**: Execute NOTIFY command to reload schema

---

## ⚡ Quick Start (3 minutes)

### Step 1: Open Supabase SQL Editor

Go to:
```
https://supabase.com/dashboard/project/vymxxpjxrorpywfmqpuk/sql/new
```

Or:
1. Go to https://supabase.com/dashboard/project/vymxxpjxrorpywfmqpuk
2. Click "SQL Editor" in left sidebar
3. Click "New query"

---

### Step 2: Execute NOTIFY Command

**Copy and paste this EXACT query**:

```sql
NOTIFY pgrst, 'reload schema';
```

**Then click "Run" button** (or press Cmd+Enter / Ctrl+Enter)

**Expected Result**:
```
Success. No rows returned
```

This is **NORMAL** - NOTIFY doesn't return rows!

---

### Step 3: Wait 10 Seconds

PostgREST needs time to reload the schema cache.

```bash
# You can use this terminal command:
sleep 10
```

Or just count to 10 slowly 😊

---

### Step 4: Verify Fix

Open Terminal and run:

```bash
cd ~/Desktop/pickly_service/apps/pickly_admin
node check-production-db.cjs
```

**Expected Output** (after successful reload):

```
📋 Test 2: Accessing announcements table...
✅ announcements table accessible
   Found 3 announcements

📦 Test 3: Accessing benefit_categories table...
✅ benefit_categories table accessible
   Found 5 categories

👶 Test 4: Accessing age_categories table...
✅ age_categories table accessible
   Found 7 age categories

═══════════════════════════════════════════════════
📊 SUMMARY
═══════════════════════════════════════════════════
Connection:               ✅ Success
Anon Key:                 ✅ Valid
announcements table:      ✅ Accessible
benefit_categories table: ✅ Accessible
age_categories table:     ✅ Accessible

✅ ALL CHECKS PASSED!
```

---

### Step 5: Test in Browser

Open:
```
http://localhost:5180
```

Press **F12** → **Console** tab

Look for:
```
🔍 Testing Supabase connection...
✅ Found 2 Storage buckets
✅ Found 3 announcements
🟢 Supabase connection: READY
```

Try logging in:
- Email: `admin@pickly.com`
- Password: `pickly2025!` (or your password)

---

## 🔧 Troubleshooting

### Issue 1: "Permission Denied" Error

**Error**:
```
ERROR: permission denied for function pg_notify
```

**Cause**: You're logged in as anon user, not postgres/service_role

**Solution A** (Dashboard - Recommended):
1. Go to https://supabase.com/dashboard/project/vymxxpjxrorpywfmqpuk/settings/api
2. Click "Restart API" button
3. Wait 15 seconds
4. Skip to Step 4 (Verify Fix)

**Solution B** (Get Service Role Key):
1. Go to https://supabase.com/dashboard/project/vymxxpjxrorpywfmqpuk/settings/api
2. Copy "service_role" key (⚠️ KEEP SECRET)
3. Create new query with service_role authentication
4. Execute NOTIFY command again

---

### Issue 2: Still Getting PGRST205 After NOTIFY

**Symptom**: Verification script still shows errors

**Possible Causes**:
1. Didn't wait long enough (wait 30 seconds instead of 10)
2. PostgREST didn't receive the notification
3. Multiple PostgREST instances (rare)

**Solution**:
1. Try executing NOTIFY again
2. Wait 30 seconds
3. If still failing, use Dashboard "Restart API" method

---

### Issue 3: NOTIFY Succeeded But No Output

**This is NORMAL!**

NOTIFY commands don't return any rows. You should see:
```
Success. No rows returned
```

This means it worked! Proceed to Step 3 (wait 10 seconds).

---

## 📊 Before vs After

### Before NOTIFY

```
❌ announcements table: PGRST205 error
❌ benefit_categories table: PGRST205 error
❌ age_categories table: PGRST205 error
```

### After NOTIFY

```
✅ announcements table: Accessible
✅ benefit_categories table: Accessible
✅ age_categories table: Accessible
```

---

## ⚠️ Important Notes

### About NOTIFY

- **Safe to execute**: Does NOT modify data
- **Safe to retry**: Can execute multiple times
- **No side effects**: Only reloads schema cache
- **Instant**: Takes effect in ~5-10 seconds

### About Permissions

- **SQL Editor**: Usually has postgres permissions by default
- **Anon Key**: Cannot execute NOTIFY (by design)
- **Service Role**: Can execute NOTIFY

If SQL Editor doesn't work, use Dashboard "Restart API" instead.

---

## 🎯 Quick Reference

### SQL Command
```sql
NOTIFY pgrst, 'reload schema';
```

### Verification Command
```bash
cd ~/Desktop/pickly_service/apps/pickly_admin
node check-production-db.cjs
```

### Expected Result
```
✅ ALL CHECKS PASSED!
All tables are accessible through PostgREST API.
```

---

## 📞 Need Help?

If you encounter issues:

1. **Try Dashboard method** (easier):
   - Go to Settings → API
   - Click "Restart API"

2. **Check SQL Editor permissions**:
   - Make sure you're logged in to Dashboard
   - SQL Editor should have postgres role by default

3. **Re-run diagnostic**:
   ```bash
   node check-production-db.cjs
   ```

---

**Ready to execute? Follow Steps 1-5 above!** ✅
