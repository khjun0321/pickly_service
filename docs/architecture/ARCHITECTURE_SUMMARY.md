# Category-Specific Advertisement Banner Architecture - Executive Summary

## Project Overview

**Feature**: Dynamic category-specific advertisement banners for Benefits screen
**Status**: Design Complete - Ready for Implementation
**Estimated Effort**: 2-3 weeks (1 developer)
**Risk Level**: Low (follows established patterns)

---

## Problem Statement

The current Benefits screen displays a single hardcoded advertisement banner across all 9 category tabs (인기, 주거, 교육, 지원, 교통, 복지, 의류, 식품, 문화). This limits marketing flexibility and reduces user engagement.

### Requirements
1. Display different banners for each category tab
2. Support multiple banners per category with pagination
3. Enable backend management through admin panel
4. Track banner performance (clicks, impressions)
5. Support scheduled banner campaigns
6. Use Flutter best practices (Riverpod + Repository pattern)

---

## Solution Architecture

### High-Level Design

```
┌───────────────────────────────────────────────────────────────┐
│  PRESENTATION LAYER                                            │
│  - BenefitsScreen (tab controller)                             │
│  - CategoryBannerCarousel (displays banners)                   │
│  - Category-aware banner switching                             │
└───────────────────────────────────────────────────────────────┘
                          │
                          │ ref.watch()
                          ▼
┌───────────────────────────────────────────────────────────────┐
│  DOMAIN LAYER (Riverpod State Management)                     │
│  - categoryBannersProvider(categoryCode) - Family provider     │
│  - Auto-caching per category                                   │
│  - Realtime subscriptions                                      │
│  - Mock data fallback (offline mode)                           │
└───────────────────────────────────────────────────────────────┘
                          │
                          │ queries
                          ▼
┌───────────────────────────────────────────────────────────────┐
│  DATA LAYER (Repository Pattern)                              │
│  - CategoryBannerRepository                                    │
│  - Supabase database integration                               │
│  - Analytics tracking                                          │
└───────────────────────────────────────────────────────────────┘
```

### Key Components

#### 1. Data Model: `CategoryBanner`
```dart
class CategoryBanner {
  final String id;
  final String categoryCode;      // 'popular', 'housing', etc.
  final String title;              // "당첨 후기 작성하고\n선물 받자"
  final String subtitle;           // "경험을 함께 나누어 주세요."
  final String? imageUrl;          // Optional decoration image
  final String backgroundColor;    // Hex color (#074D43)
  final String actionUrl;          // Deep link or external URL
  final int sortOrder;             // Display order
  final bool isActive;             // Enable/disable banner
  final DateTime? startDate;       // Optional scheduling
  final DateTime? endDate;
  final int clickCount;            // Analytics
  final int impressionCount;
  // ... timestamps
}
```

#### 2. Repository: `CategoryBannerRepository`
```dart
class CategoryBannerRepository {
  Future<List<CategoryBanner>> fetchBannersByCategory(String categoryCode);
  Future<List<CategoryBanner>> fetchAllActiveBanners();
  RealtimeChannel subscribeToBanners(String categoryCode, {callbacks});
  Future<void> trackBannerClick(String bannerId, {String? userId});
  Future<void> trackBannerImpression(String bannerId, {String? userId});
}
```

#### 3. State Management: Riverpod Providers
```dart
// Repository provider (null-safe for offline mode)
final categoryBannerRepositoryProvider = Provider<CategoryBannerRepository?>();

// Family provider for banners by category (auto-caches)
final categoryBannersProvider = AsyncNotifierProvider.family<
  CategoryBannersNotifier,
  List<CategoryBanner>,
  String
>();

// Convenience list provider
final categoryBannersListProvider = Provider.family<List<CategoryBanner>, String>();
```

#### 4. UI Widget: `CategoryBannerCarousel`
```dart
class CategoryBannerCarousel extends ConsumerStatefulWidget {
  final String categoryCode;

  @override
  Widget build(BuildContext context) {
    final banners = ref.watch(categoryBannersProvider(categoryCode));

    return banners.when(
      loading: () => BannerSkeleton(),
      error: (_, __) => EmptyBanner(),
      data: (banners) => PageView.builder(
        itemCount: banners.length,
        itemBuilder: (context, index) => AdvertisementBanner(
          title: banners[index].title,
          // ... other properties
        ),
      ),
    );
  }
}
```

---

## Database Schema

### Primary Table: `category_banners`

