# Supabase Storage Setup Guide - Pickly Service

## Overview

This document describes the Supabase Storage configuration for the Pickly benefit announcement system.

## Bucket Configuration

### Bucket Name
`pickly-storage`

### Settings
- **Public Access**: Enabled (true)
- **File Size Limit**: 50MB (52,428,800 bytes)
- **Allowed MIME Types**:
  - Images: `image/jpeg`, `image/jpg`, `image/png`, `image/gif`, `image/webp`
  - Documents: `application/pdf`, `application/msword`, `application/vnd.openxmlformats-officedocument.wordprocessingml.document`

## Folder Structure

```
pickly-storage/
├── announcements/
│   ├── thumbnails/{announcement_id}/
│   │   └── [thumbnail images for cards]
│   ├── images/{announcement_id}/
│   │   └── [full-size images for details]
│   └── documents/{announcement_id}/
│       └── [PDF and document attachments]
├── banners/
│   ├── categories/
│   │   └── {category_id}/
│   │       └── [category banner images]
│   └── promotions/
│       └── [promotional banners]
└── test/
    └── [test files for development]
```

## Storage Policies

### 1. Public Read Access
- **Policy Name**: "Public Access to All Files"
- **Action**: SELECT
- **Access**: Anyone can read/view files
- **Purpose**: Allow public viewing of benefit announcements and images

### 2. Authenticated Upload
- **Policy Name**: "Authenticated Upload"
- **Action**: INSERT
- **Access**: Authenticated users only
- **Purpose**: Secure file uploads

### 3. Authenticated Update
- **Policy Name**: "Authenticated Update Own Files"
- **Action**: UPDATE
- **Access**: Users can update their own uploads
- **Purpose**: Allow file modifications

### 4. Authenticated Delete
- **Policy Name**: "Authenticated Delete"
- **Action**: DELETE
- **Access**: Users can delete their own uploads
- **Purpose**: File management

### 5. Service Role Access
- **Policy Name**: "Service Role Full Access"
- **Action**: ALL
- **Access**: Service role (admin operations)
- **Purpose**: Administrative control

## Database Tables

### `storage_folders`
Documents the intended folder structure.

**Columns**:
- `id` (UUID): Primary key
- `bucket_id` (TEXT): Reference to storage bucket
- `path` (TEXT): Folder path (unique)
- `description` (TEXT): Folder description
- `created_at` (TIMESTAMPTZ): Creation timestamp

### `benefit_files`
Tracks all uploaded files for benefit announcements.

**Columns**:
- `id` (UUID): Primary key
- `announcement_id` (UUID): Reference to benefit announcement
- `file_type` (TEXT): Type of file (thumbnail, image, document, banner)
- `storage_path` (TEXT): Full path in storage (unique)
- `file_name` (TEXT): Original file name
- `file_size` (INTEGER): File size in bytes
- `mime_type` (TEXT): MIME type
- `public_url` (TEXT): Public access URL
- `uploaded_by` (UUID): User who uploaded
- `uploaded_at` (TIMESTAMPTZ): Upload timestamp
- `metadata` (JSONB): Additional metadata

**Indexes**:
- `idx_benefit_files_announcement`: Fast lookup by announcement
- `idx_benefit_files_type`: Fast lookup by file type
- `idx_benefit_files_uploaded_at`: Sort by upload date

**RLS Policies**:
- Public read access
- Authenticated users can upload
- Users can update/delete their own uploads

## Helper Functions

### `generate_announcement_file_path()`
Generates standardized storage path for announcement files.

**Parameters**:
- `p_announcement_id` (UUID): Announcement ID
- `p_file_type` (TEXT): File type (thumbnails, images, documents)
- `p_file_name` (TEXT): File name

**Returns**: Full storage path

**Example**:
```sql
SELECT generate_announcement_file_path(
  '123e4567-e89b-12d3-a456-426614174000',
  'thumbnails',
  'image.jpg'
);
-- Returns: announcements/thumbnails/123e4567-e89b-12d3-a456-426614174000/image.jpg
```

### `generate_banner_path()`
Generates storage path for banner images.

**Parameters**:
- `p_category` (TEXT): Category name
- `p_file_name` (TEXT): File name

**Returns**: Full storage path

**Example**:
```sql
SELECT generate_banner_path('housing', 'banner.jpg');
-- Returns: banners/housing/banner.jpg
```

### `get_storage_public_url()`
Generates public URL for storage object.

**Parameters**:
- `p_bucket_id` (TEXT): Bucket ID
- `p_path` (TEXT): Object path

**Returns**: Public URL

## Views

### `v_announcement_files`
Combined view of files with announcement details.

**Columns**:
- All columns from `benefit_files`
- `announcement_title`: Title of the announcement
- `organization`: Organization name

### `v_storage_stats`
Storage usage statistics by file type.

**Columns**:
- `file_type`: Type of file
- `file_count`: Number of files
- `total_size_bytes`: Total size in bytes
- `total_size_mb`: Total size in MB
- `avg_file_size_bytes`: Average file size

## Usage Examples

### Upload File (JavaScript/TypeScript)

