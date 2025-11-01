/**
 * Image Uploader Component
 * Handles image uploads to Supabase Storage with preview, progress, and validation
 */

import { useState, useRef } from 'react'
import {
  Box,
  Button,
  IconButton,
  Typography,
  LinearProgress,
  Alert,
  Paper,
} from '@mui/material'
import {
  CloudUpload as UploadIcon,
  Delete as DeleteIcon,
  Image as ImageIcon,
} from '@mui/icons-material'
import { supabase } from '@/lib/supabase'
import toast from 'react-hot-toast'

interface ImageUploaderProps {
  bucket: 'benefit-icons' | 'benefit-thumbnails' | 'benefit-banners' | 'pickly-storage'
  currentImageUrl?: string | null
  onUploadComplete: (url: string, path: string) => void
  onDelete?: () => void
  maxSizeMB?: number
  acceptedFormats?: string[]
  label?: string
  helperText?: string
}

export default function ImageUploader({
  bucket,
  currentImageUrl,
  onUploadComplete,
  onDelete,
  maxSizeMB = 5,
  acceptedFormats = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'],
  label = '이미지 업로드',
  helperText,
}: ImageUploaderProps) {
  const [uploading, setUploading] = useState(false)
  const [progress, setProgress] = useState(0)
  const [previewUrl, setPreviewUrl] = useState<string | null>(currentImageUrl || null)
  const [error, setError] = useState<string | null>(null)
  const fileInputRef = useRef<HTMLInputElement>(null)

  const validateFile = (file: File): string | null => {
    // Check file type
    if (!acceptedFormats.includes(file.type)) {
      return `지원하지 않는 파일 형식입니다. (지원: ${acceptedFormats.join(', ')})`
    }

    // Check file size
    const fileSizeMB = file.size / (1024 * 1024)
    if (fileSizeMB > maxSizeMB) {
      return `파일 크기가 너무 큽니다. (최대: ${maxSizeMB}MB, 현재: ${fileSizeMB.toFixed(2)}MB)`
    }

    return null
  }

  const handleFileSelect = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (!file) return

    setError(null)

    // Validate file
    const validationError = validateFile(file)
    if (validationError) {
      setError(validationError)
      toast.error(validationError)
      return
    }

    // Show preview
    const reader = new FileReader()
    reader.onloadend = () => {
      setPreviewUrl(reader.result as string)
    }
    reader.readAsDataURL(file)

    // Upload to Supabase
    await uploadFile(file)
  }

  const uploadFile = async (file: File) => {
    setUploading(true)
    setProgress(0)

    try {
      // Generate unique filename
      const timestamp = Date.now()
      const randomStr = Math.random().toString(36).substring(2, 15)
      const fileExt = file.name.split('.').pop()
      const fileName = `${timestamp}-${randomStr}.${fileExt}`
      const filePath = `uploads/${fileName}`

      // Upload to Supabase Storage
      const { data, error: uploadError } = await supabase.storage
        .from(bucket)
        .upload(filePath, file, {
          cacheControl: '3600',
          upsert: false,
        })

      if (uploadError) {
        throw uploadError
      }

      // Get public URL
      const {
        data: { publicUrl },
      } = supabase.storage.from(bucket).getPublicUrl(filePath)

      setProgress(100)
      toast.success('이미지 업로드 완료')
      onUploadComplete(publicUrl, data.path)
    } catch (error: any) {
      console.error('Upload error:', error)
      setError(error.message || '업로드 중 오류가 발생했습니다')
      toast.error('업로드 실패: ' + (error.message || '알 수 없는 오류'))
      setPreviewUrl(currentImageUrl || null)
    } finally {
      setUploading(false)
      setProgress(0)
    }
  }

  const handleDelete = () => {
    setPreviewUrl(null)
    setError(null)
    if (fileInputRef.current) {
      fileInputRef.current.value = ''
    }
    if (onDelete) {
      onDelete()
    }
  }

  const handleUploadClick = () => {
    fileInputRef.current?.click()
  }

  return (
    <Box sx={{ width: '100%' }}>
      <Typography variant="subtitle2" sx={{ mb: 1 }}>
        {label}
      </Typography>

      {helperText && (
        <Typography variant="caption" color="text.secondary" sx={{ display: 'block', mb: 1 }}>
          {helperText}
        </Typography>
      )}

      <input
        ref={fileInputRef}
        type="file"
        accept={acceptedFormats.join(',')}
        onChange={handleFileSelect}
        style={{ display: 'none' }}
      />

      {previewUrl ? (
        <Paper
          variant="outlined"
          sx={{
            p: 2,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            gap: 2,
          }}
        >
          <Box
            component="img"
            src={previewUrl}
            alt="Preview"
            sx={{
              maxWidth: '100%',
              maxHeight: 300,
              objectFit: 'contain',
              borderRadius: 1,
            }}
          />

          <Box sx={{ display: 'flex', gap: 1 }}>
            <Button
              variant="outlined"
              startIcon={<UploadIcon />}
              onClick={handleUploadClick}
              disabled={uploading}
            >
              이미지 변경
            </Button>
            <IconButton color="error" onClick={handleDelete} disabled={uploading}>
              <DeleteIcon />
            </IconButton>
          </Box>
        </Paper>
      ) : (
        <Button
          variant="outlined"
          startIcon={<ImageIcon />}
          onClick={handleUploadClick}
          disabled={uploading}
          fullWidth
          sx={{ py: 3 }}
        >
          {uploading ? '업로드 중...' : '이미지 선택'}
        </Button>
      )}

      {uploading && (
        <Box sx={{ mt: 2 }}>
          <LinearProgress variant="determinate" value={progress} />
          <Typography variant="caption" color="text.secondary" sx={{ mt: 0.5, display: 'block' }}>
            업로드 중... {progress}%
          </Typography>
        </Box>
      )}

      {error && (
        <Alert severity="error" sx={{ mt: 2 }}>
          {error}
        </Alert>
      )}

      <Typography variant="caption" color="text.secondary" sx={{ mt: 1, display: 'block' }}>
        최대 파일 크기: {maxSizeMB}MB | 지원 형식: {acceptedFormats.join(', ')}
      </Typography>
    </Box>
  )
}