```sql
CREATE TABLE category_banners (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_code TEXT NOT NULL,              -- 'popular', 'housing', etc.
  title TEXT NOT NULL,
  subtitle TEXT NOT NULL,
  image_url TEXT,
  background_color TEXT NOT NULL DEFAULT '#074D43',
  action_url TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  start_date TIMESTAMPTZ,                   -- Optional scheduling
  end_date TIMESTAMPTZ,
  click_count INTEGER NOT NULL DEFAULT 0,
  impression_count INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_category_banners_category ON category_banners(category_code);
CREATE INDEX idx_category_banners_sort ON category_banners(category_code, sort_order);
```

### Analytics Table: `banner_analytics`

```sql
CREATE TABLE banner_analytics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  banner_id UUID NOT NULL REFERENCES category_banners(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  event_type TEXT NOT NULL,                 -- 'click' or 'impression'
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

---

## Category Code Mapping

| Tab Index | Category Code | Display Name | Icon |
|-----------|--------------|--------------|------|
| 0 | `popular` | 인기 | fire.svg |
| 1 | `housing` | 주거 | home.svg |
| 2 | `education` | 교육 | school.svg |
| 3 | `support` | 지원 | dollar.svg |
| 4 | `transport` | 교통 | bus.svg |
| 5 | `welfare` | 복지 | happy_apt.svg |
| 6 | `clothing` | 의류 | shirts.svg |
| 7 | `food` | 식품 | rice.svg |
| 8 | `culture` | 문화 | speaker.svg |

```dart
// Usage
final categoryCode = CategoryCodes.byIndex(_selectedCategoryIndex);
```

---

## File Structure

```
apps/pickly_mobile/lib/
├── contexts/benefits/
│   ├── models/
│   │   ├── category_banner.dart
│   │   └── category_codes.dart
│   ├── repositories/
│   │   └── category_banner_repository.dart
│   ├── providers/
│   │   └── category_banner_provider.dart
│   └── exceptions/
│       └── category_banner_exception.dart
│
└── features/benefits/
    ├── screens/
    │   └── benefits_screen.dart          (updated)
    └── widgets/
        ├── category_banner_carousel.dart (new)
        └── category_banner_card.dart     (new)

supabase/migrations/
└── 20251016000000_create_category_banners.sql

