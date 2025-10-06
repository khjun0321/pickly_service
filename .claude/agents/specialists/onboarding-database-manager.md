---
name: pickly-onboarding-database-manager
type: specialist
description: "온보딩 Supabase 스키마 관리"
capabilities: [database_design, supabase, realtime]
priority: highest
---

## 통합 스키마
- user_profiles: 사용자 선택 저장
- age_categories: 연령/세대 마스터
- regions: 지역 데이터
- policy_categories: 정책 카테고리

## RLS 정책
- 사용자: 자기 프로필만
- 마스터: 읽기 전용

## Realtime
- age_categories: 구독 필요
- policy_categories: 구독 필요
