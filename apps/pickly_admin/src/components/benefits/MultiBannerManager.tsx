import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import {
  Box,
  Paper,
  Typography,
  Button,
  IconButton,
  TextField,
  Switch,
  FormControlLabel,
  CircularProgress,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  List,
  ListItem,
} from '@mui/material'
import {
  Add as AddIcon,
  Delete as DeleteIcon,
  Edit as EditIcon,
  DragIndicator as DragIcon,
  Upload as UploadIcon,
} from '@mui/icons-material'
import {
  DndContext,
  closestCenter,
  KeyboardSensor,
  PointerSensor,
  useSensor,
  useSensors,
} from '@dnd-kit/core'
import type { DragEndEvent } from '@dnd-kit/core'
import {
  arrayMove,
  SortableContext,
  sortableKeyboardCoordinates,
  useSortable,
  verticalListSortingStrategy,
} from '@dnd-kit/sortable'
import { CSS } from '@dnd-kit/utilities'
import { restrictToVerticalAxis } from '@dnd-kit/modifiers'
import toast from 'react-hot-toast'
import { supabase } from '@/lib/supabase'
import type { BenefitCategory, BenefitBanner, BenefitBannerInsert, BenefitBannerUpdate } from '@/types/database'

interface MultiBannerManagerProps {
  category: BenefitCategory
}

interface SortableBannerItemProps {
  banner: BenefitBanner
  onEdit: (banner: BenefitBanner) => void
  onDelete: (id: string) => void
  onToggleActive: (id: string, isActive: boolean) => void
}

function SortableBannerItem({ banner, onEdit, onDelete, onToggleActive }: SortableBannerItemProps) {
  const [imageError, setImageError] = useState(false)
  const [imageLoading, setImageLoading] = useState(true)

  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id: banner.id })

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
    opacity: isDragging ? 0.5 : 1,
  }

  return (
    <ListItem
      ref={setNodeRef}
      style={style}
      sx={{
        border: 1,
        borderColor: 'divider',
        borderRadius: 1,
        mb: 1,
        bgcolor: 'background.paper',
        display: 'flex',
        alignItems: 'center',
        gap: 2,
        p: 2,
      }}
    >
      {/* Drag Handle */}
      <Box {...attributes} {...listeners} sx={{ cursor: 'grab', display: 'flex', alignItems: 'center' }}>
        <DragIcon />
      </Box>

      {/* Banner Preview */}
      <Box
        sx={{
          width: 120,
          height: 60,
          overflow: 'hidden',
          borderRadius: 1,
          bgcolor: imageError ? '#f5f5f5' : '#E3F2FD', // ❌ REMOVED: banner.background_color (not in DB)
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          position: 'relative'
        }}
      >
        {imageLoading && !imageError && (
          <CircularProgress size={20} />
        )}
        {imageError ? (
          <Typography variant="caption" color="text.secondary">이미지 없음</Typography>
        ) : (
          <img
            src={banner.image_url}
            alt={banner.title || 'Banner'}
            style={{
              width: '100%',
              height: '100%',
              objectFit: 'cover',
              display: imageLoading ? 'none' : 'block'
            }}
            onLoad={() => setImageLoading(false)}
            onError={() => {
              console.error('Failed to load image:', banner.image_url)
              setImageError(true)
              setImageLoading(false)
            }}
          />
        )}
      </Box>

      {/* Banner Info */}
      <Box sx={{ flex: 1 }}>
        <Typography variant="body1">{banner.title || '제목 없음'}</Typography>
        {banner.subtitle && (
          <Typography variant="caption" color="text.secondary" sx={{ display: 'block' }}>
            {banner.subtitle}
          </Typography>
        )}
        {banner.link_url && (
          <Typography variant="caption" color="text.secondary" sx={{ display: 'block', fontSize: '0.7rem' }}>
            🔗 {banner.link_url}
          </Typography>
        )}
      </Box>

      {/* Active Toggle */}
      <FormControlLabel
        control={
          <Switch
            checked={banner.is_active ?? false}
            onChange={(e) => onToggleActive(banner.id, e.target.checked)}
            size="small"
          />
        }
        label={banner.is_active ? '표시' : '숨김'}
      />

      {/* Actions */}
      <IconButton size="small" onClick={() => onEdit(banner)}>
        <EditIcon />
      </IconButton>
      <IconButton size="small" color="error" onClick={() => onDelete(banner.id)}>
        <DeleteIcon />
      </IconButton>
    </ListItem>
  )
}

