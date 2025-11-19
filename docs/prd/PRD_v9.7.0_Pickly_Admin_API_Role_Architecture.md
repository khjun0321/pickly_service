# 📘 Pickly Integrated System — PRD v9.7.0 (Admin API Role Guard Architecture)
**작성일:** 2025-11-07  
**작성자:** PM (사용자)  
**대상:** Pickly Web Admin (Next.js) / Flutter App / Supabase / Claude Code  
**상태:** ✅ Migration Required → Production Ready  
**이전 버전:** v9.6.2  
**핵심 변경:** Supabase RLS 제거 + Next.js Role 기반 보안 구조 전환  

---

## 🎯 개요 (Overview)
v9.7.0은 기존 v9.6.2의 RLS 기반 접근 제어를 완전히 제거하고,  
Next.js Admin API 내부에서만 관리자 권한 검증을 수행하도록 구조를 전환한다.  

> 🎯 목표: “Supabase는 저장소(DB/Storage)만, Next.js가 권한 검증과 로직을 전담한다.”

---

## ⚙️ 주요 변경 사항 요약

| 구분 | v9.6.2 | v9.7.0 |
|------|---------|---------|
| RLS 정책 | auth.jwt()->>'user_role' 기반 정책 다수 | 모두 비활성화 (DISABLE RLS) |
| 권한 검증 위치 | Supabase (DB Policy) | Next.js API 내부 (Session / JWT role check) |
| 파일 업로드 | Storage RLS 정책 필요 | API route에서 service_role key로 처리 |
| 관리자 메타데이터 | user_role='admin' 유지 | 그대로 유지 |
| 앱 반영 방식 | Supabase Realtime | 동일 |
| 구조 복잡도 | 높음 | 단순화 |
| 유지보수 난이도 | 높음 | 매우 낮음 |

---

## 🔐 새로운 보안 모델 (Next.js Role Guard)

```mermaid
graph TD
  A[Admin 로그인] --> B[Supabase Auth JWT 발급]
  B --> C[Next.js API Route 호출]
  C -->|검증| D{session.user.role === 'admin'?}
  D -->|YES| E[Supabase (Service Key) 접근 → DB/Storage 조작]
  D -->|NO| F[403 Forbidden 반환]
  G[Flutter App] -->|anon key| H[Supabase SELECT active 데이터만]
```

---

## 🗄️ Supabase 정책 (v9.7.0)

```sql
ALTER TABLE age_categories DISABLE ROW LEVEL SECURITY;
ALTER TABLE benefit_categories DISABLE ROW LEVEL SECURITY;
ALTER TABLE benefit_subcategories DISABLE ROW LEVEL SECURITY;
ALTER TABLE category_banners DISABLE ROW LEVEL SECURITY;
ALTER TABLE announcements DISABLE ROW LEVEL SECURITY;
ALTER TABLE announcement_tabs DISABLE ROW LEVEL SECURITY;
ALTER TABLE api_sources DISABLE ROW LEVEL SECURITY;
ALTER TABLE raw_announcements DISABLE ROW LEVEL SECURITY;
UPDATE storage.buckets SET public = true WHERE name IN ('benefit-icons', 'home-banners');
```

---

## 🧩 Next.js API 구조

```
/apps/pickly_admin/src/pages/api/
├─ age-categories/
│  ├─ add.ts
│  ├─ update.ts
│  └─ delete.ts
├─ benefit-categories/
│  ├─ add.ts
│  ├─ update.ts
│  └─ delete.ts
├─ upload.ts
└─ auth/
   └─ session.ts
```

---

## 📱 Flutter 앱 영향 없음

| 구분 | 기존 | 변경 후 |
|------|------|---------|
| DB 구조 | 동일 | 동일 |
| 접근 키 | anon key | 그대로 |
| 데이터 반영 | 실시간 | 동일 |
| 보안 정책 | RLS | 비활성화 (Public SELECT) |

---

## 🚀 Claude Code Task 명령어

```bash
claude-code task create --title "🧱 Phase 5.4 — Disable Supabase RLS & Apply Next.js Role Guard (PRD v9.7.0)" --description "
🎯 Objective
Supabase RLS를 완전히 제거하고 Next.js API 내부에서 role 기반 권한 검증을 수행한다.

📘 Reference
- /docs/prd/PRD_v9.7.0_Pickly_Admin_API_Role_Architecture.md
- /backend/supabase/migrations/20251107_disable_all_rls.sql

🧩 Implementation
1. Run migration: disable_all_rls.sql
2. Update Next.js API routes with role checks
3. Verify admin CRUD + file upload
4. Test Flutter app data sync

✅ Success
- Admin API fully working
- Upload works via service_role key
- Flutter app unaffected
"
```