# FileUploader Component

A reusable, production-ready file upload component with drag-and-drop support, progress tracking, and Supabase Storage integration.

## Features

✅ **Drag-and-drop interface** using `react-dropzone`
✅ **Image and PDF support** with configurable MIME types
✅ **Real-time upload progress** with Material-UI LinearProgress
✅ **File preview** with thumbnails for images and icons for PDFs
✅ **Multiple file upload** with configurable limits
✅ **Supabase Storage integration** with automatic path organization
✅ **File size validation** with user-friendly error messages
✅ **Delete uploaded files** with storage cleanup
✅ **Responsive design** with Material-UI components

## Installation

The component requires `react-dropzone`:

```bash
npm install react-dropzone
```

## Basic Usage

```tsx
import { FileUploader } from '@/components/shared';
import type { AnnouncementFile } from '@/components/shared';

function MyForm() {
  const [files, setFiles] = useState<AnnouncementFile[]>([]);

  return (
    <FileUploader
      announcementId="announcement-123"
      onUploadComplete={setFiles}
      accept="image/*,application/pdf"
      maxFiles={10}
      maxSizeMB={10}
    />
  );
}
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `announcementId` | `string` | **Required** | Unique identifier for organizing files in storage |
| `onUploadComplete` | `(files: AnnouncementFile[]) => void` | **Required** | Callback when files are uploaded |
| `accept` | `string` | `'image/*,application/pdf'` | Accepted MIME types |
| `maxFiles` | `number` | `10` | Maximum number of files allowed |
| `maxSizeMB` | `number` | `10` | Maximum file size in megabytes |

## AnnouncementFile Type

```typescript
interface AnnouncementFile {
  id: string;           // Unique file identifier
  file_name: string;    // Original file name
  file_path: string;    // Storage path in Supabase
  file_url: string;     // Public URL for accessing the file
  file_type: string;    // MIME type (e.g., 'image/jpeg')
  file_size: number;    // File size in bytes
}
```

## Storage Structure

Files are organized in Supabase Storage as:

```
announcements/
  images/
    {announcementId}/
      {timestamp}-0.jpg
      {timestamp}-1.pdf
      {timestamp}-2.png
```

## Usage Examples

### Images Only

```tsx
<FileUploader
  announcementId="announcement-123"
  onUploadComplete={handleUpload}
  accept="image/*"
  maxFiles={5}
  maxSizeMB={5}
/>
```

### PDFs Only

```tsx
<FileUploader
  announcementId="announcement-123"
  onUploadComplete={handleUpload}
  accept="application/pdf"
  maxFiles={3}
  maxSizeMB={10}
/>
```

### Mixed Files (Default)

```tsx
<FileUploader
  announcementId="announcement-123"
  onUploadComplete={handleUpload}
  accept="image/*,application/pdf"
  maxFiles={10}
  maxSizeMB={10}
/>
```

## Integration with Forms

### With BenefitAnnouncementForm

```tsx
const BenefitAnnouncementForm = () => {
  const [formData, setFormData] = useState({...});
  const [files, setFiles] = useState<AnnouncementFile[]>([]);

  const handleSubmit = async () => {
    // Save announcement
    const { data } = await supabase
      .from('benefit_announcements')
      .insert({
        ...formData,
        thumbnail_url: files[0]?.file_url, // Use first image as thumbnail
      })
      .select()
      .single();

    // Optionally save file references to a separate table
    if (files.length > 0) {
      await supabase.from('announcement_files').insert(
        files.map(file => ({
          announcement_id: data.id,
          ...file,
        }))
      );
    }
  };

  return (
    <form>
      {/* Other form fields */}

      <FileUploader
        announcementId={announcement?.id || 'temp'}
        onUploadComplete={setFiles}
        accept="image/*,application/pdf"
        maxFiles={10}
      />

      <Button onClick={handleSubmit}>Submit</Button>
    </form>
  );
};
```

## Features in Detail

### 1. Drag-and-Drop Zone

- Visual feedback when dragging files
- Click to open file picker
- Shows upload constraints (max files, max size, accepted types)

### 2. Upload Progress

- Real-time progress bar for each file
- Shows file name and size
- Error messages for failed uploads

### 3. File Preview

- Thumbnail grid for images (4 columns)
- Icon representation for PDFs
- File name and size displayed
- Delete button for each file

### 4. Validation

- File type validation
- File size validation
- Maximum file count validation
- User-friendly error messages

### 5. Supabase Integration

- Automatic upload to `announcements` bucket
- Organized folder structure by announcement ID
- Public URL generation
- File deletion with storage cleanup

## Error Handling

The component handles various error scenarios:

```tsx
// File size too large
"Files must be smaller than 10MB"

// Too many files
"Maximum 10 files allowed"

// Upload failure
"Upload failed: [error message]"

// Delete failure
"Delete failed: [error message]"
```

## Styling

The component uses Material-UI theme tokens for consistent styling:

- Border color adapts to theme
- Hover effects for better UX
- Responsive layout
- Accessible color contrast

## Performance

- Sequential uploads to avoid overwhelming the server
- Progress tracking with smooth animations
- Automatic cleanup of upload state
- Lazy loading of images in preview

## Future Enhancements

- [ ] Parallel uploads with concurrency control
- [ ] Image compression before upload
- [ ] Crop/resize images
- [ ] Support for more file types (videos, documents)
- [ ] Resume failed uploads
- [ ] Drag to reorder files
- [ ] Download uploaded files

## Supabase Storage Setup

Ensure your Supabase storage bucket is configured:

1. Create `announcements` bucket in Supabase Storage
2. Set bucket to **public** or configure RLS policies
3. Enable public access for the `announcements/images/` path

```sql
-- Example RLS policy for public read
CREATE POLICY "Public read access"
ON storage.objects FOR SELECT
USING (bucket_id = 'announcements');

-- Example RLS policy for authenticated upload
CREATE POLICY "Authenticated users can upload"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'announcements'
  AND auth.role() = 'authenticated'
);
```

## License

MIT