export default function MultiBannerManager({ category }: MultiBannerManagerProps) {
  const queryClient = useQueryClient()
  const [dialogOpen, setDialogOpen] = useState(false)
  const [editingBanner, setEditingBanner] = useState<BenefitBanner | null>(null)
  const [formData, setFormData] = useState({
    title: '',
    link_url: '',
  })
  // const [uploadingImage, setUploadingImage] = useState(false) // ❌ REMOVED: Unused variables
  const [imagePreview, setImagePreview] = useState<string | null>(null)
  const [imageFile, setImageFile] = useState<File | null>(null)

  const sensors = useSensors(
    useSensor(PointerSensor),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    })
  )

  // Fetch banners
  const { data: banners = [], isLoading, error: queryError } = useQuery({
    queryKey: ['benefit-banners', category.id],
    queryFn: async () => {
      console.log('🔍 Fetching banners for category:', category.id, category.name)
      const { data, error } = await supabase
        .from('category_banners')
        .select('*')
        .eq('category_id', category.id)
        .order('display_order')

      console.log('📦 Banner query result:', { data, error })
      if (error) {
        console.error('❌ Banner fetch error:', error)
        throw error
      }
      console.log('✅ Fetched banners:', data?.length || 0)
      return data as BenefitBanner[]
    },
  })

  // Log when component renders
  console.log('MultiBannerManager render:', {
    categoryId: category.id,
    categoryName: category.name,
    bannersCount: banners.length,
    isLoading,
    queryError
  })

  // Create/Update banner
  const saveBannerMutation = useMutation({
    mutationFn: async () => {
      if (!imageFile && !editingBanner) {
        throw new Error('이미지를 업로드해주세요')
      }

      let imageUrl = editingBanner?.image_url || ''

      // Upload new image if provided
      if (imageFile) {
        const fileExt = imageFile.name.split('.').pop()
        const fileName = `${category.slug}-banner-${Date.now()}.${fileExt}`
        const filePath = `banners/${fileName}`

        const { error: uploadError } = await supabase.storage
          .from('pickly-storage')
          .upload(filePath, imageFile, {
            upsert: true,
            contentType: imageFile.type,
          })

        if (uploadError) throw uploadError

        const { data: urlData } = supabase.storage
          .from('pickly-storage')
          .getPublicUrl(filePath)

        imageUrl = urlData.publicUrl
      }

      if (editingBanner) {
        const updateData: BenefitBannerUpdate = {
          title: formData.title || undefined,
          image_url: imageUrl,
          link_url: formData.link_url || undefined,
        }

        const { error } = await supabase
          .from('category_banners')
          .update(updateData)
          .eq('id', editingBanner.id)

        if (error) throw error
      } else {
        const insertData: BenefitBannerInsert = {
          category_id: category.id,
          title: formData.title || '배너',
          image_url: imageUrl,
          link_url: formData.link_url || null,
          display_order: banners.length,
          is_active: true,
        }

        const { error } = await supabase
          .from('category_banners')
          .insert(insertData)

        if (error) throw error
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['benefit-banners', category.id] })
      toast.success(editingBanner ? '배너가 수정되었습니다' : '배너가 추가되었습니다')
      handleCloseDialog()
    },
    onError: (error: Error) => {
      toast.error(`저장 실패: ${error.message}`)
    },
  })

  // Delete banner
  const deleteBannerMutation = useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase
        .from('category_banners')
        .delete()
        .eq('id', id)

      if (error) throw error
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['benefit-banners', category.id] })
      toast.success('배너가 삭제되었습니다')
    },
    onError: (error: Error) => {
      toast.error(`삭제 실패: ${error.message}`)
    },
  })

  // Toggle active
  const toggleActiveMutation = useMutation({
    mutationFn: async ({ id, isActive }: { id: string; isActive: boolean }) => {
      const updateData: BenefitBannerUpdate = {
        is_active: isActive
      }

      const { error } = await supabase
        .from('category_banners')
        .update(updateData)
        .eq('id', id)

      if (error) throw error
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['benefit-banners', category.id] })
    },
  })

  // Update display orders
  const updateOrdersMutation = useMutation({
    mutationFn: async (updatedBanners: BenefitBanner[]) => {
      for (const [index, banner] of updatedBanners.entries()) {
        const updateData: BenefitBannerUpdate = {
          display_order: index
        }

        const { error } = await supabase
          .from('category_banners')
          .update(updateData)
          .eq('id', banner.id)

        if (error) throw error
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['benefit-banners', category.id] })
    },
  })

  const handleDragEnd = (event: DragEndEvent) => {
    const { active, over } = event
    if (!over || active.id === over.id) return

    const oldIndex = banners.findIndex((b) => b.id === active.id)
    const newIndex = banners.findIndex((b) => b.id === over.id)

    const newBanners = arrayMove(banners, oldIndex, newIndex)
    queryClient.setQueryData(['benefit-banners', category.id], newBanners)
    updateOrdersMutation.mutate(newBanners)
  }

  const handleOpenDialog = (banner?: BenefitBanner) => {
    if (banner) {
      setEditingBanner(banner)
      setFormData({
        title: banner.title || '',
        link_url: banner.link_url || '',
      })
      setImagePreview(banner.image_url)
    } else {
      setEditingBanner(null)
      setFormData({ title: '', link_url: '' })
      setImagePreview(null)
    }
    setImageFile(null)
    setDialogOpen(true)
  }

  const handleCloseDialog = () => {
    setDialogOpen(false)
    setEditingBanner(null)
    setFormData({ title: '', link_url: '' })
    setImagePreview(null)
    setImageFile(null)
  }

  const handleImageSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (!file) return

    const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp']
    if (!allowedTypes.includes(file.type)) {
      toast.error('JPG, PNG, WebP 파일만 업로드 가능합니다')
      return
    }

    if (file.size > 5 * 1024 * 1024) {
      toast.error('파일 크기는 5MB 이하여야 합니다')
      return
    }

    setImageFile(file)
    setImagePreview(URL.createObjectURL(file))
  }

  if (isLoading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', p: 3 }}>
        <CircularProgress />
      </Box>
    )
  }

  if (queryError) {
    return (
      <Box sx={{ p: 3 }}>
        <Typography color="error">
          배너 로딩 실패: {queryError instanceof Error ? queryError.message : '알 수 없는 오류'}
        </Typography>
      </Box>
    )
  }

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
        <Typography variant="body2" color="text.secondary">
          {banners.length}개의 배너
        </Typography>
        <Button
          variant="contained"
          size="small"
          startIcon={<AddIcon />}
          onClick={() => handleOpenDialog()}
        >
          배너 추가
        </Button>
      </Box>

      {banners.length === 0 ? (
        <Paper sx={{ p: 3, textAlign: 'center' }}>
          <Typography color="text.secondary">등록된 배너가 없습니다</Typography>
        </Paper>
      ) : (
        <DndContext
          sensors={sensors}
          collisionDetection={closestCenter}
          onDragEnd={handleDragEnd}
          modifiers={[restrictToVerticalAxis]}
        >
          <SortableContext items={banners.map(b => b.id)} strategy={verticalListSortingStrategy}>
            <List>
              {banners.map((banner) => (
                <SortableBannerItem
                  key={banner.id}
                  banner={banner}
                  onEdit={handleOpenDialog}
                  onDelete={(id) => {
                    if (confirm('정말 삭제하시겠습니까?')) {
                      deleteBannerMutation.mutate(id)
                    }
                  }}
                  onToggleActive={(id, isActive) => toggleActiveMutation.mutate({ id, isActive })}
                />
              ))}
            </List>
          </SortableContext>
        </DndContext>
      )}

      {/* Banner Dialog */}
      <Dialog open={dialogOpen} onClose={handleCloseDialog} maxWidth="sm" fullWidth>
        <DialogTitle>{editingBanner ? '배너 수정' : '새 배너 추가'}</DialogTitle>
        <DialogContent>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, mt: 1 }}>
            {/* Image Upload */}
            <Box>
              <Typography variant="body2" gutterBottom>
                배너 이미지 *
              </Typography>
              {imagePreview && (
                <Paper sx={{ p: 2, mb: 2 }}>
                  <img
                    src={imagePreview}
                    alt="Preview"
                    style={{ width: '100%', maxHeight: '200px', objectFit: 'contain' }}
                  />
                </Paper>
              )}
              <Button
                variant="outlined"
                component="label"
                startIcon={<UploadIcon />}
                fullWidth
              >
                {imagePreview ? '이미지 변경' : '이미지 업로드'}
                <input
                  type="file"
                  hidden
                  accept=".jpg,.jpeg,.png,.webp,image/jpeg,image/png,image/webp"
                  onChange={handleImageSelect}
                />
              </Button>
              <Typography variant="caption" color="text.secondary" sx={{ mt: 1, display: 'block' }}>
                권장 크기: 1200x400px, 최대 5MB (JPG, PNG, WebP만 가능)
              </Typography>
            </Box>

            {/* Title */}
            <TextField
              label="배너 제목 (선택)"
              value={formData.title}
              onChange={(e) => setFormData({ ...formData, title: e.target.value })}
              fullWidth
            />

            {/* Action URL */}
            <TextField
              label="링크 URL (선택)"
              value={formData.link_url}
              onChange={(e) => setFormData({ ...formData, link_url: e.target.value })}
              placeholder="https://example.com"
              fullWidth
            />
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDialog}>취소</Button>
          <Button
            variant="contained"
            onClick={() => saveBannerMutation.mutate()}
            disabled={saveBannerMutation.isPending || (!imageFile && !editingBanner)}
          >
            {saveBannerMutation.isPending ? '저장 중...' : '저장'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  )
}
