# 📑 Claude-Flow 에이전트 역할 문서

## 1. 설계/디자인 계열
- **Designer Agent (디자이너)**  
  - 디자인 문서, UI/UX 가이드라인, 디자인 토큰, 공통 컴포넌트 생성 🎨  
  - 버튼, 카드, 모달 같은 **공용 컴포넌트 코드 + 스타일**을 만들어두고, 개발자가 필요할 때 재사용 가능.

- **Architect Agent (아키텍트)**  
  - 프로젝트 구조와 기술 스택 설계 🏗  
  - 모노레포 구조, 폴더 관리, 어떤 패키지를 어디에 둘지 정의.

---

## 2. 개발/검증 계열
- **Coder Agent (코더)**  
  - 직접 코드 작성 ✍️ (예: Flutter 화면 개발)

- **Reviewer Agent (리뷰어)**  
  - 코드 리뷰, 버그 탐지 🕵️  
  - 코드 품질 관리.

- **TDD Agent (테스터)**  
  - 테스트 코드 생성 및 실행 🧪  
  - 기능이 잘 동작하는지 자동 확인.

---

## 3. 배포/운영 계열
- **DevOps Agent**  
  - CI/CD 자동화, 빌드와 배포 🚀  
  - GitHub Actions 등과 연계.

- **Data Agent**  
  - DB/데이터 흐름 설계 📊  
  - API 구조 정의, Supabase 등과 연동.

---

## 4. 시스템/조율 계열
- **Memory Agent**  
  - 기록 유지 🗂  
  - 이전 대화/작업을 기억하고 이어서 작업.

- **Hive-Mind**  
  - 여러 에이전트 조율 🧠  
  - 요청에 따라 에이전트들에 역할 분배.

---

## ✅ Pickly 서비스 적용 예시
- 디자인 시스템 반영: Designer Agent
- 구조 설계: Architect Agent
- 코드 작성: Coder Agent
- 테스트/검증: Reviewer Agent + TDD Agent
- 배포: DevOps Agent
- 데이터 관리: Data Agent
- 전체 조율: Hive-Mind + Memory Agent

