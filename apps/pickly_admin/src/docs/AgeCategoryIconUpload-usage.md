# Age Category Icon Upload - Usage Guide

## 📋 Overview

Age category icon upload functionality allows Admin users to upload SVG icons for age categories and automatically update the database with the public URL and component name.

**Added:** 2025-11-08
**Module:** `src/utils/storage.ts`
**Functions:** `uploadAndUpdateAgeCategoryIcon()`, `uploadAgeCategoryIconOnly()`

---

## 🎯 Features

- ✅ **SVG-only validation** (age category icons must be SVG)
- ✅ **File size validation** (max 1MB)
- ✅ **Automatic filename generation** (timestamp + random string)
- ✅ **Public URL generation** from Supabase Storage
- ✅ **Automatic database update** (icon_url + icon_component fields)
- ✅ **Component name extraction** from filename

---

## 📦 Storage Bucket

**Bucket:** `age-icons`
**Folder:** `icons/`
**File Pattern:** `{timestamp}-{randomStr}.svg`
**Example:** `1731034567890-abc123.svg`

---

## 🔧 Function Signatures

### 1. uploadAndUpdateAgeCategoryIcon (Recommended)

```typescript
export async function uploadAndUpdateAgeCategoryIcon(
  file: File,
  ageCategoryId: string
): Promise<UploadResult>
```

**Parameters:**
- `file: File` - SVG icon file to upload
- `ageCategoryId: string` - UUID of the age category to update

**Returns:** `Promise<UploadResult>`
```typescript
{
  url: string       // Public URL (e.g., "http://.../age-icons/icons/123-abc.svg")
  path: string      // Storage path (e.g., "icons/123-abc.svg")
  name: string      // Original filename (e.g., "young_man.svg")
  size: number      // File size in bytes
  type: string      // MIME type ("image/svg+xml")
}
```

**Throws:**
- `Error` - If file is not SVG
- `Error` - If file size > 1MB
- `Error` - If upload fails
- `Error` - If database update fails

---

### 2. uploadAgeCategoryIconOnly

```typescript
export async function uploadAgeCategoryIconOnly(
  file: File
): Promise<UploadResult>
```

**Use Case:** Upload icon first, update database separately

**Parameters:**
- `file: File` - SVG icon file to upload

**Returns:** Same as above

**Throws:** Same validation errors

---

## 💻 Usage Examples

### Example 1: Basic Usage (React Component)

```tsx
import { uploadAndUpdateAgeCategoryIcon } from '@/utils/storage'
import { useState } from 'react'
import toast from 'react-hot-toast'

function AgeCategoryIconUploader({ categoryId }: { categoryId: string }) {
  const [uploading, setUploading] = useState(false)

  const handleFileChange = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (!file) return

    setUploading(true)

    try {
      const result = await uploadAndUpdateAgeCategoryIcon(file, categoryId)

      toast.success('Icon uploaded successfully!')
      console.log('Uploaded to:', result.url)
      console.log('Component name:', result.name.replace('.svg', ''))

      // Refresh UI or update local state
      // ...

    } catch (error: any) {
      toast.error(error.message || 'Upload failed')
      console.error('Upload error:', error)
    } finally {
      setUploading(false)
    }
  }

  return (
    <div>
      <input
        type="file"
        accept="image/svg+xml"
        onChange={handleFileChange}
        disabled={uploading}
      />
      {uploading && <p>Uploading...</p>}
    </div>
  )
}
```

---

### Example 2: With ImageUploader Component

