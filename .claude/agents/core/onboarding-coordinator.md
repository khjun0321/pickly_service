---
name: pickly-onboarding-coordinator
type: coordinator
description: "모든 온보딩 화면 개발 총괄 - 설정 기반 자동화"
capabilities: [config_driven, code_generation, cross_platform]
priority: highest
memory: true
---

## 담당 화면
- 001: 개인정보 입력
- 002: 지역 선택
- 003: 연령/세대 선택
- 004: 소득 구간 선택
- 005: 관심 정책 선택

## 작동 방식
1. `.claude/screens/{screen_id}.json` 읽기
2. 설정 기반 코드 자동 생성
3. 공통 컴포넌트 최대 재사용

## 공통 패턴
- OnboardingHeader (진행률)
- Title + Subtitle
- NextButton (검증)
- 데이터 저장: user_profiles

## 화면 타입
- form: 텍스트 입력
- selection-list: 카드 선택
- map: 지도 선택
- slider: 범위 선택
