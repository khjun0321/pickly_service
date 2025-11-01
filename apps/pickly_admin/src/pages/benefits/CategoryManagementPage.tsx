/**
 * Category Management Page
 * PRD v9.6 Section 4.2 - Benefits Management (대분류 관리)
 * Route: /benefits/categories
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
} from '@mui/material'
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  DragIndicator as DragIcon,
} from '@mui/icons-material'
import { supabase } from '@/lib/supabase'
import SVGUploader from '@/components/common/SVGUploader'
import type { BenefitCategory, BenefitCategoryFormData } from '@/types/benefits'
import toast from 'react-hot-toast'

export default function CategoryManagementPage() {
  const queryClient = useQueryClient()
  const [dialogOpen, setDialogOpen] = useState(false)
  const [editingCategory, setEditingCategory] = useState<BenefitCategory | null>(null)
  const [formData, setFormData] = useState<BenefitCategoryFormData>({
    title: '',
    slug: '',
    description: null,
    icon_url: null,
    icon_name: null,
    sort_order: 0,
    is_active: true,
  })

  // Fetch benefit categories
  const { data: categories = [], isLoading } = useQuery({
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

  // Create/Update mutation
  const saveMutation = useMutation({
    mutationFn: async (data: BenefitCategoryFormData & { id?: string }) => {
      if (data.id) {
        const { error } = await supabase
          .from('benefit_categories')
          .update(data)
          .eq('id', data.id)
        if (error) throw error
      } else {
        const { error } = await supabase.from('benefit_categories').insert([data])
        if (error) throw error
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['benefit_categories'] })
      toast.success(editingCategory ? '카테고리가 수정되었습니다' : '카테고리가 추가되었습니다')
      handleCloseDialog()
    },
    onError: (error: Error) => {
      toast.error(`오류: ${error.message}`)
    },
  })

  // Delete mutation
  const deleteMutation = useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from('benefit_categories').delete().eq('id', id)
      if (error) throw error
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['benefit_categories'] })
      toast.success('카테고리가 삭제되었습니다')
    },
    onError: (error: Error) => {
      toast.error(`삭제 실패: ${error.message}`)
    },
  })

  // Toggle active status
  const toggleActiveMutation = useMutation({
    mutationFn: async ({ id, is_active }: { id: string; is_active: boolean }) => {
      const { error } = await supabase
        .from('benefit_categories')
        .update({ is_active })
        .eq('id', id)
      if (error) throw error
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['benefit_categories'] })
    },
  })

  const handleOpenDialog = (category?: BenefitCategory) => {
    if (category) {
      setEditingCategory(category)
      setFormData({
        title: category.title,
        slug: category.slug,
        description: category.description,
        icon_url: category.icon_url,
        icon_name: category.icon_name,
        sort_order: category.sort_order,
        is_active: category.is_active,
      })
    } else {
      setEditingCategory(null)
      setFormData({
        title: '',
        slug: '',
        description: null,
        icon_url: null,
        icon_name: null,
        sort_order: categories.length,
        is_active: true,
      })
    }
    setDialogOpen(true)
  }

  const handleCloseDialog = () => {
    setDialogOpen(false)
    setEditingCategory(null)
  }

  const handleSave = () => {
    // Validation
    if (!formData.title.trim()) {
      toast.error('카테고리 제목을 입력하세요')
      return
    }
    if (!formData.slug.trim()) {
      toast.error('슬러그를 입력하세요')
      return
    }

    // Validate slug format (lowercase, alphanumeric, hyphens only)
    const slugPattern = /^[a-z0-9]+(-[a-z0-9]+)*$/
    if (!slugPattern.test(formData.slug)) {
      toast.error('슬러그는 소문자, 숫자, 하이픈(-)만 사용 가능합니다 (예: housing-support)')
      return
    }

    saveMutation.mutate({
      ...formData,
      ...(editingCategory && { id: editingCategory.id }),
    })
  }

  const handleDelete = (id: string) => {
    if (window.confirm('이 카테고리를 삭제하시겠습니까? 관련된 하위분류와 공고도 함께 삭제됩니다.')) {
      deleteMutation.mutate(id)
    }
  }

  const handleTitleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const title = e.target.value
    setFormData({ ...formData, title })

    // Auto-generate slug from title (only when creating new category)
    if (!editingCategory) {
      const slug = title
        .toLowerCase()
        .replace(/\s+/g, '-') // Replace spaces with hyphens
        .replace(/[^a-z0-9-]/g, '') // Remove non-alphanumeric except hyphens
        .replace(/-+/g, '-') // Replace multiple hyphens with single hyphen
        .replace(/^-|-$/g, '') // Remove leading/trailing hyphens
      setFormData((prev) => ({ ...prev, slug }))
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
          <Typography variant="h4">혜택 대분류 관리</Typography>
          <Typography variant="body2" color="text.secondary" sx={{ mt: 0.5 }}>
            PRD v9.6 Section 4.2 - 혜택 카테고리 관리
          </Typography>
        </Box>
        <Button variant="contained" startIcon={<AddIcon />} onClick={() => handleOpenDialog()}>
          카테고리 추가
        </Button>
      </Box>

      <Paper>
        <List>
          {categories.map((category) => (
            <ListItem
              key={category.id}
              sx={{
                borderBottom: '1px solid',
                borderColor: 'divider',
                '&:last-child': { borderBottom: 'none' },
              }}
            >
              <IconButton sx={{ mr: 1, cursor: 'grab' }}>
                <DragIcon />
              </IconButton>

              {/* Icon Preview */}
              {category.icon_url && (
                <Box
                  sx={{
                    width: 40,
                    height: 40,
                    mr: 2,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    bgcolor: 'grey.100',
                    borderRadius: 1,
                  }}
                >
                  <img
                    src={category.icon_url}
                    alt={category.title}
                    style={{ maxWidth: '100%', maxHeight: '100%' }}
                  />
                </Box>
              )}

              <ListItemText
                primary={
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <Typography variant="h6">{category.title}</Typography>
                    <Chip label={category.slug} size="small" variant="outlined" />
                    {!category.is_active && (
                      <Chip label="비활성" size="small" color="default" variant="outlined" />
                    )}
                  </Box>
                }
                secondary={
                  <Box>
                    {category.description && (
                      <Typography variant="body2" color="text.secondary">
                        {category.description}
                      </Typography>
                    )}
                    <Typography variant="caption" color="text.secondary">
                      정렬 순서: {category.sort_order}
                      {category.icon_name && ` | 아이콘: ${category.icon_name}`}
                    </Typography>
                  </Box>
                }
              />
              <ListItemSecondaryAction>
                <Switch
                  checked={category.is_active}
                  onChange={(e) =>
                    toggleActiveMutation.mutate({ id: category.id, is_active: e.target.checked })
                  }
                  color="primary"
                />
                <IconButton onClick={() => handleOpenDialog(category)} sx={{ ml: 1 }}>
                  <EditIcon />
                </IconButton>
                <IconButton onClick={() => handleDelete(category.id)} color="error">
                  <DeleteIcon />
                </IconButton>
              </ListItemSecondaryAction>
            </ListItem>
          ))}
          {categories.length === 0 && (
            <ListItem>
              <ListItemText
                primary="카테고리가 없습니다"
                secondary="새 카테고리를 추가하려면 '카테고리 추가' 버튼을 클릭하세요"
              />
            </ListItem>
          )}
        </List>
      </Paper>

      {/* Create/Edit Dialog */}
      <Dialog open={dialogOpen} onClose={handleCloseDialog} maxWidth="md" fullWidth>
        <DialogTitle>{editingCategory ? '카테고리 수정' : '카테고리 추가'}</DialogTitle>
        <DialogContent>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, pt: 2 }}>
            <TextField
              label="카테고리 제목"
              value={formData.title}
              onChange={handleTitleChange}
              fullWidth
              required
              helperText="예: 주거 지원, 취업 지원, 청년 복지"
            />
            <TextField
              label="슬러그"
              value={formData.slug}
              onChange={(e) => setFormData({ ...formData, slug: e.target.value.toLowerCase() })}
              fullWidth
              required
              helperText="URL에 사용될 식별자 (소문자, 숫자, 하이픈만 가능, 예: housing-support)"
              disabled={!!editingCategory}
            />
            <TextField
              label="설명"
              value={formData.description || ''}
              onChange={(e) => setFormData({ ...formData, description: e.target.value || null })}
              multiline
              rows={3}
              fullWidth
              helperText="카테고리에 대한 간단한 설명"
            />

            {/* SVG Icon Upload */}
            <SVGUploader
              bucket="benefit-icons"
              currentSvgUrl={formData.icon_url}
              onUploadComplete={(url, path) => {
                setFormData({
                  ...formData,
                  icon_url: url,
                  icon_name: path.split('/').pop() || null,
                })
              }}
              onDelete={() => {
                setFormData({ ...formData, icon_url: null, icon_name: null })
              }}
              label="카테고리 아이콘 (SVG)"
              helperText="카테고리를 나타내는 SVG 아이콘을 업로드하세요"
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
            {editingCategory ? '수정' : '추가'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  )
}