```tsx
import ImageUploader from '@/components/common/ImageUploader'
import { uploadAndUpdateAgeCategoryIcon } from '@/utils/storage'

function AgeCategoryEditor({ category }: { category: AgeCategory }) {
  const handleIconUpload = async (url: string, path: string) => {
    // ImageUploader already handles the upload
    // Just update the database
    const { error } = await supabase
      .from('age_categories')
      .update({ icon_url: url })
      .eq('id', category.id)

    if (error) {
      toast.error('Failed to update icon')
    } else {
      toast.success('Icon updated!')
    }
  }

  return (
    <ImageUploader
      bucket="pickly-storage"
      currentImageUrl={category.icon_url}
      onUploadComplete={handleIconUpload}
      maxSizeMB={1}
      acceptedFormats={['image/svg+xml']}
      label="Age Category Icon"
      helperText="SVG files only, max 1MB"
    />
  )
}
```

---

### Example 3: Two-Step Process (Upload then Update)

```tsx
import { uploadAgeCategoryIconOnly } from '@/utils/storage'
import { supabase } from '@/lib/supabase'

async function uploadIconTwoStep(file: File, categoryId: string) {
  try {
    // Step 1: Upload icon to storage
    const uploadResult = await uploadAgeCategoryIconOnly(file)
    console.log('File uploaded:', uploadResult.url)

    // Step 2: Update database manually
    const componentName = file.name.replace(/\.(svg|SVG)$/, '')

    const { error } = await supabase
      .from('age_categories')
      .update({
        icon_url: uploadResult.url,
        icon_component: componentName,
      })
      .eq('id', categoryId)

    if (error) throw error

    return uploadResult
  } catch (error) {
    console.error('Two-step upload failed:', error)
    throw error
  }
}
```

---

### Example 4: Complete Admin Page Integration

```tsx
import { useState, useEffect } from 'react'
import { supabase } from '@/lib/supabase'
import { uploadAndUpdateAgeCategoryIcon } from '@/utils/storage'
import { Button, Table, TableBody, TableCell, TableHead, TableRow } from '@mui/material'
import toast from 'react-hot-toast'

interface AgeCategory {
  id: string
  name: string
  icon_url: string | null
  icon_component: string | null
}

function AgeCategoryManagementPage() {
  const [categories, setCategories] = useState<AgeCategory[]>([])
  const [uploading, setUploading] = useState<string | null>(null)

  useEffect(() => {
    fetchCategories()
  }, [])

  const fetchCategories = async () => {
    const { data, error } = await supabase
      .from('age_categories')
      .select('*')
      .order('min_age', { ascending: true })

    if (error) {
      toast.error('Failed to load categories')
    } else {
      setCategories(data || [])
    }
  }

  const handleIconUpload = async (categoryId: string, file: File) => {
    setUploading(categoryId)

    try {
      const result = await uploadAndUpdateAgeCategoryIcon(file, categoryId)

      toast.success(`Icon uploaded: ${result.name}`)

      // Refresh the categories list
      await fetchCategories()

    } catch (error: any) {
      toast.error(error.message || 'Upload failed')
    } finally {
      setUploading(null)
    }
  }

  return (
    <div>
      <h1>Age Category Management</h1>

      <Table>
        <TableHead>
          <TableRow>
            <TableCell>Name</TableCell>
            <TableCell>Current Icon</TableCell>
            <TableCell>Component</TableCell>
            <TableCell>Actions</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {categories.map((category) => (
            <TableRow key={category.id}>
              <TableCell>{category.name}</TableCell>
              <TableCell>
                {category.icon_url ? (
                  <img
                    src={category.icon_url}
                    alt={category.name}
                    style={{ width: 32, height: 32 }}
                  />
                ) : (
                  'No icon'
                )}
              </TableCell>
              <TableCell>{category.icon_component || 'N/A'}</TableCell>
              <TableCell>
                <input
                  type="file"
                  accept="image/svg+xml"
                  onChange={(e) => {
                    const file = e.target.files?.[0]
                    if (file) handleIconUpload(category.id, file)
                  }}
                  disabled={uploading === category.id}
                  style={{ display: 'none' }}
                  id={`upload-${category.id}`}
                />
                <label htmlFor={`upload-${category.id}`}>
                  <Button
                    component="span"
                    variant="outlined"
                    disabled={uploading === category.id}
                  >
                    {uploading === category.id ? 'Uploading...' : 'Upload Icon'}
                  </Button>
                </label>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  )
}

export default AgeCategoryManagementPage
```

