import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import {
  Box,
  Button,
  Paper,
  IconButton,
  Typography,
  Switch,
  Chip,
  CircularProgress,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Grid,
  Stack,
  Card,
  CardMedia,
  CardContent,
  CardActions,
} from '@mui/material'
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  DragIndicator as DragIcon,
  Upload as UploadIcon,
} from '@mui/icons-material'
import toast from 'react-hot-toast'
import {
  fetchBannersByCategory,
  createBanner,
  updateBanner,
  deleteBanner,
  toggleBannerStatus,
  type BenefitBanner,
  // type BenefitBannerInsert, // ❌ REMOVED: Unused import
} from '@/api/banners'
import { supabase } from '@/lib/supabase'
import type { BenefitCategory } from '@/types/database'

interface BenefitBannerManagerProps {
  category: BenefitCategory
}

interface BannerFormData {
  title: string
  subtitle: string
  image_url: string
  link_url: string
  background_color: string
}

export default function BenefitBannerManager({ category }: BenefitBannerManagerProps) {
  const queryClient = useQueryClient()
  const [dialogOpen, setDialogOpen] = useState(false)
  const [editingBanner, setEditingBanner] = useState<BenefitBanner | null>(null)
  const [uploadingImage, setUploadingImage] = useState(false)
  const [formData, setFormData] = useState<BannerFormData>({
    title: '',
    subtitle: '',
    image_url: '',
    link_url: '',
    background_color: '#E3F2FD',
  })

  const { data: banners, isLoading } = useQuery({
    queryKey: ['benefit-banners', category.id],
    queryFn: () => fetchBannersByCategory(category.id),
  })

  const createMutation = useMutation({
    mutationFn: createBanner,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ['benefit-banners', category.id] })
      await queryClient.refetchQueries({ queryKey: ['benefit-banners', category.id] })
      toast.success('배너가 생성되었습니다')
      handleCloseDialog()
    },
    onError: (error: Error) => {
      toast.error(`생성 실패: ${error.message}`)
    },
  })

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: Partial<BenefitBanner> }) =>
      updateBanner(id, data),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ['benefit-banners', category.id] })
      await queryClient.refetchQueries({ queryKey: ['benefit-banners', category.id] })
      toast.success('배너가 수정되었습니다')
      handleCloseDialog()
    },
    onError: (error: Error) => {
      toast.error(`수정 실패: ${error.message}`)
    },
  })

  const deleteMutation = useMutation({
    mutationFn: deleteBanner,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ['benefit-banners', category.id] })
      await queryClient.refetchQueries({ queryKey: ['benefit-banners', category.id] })
      toast.success('배너가 삭제되었습니다')
    },
    onError: (error: Error) => {
      toast.error(`삭제 실패: ${error.message}`)
    },
  })

  const toggleMutation = useMutation({
    mutationFn: ({ id, isActive }: { id: string; isActive: boolean }) =>
      toggleBannerStatus(id, isActive),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ['benefit-banners', category.id] })
      await queryClient.refetchQueries({ queryKey: ['benefit-banners', category.id] })
      toast.success('배너 상태가 변경되었습니다')
    },
    onError: (error: Error) => {
      toast.error(`상태 변경 실패: ${error.message}`)
    },
  })

  const handleOpenCreateDialog = () => {
    setEditingBanner(null)
    setFormData({
      title: '',
      subtitle: '',
      image_url: '',
      link_url: '',
      background_color: '#E3F2FD',
    })
    setDialogOpen(true)
  }

  const handleOpenEditDialog = (banner: BenefitBanner) => {
    setEditingBanner(banner)
    setFormData({
      title: banner.title,
      subtitle: banner.subtitle || '',
      image_url: banner.image_url,
      link_url: banner.link_url || '',
      background_color: '#E3F2FD', // ❌ REMOVED: banner.background_color (field doesn't exist in DB)
    })
    setDialogOpen(true)
  }

  const handleCloseDialog = () => {
    setDialogOpen(false)
    setEditingBanner(null)
  }

  const handleImageUpload = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (!file) return

    if (!file.type.startsWith('image/')) {
      toast.error('이미지 파일만 업로드 가능합니다')
      return
    }

    if (file.size > 5 * 1024 * 1024) {
      toast.error('파일 크기는 5MB 이하여야 합니다')
      return
    }

    setUploadingImage(true)

    try {
      const fileExt = file.name.split('.').pop()
      const fileName = `${category.slug}-banner-${Date.now()}.${fileExt}`
      const filePath = `banners/${fileName}`

      const { error: uploadError } = await supabase.storage
        .from('benefit-images')
        .upload(filePath, file, {
          upsert: true,
          contentType: file.type,
        })

      if (uploadError) throw uploadError

      const { data: urlData } = supabase.storage
        .from('benefit-images')
        .getPublicUrl(filePath)

      setFormData((prev) => ({ ...prev, image_url: urlData.publicUrl }))
      toast.success('이미지가 업로드되었습니다')
    } catch (error) {
      console.error('Image upload error:', error)
      toast.error('이미지 업로드 실패')
    } finally {
      setUploadingImage(false)
    }
  }

  const handleSubmit = () => {
    if (!formData.title.trim()) {
      toast.error('제목을 입력하세요')
      return
    }
    if (!formData.image_url.trim()) {
      toast.error('이미지를 업로드하세요')
      return
    }

    if (editingBanner) {
      updateMutation.mutate({
        id: editingBanner.id,
        data: {
          title: formData.title,
          subtitle: formData.subtitle || null,
          image_url: formData.image_url,
          link_url: formData.link_url || null,
          // background_color: formData.background_color || null, // ❌ REMOVED: Not in DB schema
        },
      })
    } else {
      const nextDisplayOrder = banners ? banners.length + 1 : 1
      createMutation.mutate({
        category_id: category.id,
        title: formData.title,
        subtitle: formData.subtitle || null,
        image_url: formData.image_url,
        link_url: formData.link_url || null,
        // background_color: formData.background_color || null, // ❌ REMOVED: Not in DB schema
        display_order: nextDisplayOrder,
        is_active: true,
      })
    }
  }

  const handleDelete = (banner: BenefitBanner) => {
    if (confirm(`"${banner.title}" 배너를 삭제하시겠습니까?`)) {
      deleteMutation.mutate(banner.id)
    }
  }

  const handleToggleStatus = (banner: BenefitBanner) => {
    toggleMutation.mutate({ id: banner.id, isActive: !banner.is_active })
  }

  if (isLoading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', p: 4 }}>
        <CircularProgress />
      </Box>
    )
  }

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
        <Typography variant="body2" color="text.secondary">
          총 {banners?.length || 0}개 배너
        </Typography>
        <Button variant="contained" startIcon={<AddIcon />} onClick={handleOpenCreateDialog}>
          배너 추가
        </Button>
      </Box>

      <Grid container spacing={2}>
        {banners && banners.length > 0 ? (
          banners.map((banner) => (
            <Grid item xs={12} sm={6} md={4} key={banner.id}>
              <Card>
                <CardMedia
                  component="img"
                  height="160"
                  image={banner.image_url}
                  alt={banner.title}
                  sx={{ objectFit: 'cover', backgroundColor: '#f0f0f0' }} // ❌ REMOVED: banner.background_color (not in DB)
                />
                <CardContent sx={{ pb: 1 }}>
                  <Stack direction="row" spacing={1} alignItems="center" sx={{ mb: 1 }}>
                    <DragIcon sx={{ color: 'text.secondary', fontSize: 16 }} />
                    <Chip
                      size="small"
                      label={`순서: ${banner.display_order}`}
                      color="default"
                      variant="outlined"
                    />
                    <Chip
                      size="small"
                      label={banner.is_active ? '활성' : '비활성'}
                      color={banner.is_active ? 'success' : 'default'}
                    />
                  </Stack>
                  <Typography variant="subtitle2" sx={{ fontWeight: 600, mb: 0.5 }}>
                    {banner.title}
                  </Typography>
                  {banner.subtitle && (
                    <Typography variant="caption" color="text.secondary" sx={{ display: 'block' }}>
                      {banner.subtitle}
                    </Typography>
                  )}
                  {banner.link_url && (
                    <Typography
                      variant="caption"
                      color="primary"
                      sx={{ display: 'block', mt: 0.5, wordBreak: 'break-all' }}
                    >
                      {banner.link_url}
                    </Typography>
                  )}
                </CardContent>
                <CardActions sx={{ justifyContent: 'space-between', px: 2, pt: 0 }}>
                  <Switch
                    checked={banner.is_active}
                    onChange={() => handleToggleStatus(banner)}
                    size="small"
                  />
                  <Box>
                    <IconButton size="small" onClick={() => handleOpenEditDialog(banner)}>
                      <EditIcon fontSize="small" />
                    </IconButton>
                    <IconButton size="small" color="error" onClick={() => handleDelete(banner)}>
                      <DeleteIcon fontSize="small" />
                    </IconButton>
                  </Box>
                </CardActions>
              </Card>
            </Grid>
          ))
        ) : (
          <Grid item xs={12}>
            <Paper sx={{ p: 4, textAlign: 'center' }}>
              <Typography variant="body2" color="text.secondary">
                등록된 배너가 없습니다.
              </Typography>
              <Button
                variant="outlined"
                startIcon={<AddIcon />}
                onClick={handleOpenCreateDialog}
                sx={{ mt: 2 }}
              >
                첫 배너 추가하기
              </Button>
            </Paper>
          </Grid>
        )}
      </Grid>

      {/* Banner Form Dialog */}
      <Dialog open={dialogOpen} onClose={handleCloseDialog} maxWidth="md" fullWidth>
        <DialogTitle>{editingBanner ? '배너 수정' : '배너 추가'}</DialogTitle>
        <DialogContent>
          <Grid container spacing={2} sx={{ mt: 0.5 }}>
            <Grid item xs={12}>
              <TextField
                fullWidth
                label="제목"
                value={formData.title}
                onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                required
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                fullWidth
                label="부제목 (선택)"
                value={formData.subtitle}
                onChange={(e) => setFormData({ ...formData, subtitle: e.target.value })}
              />
            </Grid>
            <Grid item xs={12}>
              {formData.image_url && (
                <Box sx={{ mb: 2 }}>
                  <img
                    src={formData.image_url}
                    alt="Preview"
                    style={{ width: '100%', maxHeight: '200px', objectFit: 'contain', borderRadius: 4 }}
                  />
                </Box>
              )}
              <Button
                variant="outlined"
                component="label"
                startIcon={uploadingImage ? <CircularProgress size={20} /> : <UploadIcon />}
                disabled={uploadingImage}
                fullWidth
              >
                {uploadingImage ? '업로드 중...' : formData.image_url ? '이미지 변경' : '이미지 업로드'}
                <input type="file" hidden accept="image/*" onChange={handleImageUpload} />
              </Button>
              <Typography variant="caption" color="text.secondary" sx={{ display: 'block', mt: 1 }}>
                권장 크기: 1200x400px, 최대 5MB
              </Typography>
            </Grid>
            <Grid item xs={12}>
              <TextField
                fullWidth
                label="링크 URL (선택)"
                value={formData.link_url}
                onChange={(e) => setFormData({ ...formData, link_url: e.target.value })}
                placeholder="https://example.com"
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                fullWidth
                label="배경 색상 (선택)"
                value={formData.background_color}
                onChange={(e) => setFormData({ ...formData, background_color: e.target.value })}
                placeholder="#E3F2FD"
              />
            </Grid>
          </Grid>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDialog}>취소</Button>
          <Button
            variant="contained"
            onClick={handleSubmit}
            disabled={createMutation.isPending || updateMutation.isPending}
          >
            {editingBanner ? '수정' : '생성'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  )
}
