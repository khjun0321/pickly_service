/**
 * Subcategory Management Page
 * PRD v9.6 Section 4.2 - Benefits Management (하위분류 관리)
 * Route: /benefits/subcategories
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
import SVGUploader from '@/components/common/SVGUploader'
import type { BenefitSubcategory, BenefitSubcategoryFormData, BenefitCategory } from '@/types/benefits'
import toast from 'react-hot-toast'

export default function SubcategoryManagementPage() {
  const queryClient = useQueryClient()
  const [dialogOpen, setDialogOpen] = useState(false)
  const [editingSubcategory, setEditingSubcategory] = useState<BenefitSubcategory | null>(null)
  const [formData, setFormData] = useState<BenefitSubcategoryFormData>({
    category_id: null,
    name: '',
    slug: '',
    sort_order: 0,
    is_active: true,
    icon_url: null,
    icon_name: null,
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

  // Fetch benefit subcategories with category info
  const { data: subcategories = [], isLoading } = useQuery({
    queryKey: ['benefit_subcategories'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('benefit_subcategories')
        .select(`
          *,
          category:benefit_categories(id, title, slug)
        `)
        .order('sort_order', { ascending: true })

      if (error) throw error
      return data as (BenefitSubcategory & { category?: BenefitCategory })[]
    },
  })

  // Create/Update mutation
  const saveMutation = useMutation({
    mutationFn: async (data: BenefitSubcategoryFormData & { id?: string }) => {
      if (data.id) {
        const { error } = await supabase
          .from('benefit_subcategories')
          .update(data)
          .eq('id', data.id)
        if (error) throw error
      } else {
        const { error } = await supabase.from('benefit_subcategories').insert([data])
        if (error) throw error
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['benefit_subcategories'] })
      toast.success(editingSubcategory ? '하위분류가 수정되었습니다' : '하위분류가 추가되었습니다')
      handleCloseDialog()
    },
    onError: (error: Error) => {
      toast.error(`오류: ${error.message}`)
    },
  })

  // Delete mutation
  const deleteMutation = useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from('benefit_subcategories').delete().eq('id', id)
      if (error) throw error
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['benefit_subcategories'] })
      toast.success('하위분류가 삭제되었습니다')
    },
    onError: (error: Error) => {
      toast.error(`삭제 실패: ${error.message}`)
    },
  })

  // Toggle active status
  const toggleActiveMutation = useMutation({
    mutationFn: async ({ id, is_active }: { id: string; is_active: boolean }) => {
      const { error } = await supabase
        .from('benefit_subcategories')
        .update({ is_active })
        .eq('id', id)
      if (error) throw error
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['benefit_subcategories'] })
    },
  })

  const handleOpenDialog = (subcategory?: BenefitSubcategory) => {
    if (subcategory) {
      setEditingSubcategory(subcategory)
      setFormData({
        category_id: subcategory.category_id,
        name: subcategory.name,
        slug: subcategory.slug,
        sort_order: subcategory.sort_order,
        is_active: subcategory.is_active,
        icon_url: subcategory.icon_url,
        icon_name: subcategory.icon_name,
      })
    } else {
      setEditingSubcategory(null)
      setFormData({
        category_id: null,
        name: '',
        slug: '',
        sort_order: subcategories.length,
        is_active: true,
        icon_url: null,
        icon_name: null,
      })
    }
    setDialogOpen(true)
  }

  const handleCloseDialog = () => {
    setDialogOpen(false)
    setEditingSubcategory(null)
  }

  const handleSave = () => {
    // Validation
    if (!formData.name.trim()) {
      toast.error('하위분류 이름을 입력하세요')
      return
    }
    if (!formData.slug.trim()) {
      toast.error('슬러그를 입력하세요')
      return
    }
    if (!formData.category_id) {
      toast.error('상위 카테고리를 선택하세요')
      return
    }

    // Validate slug format (lowercase, alphanumeric, hyphens only)
    const slugPattern = /^[a-z0-9]+(-[a-z0-9]+)*$/
    if (!slugPattern.test(formData.slug)) {
      toast.error('슬러그는 소문자, 숫자, 하이픈(-)만 사용 가능합니다 (예: single-household)')
      return
    }

    saveMutation.mutate({
      ...formData,
      ...(editingSubcategory && { id: editingSubcategory.id }),
    })
  }

  const handleDelete = (id: string) => {
    if (window.confirm('이 하위분류를 삭제하시겠습니까? 관련된 공고도 함께 영향을 받을 수 있습니다.')) {
      deleteMutation.mutate(id)
    }
  }

  const handleNameChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const name = e.target.value
    setFormData({ ...formData, name })

    // Auto-generate slug from name (only when creating new subcategory)
    if (!editingSubcategory) {
      const slug = name
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
          <Typography variant="h4">혜택 하위분류 관리</Typography>
          <Typography variant="body2" color="text.secondary" sx={{ mt: 0.5 }}>
            PRD v9.6 Section 4.2 - 카테고리별 하위분류 관리
          </Typography>
        </Box>
        <Button variant="contained" startIcon={<AddIcon />} onClick={() => handleOpenDialog()}>
          하위분류 추가
        </Button>
      </Box>

      <Paper>
        <List>
          {subcategories.map((subcategory) => (
            <ListItem
              key={subcategory.id}
              sx={{
                borderBottom: '1px solid',
                borderColor: 'divider',
                '&:last-child': { borderBottom: 'none' },
              }}
            >
              <IconButton sx={{ mr: 1, cursor: 'grab' }}>
                <DragIcon />
              </IconButton>

              <ListItemText
                primary={
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <Typography variant="h6">{subcategory.name}</Typography>
                    <Chip label={subcategory.slug} size="small" variant="outlined" />
                    {subcategory.category && (
                      <Chip
                        label={subcategory.category.title}
                        size="small"
                        color="primary"
                        variant="outlined"
                      />
                    )}
                    {!subcategory.is_active && (
                      <Chip label="비활성" size="small" color="default" variant="outlined" />
                    )}
                  </Box>
                }
                secondary={
                  <Typography variant="caption" color="text.secondary">
                    정렬 순서: {subcategory.sort_order}
                    {subcategory.category && ` | 상위 카테고리: ${subcategory.category.title}`}
                    {subcategory.icon_name && ` | 아이콘: ${subcategory.icon_name}`}
                  </Typography>
                }
              />
              <ListItemSecondaryAction>
                <Switch
                  checked={subcategory.is_active}
                  onChange={(e) =>
                    toggleActiveMutation.mutate({ id: subcategory.id, is_active: e.target.checked })
                  }
                  color="primary"
                />
                <IconButton onClick={() => handleOpenDialog(subcategory)} sx={{ ml: 1 }}>
                  <EditIcon />
                </IconButton>
                <IconButton onClick={() => handleDelete(subcategory.id)} color="error">
                  <DeleteIcon />
                </IconButton>
              </ListItemSecondaryAction>
            </ListItem>
          ))}
          {subcategories.length === 0 && (
            <ListItem>
              <ListItemText
                primary="하위분류가 없습니다"
                secondary="새 하위분류를 추가하려면 '하위분류 추가' 버튼을 클릭하세요"
              />
            </ListItem>
          )}
        </List>
      </Paper>

      {/* Create/Edit Dialog */}
      <Dialog open={dialogOpen} onClose={handleCloseDialog} maxWidth="md" fullWidth>
        <DialogTitle>{editingSubcategory ? '하위분류 수정' : '하위분류 추가'}</DialogTitle>
        <DialogContent>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, pt: 2 }}>
            {/* Category Dropdown */}
            <FormControl fullWidth required>
              <InputLabel>상위 카테고리</InputLabel>
              <Select
                value={formData.category_id || ''}
                onChange={(e) => setFormData({ ...formData, category_id: e.target.value })}
                label="상위 카테고리"
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
              label="하위분류 이름"
              value={formData.name}
              onChange={handleNameChange}
              fullWidth
              required
              helperText="예: 1인가구, 신혼부부, 대학생"
            />
            <TextField
              label="슬러그"
              value={formData.slug}
              onChange={(e) => setFormData({ ...formData, slug: e.target.value.toLowerCase() })}
              fullWidth
              required
              helperText="URL에 사용될 식별자 (소문자, 숫자, 하이픈만 가능, 예: single-household)"
              disabled={!!editingSubcategory}
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
              label="하위분류 아이콘 (SVG)"
              helperText="하위분류를 나타내는 SVG 아이콘을 업로드하세요 (선택사항)"
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
            {editingSubcategory ? '수정' : '추가'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  )
}
