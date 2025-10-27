# Pickly Mobile Setup Guide

## 🔧 환경 설정

### 1. Supabase 환경 변수 설정

프로젝트 루트에 `.env` 파일을 생성하세요:

```bash
cp .env.example .env
```

`.env` 파일을 열고 실제 Supabase 프로젝트 정보로 수정:

```env
SUPABASE_URL=https://your-actual-project-id.supabase.co
SUPABASE_ANON_KEY=your-actual-anon-key
```

### 2. Supabase 프로젝트 정보 확인

1. [Supabase Dashboard](https://app.supabase.com) 접속
2. 프로젝트 선택
3. Settings > API 메뉴에서:
   - **Project URL** → `SUPABASE_URL`
   - **anon public** key → `SUPABASE_ANON_KEY`

### 3. 의존성 설치

```bash
cd apps/pickly_mobile
flutter pub get
```

### 4. iOS 설정 (iOS만 해당)

```bash
cd ios
pod install
cd ..
```

### 5. 앱 실행

```bash
flutter run
```

## ⚠️ 주의사항

- **절대 `.env` 파일을 Git에 커밋하지 마세요!**
- `.env.example` 파일만 커밋하세요
- 팀원과 환경 변수를 안전하게 공유하세요 (Slack, 1Password 등)

## 🔥 문제 해결

### "LateInitializationError: Field '_client' has not been initialized"
→ `.env` 파일이 없거나 Supabase가 초기화되지 않았습니다.
→ `.env` 파일을 생성하고 올바른 값을 입력했는지 확인하세요.

### "Invalid API key"
→ `SUPABASE_ANON_KEY` 값이 잘못되었습니다.
→ Supabase Dashboard에서 키를 다시 확인하세요.

### "Error loading .env"
→ `.env` 파일이 `apps/pickly_mobile/` 폴더에 있는지 확인하세요.
→ `pubspec.yaml`의 assets 섹션에 `.env`가 포함되어 있는지 확인하세요.
