import { useState, useEffect } from 'react'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import {
  Box,
  Paper,
  Typography,
  Button,
  Switch,
  FormControlLabel,
  TextField,
  CircularProgress,
} from '@mui/material'
import {
  Upload as UploadIcon,
} from '@mui/icons-material'
import toast from 'react-hot-toast'
import { supabase } from '@/lib/supabase'
import type { BenefitCategory } from '@/types/database'

interface BannerManagerProps {
  category: BenefitCategory
}

export default function BannerManager({ category }: BannerManagerProps) {
  const queryClient = useQueryClient()
  const [bannerEnabled, setBannerEnabled] = useState(category.banner_enabled || false)
  const [bannerLinkUrl, setBannerLinkUrl] = useState(category.banner_link_url || '')
  const [uploadingImage, setUploadingImage] = useState(false)
  const [imagePreview, setImagePreview] = useState<string | null>(category.banner_image_url || null)

  useEffect(() => {
    setBannerEnabled(category.banner_enabled || false)
    setBannerLinkUrl(category.banner_link_url || '')
    setImagePreview(category.banner_image_url || null)
  }, [category])

  const updateBannerMutation = useMutation({
    mutationFn: async (updates: { banner_enabled?: boolean; banner_image_url?: string; banner_link_url?: string }) => {
      const { error } = await supabase
        .from('benefit_categories')
        .update(updates)
        .eq('id', category.id)

      if (error) throw error
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['benefit-category'] })
      queryClient.invalidateQueries({ queryKey: ['benefit-subcategories'] })
      toast.success('배너 설정이 저장되었습니다')
    },
    onError: (error: Error) => {
      toast.error(`저장 실패: ${error.message}`)
    },
  })

  const handleToggleBanner = async (enabled: boolean) => {
    setBannerEnabled(enabled)
    updateBannerMutation.mutate({ banner_enabled: enabled })
  }

  const handleImageUpload = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (!file) return

    // 이미지 파일 검증
    if (!file.type.startsWith('image/')) {
      toast.error('이미지 파일만 업로드 가능합니다')
      return
    }

    // 파일 크기 검증 (5MB)
    if (file.size > 5 * 1024 * 1024) {
      toast.error('파일 크기는 5MB 이하여야 합니다')
      return
    }

    setUploadingImage(true)

    try {
      // 파일명 생성 (카테고리 slug + 타임스탬프)
      const fileExt = file.name.split('.').pop()
      const fileName = `${category.slug}-banner-${Date.now()}.${fileExt}`
      const filePath = `banners/${fileName}`

      // Supabase Storage에 업로드
      const { error: uploadError } = await supabase.storage
        .from('benefit-images')
        .upload(filePath, file, {
          upsert: true,
          contentType: file.type,
        })

      if (uploadError) throw uploadError

      // Public URL 가져오기
      const { data: urlData } = supabase.storage
        .from('benefit-images')
        .getPublicUrl(filePath)

      const publicUrl = urlData.publicUrl

      // 미리보기 업데이트
      setImagePreview(publicUrl)

      // 데이터베이스 업데이트
      updateBannerMutation.mutate({ banner_image_url: publicUrl })
    } catch (error) {
      console.error('Image upload error:', error)
      toast.error('이미지 업로드 실패')
    } finally {
      setUploadingImage(false)
    }
  }

  const handleSaveLinkUrl = () => {
    updateBannerMutation.mutate({ banner_link_url: bannerLinkUrl })
  }

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
      {/* 배너 ON/OFF */}
      <FormControlLabel
        control={
          <Switch
            checked={bannerEnabled}
            onChange={(e) => handleToggleBanner(e.target.checked)}
            disabled={updateBannerMutation.isPending}
          />
        }
        label={bannerEnabled ? '배너 표시 중' : '배너 숨김'}
      />

      {/* 이미지 업로드 */}
      <Box>
        <Typography variant="body2" gutterBottom>
          배너 이미지
        </Typography>
        {imagePreview && (
          <Paper sx={{ p: 2, mb: 2 }}>
            <img
              src={imagePreview}
              alt="Banner preview"
              style={{ width: '100%', maxHeight: '200px', objectFit: 'contain' }}
            />
          </Paper>
        )}
        <Button
          variant="outlined"
          component="label"
          startIcon={uploadingImage ? <CircularProgress size={20} /> : <UploadIcon />}
          disabled={uploadingImage || updateBannerMutation.isPending}
          fullWidth
        >
          {uploadingImage ? '업로드 중...' : imagePreview ? '이미지 변경' : '이미지 업로드'}
          <input
            type="file"
            hidden
            accept="image/*"
            onChange={handleImageUpload}
            disabled={uploadingImage}
          />
        </Button>
        <Typography variant="caption" color="text.secondary" sx={{ mt: 1, display: 'block' }}>
          권장 크기: 1200x400px, 최대 5MB
        </Typography>
      </Box>

      {/* 링크 URL */}
      <Box>
        <TextField
          fullWidth
          label="링크 URL (외부 페이지)"
          value={bannerLinkUrl}
          onChange={(e) => setBannerLinkUrl(e.target.value)}
          placeholder="https://example.com"
          helperText="배너 클릭 시 이동할 외부 링크 (선택사항)"
          disabled={updateBannerMutation.isPending}
        />
        <Button
          variant="contained"
          onClick={handleSaveLinkUrl}
          disabled={updateBannerMutation.isPending}
          sx={{ mt: 1 }}
        >
          링크 저장
        </Button>
      </Box>
    </Box>
  )
}
