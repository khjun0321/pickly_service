# Category Banner Backend Integration Design

## Overview
This document outlines the complete backend integration architecture for category-specific advertisement banners in the Pickly mobile application.

## Architecture Layers

```
┌─────────────────────────────────────────┐
│         UI Layer (Widgets)              │
│  - BenefitsScreen                       │
│  - AdvertisementBanner                  │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│      State Management (Riverpod)        │
│  - categoryBannersProvider              │
│  - activeBannersProvider                │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│       Service Layer (Business Logic)    │
│  - BannerService                        │
│  - BannerCacheService                   │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│    Repository Layer (Data Access)       │
│  - BannerRepository                     │
│  - BannerLocalCache                     │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│         Data Sources                    │
│  - Supabase (Remote)                    │
│  - SharedPreferences (Local Cache)      │
└─────────────────────────────────────────┘
```

## Data Model

### Category Enum
- `popular` (인기)
- `housing` (주거)
- `education` (교육)
- `support` (지원)
- `transportation` (교통)
- `welfare` (복지)
- `clothing` (의류)
- `food` (식품)
- `culture` (문화)

### Banner Entity
```dart
{
  id: UUID,
  categoryId: BannerCategory,
  title: String,
  subtitle: String,
  imageUrl: String,
  backgroundColor: String (hex color),
  actionType: BannerActionType,
  actionUrl: String?,
  displayOrder: int,
  isActive: bool,
  startDate: DateTime?,
  endDate: DateTime?,
  impressionCount: int,
  clickCount: int,
  createdAt: DateTime,
  updatedAt: DateTime
}
```

## Supabase Schema

### Table: `category_banners`
```sql
CREATE TABLE category_banners (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  category_id VARCHAR(20) NOT NULL,
  title VARCHAR(100) NOT NULL,
  subtitle VARCHAR(200),
  image_url TEXT NOT NULL,
  background_color VARCHAR(7) DEFAULT '#FF6B35',
  action_type VARCHAR(20) DEFAULT 'internal_link',
  action_url TEXT,
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  start_date TIMESTAMP WITH TIME ZONE,
  end_date TIMESTAMP WITH TIME ZONE,
  impression_count INTEGER DEFAULT 0,
  click_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  CONSTRAINT valid_category CHECK (
    category_id IN (
      'popular', 'housing', 'education', 'support',
      'transportation', 'welfare', 'clothing', 'food', 'culture'
    )
  ),
  CONSTRAINT valid_action_type CHECK (
    action_type IN ('internal_link', 'external_link', 'deep_link', 'none')
  ),
  CONSTRAINT valid_dates CHECK (
    start_date IS NULL OR end_date IS NULL OR start_date <= end_date
  )
);

-- Indexes for performance
CREATE INDEX idx_category_banners_category ON category_banners(category_id);
CREATE INDEX idx_category_banners_active ON category_banners(is_active);
CREATE INDEX idx_category_banners_order ON category_banners(category_id, display_order);
CREATE INDEX idx_category_banners_dates ON category_banners(start_date, end_date);

-- Updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_category_banners_updated_at
  BEFORE UPDATE ON category_banners
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

### Views for Admin Panel

```sql
-- View: Active banners with analytics
CREATE VIEW active_category_banners AS
SELECT
  id,
  category_id,
  title,
  subtitle,
  image_url,
  background_color,
  action_type,
  action_url,
  display_order,
  is_active,
  start_date,
  end_date,
  impression_count,
  click_count,
  CASE
    WHEN click_count > 0 THEN ROUND((click_count::DECIMAL / impression_count::DECIMAL) * 100, 2)
    ELSE 0
  END as ctr_percentage,
  created_at,
  updated_at
FROM category_banners
WHERE is_active = true
  AND (start_date IS NULL OR start_date <= NOW())
  AND (end_date IS NULL OR end_date >= NOW())
ORDER BY category_id, display_order;

