# Storage Setup Quick Start

## Prerequisites

- Supabase CLI installed: `npm install -g supabase`
- Docker running (for local development)

## Quick Setup Steps

### 1. Start Supabase

```bash
cd /Users/kwonhyunjun/Desktop/pickly_service/supabase
supabase start
```

This will start all Supabase services including Storage.

### 2. Apply Storage Migration

```bash
supabase db reset
```

This applies the storage setup migration (`20251024100000_storage_setup.sql`).

### 3. Verify Setup

```bash
cd /Users/kwonhyunjun/Desktop/pickly_service
./scripts/test_storage_setup.sh
```

### 4. Test Upload (Optional)

```bash
cd /Users/kwonhyunjun/Desktop/pickly_service

# Install dependencies if needed
npm install @supabase/supabase-js

# Run upload test
node scripts/test_storage_upload.js
```

## What Gets Created

### Storage Bucket
- **Name**: `pickly-storage`
- **Public**: Yes
- **File Size Limit**: 50MB
- **Allowed Types**: Images (JPEG, PNG, GIF, WebP), Documents (PDF, DOC, DOCX)

### Folder Structure
```
pickly-storage/
├── announcements/
│   ├── thumbnails/{announcement_id}/
│   ├── images/{announcement_id}/
│   └── documents/{announcement_id}/
├── banners/
│   ├── categories/
│   └── promotions/
└── test/
```

### Database Tables
1. **storage_folders**: Documents folder structure
2. **benefit_files**: Tracks all uploaded files with metadata

### Helper Functions
- `generate_announcement_file_path()`: Generate standardized paths
- `generate_banner_path()`: Generate banner paths
- `get_storage_public_url()`: Get public URLs

### Views
- `v_announcement_files`: Files with announcement details
- `v_storage_stats`: Storage usage statistics

## Access URLs

After starting Supabase, you'll have:

- **API URL**: `http://localhost:54321`
- **Studio URL**: `http://localhost:54323`
- **Storage API**: `http://localhost:54321/storage/v1`
- **Public Storage**: `http://localhost:54321/storage/v1/object/public/pickly-storage`

## Example Usage

### Upload via JavaScript

```javascript
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  'http://localhost:54321',
  'YOUR_ANON_KEY'
);

// Upload file
const { data, error } = await supabase.storage
  .from('pickly-storage')
  .upload('banners/test/sample.jpg', file);

// Get public URL
const { data: urlData } = supabase.storage
  .from('pickly-storage')
  .getPublicUrl('banners/test/sample.jpg');

console.log(urlData.publicUrl);
```

### Upload via cURL

```bash
curl -X POST "http://localhost:54321/storage/v1/object/pickly-storage/banners/test/sample.jpg" \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -F "file=@/path/to/image.jpg"
```

## Troubleshooting

### Storage Not Enabled
Edit `/supabase/config.toml`:
```toml
[storage]
enabled = true
```

### Supabase Won't Start
```bash
# Stop all services
supabase stop

# Start fresh
supabase start
```

### Migration Errors
```bash
# Reset database
supabase db reset --debug

# Or apply specific migration
supabase migration up
```

## Next Steps

1. ✓ Storage configured and ready
2. → Integrate into mobile app
3. → Add file upload UI
4. → Implement image optimization
5. → Add CDN for production

## Files Created

- `/supabase/migrations/20251024100000_storage_setup.sql` - Main migration
- `/supabase/config.toml` - Updated with storage config
- `/scripts/test_storage_setup.sh` - Setup verification script
- `/scripts/test_storage_upload.js` - Upload test script
- `/docs/storage-setup-guide.md` - Complete documentation
- `/docs/storage-quick-start.md` - This file

## Support

See full documentation: `/docs/storage-setup-guide.md`
