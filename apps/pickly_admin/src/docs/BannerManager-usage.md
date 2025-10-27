# BannerManager Component Usage

## Overview
The `BannerManager` component provides a complete solution for managing category banners with image upload, live preview, and toggle functionality.

## Features
1. **Toggle Switch**: Enable/disable banners with ON/OFF switch
2. **Image Upload**: Upload images to Supabase Storage (`banners/{category_id}/`)
3. **Link URL Input**: Optional link URL for banner clicks
4. **Live Preview**: Real-time preview of uploaded banner
5. **Database Integration**: Updates `benefit_categories` table automatically

## Installation

### 1. Run Database Migration
Execute the SQL migration to add banner fields:

```sql
-- In Supabase SQL Editor
ALTER TABLE benefit_categories
ADD COLUMN IF NOT EXISTS banner_image_url TEXT,
ADD COLUMN IF NOT EXISTS banner_link_url TEXT;
```

### 2. Configure Supabase Storage
Ensure the `pickly-storage` bucket exists with proper policies.

## Usage Example

### Basic Usage
```tsx
import BannerManager from '@/components/benefits/BannerManager'
import { BenefitCategory } from '@/types/database'

function CategoryPage() {
  const category: BenefitCategory = {
    id: 'category-123',
    name: '청년 주택',
    slug: 'youth-housing',
    // ... other fields
  }

  const handleBannerUpdate = () => {
    // Refresh category data or show success message
    console.log('Banner updated successfully')
  }

  return (
    <BannerManager
      category={category}
      onUpdate={handleBannerUpdate}
    />
  )
}
```

### Integration with Category Management Page
```tsx
import { useQuery } from '@tanstack/react-query'
import BannerManager from '@/components/benefits/BannerManager'
import { fetchCategoryById } from '@/api/categories'

function CategoryEditPage({ categoryId }: { categoryId: string }) {
  const { data: category, refetch } = useQuery({
    queryKey: ['category', categoryId],
    queryFn: () => fetchCategoryById(categoryId),
  })

  if (!category) return <div>Loading...</div>

  return (
    <div>
      <h1>Edit Category: {category.name}</h1>

      {/* Category form fields */}
      <CategoryForm category={category} />

      {/* Banner management */}
      <BannerManager
        category={category}
        onUpdate={() => refetch()}
      />
    </div>
  )
}
```

## Component Props

| Prop | Type | Required | Description |
|------|------|----------|-------------|
| `category` | `BenefitCategory` | Yes | The category object to manage banners for |
| `onUpdate` | `() => void` | No | Callback function called after successful banner update |

## Features in Detail

### 1. Toggle Switch
- Located in the card header
- ON: Shows banner management interface
- OFF: Hides interface and clears banner data from database

### 2. Image Upload
- **Supported formats**: All image types (jpg, png, gif, webp, etc.)
- **Max file size**: 5MB
- **Storage path**: `banners/{category_id}/banner-{timestamp}.{ext}`
- **Upload process**:
  1. File validation (type and size)
  2. Upload to Supabase Storage
  3. Generate public URL
  4. Update preview automatically

### 3. Direct URL Input
- Alternative to file upload
- Accepts any valid image URL
- Updates preview in real-time

### 4. Live Preview
- Displays uploaded or URL-based image
- Max height: 300px
- Responsive width
- Error handling for invalid URLs

### 5. Link URL
- Optional field
- Stores URL for banner click navigation
- Example: `/benefits/youth-housing` or `https://external-site.com`

### 6. Save Functionality
- Validates banner image exists
- Updates `benefit_categories` table:
  - `banner_image_url`
  - `banner_link_url`
  - `updated_at`
- Shows success/error toast notifications

## Storage Structure

```
pickly-storage/
└── banners/
    ├── category-1/
    │   └── banner-1698765432123.jpg
    ├── category-2/
    │   └── banner-1698765445678.png
    └── category-3/
        └── banner-1698765456789.webp
```

## Database Schema

### Updated `benefit_categories` Table
```sql
CREATE TABLE benefit_categories (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  slug TEXT NOT NULL,
  description TEXT,
  icon_url TEXT,
  banner_image_url TEXT,      -- NEW
  banner_link_url TEXT,        -- NEW
  display_order INTEGER,
  is_active BOOLEAN,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

## Error Handling

The component handles various error scenarios:

1. **File validation errors**
   - Non-image files
   - Files exceeding 5MB

2. **Upload errors**
   - Network failures
   - Storage permission issues
   - Invalid file formats

3. **Image loading errors**
   - Invalid URLs
   - Broken image links
   - CORS issues

4. **Database errors**
   - Update failures
   - Connection issues

All errors display user-friendly toast notifications.

## Best Practices

1. **Image Optimization**
   - Recommended size: 1200x400px
   - Use compressed images for faster loading
   - Consider WebP format for better compression

2. **URL Validation**
   - Validate link URLs before saving
   - Use relative URLs for internal links
   - Ensure HTTPS for external links

3. **Testing**
   - Test with various image formats
   - Verify upload with large files (near 5MB limit)
   - Test toggle behavior
   - Verify database updates

4. **Accessibility**
   - Images should have descriptive alt text
   - Ensure sufficient color contrast
   - Test keyboard navigation

## Troubleshooting

### Upload fails with 413 error
- File size exceeds 5MB limit
- Compress or resize the image

### Image doesn't display in preview
- Check if URL is publicly accessible
- Verify CORS settings in Supabase Storage
- Check browser console for errors

### Banner doesn't save to database
- Verify Supabase authentication
- Check table permissions in RLS policies
- Ensure `banner_image_url` and `banner_link_url` columns exist

## API Reference

### Upload Function
```typescript
async function handleFileUpload(file: File): Promise<void>
```

### Update Function
```typescript
async function handleUpdate(
  imageUrl?: string | null,
  linkUrl?: string | null
): Promise<void>
```

### Toggle Function
```typescript
async function handleToggleChange(
  event: React.ChangeEvent<HTMLInputElement>
): Promise<void>
```

## Future Enhancements

Potential improvements for future versions:

1. **Image Cropping**: Built-in image editor
2. **Multiple Banners**: Carousel/slider support
3. **A/B Testing**: Test different banner designs
4. **Analytics**: Track banner click rates
5. **Scheduling**: Set banner start/end dates
6. **Templates**: Pre-designed banner templates
