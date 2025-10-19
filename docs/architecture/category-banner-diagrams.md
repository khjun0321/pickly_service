# Category Banner Architecture - Visual Diagrams

## C4 Model - System Context

```
┌──────────────────────────────────────────────────────────────────────┐
│                          PICKLY MOBILE APP                            │
│                                                                        │
│  ┌────────────┐         ┌───────────────┐         ┌──────────────┐  │
│  │   User     │◄───────►│ Benefits      │◄───────►│  Category    │  │
│  │ (Customer) │         │ Screen        │         │  Banner      │  │
│  │            │         │               │         │  System      │  │
│  └────────────┘         └───────────────┘         └──────────────┘  │
│                                                           │           │
└───────────────────────────────────────────────────────────┼───────────┘
                                                            │
                                                            │
                                            ┌───────────────▼───────────┐
                                            │  Supabase Backend         │
                                            │  - category_banners       │
                                            │  - banner_analytics       │
                                            │  - Realtime subscriptions │
                                            └───────────────────────────┘
                                                            ▲
                                                            │
                                                            │
                                            ┌───────────────┴───────────┐
                                            │  Admin Panel (백오피스)     │
                                            │  - Create/Edit banners    │
                                            │  - Schedule campaigns     │
                                            │  - View analytics         │
                                            └───────────────────────────┘
```

## C4 Model - Container Diagram

```
┌──────────────────────────────────────────────────────────────────────────┐
│                      PICKLY MOBILE APPLICATION                            │
│                                                                            │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │                    PRESENTATION LAYER                             │   │
│  │                                                                    │   │
│  │  ┌─────────────────┐         ┌──────────────────────────────┐   │   │
│  │  │ BenefitsScreen  │────────►│ CategoryBannerCarousel       │   │   │
│  │  │                 │         │ - PageView                   │   │   │
│  │  │ - Tab selector  │         │ - Banner cards               │   │   │
│  │  │ - Category mgmt │         │ - Pagination indicators      │   │   │
│  │  └─────────────────┘         └──────────────────────────────┘   │   │
│  │                                         │                         │   │
│  │                                         │ ref.watch()            │   │
│  └─────────────────────────────────────────┼─────────────────────────┘   │
│                                            │                             │
│  ┌─────────────────────────────────────────┼─────────────────────────┐   │
│  │                    DOMAIN LAYER         │                         │   │
│  │                                         ▼                         │   │
│  │  ┌────────────────────────────────────────────────────────────┐  │   │
│  │  │  Riverpod State Management                                 │  │   │
│  │  │                                                             │  │   │
│  │  │  categoryBannersProvider(categoryCode)                     │  │   │
│  │  │  ├─ AsyncNotifierProvider.family                          │  │   │
│  │  │  ├─ Auto-caching per category                             │  │   │
│  │  │  ├─ Realtime subscription                                  │  │   │
│  │  │  └─ Mock data fallback                                     │  │   │
│  │  │                                                             │  │   │
│  │  │  categoryBannerRepositoryProvider                          │  │   │
│  │  │  └─ Provider<CategoryBannerRepository?>                    │  │   │
│  │  └────────────────────────────────────────────────────────────┘  │   │
│  │                                         │                         │   │
│  │                                         │ uses                   │   │
│  └─────────────────────────────────────────┼─────────────────────────┘   │
│                                            │                             │
│  ┌─────────────────────────────────────────┼─────────────────────────┐   │
│  │                     DATA LAYER          ▼                         │   │
│  │                                                                    │   │
│  │  ┌────────────────────────────────────────────────────────────┐  │   │
│  │  │  CategoryBannerRepository                                  │  │   │
│  │  │  + fetchBannersByCategory(categoryCode)                    │  │   │
│  │  │  + fetchAllActiveBanners()                                 │  │   │
│  │  │  + fetchBannerById(id)                                     │  │   │
│  │  │  + subscribeToBanners(categoryCode, callbacks)             │  │   │
│  │  │  + trackBannerClick(bannerId, userId?)                     │  │   │
│  │  │  + trackBannerImpression(bannerId, userId?)                │  │   │
│  │  └────────────────────────────────────────────────────────────┘  │   │
│  │                                         │                         │   │
│  │                                         │ queries                │   │
│  └─────────────────────────────────────────┼─────────────────────────┘   │
└─────────────────────────────────────────────┼──────────────────────────────┘
                                             │
                                             │ HTTPS / WebSocket
                                             │
┌────────────────────────────────────────────▼───────────────────────────┐
│                         SUPABASE BACKEND                                │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐ │
│  │  PostgreSQL Database                                              │ │
│  │                                                                    │ │
│  │  ┌───────────────────────┐         ┌─────────────────────────┐  │ │
│  │  │ category_banners      │         │ banner_analytics        │  │ │
│  │  │ ├─ id (PK)            │         │ ├─ id (PK)              │  │ │
│  │  │ ├─ category_code      │         │ ├─ banner_id (FK)       │  │ │
│  │  │ ├─ title              │         │ ├─ user_id (FK)         │  │ │
│  │  │ ├─ subtitle           │         │ ├─ event_type           │  │ │
│  │  │ ├─ image_url          │         │ └─ created_at           │  │ │
│  │  │ ├─ background_color   │         └─────────────────────────┘  │ │
│  │  │ ├─ action_url         │                                       │ │
│  │  │ ├─ sort_order         │                                       │ │
│  │  │ ├─ is_active          │                                       │ │
│  │  │ ├─ start_date         │                                       │ │
│  │  │ ├─ end_date           │                                       │ │
│  │  │ ├─ click_count        │                                       │ │
│  │  │ ├─ impression_count   │                                       │ │
│  │  │ ├─ created_at         │                                       │ │
│  │  │ └─ updated_at         │                                       │ │
│  │  └───────────────────────┘                                       │ │
│  │                                                                    │ │
│  │  Indexes:                                                          │ │
│  │  - idx_category_banners_category (category_code)                  │ │
│  │  - idx_category_banners_active (is_active)                        │ │
│  │  - idx_category_banners_sort (category_code, sort_order)          │ │
│  └──────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐ │
│  │  Database Functions (RPC)                                         │ │
│  │  - increment_banner_clicks(banner_id UUID)                        │ │
│  │  - increment_banner_impressions(banner_id UUID)                   │ │
│  └──────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐ │
│  │  Row Level Security (RLS)                                         │ │
│  │  - Public: Read active banners                                    │ │
│  │  - Admins: Full CRUD access                                       │ │
│  │  - Users: Insert analytics events                                 │ │
│  └──────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐ │
│  │  Realtime                                                         │ │
│  │  - Broadcasts INSERT/UPDATE/DELETE events                         │ │
│  │  - Filtered by category_code                                      │ │
│  └──────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────┘
```