-- View: Banner performance metrics
CREATE VIEW banner_analytics AS
SELECT
  category_id,
  COUNT(*) as total_banners,
  COUNT(*) FILTER (WHERE is_active = true) as active_banners,
  SUM(impression_count) as total_impressions,
  SUM(click_count) as total_clicks,
  CASE
    WHEN SUM(impression_count) > 0
    THEN ROUND((SUM(click_count)::DECIMAL / SUM(impression_count)::DECIMAL) * 100, 2)
    ELSE 0
  END as avg_ctr_percentage
FROM category_banners
GROUP BY category_id;
```

## Row Level Security (RLS)

```sql
-- Enable RLS
ALTER TABLE category_banners ENABLE ROW LEVEL SECURITY;

-- Public can read active banners
CREATE POLICY "Public can view active banners"
  ON category_banners
  FOR SELECT
  USING (
    is_active = true
    AND (start_date IS NULL OR start_date <= NOW())
    AND (end_date IS NULL OR end_date >= NOW())
  );

-- Admins can manage all banners (assuming admin role)
CREATE POLICY "Admins can manage banners"
  ON category_banners
  FOR ALL
  USING (auth.jwt() ->> 'role' = 'admin');

-- Allow updating impression/click counts without authentication
CREATE POLICY "Allow analytics updates"
  ON category_banners
  FOR UPDATE
  USING (true)
  WITH CHECK (true);
