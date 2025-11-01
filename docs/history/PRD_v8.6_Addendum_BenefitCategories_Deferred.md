
# 📘 Pickly v8.6 Addendum — Benefit Categories Stream Migration Deferred

**작성일:** 2025-10-31  
**관련 문서:** `PRD_v8.6_RealtimeStream.md`, `realtime_stream_report_v8.6_phase3-4.md`  
**작성자:** Claude Code + ChatGPT Co-Pilot  

---

## 🎯 목적
`benefit_categories` 테이블의 실시간 Stream Migration 작업이  
현 PRD의 **“Flutter UI 절대 변경 금지” 정책**과 충돌하여  
임시 보류(Deferred)됨을 명시한다.

---

## ⚠️ 예외 사유  

| 항목 | 설명 |
|------|------|
| **위반 가능성** | Flutter UI 내 카테고리 탭 데이터가 하드코딩되어 있음 |
| **수정 필요 범위** | UI 내 카테고리명, 아이콘 매핑, 필터 로직 등 |
| **정책 충돌** | PRD_v8.5의 “UI 절대 변경 금지” 조항 위반 우려 |
| **현재 조치** | 데이터 레이어(Stream) 준비만 완료, UI 연결은 보류 |

---

## 📌 결정 사항  

1️⃣ **Phase 3 작업 상태:** Deferred ⏳  
2️⃣ **대체 계획:** v9.0 이후 Flutter UI 개선 승인 시 재개  
3️⃣ **대체 브랜치:** `feature/benefit-categories-stream`  
4️⃣ **필수 승인:**  
- UI/UX 디자이너 승인  
- PM(Product Manager) 승인  
- Claude Flow 컨텍스트 업데이트  

---

## 🗺️ 향후 절차  

| 단계 | 작업 | 담당 | 일정 |
|------|------|------|------|
| 1️⃣ | PRD 예외 문서 추가 (본 파일) | ChatGPT | 10/31 |
| 2️⃣ | Git 커밋 및 푸시 | User | 즉시 |
| 3️⃣ | `feature/benefit-categories-stream` 브랜치 생성 | Claude Code | 11/1 |
| 4️⃣ | Flutter UI 개선 승인 후 PR | PM + Design | v9.0 시점 |

---

## 🧠 참고  

> “벽 속 배선(하드코딩)을 건드리지 않기 위해,  
> 우선 배전함(Repository)까지만 연결해둔 상태입니다.”  
>  
> Flutter UI는 잠금 상태로 유지하며,  
> 추후 승인 후 새 배선을 연결할 예정입니다. ⚡