## Sequence Diagram - Initial Load

```
User          BenefitsScreen    CategoryBannerCarousel    Provider         Repository       Supabase
 │                 │                      │                 │                  │               │
 │ Opens app       │                      │                 │                  │               │
 │────────────────►│                      │                 │                  │               │
 │                 │                      │                 │                  │               │
 │                 │ Builds widget        │                 │                  │               │
 │                 │─────────────────────►│                 │                  │               │
 │                 │                      │                 │                  │               │
 │                 │                      │ ref.watch(      │                  │               │
 │                 │                      │   categoryBannersProvider)         │               │
 │                 │                      │────────────────►│                  │               │
 │                 │                      │                 │                  │               │
 │                 │                      │                 │ _fetchBanners()  │               │
 │                 │                      │                 │─────────────────►│               │
 │                 │                      │                 │                  │               │
 │                 │                      │                 │                  │ SELECT *     │
 │                 │                      │                 │                  │ FROM banners │
 │                 │                      │                 │                  │ WHERE...     │
 │                 │                      │                 │                  │──────────────►│
 │                 │                      │                 │                  │               │
 │                 │                      │                 │                  │ Banners[]    │
 │                 │                      │                 │                  │◄──────────────│
 │                 │                      │                 │                  │               │
 │                 │                      │                 │ List<Banner>     │               │
 │                 │                      │                 │◄─────────────────│               │
 │                 │                      │                 │                  │               │
 │                 │                      │ AsyncValue.data(banners)           │               │
 │                 │                      │◄────────────────│                  │               │
 │                 │                      │                 │                  │               │
 │                 │                      │ Builds UI       │                  │               │
 │                 │ Rendered banners     │                 │                  │               │
 │◄────────────────│◄─────────────────────│                 │                  │               │
 │                 │                      │                 │                  │               │
 │ Sees banners    │                      │                 │                  │               │
```

## Sequence Diagram - User Interaction

