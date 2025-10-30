
# 🧱 Pickly PRD v8.6 — Realtime Stream Implementation
> 기반 문서: PRD_v8.5_Master_Final.md + 실시간 급수(6.1) 심화

---

## 🌊 6️⃣ 실시간 급수 (기존 개요 요약)

Flutter와 Admin이 Supabase를 통해 실시간으로 동기화되는 구조.
Admin에서 데이터를 수정하면, Supabase를 통해 Flutter 앱에 반영된다.

---

## ⚡ 6.1 Realtime Stream Implementation (Phase 2)

### 🎯 목적
Admin에서 수정한 데이터가 Supabase를 통해 Flutter 앱에 **0.3초 이내 자동 반영**되도록 구현한다.

---

### 🧱 적용 대상
| 구분 | 경로 | 변경 내용 |
|------|------|-----------|
| Repository Layer | `/apps/pickly_mobile/lib/contexts/**/repositories` | Future 기반 메서드를 Stream 기반으로 전환 |
| Provider Layer | `/apps/pickly_mobile/lib/contexts/**/providers` | FutureProvider → StreamProvider 전환 |
| Supabase | `/backend/supabase/config.toml` | Realtime 활성화 유지 및 권한 확인 |

---

### ⚙️ 구현 방식
- Supabase의 `from('table').stream(primaryKey: ['id'])` 사용
- Riverpod의 `StreamProvider`를 통해 UI 자동 갱신
- Pull-to-refresh 제거, 실시간 자동 반응형 데이터
- Realtime Event 기반으로 Repository → Provider → UI 흐름 유지

---

### 💡 성능 목표
| 항목 | 목표 |
|------|------|
| Admin → Supabase 반영 | 100ms 이내 |
| Supabase → Flutter 반영 | 150ms 이내 |
| 전체 반영 속도 | 평균 0.3초 이하 |
| 수동 새로고침 | 제거 |
| 사용자 경험 | 완전 실시간 반응형 UI |

---

### 📋 구현 체크리스트
| 항목 | 상태 |
|------|------|
| announcements Stream 구현 | ☐ |
| category_banners Stream 구현 | ☐ |
| benefit_categories Stream 구현 | ☐ |
| age_categories Stream 최적화 | ☐ |
| 모든 Provider StreamProvider로 전환 | ☐ |

---

### 🔒 제약 조건
- Flutter UI(Widget, Layout)는 절대 수정 금지
- 변경 허용 범위:
  - Repository 내부 로직
  - Provider의 타입(Future → Stream)
  - Supabase 구독 채널 설정

---

### 🧠 기술 흐름 요약 (생활 비유)

🏗️ Supabase → 수도관  
🧰 Repository → 밸브 연결  
⚙️ Provider → 수도꼭지  
🏠 Flutter 앱 → 물이 나오는 집  

> 이제 Admin이 밸브를 돌리면 💧 Supabase를 통해  
> Flutter 앱의 화면에 **바로 물이 나온다 (데이터 자동 반영)**!

---

### ✅ 성능 검증 계획
- Admin 수정 후 앱 반영 속도 측정 (0.3초 목표)
- Stream 데이터 누락/중복 테스트
- 네트워크 지연 환경에서 안정성 검증

---

### 📘 문서 반영 위치
- 이 섹션은 기존 PRD_v8.5_Master_Final.md의 “6️⃣ 실시간 급수” 아래에 삽입됨
- 이후 Claude Flow는 `pickly_v8.6_master` 컨텍스트로 작업

---

### 🧾 참고 명령 (Claude Code / Flow)

```bash
claude read PRD_v8.6_RealtimeStream.md
claude set-context pickly_v8.6_master
claude-flow agent message struct-architect "
지금부터 PRD_v8.6_RealtimeStream.md 기준으로 Pickly 개발을 진행한다.
Flutter UI는 절대 변경하지 말고,
Admin + Supabase + Repository의 StreamProvider 기반 실시간 구조로 완성한다.
"
```

---

🎉 **결론**
이제 Pickly는 “진짜 실시간” 데이터 구조를 완성할 준비가 되었다.
Admin이 데이터를 수정하면 → Supabase가 이벤트를 발행하고 →
Flutter 앱이 Stream으로 받아 UI를 자동 갱신한다.