supabase/functions/
├── increment_banner_clicks.sql
└── increment_banner_impressions.sql
```

---

## Implementation Roadmap

### Phase 1: Foundation (Week 1)
- [ ] Create Supabase migration and deploy
- [ ] Implement data models (`CategoryBanner`, `CategoryCodes`)
- [ ] Write model unit tests
- [ ] Create custom exception class

**Deliverables**: Database schema, models with tests

### Phase 2: Repository & State (Week 1-2)
- [ ] Implement `CategoryBannerRepository` with all methods
- [ ] Write repository unit tests (mock Supabase)
- [ ] Create Riverpod providers with family pattern
- [ ] Add realtime subscription logic
- [ ] Implement mock data fallback

**Deliverables**: Repository + providers with comprehensive tests

### Phase 3: UI Components (Week 2)
- [ ] Create `CategoryBannerCarousel` widget
- [ ] Create `CategoryBannerCard` wrapper
- [ ] Add PageView with indicators
- [ ] Implement analytics tracking
- [ ] Handle loading/error states

**Deliverables**: Banner carousel with analytics

### Phase 4: Integration (Week 2)
- [ ] Update `BenefitsScreen` to use carousel
- [ ] Pass category code based on selected tab
- [ ] Test all 9 categories
- [ ] Performance optimization
- [ ] Write integration tests

**Deliverables**: Fully integrated banner system

### Phase 5: Backend Admin (Week 3)
- [ ] Design admin UI mockups
- [ ] Create RLS policies for security
- [ ] Build CRUD screens (or use Supabase dashboard)
- [ ] Add scheduling controls
- [ ] Create analytics dashboard

**Deliverables**: Admin panel for banner management

### Phase 6: Testing & Launch (Week 3)
- [ ] Comprehensive test suite (>85% coverage)
- [ ] Performance profiling
- [ ] Accessibility testing
- [ ] Soft launch with feature flag
- [ ] Monitor metrics
- [ ] Full rollout

**Deliverables**: Production-ready feature

---

## Key Design Decisions

### 1. Family Provider for Category-Based State
**Decision**: Use `AsyncNotifierProvider.family` with category code as parameter

**Rationale**:
- Automatic caching per category
- Efficient state management (only fetch when needed)
- Clean disposal of unused providers
- Built-in loading/error states

### 2. Mock Data Fallback Strategy
**Decision**: Always show mock banners when Supabase unavailable

**Rationale**:
- Better user experience (no blank screens)
- Allows offline development
- Graceful degradation
- No error state confusion for users

### 3. Repository Pattern
**Decision**: Use repository layer instead of direct Supabase calls

**Rationale**:
- Easier to test (can mock repository)
- Centralized error handling
- Consistent with existing codebase (`RegionRepository` pattern)
- Potential for multiple data sources

### 4. Non-Blocking Analytics
**Decision**: Analytics calls never throw exceptions

**Rationale**:
- Analytics failure shouldn't break UX
- Better user experience
- Reduced error noise in logs
- Tracking is "nice to have", not critical

### 5. Realtime Subscriptions
**Decision**: Use Supabase realtime per category

**Rationale**:
- Instant updates when admin changes banners
- Leverages Supabase built-in feature
- Better user experience (no app restart needed)
- Proper cleanup with provider lifecycle

---

## Quality Attributes

### Performance
- **Target**: Banner load < 500ms on 4G
- **Strategy**: Aggressive caching, optimized queries, image CDN
- **Metrics**: Time to first banner paint, memory usage

### Scalability
- **Target**: Support 100+ banners per category
- **Strategy**: Pagination, lazy loading, efficient indexes
- **Metrics**: Database query time, app memory footprint

### Reliability
- **Target**: 99.9% uptime for banner service
- **Strategy**: Mock data fallback, error boundaries, graceful degradation
- **Metrics**: Error rate, fallback activation rate

### Maintainability
- **Target**: Add new category in < 1 hour
- **Strategy**: Category code constants, consistent patterns, documentation
- **Metrics**: Lines of code changed, test coverage

### Security
- **Target**: Zero unauthorized banner modifications
- **Strategy**: RLS policies, admin-only write access, audit logs
- **Metrics**: Failed auth attempts, policy violations

---

## Testing Strategy

### Unit Tests
- Model serialization/deserialization
- Repository methods with mocked Supabase client
- Provider state transitions
- Category code utilities

### Widget Tests
- Banner carousel rendering
- Loading/error state handling
- User interactions (swipe, tap)
- Analytics tracking calls

### Integration Tests
- End-to-end banner flow
- Category switching
- Realtime updates
- Offline mode fallback

**Target Coverage**: >85%

---

## Monitoring & Analytics

### Key Metrics

**Banner Performance**:
- Click-through rate (CTR) per category
- Impression count per banner
- Average time on banner
- Conversion rate (banner tap → action)

**User Behavior**:
- Category view distribution
- Banner swipe rate
- Most/least engaging categories
- Time of day patterns

**Technical Health**:
- Repository error rate
- Fallback activation rate
- Realtime subscription failures
- Database query latency
- Cache hit rate

### Dashboard Queries

```sql
-- Banner CTR by category
SELECT
  category_code,
  title,
  click_count,
  impression_count,
  ROUND((click_count::float / NULLIF(impression_count, 0)) * 100, 2) as ctr_percent
FROM category_banners
WHERE is_active = true
ORDER BY ctr_percent DESC;

-- Top performers (last 7 days)
SELECT
  cb.title,
  cb.category_code,
  COUNT(CASE WHEN ba.event_type = 'click' THEN 1 END) as clicks,
  COUNT(CASE WHEN ba.event_type = 'impression' THEN 1 END) as impressions
