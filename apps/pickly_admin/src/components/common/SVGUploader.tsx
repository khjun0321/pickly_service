/**
 * SVG Uploader Component
 * Specialized uploader for SVG icons with preview and validation
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
  Code as CodeIcon,
} from '@mui/icons-material'
import { supabase } from '@/lib/supabase'
import toast from 'react-hot-toast'

interface SVGUploaderProps {
  bucket: 'benefit-icons' | 'pickly-storage'
  currentSvgUrl?: string | null
  onUploadComplete: (url: string, path: string) => void
  onDelete?: () => void
  maxSizeMB?: number
  label?: string
  helperText?: string
}

export default function SVGUploader({
  bucket,
  currentSvgUrl,
  onUploadComplete,
  onDelete,
  maxSizeMB = 1,
  label = 'SVG 아이콘 업로드',
  helperText = 'SVG 파일만 업로드 가능합니다',
}: SVGUploaderProps) {
  const [uploading, setUploading] = useState(false)
  const [progress, setProgress] = useState(0)
  const [previewUrl, setPreviewUrl] = useState<string | null>(currentSvgUrl || null)
  const [svgContent, setSvgContent] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)
  const fileInputRef = useRef<HTMLInputElement>(null)

  const validateSVG = (file: File, content: string): string | null => {
    // Check file type
    if (file.type !== 'image/svg+xml' && !file.name.endsWith('.svg')) {
      return 'SVG 파일만 업로드 가능합니다'
    }

    // Check file size
    const fileSizeMB = file.size / (1024 * 1024)
    if (fileSizeMB > maxSizeMB) {
      return `파일 크기가 너무 큽니다. (최대: ${maxSizeMB}MB, 현재: ${fileSizeMB.toFixed(2)}MB)`
    }

    // Check if content is valid SVG
    if (!content.trim().startsWith('<svg') && !content.includes('<svg')) {
      return '유효하지 않은 SVG 파일입니다'
    }

    return null
  }

  const handleFileSelect = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (!file) return

    setError(null)

    // Read file content
    const reader = new FileReader()
    reader.onload = async (e) => {
      const content = e.target?.result as string

      // Validate SVG
      const validationError = validateSVG(file, content)
      if (validationError) {
        setError(validationError)
        toast.error(validationError)
        return
      }

      // Show preview
      setSvgContent(content)
      const blob = new Blob([content], { type: 'image/svg+xml' })
      const url = URL.createObjectURL(blob)
      setPreviewUrl(url)

      // Upload to Supabase
      await uploadFile(file)
    }

    reader.onerror = () => {
      setError('파일을 읽을 수 없습니다')
      toast.error('파일 읽기 실패')
    }

    reader.readAsText(file)
  }

  const uploadFile = async (file: File) => {
    setUploading(true)
    setProgress(0)

    try {
      // Generate unique filename
      const timestamp = Date.now()
      const randomStr = Math.random().toString(36).substring(2, 15)
      const fileName = `${timestamp}-${randomStr}.svg`
      const filePath = `icons/${fileName}`

      // Upload to Supabase Storage
      const { data, error: uploadError } = await supabase.storage
        .from(bucket)
        .upload(filePath, file, {
          cacheControl: '3600',
          upsert: false,
          contentType: 'image/svg+xml',
        })

      if (uploadError) {
        throw uploadError
      }

      // Get public URL
      const {
        data: { publicUrl },
      } = supabase.storage.from(bucket).getPublicUrl(filePath)

      setProgress(100)
      toast.success('SVG 아이콘 업로드 완료')
      onUploadComplete(publicUrl, data.path)
    } catch (error: any) {
      console.error('Upload error:', error)
      setError(error.message || '업로드 중 오류가 발생했습니다')
      toast.error('업로드 실패: ' + (error.message || '알 수 없는 오류'))
      setPreviewUrl(currentSvgUrl || null)
      setSvgContent(null)
    } finally {
      setUploading(false)
      setProgress(0)
    }
  }

  const handleDelete = () => {
    setPreviewUrl(null)
    setSvgContent(null)
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
        accept=".svg,image/svg+xml"
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
          {/* SVG Preview */}
          <Box
            sx={{
              width: '100%',
              maxWidth: 200,
              height: 200,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              bgcolor: 'grey.100',
              borderRadius: 1,
              p: 2,
            }}
          >
            {svgContent ? (
              <div dangerouslySetInnerHTML={{ __html: svgContent }} style={{ maxWidth: '100%', maxHeight: '100%' }} />
            ) : (
              <img
                src={previewUrl}
                alt="SVG Preview"
                style={{
                  maxWidth: '100%',
                  maxHeight: '100%',
                  objectFit: 'contain',
                }}
              />
            )}
          </Box>

          {/* SVG Code Preview (first 200 chars) */}
          {svgContent && (
            <Paper
              variant="outlined"
              sx={{
                p: 1,
                width: '100%',
                maxHeight: 100,
                overflow: 'auto',
                bgcolor: 'grey.50',
                fontFamily: 'monospace',
                fontSize: '0.75rem',
              }}
            >
              <code>{svgContent.substring(0, 200)}...</code>
            </Paper>
          )}

          <Box sx={{ display: 'flex', gap: 1 }}>
            <Button
              variant="outlined"
              startIcon={<UploadIcon />}
              onClick={handleUploadClick}
              disabled={uploading}
            >
              SVG 변경
            </Button>
            <IconButton color="error" onClick={handleDelete} disabled={uploading}>
              <DeleteIcon />
            </IconButton>
          </Box>
        </Paper>
      ) : (
        <Button
          variant="outlined"
          startIcon={<CodeIcon />}
          onClick={handleUploadClick}
          disabled={uploading}
          fullWidth
          sx={{ py: 3 }}
        >
          {uploading ? '업로드 중...' : 'SVG 파일 선택'}
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
        최대 파일 크기: {maxSizeMB}MB | SVG 파일만 지원
      </Typography>
    </Box>
  )
}
