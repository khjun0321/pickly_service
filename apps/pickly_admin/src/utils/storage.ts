/**
 * Supabase Storage Utilities
 *
 * Helper functions for file uploads to Supabase Storage:
 * - Age category icons (SVG)
 * - Announcement floor plans (images)
 * - Announcement PDFs (documents)
 */

import { supabase } from '@/lib/supabase'

export interface UploadOptions {
  bucket: string
  folder: string
  file: File
  upsert?: boolean
}

export interface UploadResult {
  url: string
  path: string
  name: string
  size: number
  type: string
}

/**
 * Upload a file to Supabase Storage
 *
 * @param options - Upload configuration
 * @returns Upload result with public URL
 * @throws Error if upload fails
 */
export async function uploadFile(options: UploadOptions): Promise<UploadResult> {
  const { bucket, folder, file, upsert = false } = options

  // Generate unique filename
  const fileExt = file.name.split('.').pop()
  const timestamp = Date.now()
  const randomStr = Math.random().toString(36).substring(2, 8)
  const fileName = `${timestamp}-${randomStr}.${fileExt}`
  const filePath = `${folder}/${fileName}`

  // Upload to storage
  const { error: uploadError } = await supabase.storage
    .from(bucket)
    .upload(filePath, file, {
      upsert,
      contentType: file.type,
      cacheControl: '3600',
    })

  if (uploadError) {
    throw new Error(`Upload failed: ${uploadError.message}`)
  }

  // Get public URL
  const { data: urlData } = supabase.storage
    .from(bucket)
    .getPublicUrl(filePath)

  return {
    url: urlData.publicUrl,
    path: filePath,
    name: file.name,
    size: file.size,
    type: file.type,
  }
}

/**
 * Delete a file from Supabase Storage
 *
 * @param bucket - Storage bucket name
 * @param path - File path to delete
 * @throws Error if deletion fails
 */
export async function deleteFile(bucket: string, path: string): Promise<void> {
  const { error } = await supabase.storage
    .from(bucket)
    .remove([path])

  if (error) {
    throw new Error(`Delete failed: ${error.message}`)
  }
}

/**
 * Upload age category icon (SVG only)
 */
export async function uploadAgeCategoryIcon(file: File): Promise<UploadResult> {
  if (file.type !== 'image/svg+xml') {
    throw new Error('Only SVG files are allowed for age category icons')
  }

  if (file.size > 1 * 1024 * 1024) {
    throw new Error('File size must be less than 1MB')
  }

  return uploadFile({
    bucket: 'pickly-storage',
    folder: 'age_category_icons',
    file,
    upsert: true,
  })
}

/**
 * Upload floor plan image
 */
export async function uploadFloorPlanImage(file: File, announcementId: string): Promise<UploadResult> {
  if (!file.type.startsWith('image/')) {
    throw new Error('Only image files are allowed for floor plans')
  }

  if (file.size > 10 * 1024 * 1024) {
    throw new Error('File size must be less than 10MB')
  }

  return uploadFile({
    bucket: 'pickly-storage',
    folder: `announcement_floor_plans/${announcementId}`,
    file,
  })
}

/**
 * Upload announcement PDF
 */
export async function uploadAnnouncementPDF(file: File, announcementId: string): Promise<UploadResult> {
  if (file.type !== 'application/pdf') {
    throw new Error('Only PDF files are allowed')
  }

  if (file.size > 20 * 1024 * 1024) {
    throw new Error('File size must be less than 20MB')
  }

  return uploadFile({
    bucket: 'pickly-storage',
    folder: `announcement_pdfs/${announcementId}`,
    file,
  })
}

/**
 * Upload custom content images
 */
export async function uploadCustomContentImage(file: File, announcementId: string): Promise<UploadResult> {
  if (!file.type.startsWith('image/')) {
    throw new Error('Only image files are allowed')
  }

  if (file.size > 10 * 1024 * 1024) {
    throw new Error('File size must be less than 10MB')
  }

  return uploadFile({
    bucket: 'pickly-storage',
    folder: `announcement_custom_content/${announcementId}`,
    file,
  })
}

/**
 * Format file size for display
 */
export function formatFileSize(bytes: number): string {
  if (bytes < 1024) return `${bytes} B`
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`
}

/**
 * Validate file type
 */
export function validateFileType(file: File, allowedTypes: string[]): boolean {
  return allowedTypes.some(type => {
    if (type.endsWith('/*')) {
      return file.type.startsWith(type.replace('/*', '/'))
    }
    return file.type === type
  })
}