---

## 🗄️ Database Schema

**Table:** `age_categories`

```sql
CREATE TABLE age_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  min_age INT NOT NULL,
  max_age INT,
  icon_url TEXT,           -- Public URL from Supabase Storage
  icon_component TEXT,     -- Component name (filename without extension)
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
```

**Example Row After Upload:**
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "name": "청년",
  "min_age": 19,
  "max_age": 34,
  "icon_url": "http://127.0.0.1:54321/storage/v1/object/public/age-icons/icons/1731034567890-abc123.svg",
  "icon_component": "young_man",
  "created_at": "2025-11-08T00:00:00Z",
  "updated_at": "2025-11-08T01:23:45Z"
}
```

---

## ⚠️ Error Handling

### Common Errors

**1. File Type Error**
```typescript
Error: Age category icons must be SVG files
```
**Solution:** Only upload `.svg` files

**2. File Size Error**
```typescript
Error: Icon size must be less than 1MB
```
**Solution:** Compress the SVG file

**3. Upload Error**
```typescript
Error: Upload failed: Bucket not found
```
**Solution:** Ensure `age-icons` bucket exists in Supabase Storage

**4. Database Update Error**
```typescript
Error: Database update failed: Permission denied
```
**Solution:** Check RLS policies on `age_categories` table

---

## 🧪 Testing

### Manual Test Checklist

- [ ] Upload valid SVG file (<1MB)
- [ ] Verify file appears in Supabase Storage (`age-icons/icons/`)
- [ ] Verify `icon_url` updated in database
- [ ] Verify `icon_component` extracted correctly
- [ ] Try uploading non-SVG file (should fail with error)
- [ ] Try uploading large file (>1MB) (should fail with error)
- [ ] Verify icon displays correctly in Flutter app
- [ ] Test with special characters in filename

### Unit Test Example

```typescript
import { describe, it, expect, vi } from 'vitest'
import { uploadAndUpdateAgeCategoryIcon } from '@/utils/storage'

describe('uploadAndUpdateAgeCategoryIcon', () => {
  it('should reject non-SVG files', async () => {
    const file = new File(['test'], 'test.png', { type: 'image/png' })

    await expect(
      uploadAndUpdateAgeCategoryIcon(file, 'category-id')
    ).rejects.toThrow('Age category icons must be SVG files')
  })

  it('should reject files larger than 1MB', async () => {
    const largeContent = new Array(1024 * 1024 + 1).fill('a').join('')
    const file = new File([largeContent], 'large.svg', { type: 'image/svg+xml' })

    await expect(
      uploadAndUpdateAgeCategoryIcon(file, 'category-id')
    ).rejects.toThrow('Icon size must be less than 1MB')
  })
})
```

---

## 🔗 Related Files

- `src/utils/storage.ts` - Storage utility functions
- `src/components/common/ImageUploader.tsx` - Reusable upload component
- `src/lib/supabase.ts` - Supabase client configuration

---

## 📝 Notes

1. **Component Name Extraction:**
   - Filename `young_man.svg` → component name `young_man`
   - Used for dynamic icon rendering in Flutter app

2. **URL Format:**
   - Local dev: `http://127.0.0.1:54321/storage/v1/object/public/age-icons/icons/...`
   - Production: `https://your-project.supabase.co/storage/v1/object/public/age-icons/icons/...`

3. **Upsert Enabled:**
   - If filename exists, it will be overwritten
   - Useful for updating existing icons

4. **Cache Control:**
   - Set to 3600 seconds (1 hour)
   - Reduces bandwidth usage

---

**Last Updated:** 2025-11-08
**Status:** Ready for use
**Tested:** Compilation ✅ | Manual Testing ⏳
