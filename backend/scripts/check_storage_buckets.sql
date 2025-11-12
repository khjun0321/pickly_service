-- Check Storage buckets
SELECT
  id,
  name,
  public,
  file_size_limit,
  array_length(allowed_mime_types, 1) AS mime_type_count
FROM storage.buckets
WHERE id IN (
  'announcement-thumbnails',
  'announcement-pdfs',
  'announcement-images'
)
ORDER BY id;
