# 🚀 Phase 5.3 Quick Start Guide — PRD v9.6.2

**For**: Admin File Upload Fix
**Time Required**: 5-10 minutes
**Status**: Ready to Execute

---

## 📋 What You Need to Do

Phase 5.3 fixes ALL admin file upload issues by implementing proper role-based RLS policies. Follow these 3 simple steps:

---

## Step 1: Apply Migrations via Supabase Studio (RECOMMENDED)

### 1.1 Open Supabase Studio
- URL: http://localhost:54323 (local dev)
- Or your production Supabase Studio URL

### 1.2 Go to SQL Editor
- Click "SQL Editor" in left sidebar
- Click "New Query"

### 1.3 Apply Migration 1: RLS Policies
Copy and paste the **ENTIRE contents** of:
```
backend/supabase/migrations/20251106000001_fix_rls_admin_role_guard_prd_v9_6_2.sql
```

Click "Run" (bottom right)

**Expected Output**:
```
✅ Step 1: All existing RLS policies dropped
✅ Step 2.1: benefit_categories RLS policies created
✅ Step 2.2: benefit_subcategories RLS policies created
✅ Step 2.3: age_categories RLS policies created
✅ Step 2.4: announcements RLS policies created
📊 RLS Policy Count:
  benefit_categories: 5
  benefit_subcategories: 5
  age_categories: 5
  announcements: 5
✅ All RLS policies created successfully
```

### 1.4 Apply Migration 2: Storage Policies
Click "New Query" again

Copy and paste the **ENTIRE contents** of:
```
backend/supabase/migrations/20251106000002_fix_storage_bucket_policies_prd_v9_6_2.sql
```

Click "Run"

**Expected Output**:
```
✅ Step 1: Storage buckets created/updated
✅ Step 2: All existing storage policies dropped
✅ Step 3.1: benefit-icons storage policies created
✅ Step 3.2: home-banners storage policies created
📊 Storage Configuration:
  Buckets created: 2
  Total storage.objects policies: 8
  benefit-icons policies: 4
  home-banners policies: 4
✅ All storage policies created successfully
```

### 1.5 Apply Migration 3: Admin Metadata
Click "New Query" again

Copy and paste the **ENTIRE contents** of:
```
backend/supabase/migrations/20251106000003_update_admin_user_metadata.sql
```

Click "Run"

**Expected Output**:
```
📊 Admin Users Configuration:
  Total admin users: 1 (or more)
  Admin emails: admin@pickly.com, dev@pickly.com (or your admin email)
✅ Admin user metadata updated successfully
```

---

## Step 2: Verify Everything Works

### 2.1 Check RLS Policies
In Supabase Studio SQL Editor, run:

```sql
SELECT tablename, COUNT(*) as policy_count
FROM pg_policies
WHERE tablename IN ('benefit_categories', 'benefit_subcategories', 'age_categories', 'announcements')
GROUP BY tablename
ORDER BY tablename;
```

**You should see**:
```
tablename                  | policy_count
---------------------------+-------------
age_categories             | 5
announcements              | 5
benefit_categories         | 5
benefit_subcategories      | 5
```

### 2.2 Check Storage Policies
Run:

```sql
SELECT COUNT(*) as storage_policy_count
FROM pg_policies
WHERE schemaname = 'storage' AND tablename = 'objects';
```

**You should see**: `8`

### 2.3 Check Admin User
Run:

```sql
SELECT email, raw_app_meta_data->>'user_role' as role
FROM auth.users
WHERE raw_app_meta_data->>'user_role' = 'admin';
```

**You should see**: At least one row with your admin email

---

## Step 3: Test File Upload in Admin UI

### 3.1 Login to Admin
- Open Admin panel: http://localhost:3000
- Login with your admin credentials

### 3.2 Try Uploading a File
1. Navigate to: 혜택 관리 → 대분류 관리
2. Click "추가" (Add) button
3. Fill in category details
4. **Upload an icon file (SVG)** ← This is the test!
5. Click "저장" (Save)

### 3.3 Expected Result
✅ File uploads successfully
✅ Category created with icon URL
✅ Icon visible in category list
✅ No errors in browser console

---

## ✅ Success Criteria

You're done when:
- [x] All 3 migrations applied successfully
- [x] Verification queries show correct policy counts
- [x] Admin can upload files without errors
- [x] Flutter app still loads data correctly (no regression)

---

## 🐛 If Something Goes Wrong

### Error: "new row violates row-level security policy"

**Solution**: Admin user missing `user_role` metadata

Run this:
```sql
UPDATE auth.users
SET raw_app_meta_data = '{"user_role": "admin"}'::jsonb
WHERE email = 'YOUR_ADMIN_EMAIL@example.com';
```

### Error: File upload shows 403 Forbidden

**Solution**: Re-run migration 2 (storage policies)

### Error: Flutter app shows empty list

**Solution**: Check if public policies exist:
```sql
SELECT tablename, policyname
FROM pg_policies
WHERE policyname LIKE '%public%select%';
```

Should show 4 rows (one per table)

---

## 📞 Quick Reference

**Migrations Location**: `backend/supabase/migrations/`

**Files**:
1. `20251106000001_fix_rls_admin_role_guard_prd_v9_6_2.sql`
2. `20251106000002_fix_storage_bucket_policies_prd_v9_6_2.sql`
3. `20251106000003_update_admin_user_metadata.sql`

**Documentation**:
- Full Guide: `docs/PHASE5_3_COMPLETE_PRD_v9_6_2_IMPLEMENTATION.md`
- PRD: `docs/prd/PRD_v9.6.2_Pickly_Admin_RLS_and_Storage_Policy.md`

---

**That's it! Phase 5.3 complete in 3 steps. 파일 업로드가 이제 정상적으로 작동할 겁니다!**