```
User          CategoryBannerCarousel    Provider         Repository       Supabase
 │                      │                 │                  │               │
 │ Swipes banner        │                 │                  │               │
 │─────────────────────►│                 │                  │               │
 │                      │                 │                  │               │
 │                      │ onPageChanged() │                  │               │
 │                      │                 │                  │               │
 │                      │ trackImpression(bannerId)          │               │
 │                      │─────────────────────────────────────►               │
 │                      │                 │                  │               │
 │                      │                 │                  │ RPC:          │
 │                      │                 │                  │ increment_    │
 │                      │                 │                  │ impressions   │
 │                      │                 │                  │──────────────►│
 │                      │                 │                  │               │
 │                      │                 │                  │ INSERT INTO   │
 │                      │                 │                  │ analytics     │
 │                      │                 │                  │──────────────►│
 │                      │                 │                  │               │
 │                      │                 │                  │ Success       │
 │                      │                 │                  │◄──────────────│
 │                      │                 │                  │               │
 │ Taps banner          │                 │                  │               │
 │─────────────────────►│                 │                  │               │
 │                      │                 │                  │               │
 │                      │ trackClick(bannerId)               │               │
 │                      │─────────────────────────────────────►               │
 │                      │                 │                  │               │
 │                      │                 │                  │ RPC:          │
 │                      │                 │                  │ increment_    │
 │                      │                 │                  │ clicks        │
 │                      │                 │                  │──────────────►│
 │                      │                 │                  │               │
 │                      │                 │                  │ INSERT INTO   │
 │                      │                 │                  │ analytics     │
 │                      │                 │                  │──────────────►│
 │                      │                 │                  │               │
 │                      │ context.push(actionUrl)            │               │
 │                      │                 │                  │               │
 │ Navigates to detail  │                 │                  │               │
 │◄─────────────────────│                 │                  │               │
```

## Sequence Diagram - Realtime Update

```
Admin        Supabase       Realtime       Provider         Repository    CategoryBannerCarousel
 │              │              │              │                  │               │
 │ Updates      │              │              │                  │               │
 │ banner       │              │              │                  │               │
 │─────────────►│              │              │                  │               │
 │              │              │              │                  │               │
 │              │ UPDATE       │              │                  │               │
 │              │ category_    │              │                  │               │
 │              │ banners      │              │                  │               │
 │              │              │              │                  │               │
 │              │ Broadcast    │              │                  │               │
 │              │ UPDATE event │              │                  │               │
 │              │─────────────►│              │                  │               │
 │              │              │              │                  │               │
 │              │              │ onUpdate()   │                  │               │
 │              │              │──────────────────────────────────►              │
 │              │              │              │                  │               │
 │              │              │              │ refresh()        │               │
 │              │              │              │◄─────────────────│               │
 │              │              │              │                  │               │
 │              │              │              │ _fetchBanners()  │               │
 │              │              │              │─────────────────►│               │
 │              │              │              │                  │               │
 │              │              │              │                  │ SELECT...    │
 │              │              │              │                  │──────────────►│
 │              │              │              │                  │               │
 │              │              │              │                  │ Updated[]    │
 │              │              │              │                  │◄──────────────│
 │              │              │              │                  │               │
 │              │              │              │ List<Banner>     │               │
 │              │              │              │◄─────────────────│               │
 │              │              │              │                  │               │
 │              │              │              │ State updated    │               │
 │              │              │              │                  │               │
 │              │              │              │                  │               │ UI rebuild
 │              │              │              │                  │               │◄────────────
 │              │              │              │                  │               │
 │              │              │              │                  │               │ User sees
 │              │              │              │                  │               │ new banner
```

## Component Diagram - CategoryBannerCarousel

```
┌──────────────────────────────────────────────────────────────────┐
│              CategoryBannerCarousel (StatefulWidget)             │
├──────────────────────────────────────────────────────────────────┤
│ Properties:                                                       │
│ + categoryCode: String                                            │
│                                                                   │
│ State:                                                            │
│ - _pageController: PageController                                 │
│ - _currentIndex: int                                              │
│ - _impressionTracked: Set<String>                                 │
│                                                                   │
│ Methods:                                                          │
│ + build(BuildContext) → Widget                                    │
│ - _handleBannerTap(CategoryBanner) → void                         │
│ - _trackImpression(String bannerId) → void                        │
│ - _trackClick(String bannerId) → void                             │
│ - _parseColor(String hexColor) → Color                            │
│                                                                   │
│ Watches:                                                          │
│ - categoryBannersProvider(categoryCode)                           │
│                                                                   │
│ Composition:                                                      │
│ ┌────────────────────────────────────────────────────────────┐  │
│ │ AsyncValue.when()                                          │  │
│ │ ├─ loading: BannerSkeleton()                               │  │
│ │ ├─ error: EmptyBanner()                                    │  │
│ │ └─ data:                                                   │  │
│ │    └─ PageView.builder()                                   │  │
│ │       └─ GestureDetector                                   │  │
│ │          └─ AdvertisementBanner                            │  │
│ │             ├─ title                                       │  │
│ │             ├─ subtitle                                    │  │
│ │             ├─ imageUrl                                    │  │
│ │             ├─ backgroundColor                             │  │
│ │             ├─ currentIndex                                │  │
│ │             └─ totalCount                                  │  │
│ └────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
```

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         DATA FLOW                                    │
└─────────────────────────────────────────────────────────────────────┘

