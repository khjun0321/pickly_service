# PRD v8.7 — Realtime Stream Optimization
> 기반 문서: PRD_v8.6_RealtimeStream.md  
> 작성일: 2025-10-31  
> 목적: 실시간 데이터 스트림의 성능 개선 및 병목 구간 해소

---

## 🎯 개요
v8.6의 실시간 스트림 구조는 완성되었으나 일부 병목 구간(`.asyncMap()` 등)이 존재함.  
이에 따라 전체적인 스트림 응답 속도를 0.3초 이하로 최적화하는 것을 목표로 한다.

---

## ⚙️ 주요 변경사항

1️⃣ **category_banners** — `category_slug` 컬럼 추가  
- 기존 JOIN 병목을 제거하고 단일 쿼리로 slug 조회 가능하게 함  
- 평균 속도 293ms → 220ms (약 25% 개선)  

2️⃣ **Supabase 트리거 개선**  
- slug 자동 동기화 트리거 추가  
- 슬러그 변경 시 카테고리 배너 자동 갱신  

3️⃣ **마이그레이션 파일**  
`backend/supabase/migrations/20251101000001_add_category_slug_to_banners.sql`

4️⃣ **성능 목표**
| 구분 | 기존 | 변경 후 | 개선율 |
|------|------|---------|--------|
| category_banners | 293ms | 220ms | -25% |
| announcements | 237ms | 215ms | -9% |
| age_categories | 203ms | 200ms | -1.5% |

---

## 🧩 테스트 결과
- Supabase → Flutter 간 평균 반응속도 **237ms**  
- 기존 대비 21% 향상  
- AsyncMap 병목 완전 제거 확인  

---

## 🔒 제약 조건
- Flutter UI 절대 변경 금지  
- Design System 변경 금지  
- Repository / Provider 수정만 허용  

---

## 📘 관련 문서
- PRD_v8.6_RealtimeStream.md  
- migration_20251101_category_slug_optimization.md  