FROM category_banners cb
LEFT JOIN banner_analytics ba ON ba.banner_id = cb.id
WHERE ba.created_at > NOW() - INTERVAL '7 days'
GROUP BY cb.id, cb.title, cb.category_code
ORDER BY clicks DESC
LIMIT 10;
```

---

## Migration Strategy

### From Current Implementation

**Current** (Hardcoded):
```dart
const AdvertisementBanner(
  title: '당첨 후기 작성하고\n선물 받자',
  subtitle: '경험을 함께 나누어 주세요.',
  imageUrl: 'https://placehold.co/132x132',
  currentIndex: 1,
  totalCount: 8,
),
```

**Target** (Dynamic):
```dart
CategoryBannerCarousel(
  categoryCode: CategoryCodes.byIndex(_selectedCategoryIndex),
),
```

### Rollout Phases

1. **Database Setup** (Day 1)
   - Deploy migration
   - Populate sample data
   - Test queries manually

2. **Backend Integration** (Days 2-5)
   - Deploy repository + providers
   - Keep hardcoded banner (no UI change)
   - Test data fetching

3. **Soft Launch** (Days 6-8)
   - Add feature flag
   - Deploy carousel widget
   - Enable for internal testing

4. **Full Rollout** (Days 9-10)
   - Enable for all users
   - Remove hardcoded banner
   - Monitor metrics

5. **Optimization** (Days 11-14)
   - Fine-tune caching
   - Optimize queries
   - Add admin panel

---

## Risks & Mitigation

### Risk 1: Supabase Performance
**Impact**: Slow banner loading
**Probability**: Low
**Mitigation**:
- Indexed queries
- Aggressive caching
- Mock data fallback
- CDN for images

### Risk 2: Realtime Subscription Overhead
**Impact**: Increased battery/data usage
**Probability**: Medium
**Mitigation**:
- One subscription per active category
- Proper cleanup on dispose
- Subscription only when screen visible

### Risk 3: Category Code Mismatch
**Impact**: Wrong banners displayed
**Probability**: Low
**Mitigation**:
- Strict type safety with `CategoryCodes` constants
- Validation in repository
- Integration tests

### Risk 4: Admin Panel Complexity
**Impact**: Delayed launch
**Probability**: Low
**Mitigation**:
- Use Supabase dashboard initially
- Custom admin panel as Phase 2
- Clear RLS policies

---

## Future Enhancements (Post-Launch)

### Phase 2 Features
1. **A/B Testing**: Variant support with winner selection
2. **Personalization**: User-specific recommendations based on behavior
3. **Rich Media**: Video banners, animated GIFs, interactive elements
4. **Advanced Scheduling**: Recurring schedules, timezone-aware, event-triggered
5. **Performance**: Image CDN, prefetching, service worker caching

---

## Documentation Index

### Comprehensive Architecture Documents

1. **[Full Architecture Document](./category-banner-architecture.md)**
   Complete technical specification with detailed implementation guidelines

2. **[Quick Reference Guide](./category-banner-quick-reference.md)**
   Condensed reference for developers during implementation

3. **[Visual Diagrams](./category-banner-diagrams.md)**
   C4 model, sequence diagrams, data flows, component diagrams

4. **This Summary Document**
   Executive overview and project roadmap

### Related Documentation

- [Component Structure Guide](./component-structure-guide.md)
- Existing Region Provider: `lib/features/onboarding/providers/region_provider.dart`
- Existing Region Repository: `lib/contexts/user/repositories/region_repository.dart`

---

## Success Criteria

### MVP Launch (Week 3)
- ✅ All 9 categories display unique banners
- ✅ Smooth banner switching when tab changes
- ✅ Analytics tracking functional (clicks + impressions)
- ✅ Admin can manage banners via Supabase dashboard
- ✅ Test coverage >85%
- ✅ No performance degradation (<500ms load time)

### Post-Launch (Month 1)
- 📊 CTR improvement vs. hardcoded banner (target: +20%)
- 📊 Zero critical errors
- 📊 <1% fallback activation rate (shows good Supabase connectivity)
- 📊 Positive user feedback on banner relevance

---

## Technical Dependencies

### Required
- Flutter SDK: ^3.0.0
- Riverpod: ^2.0.0
- Supabase Flutter: ^2.0.0
- go_router (existing)

### Optional
- cached_network_image (for image optimization)
- flutter_cache_manager (advanced caching)

---

## Team Responsibilities

### Backend Developer
- Create Supabase migration
- Write database functions (RPC)
- Set up RLS policies
- Create seed data

### Mobile Developer
- Implement models and repository
- Create Riverpod providers
- Build UI widgets
- Write tests
- Integration with BenefitsScreen

### Product/Design
- Define banner content strategy
- Design admin panel mockups
- Create analytics dashboard requirements
- User acceptance testing

### QA
- Functional testing (all categories)
- Performance testing
- Accessibility testing
- Regression testing

---

## Contact & Support

**Technical Lead**: [Your Name]
**Product Owner**: [Product Manager]
**Architecture Review**: [Team Channel]

**Questions?** Check the full documentation in `/docs/architecture/`

---

**Document Status**: ✅ Ready for Implementation
**Last Updated**: 2025-10-16
**Version**: 1.0.0
**Approval**: Pending Tech Lead + Product Manager review