1. USER OPENS BENEFITS SCREEN
   │
   ├─► BenefitsScreen builds with selectedCategoryIndex = 0
   │
   └─► CategoryBannerCarousel receives categoryCode = "popular"

2. WIDGET WATCHES PROVIDER
   │
   └─► ref.watch(categoryBannersProvider("popular"))
       │
       ├─► Cache Miss → Fetch from repository
       │   │
       │   ├─► Repository queries Supabase
       │   │   SELECT * FROM category_banners
       │   │   WHERE category_code = 'popular'
       │   │   AND is_active = true
       │   │   ORDER BY sort_order ASC
       │   │
       │   └─► Returns List<CategoryBanner>
       │
       ├─► Cache Hit → Return cached data
       │
       └─► Returns AsyncValue<List<CategoryBanner>>

3. UI BUILDS WITH DATA
   │
   ├─► AsyncValue.when() handles states:
   │   ├─ loading → Show skeleton
   │   ├─ error → Show empty state
   │   └─ data → Build PageView
   │
   └─► PageView displays banners with indicators

4. USER SWIPES BANNER
   │
   ├─► PageController.onPageChanged(index)
   │
   └─► Track impression (if not already tracked)
       │
       └─► Repository.trackBannerImpression(bannerId)
           ├─► RPC: increment_banner_impressions
           └─► INSERT INTO banner_analytics

5. USER TAPS BANNER
   │
   ├─► GestureDetector.onTap()
   │
   ├─► Repository.trackBannerClick(bannerId)
   │   ├─► RPC: increment_banner_clicks
   │   └─► INSERT INTO banner_analytics
   │
   └─► context.push(banner.actionUrl)

6. USER SWITCHES CATEGORY TAB
   │
   ├─► setState(() => _selectedCategoryIndex = newIndex)
   │
   ├─► CategoryBannerCarousel rebuilds with new categoryCode
   │
   └─► Provider fetches banners for new category
       │
       └─► Cache check → Fetch if needed → Update UI

7. ADMIN UPDATES BANNER (REALTIME)
   │
   ├─► Admin panel UPDATE category_banners
   │
   ├─► Supabase broadcasts realtime event
   │
   ├─► Repository subscription receives event
   │   │
   │   └─► onUpdate(banner) callback
   │
   ├─► Provider.refresh() triggered
   │
   └─► UI automatically rebuilds with new data
```

## State Management Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    RIVERPOD PROVIDER HIERARCHY                       │
└─────────────────────────────────────────────────────────────────────┘

supabaseServiceProvider
└─► Provider<SupabaseService>
    └─► Singleton instance

categoryBannerRepositoryProvider
└─► Provider<CategoryBannerRepository?>
    ├─► Depends on: supabaseServiceProvider
    └─► Returns null if Supabase not initialized

categoryBannersProvider(categoryCode)
└─► AsyncNotifierProvider.family<CategoryBannersNotifier, List<CategoryBanner>, String>
    ├─► Depends on: categoryBannerRepositoryProvider
    ├─► Auto-caches per category code
    ├─► Lifecycle:
    │   ├─ build() → Fetch initial data
    │   ├─ _setupRealtimeSubscription() → Subscribe to changes
    │   └─ dispose() → Cleanup subscription
    └─► Methods:
        ├─ refresh() → Manual refresh
        └─ _fetchBanners() → Fetch from repository or mock

categoryBannersListProvider(categoryCode)
└─► Provider.family<List<CategoryBanner>, String>
    ├─► Depends on: categoryBannersProvider(categoryCode)
    └─► Convenience accessor for simple list

categoryBannerIndexProvider(categoryCode)
└─► StateProvider.family<int, String>
    └─► Tracks current banner index per category

┌─────────────────────────────────────────────────────────────────────┐
│                      PROVIDER LIFECYCLE                              │
└─────────────────────────────────────────────────────────────────────┘

INITIALIZATION
├─ Widget mounts
├─ ref.watch(categoryBannersProvider("popular"))
├─ Provider not in cache → build() called
├─ _setupRealtimeSubscription()
└─ _fetchBanners() → State = AsyncValue.data(banners)

UPDATES
├─ Realtime event received
├─ onUpdate callback → refresh()
├─ State = AsyncValue.loading()
├─ _fetchBanners()
└─ State = AsyncValue.data(updatedBanners)

DISPOSAL
├─ Widget unmounts
├─ ref.onDispose() triggered
├─ _channel?.unsubscribe()
└─ Provider garbage collected (after keepAlive period)

CACHE BEHAVIOR
├─ Family providers cached by parameter (categoryCode)
├─ Multiple widgets watching same category → single fetch
├─ Different categories → separate provider instances
└─ Auto-cleanup when no longer watched
```

