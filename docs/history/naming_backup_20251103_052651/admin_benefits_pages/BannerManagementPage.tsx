/**
 * Banner Management Page
 * PRD v9.6 Section 4.2 & 5.3 - Category Banners Management
 * Route: /benefits/banners
 */

import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import {
  Box,
  Typography,
  Button,
  Paper,
  List,
  ListItem,
  ListItemText,
  ListItemSecondaryAction,
  IconButton,
  Switch,
  Chip,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  FormControlLabel,
  MenuItem,
  Select,
  FormControl,
  InputLabel,
} from '@mui/material'
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  DragIndicator as DragIcon,
} from '@mui/icons-material'
import { supabase } from '@/lib/supabase'
import ImageUploader from '@/components/common/ImageUploader'
import type { CategoryBanner, CategoryBannerFormData, BenefitCategory, LinkType } from '@/types/benefits'
import toast from 'react-hot-toast'

export default function BannerManagementPage() {
  const queryClient = useQueryClient()
  const [dialogOpen, setDialogOpen] = useState(false)
  const [editingBanner, setEditingBanner] = useState<CategoryBanner | null>(null)
  const [formData, setFormData] = useState<CategoryBannerFormData>({
    category_id: null,
    category_slug: '',
    title: '',
    subtitle: null,
    image_url: null,
    link_url: null,
    link_type: 'none',
    background_color: '#FFFFFF',
    sort_order: 0,
    is_active: true,
  })

  // Fetch benefit categories for dropdown
  const { data: categories = [] } = useQuery({
    queryKey: ['benefit_categories'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('benefit_categories')
        .select('*')
        .order('sort_order', { ascending: true })

      if (error) throw error
      return data as BenefitCategory[]
    },
  })

  // Fetch category banners with category info
  const { data: banners = [], isLoading } = useQuery({
    queryKey: ['category_banners'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('category_banners')
        .select(`
          *,
          category:benefit_categories(id, title, slug)
        `)
        .order('sort_order', { ascending: true })

      if (error) throw error
      return data as (CategoryBanner & { category?: BenefitCategory })[]
    },
  })

  // Create/Update mutation
  const saveMutation = useMutation({
    mutationFn: async (data: CategoryBannerFormData & { id?: string }) => {
      if (data.id) {
        const { error } = await supabase
          .from('category_banners')
          .update(data)
          .eq('id', data.id)
        if (error) throw error
      } else {
        const { error } = await supabase.from('category_banners').insert([data])
        if (error) throw error
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['category_banners'] })
      toast.success(editingBanner ? '배너가 수정되었습니다' : '배너가 추가되었습니다')
      handleCloseDialog()
    },
    onError: (error: Error) => {
      toast.error(`오류: ${error.message}`)
    },
  })

  // Delete mutation
  const deleteMutation = useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from('category_banners').delete().eq('id', id)
      if (error) throw error
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['category_banners'] })
      toast.success('배너가 삭제되었습니다')
    },
    onError: (error: Error) => {
      toast.error(`삭제 실패: ${error.message}`)
    },
  })

  // Toggle active status
  const toggleActiveMutation = useMutation({
    mutationFn: async ({ id, is_active }: { id: string; is_active: boolean }) => {
      const { error } = await supabase
        .from('category_banners')
        .update({ is_active })
        .eq('id', id)
      if (error) throw error
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['category_banners'] })
    },
  })

  const handleOpenDialog = (banner?: CategoryBanner) => {
    if (banner) {
      setEditingBanner(banner)
      setFormData({
        category_id: banner.category_id,
        category_slug: banner.category_slug,
        title: banner.title,
        subtitle: banner.subtitle,
        image_url: banner.image_url,
        link_url: banner.link_url,
        link_type: banner.link_type,
        background_color: banner.background_color,
        sort_order: banner.sort_order,
        is_active: banner.is_active,
      })
    } else {
      setEditingBanner(null)
      setFormData({
        category_id: null,
        category_slug: '',
        title: '',
        subtitle: null,
        image_url: null,
        link_url: null,
        link_type: 'none',
        background_color: '#FFFFFF',
        sort_order: banners.length,
        is_active: true,
      })
    }
    setDialogOpen(true)
  }

  const handleCloseDialog = () => {
    setDialogOpen(false)
    setEditingBanner(null)
  }

  const handleCategoryChange = (categoryId: string) => {
    const category = categories.find((c) => c.id === categoryId)
    setFormData({
      ...formData,
      category_id: categoryId,
      category_slug: category?.slug || '',
    })
  }

  const handleSave = () => {
    // Validation
    if (!formData.title.trim()) {
      toast.error('배너 제목을 입력하세요')
      return
    }
    if (!formData.category_slug.trim()) {
      toast.error('카테고리를 선택하세요')
      return
    }
    if (!formData.image_url) {
      toast.error('배너 이미지를 업로드하세요')
      return
    }

    saveMutation.mutate({
      ...formData,
      ...(editingBanner && { id: editingBanner.id }),
    })
  }

  const handleDelete = (id: string) => {
    if (window.confirm('이 배너를 삭제하시겠습니까?')) {
      deleteMutation.mutate(id)
    }
  }

  if (isLoading) {
    return (
      <Box sx={{ p: 3 }}>
        <Typography>로딩 중...</Typography>
      </Box>
    )
  }

  return (
    <Box sx={{ p: 3 }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Box>
          <Typography variant="h4">카테고리 배너 관리</Typography>
          <Typography variant="body2" color="text.secondary" sx={{ mt: 0.5 }}>
            PRD v9.6 Section 4.2 & 5.3 - 카테고리별 배너 관리
          </Typography>
        </Box>
        <Button variant="contained" startIcon={<AddIcon />} onClick={() => handleOpenDialog()}>
          배너 추가
        </Button>
      </Box>

      <Paper>
        <List>
          {banners.map((banner) => (
            <ListItem
              key={banner.id}
              sx={{
                borderBottom: '1px solid',
                borderColor: 'divider',
                '&:last-child': { borderBottom: 'none' },
              }}
            >
              <IconButton sx={{ mr: 1, cursor: 'grab' }}>
                <DragIcon />
              </IconButton>

              {/* Banner Preview Image */}
              {banner.image_url && (
                <Box
                  component="img"
                  src={banner.image_url}
                  alt={banner.title}
                  sx={{
                    width: 80,
                    height: 80,
                    objectFit: 'cover',
                    borderRadius: 1,
                    mr: 2,
                    backgroundColor: banner.background_color,
                  }}
                />
              )}

              <ListItemText
                primary={
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <Typography variant="h6">{banner.title}</Typography>
                    <Chip label={banner.category_slug} size="small" variant="outlined" />
                    {banner.category && (
                      <Chip
                        label={banner.category.title}
                        size="small"
                        color="primary"
                        variant="outlined"
                      />
                    )}
                    {!banner.is_active && (
                      <Chip label="비활성" size="small" color="default" variant="outlined" />
                    )}
                    <Chip label={banner.link_type} size="small" color="secondary" variant="outlined" />
                  </Box>
                }
                secondary={
                  <Typography variant="caption" color="text.secondary">
                    정렬 순서: {banner.sort_order}
                    {banner.subtitle && ` | ${banner.subtitle}`}
                    {banner.link_url && ` | 링크: ${banner.link_url}`}
                    {` | 배경색: ${banner.background_color}`}
                  </Typography>
                }
              />
              <ListItemSecondaryAction>
                <Switch
                  checked={banner.is_active}
                  onChange={(e) =>
                    toggleActiveMutation.mutate({ id: banner.id, is_active: e.target.checked })
                  }
                  color="primary"
                />
                <IconButton onClick={() => handleOpenDialog(banner)} sx={{ ml: 1 }}>
                  <EditIcon />
                </IconButton>
                <IconButton onClick={() => handleDelete(banner.id)} color="error">
                  <DeleteIcon />
                </IconButton>
              </ListItemSecondaryAction>
            </ListItem>
          ))}
          {banners.length === 0 && (
            <ListItem>
              <ListItemText
                primary="배너가 없습니다"
                secondary="새 배너를 추가하려면 '배너 추가' 버튼을 클릭하세요"
              />
            </ListItem>
          )}
        </List>
      </Paper>

      {/* Create/Edit Dialog */}
      <Dialog open={dialogOpen} onClose={handleCloseDialog} maxWidth="md" fullWidth>
        <DialogTitle>{editingBanner ? '배너 수정' : '배너 추가'}</DialogTitle>
        <DialogContent>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, pt: 2 }}>
            {/* Category Dropdown */}
            <FormControl fullWidth required>
              <InputLabel>카테고리</InputLabel>
              <Select
                value={formData.category_id || ''}
                onChange={(e) => handleCategoryChange(e.target.value)}
                label="카테고리"
              >
                <MenuItem value="">
                  <em>선택하세요</em>
                </MenuItem>
                {categories.map((category) => (
                  <MenuItem key={category.id} value={category.id}>
                    {category.title} ({category.slug})
                  </MenuItem>
                ))}
              </Select>
            </FormControl>

            <TextField
              label="배너 제목"
              value={formData.title}
              onChange={(e) => setFormData({ ...formData, title: e.target.value })}
              fullWidth
              required
              helperText="배너에 표시될 제목 (예: 청년 특화 혜택)"
            />

            <TextField
              label="부제목"
              value={formData.subtitle || ''}
              onChange={(e) => setFormData({ ...formData, subtitle: e.target.value || null })}
              fullWidth
              helperText="배너 하단에 표시될 부제목 (선택사항)"
            />

            {/* Image Upload */}
            <ImageUploader
              bucket="benefit-banners"
              currentImageUrl={formData.image_url}
              onUploadComplete={(url) => {
                setFormData({ ...formData, image_url: url })
              }}
              onDelete={() => {
                setFormData({ ...formData, image_url: null })
              }}
              label="배너 이미지"
              helperText="배너에 사용될 이미지를 업로드하세요 (권장 크기: 1200x400px)"
              acceptedFormats={['image/jpeg', 'image/png', 'image/webp']}
            />

            {/* Link Type */}
            <FormControl fullWidth>
              <InputLabel>링크 타입</InputLabel>
              <Select
                value={formData.link_type}
                onChange={(e) => setFormData({ ...formData, link_type: e.target.value as LinkType })}
                label="링크 타입"
              >
                <MenuItem value="none">링크 없음</MenuItem>
                <MenuItem value="internal">내부 링크</MenuItem>
                <MenuItem value="external">외부 링크</MenuItem>
              </Select>
            </FormControl>

            {/* Link URL (conditional) */}
            {formData.link_type !== 'none' && (
              <TextField
                label="링크 URL"
                value={formData.link_url || ''}
                onChange={(e) => setFormData({ ...formData, link_url: e.target.value || null })}
                fullWidth
                helperText={
                  formData.link_type === 'internal'
                    ? '예: /benefits/housing/single-household'
                    : '예: https://example.com'
                }
              />
            )}

            {/* Background Color */}
            <TextField
              label="배경색"
              type="color"
              value={formData.background_color}
              onChange={(e) => setFormData({ ...formData, background_color: e.target.value })}
              fullWidth
              helperText="배너 배경색 (Hex 컬러 코드)"
            />

            <TextField
              label="정렬 순서"
              type="number"
              value={formData.sort_order}
              onChange={(e) => setFormData({ ...formData, sort_order: Number(e.target.value) })}
              fullWidth
              helperText="낮은 숫자일수록 먼저 표시됩니다"
            />

            <FormControlLabel
              control={
                <Switch
                  checked={formData.is_active}
                  onChange={(e) => setFormData({ ...formData, is_active: e.target.checked })}
                />
              }
              label="활성 상태"
            />
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDialog}>취소</Button>
          <Button
            onClick={handleSave}
            variant="contained"
            disabled={saveMutation.isPending}
          >
            {editingBanner ? '수정' : '추가'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  )
}
