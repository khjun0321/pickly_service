# Flow Fix Testing Guide

**Date**: 2025-11-04
**Fix Commit**: `41ea525`
**Status**: Ready for Testing

---

## 🎯 Quick Test Instructions

### **Test 1: Onboarding Flow (PRIMARY FIX)**

**Expected**: Splash → Age → Region → Home completes without blocking

```bash
# Start the Flutter app
cd apps/pickly_mobile
flutter run
```

**Steps**:
1. ✅ App opens to Splash screen
2. ✅ Automatically navigates to Age Category screen
3. ✅ Select an age category (e.g., "청년")
4. ✅ Tap "다음" button
5. ✅ Navigate to Region Selection screen
6. ✅ Select a region (e.g., "서울")
7. ✅ Tap "완료" button
8. ✅ **CRITICAL**: Home screen loads successfully (no freezing, no blank screen)

**Success Criteria**:
- No navigation blocking
- Home screen appears immediately
- No error messages in console
- Smooth transition

---

### **Test 2: Benefits Tab**

**Expected**: Benefits screen loads when tapped, categories display correctly

**Steps**:
1. ✅ Complete onboarding (reach Home screen)
2. ✅ Tap "혜택" tab in bottom navigation
3. ✅ Benefits screen loads
4. ✅ Category tabs appear (인기, 주거, 교육, etc.)
5. ✅ Tap different category tabs
6. ✅ Content updates correctly

**Success Criteria**:
- Benefits screen loads without delay
- Categories display correctly
- Tab switching works smoothly
- No console errors

---

### **Test 3: Realtime Sync Verification**

**Expected**: Admin changes reflect in Flutter app

**Prerequisites**:
- Supabase running locally
- Admin panel accessible at `http://localhost:3001`

**Steps**:
1. ✅ Open Flutter app and navigate to Benefits screen
2. ✅ Open Admin panel in browser
3. ✅ Navigate to "혜택 카테고리 관리"
4. ✅ Edit a category (change name or icon)
5. ✅ Click "저장"
6. ✅ **CHECK**: Flutter app updates automatically (within 1-2 seconds)

**Success Criteria**:
- Changes appear in app without refresh
- No errors in console
- Stream connection stable

---

## 🐛 Troubleshooting

### **Issue**: Home screen still blank/frozen

**Solution**:
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### **Issue**: Benefits screen doesn't load

**Check**:
1. Console for error messages
2. Network connection
3. Supabase running: `supabase status`

### **Issue**: Realtime sync not working

**Check**:
1. Supabase running: `cd backend/supabase && supabase start`
2. `.env` file has correct `SUPABASE_URL` and `SUPABASE_ANON_KEY`
3. Check console for stream errors

---

## 📊 Console Output to Check

### **Good Signs** ✅:
```
🌊 [Stream Provider] Starting benefit categories stream (with autoDispose)
🌊 [Stream Provider] Delay complete, initializing realtime stream
📋 [Categories Stream] Loaded 9 categories
🔍 [Router] Redirect check: path=/home, onboardingComplete=true
```

### **Bad Signs** ❌:
```
❌ [Stream Error] Categories stream failed: <error>
❌ [Parsing Error] Failed to parse categories: <error>
TimeoutException after 10 seconds
```

---

## 🧪 Advanced Testing

### **Network Failure Test**

**Steps**:
1. Disable network (airplane mode)
2. Open app
3. Navigate through onboarding
4. **CHECK**: App still works, empty state shown for categories

**Expected**: Graceful degradation, no crashes

### **Slow Network Test**

**Steps**:
1. Enable network throttling in Chrome DevTools
2. Complete onboarding
3. Navigate to Benefits
4. **CHECK**: Stream timeout after 10 seconds, empty state shown

**Expected**: Timeout handled, no infinite loading

---

## 📝 Test Results Template

```markdown
## Test Results - [Date]

### Onboarding Flow
- [ ] Splash loads
- [ ] Age category works
- [ ] Region selection works
- [ ] Home screen loads successfully
- [ ] No navigation blocking

### Benefits Screen
- [ ] Tab loads when tapped
- [ ] Categories display
- [ ] Tab switching works
- [ ] State preserved

### Realtime Sync
- [ ] Admin changes reflect in app
- [ ] Stream updates work
- [ ] No errors in console

### Error Scenarios
- [ ] Network timeout handled
- [ ] Stream errors recovered
- [ ] Empty state shown correctly

**Overall Status**: ✅ PASS / ❌ FAIL

**Notes**:
[Any issues or observations]
```

---

## 🚀 Ready to Deploy?

### **Checklist**:
- [ ] All tests pass
- [ ] No console errors
- [ ] Performance acceptable
- [ ] Realtime sync works
- [ ] Error handling verified

### **Deploy Command**:
```bash
# If all tests pass
git push origin fix/v8.0-rebuild

# Or merge to main
git checkout main
git merge fix/v8.0-rebuild
git push origin main
```

---

**Testing Complete!** ✅

If you encounter any issues, check:
1. `docs/FLOW_REGRESSION_REPORT.md` - Root cause analysis
2. `docs/FLOW_REGRESSION_FIX_SUMMARY.md` - Implementation details
3. Console logs for detailed error messages