## Error Handling Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                      ERROR HANDLING STRATEGY                         │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────┐
│ Fetch Banners Attempt   │
└─────────┬───────────────┘
          │
          ├─► Supabase Available?
          │   │
          │   ├─ NO → Return Mock Data
          │   │        └─► UI shows mock banners
          │   │
          │   └─ YES → Query Database
          │            │
          │            ├─► Success & Has Data
          │            │   └─► Return banners
          │            │
          │            ├─► Success & Empty
          │            │   └─► Return Mock Data
          │            │
          │            ├─► Network Error
          │            │   ├─► Log error
          │            │   └─► Return Mock Data
          │            │
          │            └─► Database Error
          │                ├─► Log error
          │                └─► Return Mock Data
          │
          └─► UI always shows content (no error states)

┌─────────────────────────┐
│ Analytics Tracking      │
└─────────┬───────────────┘
          │
          ├─► Track Click/Impression
          │   │
          │   ├─► Success → Silent (no UI feedback)
          │   │
          │   └─► Error
          │       ├─► Log error
          │       ├─► DO NOT throw exception
          │       └─► Continue user flow
          │
          └─► Analytics failure NEVER blocks UX
```

## Database Relationships

```
┌────────────────────────────────────────────────────────────────┐
│                    DATABASE SCHEMA                              │
└────────────────────────────────────────────────────────────────┘

category_banners                     banner_analytics
┌─────────────────────┐             ┌──────────────────────┐
│ id (PK, UUID)       │◄────────────│ banner_id (FK, UUID) │
│ category_code       │      1:N    │ id (PK, UUID)        │
│ title               │             │ user_id (FK, UUID)   │
│ subtitle            │             │ event_type           │
│ image_url           │             │ created_at           │
│ background_color    │             └──────────────────────┘
│ action_url          │                      │
│ sort_order          │                      │ N:1
│ is_active           │                      │
│ start_date          │                      ▼
│ end_date            │             ┌──────────────────────┐
│ click_count         │             │ auth.users           │
│ impression_count    │             │ ├─ id (PK)           │
│ created_at          │             │ └─ email             │
│ updated_at          │             └──────────────────────┘
└─────────────────────┘

CONSTRAINTS:
- banner_analytics.banner_id → category_banners.id (ON DELETE CASCADE)
- banner_analytics.user_id → auth.users.id (ON DELETE SET NULL)

INDEXES:
- idx_category_banners_category ON category_banners(category_code)
- idx_category_banners_active ON category_banners(is_active)
- idx_category_banners_sort ON category_banners(category_code, sort_order)
- idx_banner_analytics_banner ON banner_analytics(banner_id)
- idx_banner_analytics_user ON banner_analytics(user_id)
- idx_banner_analytics_created ON banner_analytics(created_at DESC)
```

## File Dependencies Graph

```
┌─────────────────────────────────────────────────────────────────┐
│                    FILE DEPENDENCIES                             │
└─────────────────────────────────────────────────────────────────┘

BenefitsScreen
  └─► CategoryBannerCarousel
        ├─► categoryBannersProvider
        │     ├─► CategoryBannersNotifier
        │     │     ├─► categoryBannerRepositoryProvider
        │     │     │     ├─► CategoryBannerRepository
        │     │     │     │     ├─► CategoryBanner (model)
        │     │     │     │     ├─► CategoryBannerException
        │     │     │     │     └─► SupabaseClient
        │     │     │     └─► supabaseServiceProvider
        │     │     └─► CategoryBanner (model)
        │     └─► CategoryCodes (constants)
        └─► AdvertisementBanner (design system)
              └─► IndicatorBadge (design system)

DEPENDENCY DIRECTION: Top → Bottom (imports)
NO CIRCULAR DEPENDENCIES
```

---

## Legend

```
┌─────────────┐
│  Component  │  = System/Container/Widget
└─────────────┘

┌─────────────┐
│  Database   │  = Data storage
└─────────────┘

──────────────►  = Data/Control flow
◄──────────────  = Response/Result

├─► = Branch/Option
└─► = End/Result

PK = Primary Key
FK = Foreign Key
RPC = Remote Procedure Call
RLS = Row Level Security
```
