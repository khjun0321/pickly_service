# CI/CD Pipeline Documentation

## Overview

Pickly Service uses a comprehensive CI/CD pipeline powered by GitHub Actions, Melos workspace management, and automated testing to ensure code quality and architectural integrity.

## Pipeline Architecture

### Workflow Triggers
- **Pull Requests**: To `main` or `develop` branches
- **Push Events**: To `main` or `develop` branches
- **Manual Trigger**: Via `workflow_dispatch`

### Jobs Overview

```
┌─────────────────┐     ┌─────────────────┐
│  Flutter Test   │     │  Admin Build    │
│                 │     │                 │
│ - Analyze       │     │ - npm ci        │
│ - Test          │     │ - Lint          │
│ - Format Check  │     │ - Build         │
│ - Boundaries    │     │                 │
└────────┬────────┘     └────────┬────────┘
         │                       │
         └───────┬───────────────┘
                 ▼
         ┌───────────────┐
         │  Integration  │
         │  Validation   │
         └───────────────┘
```

## Melos Configuration

### Version
- **Melos**: 7.3.0+
- **Flutter**: 3.35.4
- **Dart SDK**: >=3.9.0 <4.0.0

### Key Features
1. **Parallel Execution**: Concurrency of 4 for analysis and tests
2. **Fail Fast**: Stops on first error for quick feedback
3. **Selective Filters**: Only runs tests where test directories exist
4. **Fatal Warnings**: Treats warnings as errors (`--fatal-warnings`)

### Available Melos Commands

```bash
# Bootstrap workspace (install all dependencies)
melos bootstrap

# Run static analysis (fail on warnings)
melos run analyze

# Run all tests
melos run test

# Check code formatting
melos run format:check

# Format code
melos run format

# Run analyze + test
melos run check

# Clean all packages
melos run clean

# Get dependencies for all packages
melos run get

# Build Android app
melos run build:android

# Build iOS app
melos run build:ios
```

## GitHub Workflow Details

### Job 1: Flutter Analysis & Tests

**Duration**: ~10-15 minutes

**Steps**:
1. **Checkout**: Fetch repository code
2. **Flutter Setup**: Install Flutter 3.35.4 (stable)
3. **Caching**: Restore pub dependencies from cache
4. **Dependencies**: Install root and workspace dependencies
5. **Melos Bootstrap**: Initialize monorepo workspace
6. **Boundary Check**: Enforce architectural boundaries
7. **Analysis**: Run `flutter analyze --fatal-warnings`
8. **Tests**: Run all package tests
9. **Format Check**: Verify code formatting

**Cache Strategy**:
```yaml
key: ${{ runner.os }}-pub-${{ hashFiles('**/pubspec.yaml') }}
```
- Caches `~/.pub-cache` and `.dart_tool`
- Invalidates when any `pubspec.yaml` changes

### Job 2: Admin Panel Build

**Duration**: ~5-8 minutes

**Steps**:
1. **Checkout**: Fetch repository code
2. **Node.js Setup**: Install Node.js 20 with npm caching
3. **Dependencies**: Run `npm ci` for clean install
4. **Lint**: Run ESLint checks
5. **Build**: Create production build
6. **Upload**: Save dist artifacts (7 days retention)

**Cache Strategy**:
```yaml
cache: 'npm'
cache-dependency-path: apps/pickly_admin/package-lock.json
```

### Job 3: Integration Validation

**Duration**: ~1 minute

**Purpose**: Final verification and summary generation

**Outputs**:
- GitHub Step Summary with all check statuses
- Consolidated success/failure report

## Architecture Boundary Enforcement

### Script: `scripts/enforce-boundaries.sh`

**Rules**:
1. **Features ↔ Features**: No cross-feature relative imports
2. **Contexts → Features**: Contexts CANNOT import from features

**Violations Detected**:
```bash
# Bad: Feature-to-feature relative import
import '../../other_feature/model.dart'

# Bad: Context importing from features
import '../features/auth/provider.dart'
```

**Exit Codes**:
- `0`: All boundaries respected
- `1`: Boundary violations found (CI fails)

## Local Development Workflow

### Initial Setup
```bash
# Install Melos globally
dart pub global activate melos 7.3.0

# Bootstrap workspace
melos bootstrap

# Verify setup
melos run check
```