```typescript
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Upload thumbnail for announcement
async function uploadThumbnail(announcementId: string, file: File) {
  const fileName = `thumbnail_${Date.now()}.jpg`;
  const filePath = `announcements/thumbnails/${announcementId}/${fileName}`;

  const { data, error } = await supabase.storage
    .from('pickly-storage')
    .upload(filePath, file, {
      contentType: file.type,
      upsert: false
    });

  if (error) throw error;

  // Get public URL
  const { data: { publicUrl } } = supabase.storage
    .from('pickly-storage')
    .getPublicUrl(filePath);

  // Track in database
  await supabase.from('benefit_files').insert({
    announcement_id: announcementId,
    file_type: 'thumbnail',
    storage_path: filePath,
    file_name: fileName,
    file_size: file.size,
    mime_type: file.type,
    public_url: publicUrl
  });

  return publicUrl;
}
```

### Upload Banner (cURL)

```bash
# Get your anon key from Supabase dashboard
ANON_KEY="your_anon_key_here"
API_URL="http://localhost:54321"

curl -X POST "$API_URL/storage/v1/object/pickly-storage/banners/test/sample.jpg" \
  -H "Authorization: Bearer $ANON_KEY" \
  -F "file=@/path/to/image.jpg"
```

### Get Public URL

```typescript
const { data } = supabase.storage
  .from('pickly-storage')
  .getPublicUrl('announcements/thumbnails/123/image.jpg');

console.log(data.publicUrl);
// http://localhost:54321/storage/v1/object/public/pickly-storage/announcements/thumbnails/123/image.jpg
```

### List Files in Folder

```typescript
const { data, error } = await supabase.storage
  .from('pickly-storage')
  .list('announcements/thumbnails/123', {
    limit: 100,
    offset: 0,
    sortBy: { column: 'name', order: 'asc' }
  });
```

### Delete File

```typescript
const { error } = await supabase.storage
  .from('pickly-storage')
  .remove(['announcements/thumbnails/123/image.jpg']);
```

### Query File Metadata

```sql
-- Get all files for an announcement
SELECT * FROM v_announcement_files
WHERE announcement_id = '123e4567-e89b-12d3-a456-426614174000'
ORDER BY uploaded_at DESC;

-- Get storage statistics
SELECT * FROM v_storage_stats;

-- Get all thumbnails
SELECT * FROM benefit_files
WHERE file_type = 'thumbnail'
ORDER BY uploaded_at DESC
LIMIT 10;
```

## Testing

### Run Test Script

```bash
cd /Users/kwonhyunjun/Desktop/pickly_service
chmod +x scripts/test_storage_setup.sh
./scripts/test_storage_setup.sh
```

### Manual Testing Steps

1. **Start Supabase**:
   ```bash
   cd supabase
   supabase start
   ```

2. **Apply Migration**:
   ```bash
   supabase db reset
   ```

3. **Check Bucket**:
   - Open Supabase Studio: http://localhost:54323
   - Navigate to Storage
   - Verify `pickly-storage` bucket exists

4. **Test Upload**:
   - Use Storage UI to upload a test image
   - Or use the API/SDK examples above

5. **Verify Public Access**:
   - Copy public URL from Storage UI
   - Open in browser to verify image loads

## Troubleshooting

### Storage Not Enabled
**Error**: Storage is disabled
**Solution**:
```toml
# In supabase/config.toml
[storage]
enabled = true
```

### Bucket Not Found
**Error**: Bucket 'pickly-storage' does not exist
**Solution**: Run migration or create manually in Storage UI

### Upload Permission Denied
**Error**: 403 Forbidden
**Solution**: Check RLS policies and authentication

### File Size Limit Exceeded
**Error**: File size exceeds limit
**Solution**: Reduce file size or increase limit in config.toml

## Migration Files

- **Main Migration**: `/supabase/migrations/20251024100000_storage_setup.sql`
- **Config**: `/supabase/config.toml`

## Related Tables

- `benefit_announcements`: Main announcement data
- `benefit_files`: File tracking
- `storage.buckets`: Supabase storage buckets
- `storage.objects`: Supabase storage objects

## Security Considerations

1. **Public Bucket**: All files are publicly accessible via URL
2. **Upload Authentication**: Only authenticated users can upload
3. **File Size Limits**: 50MB per file
4. **MIME Type Restrictions**: Only allowed file types can be uploaded
5. **RLS Policies**: Enforce access control at database level

## Performance Optimization

1. **CDN**: Consider using a CDN for production
2. **Image Optimization**: Compress images before upload
3. **Lazy Loading**: Load images on demand
4. **Caching**: Enable browser and CDN caching
5. **Thumbnails**: Use smaller thumbnails for lists, full images for details

## Production Checklist

- [ ] Enable storage in production config
- [ ] Create `pickly-storage` bucket
- [ ] Apply all RLS policies
- [ ] Configure CDN (optional)
- [ ] Set up image optimization
- [ ] Test file uploads
- [ ] Test public URLs
- [ ] Monitor storage usage
- [ ] Set up backup strategy
- [ ] Configure CORS if needed

## Support

For issues or questions, refer to:
- [Supabase Storage Documentation](https://supabase.com/docs/guides/storage)
- [Supabase Storage API Reference](https://supabase.com/docs/reference/javascript/storage)