```

## API Functions

```sql
-- Function: Get active banners for a category
CREATE OR REPLACE FUNCTION get_active_banners(p_category_id VARCHAR)
RETURNS TABLE (
  id UUID,
  category_id VARCHAR,
  title VARCHAR,
  subtitle VARCHAR,
  image_url TEXT,
  background_color VARCHAR,
  action_type VARCHAR,
  action_url TEXT,
  display_order INTEGER,
  impression_count INTEGER,
  click_count INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    cb.id,
    cb.category_id,
    cb.title,
    cb.subtitle,
    cb.image_url,
    cb.background_color,
    cb.action_type,
    cb.action_url,
    cb.display_order,
    cb.impression_count,
    cb.click_count
  FROM category_banners cb
  WHERE cb.category_id = p_category_id
    AND cb.is_active = true
    AND (cb.start_date IS NULL OR cb.start_date <= NOW())
    AND (cb.end_date IS NULL OR cb.end_date >= NOW())
  ORDER BY cb.display_order ASC;
END;
$$ LANGUAGE plpgsql;

-- Function: Increment impression count
CREATE OR REPLACE FUNCTION increment_banner_impression(p_banner_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE category_banners
  SET impression_count = impression_count + 1
  WHERE id = p_banner_id;
END;
$$ LANGUAGE plpgsql;

-- Function: Increment click count
CREATE OR REPLACE FUNCTION increment_banner_click(p_banner_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE category_banners
  SET click_count = click_count + 1
  WHERE id = p_banner_id;
END;
$$ LANGUAGE plpgsql;
```

## Caching Strategy

### Three-Tier Caching
1. **Memory Cache (In-App)**: 5 minutes TTL
2. **Local Storage (SharedPreferences)**: 1 hour TTL
3. **Supabase (Remote)**: Source of truth

### Cache Invalidation
- Time-based: Automatic after TTL expiration
- Event-based: Real-time updates via Supabase subscriptions
- Manual: Force refresh on pull-to-refresh

### Cache Keys
```
banner:category:{categoryId}
banner:all
banner:timestamp:{categoryId}
```

## Real-time Updates

### Supabase Realtime Subscription
```dart
// Subscribe to banner changes
final subscription = supabase
  .from('category_banners')
  .stream(primaryKey: ['id'])
  .eq('is_active', true)
  .listen((data) {
    // Update local cache
    // Notify providers
  });
```

### Update Strategy
- Subscribe to active banners on app start
- Filter by category when needed
- Debounce updates to prevent excessive rebuilds
- Batch updates every 30 seconds

## API Integration Points

### Repository Methods
```dart
// Fetch banners for specific category
Future<List<Banner>> getBannersByCategory(BannerCategory category)

// Fetch all active banners
Future<Map<BannerCategory, List<Banner>>> getAllActiveBanners()

// Record impression
Future<void> recordImpression(String bannerId)

// Record click
Future<void> recordClick(String bannerId)

// Refresh cache
Future<void> refreshBanners(BannerCategory category)

// Subscribe to real-time updates
Stream<List<Banner>> watchBannersByCategory(BannerCategory category)
```

### Service Layer Methods
```dart
// Get banners with caching
Future<List<Banner>> getCachedBanners(BannerCategory category)

// Track impression (fire-and-forget)
void trackImpression(String bannerId)

// Track click with callback
Future<void> trackClick(String bannerId, Function? onSuccess)

// Prefetch banners for all categories
Future<void> prefetchAllBanners()

// Clear cache
Future<void> clearCache()
```

## Error Handling

### Graceful Degradation
1. **Network Error**: Use cached data
2. **Cache Miss**: Show default banner
3. **Invalid Data**: Skip malformed banners
4. **Timeout**: Fall back to cached data after 5 seconds

### Retry Strategy
- Exponential backoff: 1s, 2s, 4s, 8s
- Max retries: 3
- Retry conditions: Network errors, timeouts
- No retry: 4xx client errors

## Performance Optimization

### Lazy Loading
- Load banners only when category is selected
- Prefetch next/previous category banners

### Image Optimization
- Use CDN for banner images
- Implement progressive image loading
- Cache images locally with `cached_network_image`

### Database Optimization
- Composite indexes on (category_id, display_order)
- Materialized views for analytics
- Connection pooling in Supabase

## Analytics & Monitoring

### Metrics to Track
- Banner impressions per category
- Click-through rate (CTR)
- Average display time
- Error rates
- Cache hit/miss ratio

### Logging
```dart
// Log banner fetch
logger.info('Fetching banners', {
  'category': category,
  'source': 'cache|remote',
  'count': banners.length
});

// Log analytics events
logger.analytics('banner_impression', {
  'bannerId': id,
  'category': category,
  'timestamp': DateTime.now()
});
```

## Testing Strategy

### Unit Tests
- Repository methods
- Service layer logic
- Cache invalidation
- Date validation

### Integration Tests
- Supabase queries
- Real-time subscriptions
- Error handling
- Retry logic

### Widget Tests
- Banner display
- Category switching
- Click handling
- Loading states

## Migration Guide

### Phase 1: Database Setup
1. Create table and indexes
2. Create views and functions
3. Set up RLS policies
4. Seed initial data

### Phase 2: Flutter Implementation
1. Create data models
2. Implement repository
3. Add caching layer
4. Create service layer

### Phase 3: Integration
1. Connect to Riverpod providers
2. Update UI components
3. Add analytics tracking
4. Test end-to-end

### Phase 4: Optimization
1. Enable real-time updates
2. Implement prefetching
3. Add monitoring
4. Performance tuning

## Security Considerations

### Data Validation
- Validate category IDs
- Sanitize URLs
- Validate date ranges
- Check image URLs

### Access Control
- Public: Read active banners only
- Admin: Full CRUD operations
- Analytics: Write-only for tracking

### Rate Limiting
- Limit impression tracking: Max 100/minute per banner
- Limit click tracking: Max 10/minute per banner
- Prevent abuse with device fingerprinting

## Appendix: Example Queries

### Admin Panel Queries

```sql
-- Get all banners with analytics
SELECT * FROM active_category_banners;

-- Get performance by category
SELECT * FROM banner_analytics ORDER BY total_clicks DESC;

-- Find expired banners
SELECT id, title, category_id, end_date
FROM category_banners
WHERE end_date < NOW() AND is_active = true;

-- Find top performing banners
SELECT id, title, category_id, impression_count, click_count,
  ROUND((click_count::DECIMAL / NULLIF(impression_count, 0)::DECIMAL) * 100, 2) as ctr
FROM category_banners
WHERE impression_count > 100
ORDER BY ctr DESC
LIMIT 10;
```