### Pre-Commit Checks
```bash
# Run full validation (matches CI)
melos run analyze
melos run test
bash scripts/enforce-boundaries.sh
melos run format:check
```

### Quick Development Loop
```bash
# Format code
melos run format

# Analyze single package
cd apps/pickly_mobile
flutter analyze

# Run tests with watch
cd apps/pickly_mobile
flutter test --watch
```

## Troubleshooting

### Melos Bootstrap Fails

**Symptom**: Dependency resolution errors

**Solutions**:
```bash
# Clean and retry
melos clean
flutter pub cache repair
melos bootstrap
```

### Analysis Warnings in CI

**Symptom**: CI fails on warnings that pass locally

**Cause**: CI uses `--fatal-warnings` flag

**Fix**:
```bash
# Run with same flags as CI
flutter analyze --fatal-infos --fatal-warnings
```

### Boundary Check Fails

**Symptom**: `enforce-boundaries.sh` reports violations

**Investigation**:
```bash
# Run locally with details
bash scripts/enforce-boundaries.sh

# Shows exact file and line number of violations
```

**Fix**: Refactor imports to use allowed patterns

### Admin Build Fails

**Symptom**: TypeScript errors in CI

**Investigation**:
```bash
cd apps/pickly_admin

# Run build locally
npm run build

# Check types
npx tsc --noEmit
```

## Performance Optimization

### Caching Strategy
- **Flutter**: Caches pub dependencies by `pubspec.yaml` hash
- **Node.js**: Caches npm modules by `package-lock.json` hash
- **Artifacts**: 7-day retention for build outputs

### Concurrency Settings
- **Melos**: 4 concurrent operations
- **GitHub**: Cancel in-progress runs on new pushes
- **Fail Fast**: Stops on first error for quick feedback

### Typical CI Times
| Job | Cached | Uncached |
|-----|--------|----------|
| Flutter Test | 8-10 min | 12-15 min |
| Admin Build | 3-5 min | 6-8 min |
| Integration | <1 min | <1 min |
| **Total** | **12-16 min** | **20-25 min** |

## Migration Guide

### From Old Workflow to New

**Changes**:
1. ✅ Melos upgraded to 7.3.0
2. ✅ Added admin panel build job
3. ✅ Enhanced caching strategy
4. ✅ Added format checking
5. ✅ Improved concurrency
6. ✅ Added integration validation

**Breaking Changes**: None - backward compatible

### Project Structure Updates

**Archived**:
- `backend/supabase/migrations_wrong/` → `backend/supabase/archive_migrations_wrong/`

**Reason**: Cleanup of invalid migration files

## Best Practices

### Commit Guidelines
1. Always run local checks before pushing
2. Keep commits atomic and focused
3. Use conventional commit messages
4. Address all warnings before PR

### PR Workflow
1. Create feature branch from `develop`
2. Implement changes
3. Run `melos run check` locally
4. Push and create PR
5. Wait for CI to pass
6. Request review
7. Merge when approved

### Dependency Management
1. Update `pubspec.yaml` in relevant package
2. Run `melos bootstrap` to sync
3. Commit `pubspec.lock` changes
4. Verify CI passes with new dependencies

## Security Considerations

### Secrets Management
- Never commit `.env` files
- Use GitHub Secrets for sensitive data
- Admin API keys should be in repository secrets

### Permissions
- Workflow runs with `contents: read` only
- No write access to repository from CI
- Artifacts are temporary (7 days)

## Future Enhancements

### Planned Improvements
- [ ] Add deployment jobs for staging/production
- [ ] Implement semantic versioning automation
- [ ] Add performance benchmarking
- [ ] Integrate code coverage reporting
- [ ] Add security scanning (SAST/DAST)
- [ ] Implement changelog generation

### Monitoring
- [ ] Set up workflow run notifications
- [ ] Track CI performance metrics
- [ ] Monitor dependency update frequency
- [ ] Alert on failing workflows

## Support

### Resources
- **Melos Documentation**: https://melos.invertase.dev
- **GitHub Actions**: https://docs.github.com/actions
- **Flutter CI/CD**: https://docs.flutter.dev/deployment/cd

### Getting Help
1. Check this documentation first
2. Review workflow logs in GitHub Actions tab
3. Run commands locally to reproduce issues
4. Contact team if issues persist

---

**Last Updated**: 2025-10-27
**Maintained By**: DevOps Team
