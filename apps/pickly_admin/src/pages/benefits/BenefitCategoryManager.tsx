/**
 * Benefit Category Manager
 * Manages top-level benefit_categories table (v8.1)
 * CRUD: 인기, 주거, 교육, 건강, 교통, 복지, 취업, 지원, 문화
 */

import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import {
  Box,
  Paper,
  Typography,
  Button,
  IconButton,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Chip,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Grid,
  Switch,
  FormControlLabel,
  CircularProgress,
} from '@mui/material'
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  Upload as UploadIcon,
  ArrowUpward,
  ArrowDownward,
} from '@mui/icons-material'
import { useForm, Controller } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import toast from 'react-hot-toast'
import { supabase } from '@/lib/supabase'
import { uploadBenefitIcon } from '@/utils/storage'
import type { BenefitCategory, BenefitCategoryFormData } from '@/types/benefit'

const categorySchema = z.object({
  title: z.string().min(1, '혜택명을 입력하세요'),
  slug: z.string().min(1, 'Slug를 입력하세요').regex(/^[a-z0-9-]+$/, 'Slug는 소문자, 숫자, 하이픈만 가능합니다'),
  description: z.string().nullable(),
  icon_url: z.string().nullable(),
  sort_order: z.number().int().min(0),
  is_active: z.boolean(),
  parent_id: z.string().nullable(),
})

export default function BenefitCategoryManager() {
  const queryClient = useQueryClient()
  const [dialogOpen, setDialogOpen] = useState(false)
  const [editingCategory, setEditingCategory] = useState<BenefitCategory | null>(null)
  const [iconFile, setIconFile] = useState<File | null>(null)
  const [iconPreview, setIconPreview] = useState<string | null>(null)

  // Fetch categories
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

  const {
    control,
    handleSubmit,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<BenefitCategoryFormData>({
    resolver: zodResolver(categorySchema),
    defaultValues: {
      title: '',
      slug: '',
      description: null,
      icon_url: null,
      sort_order: 0,
      is_active: true,
      parent_id: null,
    },
  })

  // Save mutation
  const saveMutation = useMutation({
    mutationFn: async (formData: BenefitCategoryFormData) => {
      let iconUrl = formData.icon_url

      if (iconFile) {
        try {
          const uploadResult = await uploadBenefitIcon(iconFile)
          iconUrl = uploadResult.url
        } catch (error) {
          console.error('Icon upload failed:', error)
          toast.error('아이콘 업로드에 실패했습니다')
        }
      }

      const dataToSave = {
        ...formData,
        icon_url: iconUrl,
      }

      if (editingCategory) {
        const { data, error } = await supabase
          .from('benefit_categories')
          .update(dataToSave)
          .eq('id', editingCategory.id)
          .select()
          .single()

        if (error) throw error
        return data
      } else {
        const { data, error } = await supabase
          .from('benefit_categories')
          .insert(dataToSave)
          .select()
          .single()

        if (error) throw error
        return data
      }
    },
    onSuccess: () => {
      toast.success(editingCategory ? '혜택이 수정되었습니다' : '혜택이 추가되었습니다')
      queryClient.invalidateQueries({ queryKey: ['benefit_categories'] })
      handleCloseDialog()
    },
    onError: (error: Error) => {
      toast.error(error.message || '저장에 실패했습니다')
    },
  })

  // Delete mutation
  const deleteMutation = useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase
        .from('benefit_categories')
        .delete()
        .eq('id', id)

      if (error) throw error
    },
    onSuccess: () => {
      toast.success('혜택이 삭제되었습니다')
      queryClient.invalidateQueries({ queryKey: ['benefit_categories'] })
    },
    onError: (error: Error) => {
      toast.error(error.message || '삭제에 실패했습니다')
    },
  })

  // Reorder mutation
  const reorderMutation = useMutation({
    mutationFn: async ({ id, newOrder }: { id: string; newOrder: number }) => {
      const { error } = await supabase
        .from('benefit_categories')
        .update({ sort_order: newOrder })
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
      reset({
        title: category.title,
        slug: category.slug,
        description: category.description,
        icon_url: category.icon_url,
        sort_order: category.sort_order,
        is_active: category.is_active,
        parent_id: category.parent_id,
      })
      setIconPreview(category.icon_url)
    } else {
      setEditingCategory(null)
      reset({
        title: '',
        slug: '',
        description: null,
        icon_url: null,
        sort_order: categories.length,
        is_active: true,
        parent_id: null,
      })
      setIconPreview(null)
    }
    setIconFile(null)
    setDialogOpen(true)
  }

  const handleCloseDialog = () => {
    setDialogOpen(false)
    setEditingCategory(null)
    setIconFile(null)
    setIconPreview(null)
    reset()
  }

  const handleIconSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (!file) return

    if (!file.type.startsWith('image/')) {
      toast.error('이미지 파일만 업로드 가능합니다')
      return
    }

    if (file.size > 1 * 1024 * 1024) {
      toast.error('파일 크기는 1MB 이하여야 합니다')
      return
    }

    setIconFile(file)
    setIconPreview(URL.createObjectURL(file))
  }

  const handleDelete = async (category: BenefitCategory) => {
    if (!window.confirm(`"${category.title}" 혜택을 삭제하시겠습니까?`)) {
      return
    }
    deleteMutation.mutate(category.id)
  }

  const handleMoveUp = (category: BenefitCategory, index: number) => {
    if (index === 0) return
    reorderMutation.mutate({ id: category.id, newOrder: category.sort_order - 1 })
    reorderMutation.mutate({ id: categories[index - 1].id, newOrder: categories[index - 1].sort_order + 1 })
  }

  const handleMoveDown = (category: BenefitCategory, index: number) => {
    if (index === categories.length - 1) return
    reorderMutation.mutate({ id: category.id, newOrder: category.sort_order + 1 })
    reorderMutation.mutate({ id: categories[index + 1].id, newOrder: categories[index + 1].sort_order - 1 })
  }

  const onSubmit = (data: BenefitCategoryFormData) => {
    saveMutation.mutate(data)
  }

  return (
    <Paper sx={{ p: 3 }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2 }}>
        <Typography variant="h6">혜택 관리</Typography>
        <Button
          variant="contained"
          size="small"
          startIcon={<AddIcon />}
          onClick={() => handleOpenDialog()}
        >
          혜택 추가
        </Button>
      </Box>

      <Typography variant="body2" color="text.secondary" gutterBottom>
        예: 인기, 주거, 교육, 건강, 교통, 복지, 취업, 지원, 문화
      </Typography>

      {isLoading ? (
        <Box sx={{ display: 'flex', justifyContent: 'center', p: 3 }}>
          <CircularProgress />
        </Box>
      ) : (
        <TableContainer>
          <Table size="small">
            <TableHead>
              <TableRow>
                <TableCell width={60}>아이콘</TableCell>
                <TableCell>혜택명</TableCell>
                <TableCell>Slug</TableCell>
                <TableCell>설명</TableCell>
                <TableCell width={80}>순서</TableCell>
                <TableCell width={80}>상태</TableCell>
                <TableCell width={150}>작업</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {categories.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={7} align="center">
                    등록된 혜택이 없습니다
                  </TableCell>
                </TableRow>
              ) : (
                categories.map((category, index) => (
                  <TableRow key={category.id}>
                    <TableCell>
                      {category.icon_url && (
                        <Box
                          component="img"
                          src={category.icon_url}
                          alt={category.title}
                          sx={{ width: 32, height: 32, objectFit: 'contain' }}
                        />
                      )}
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2" fontWeight="medium">
                        {category.title}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2" color="text.secondary">
                        {category.slug}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2" color="text.secondary">
                        {category.description || '-'}
                      </Typography>
                    </TableCell>
                    <TableCell>{category.sort_order}</TableCell>
                    <TableCell>
                      <Chip
                        label={category.is_active ? '활성' : '비활성'}
                        color={category.is_active ? 'success' : 'default'}
                        size="small"
                      />
                    </TableCell>
                    <TableCell>
                      <IconButton size="small" onClick={() => handleMoveUp(category, index)} disabled={index === 0}>
                        <ArrowUpward fontSize="small" />
                      </IconButton>
                      <IconButton size="small" onClick={() => handleMoveDown(category, index)} disabled={index === categories.length - 1}>
                        <ArrowDownward fontSize="small" />
                      </IconButton>
                      <IconButton size="small" onClick={() => handleOpenDialog(category)}>
                        <EditIcon fontSize="small" />
                      </IconButton>
                      <IconButton size="small" color="error" onClick={() => handleDelete(category)}>
                        <DeleteIcon fontSize="small" />
                      </IconButton>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </TableContainer>
      )}

      {/* Add/Edit Dialog */}
      <Dialog open={dialogOpen} onClose={handleCloseDialog} maxWidth="sm" fullWidth>
        <DialogTitle>{editingCategory ? '혜택 수정' : '혜택 추가'}</DialogTitle>
        <form onSubmit={handleSubmit(onSubmit)}>
          <DialogContent>
            <Grid container spacing={2}>
              <Grid item xs={12}>
                <Controller
                  name="title"
                  control={control}
                  render={({ field }) => (
                    <TextField
                      {...field}
                      fullWidth
                      label="혜택명"
                      error={!!errors.title}
                      helperText={errors.title?.message}
                      placeholder="예: 인기, 주거, 교육"
                    />
                  )}
                />
              </Grid>

              <Grid item xs={12}>
                <Controller
                  name="slug"
                  control={control}
                  render={({ field }) => (
                    <TextField
                      {...field}
                      fullWidth
                      label="Slug (URL 경로용)"
                      error={!!errors.slug}
                      helperText={errors.slug?.message || '예: popular, housing, education'}
                      placeholder="소문자, 숫자, 하이픈만 사용"
                    />
                  )}
                />
              </Grid>

              <Grid item xs={12}>
                <Controller
                  name="description"
                  control={control}
                  render={({ field }) => (
                    <TextField
                      {...field}
                      value={field.value || ''}
                      fullWidth
                      label="설명 (선택)"
                      multiline
                      rows={2}
                      placeholder="혜택 카테고리 설명"
                    />
                  )}
                />
              </Grid>

              <Grid item xs={12}>
                <Typography variant="body2" gutterBottom>
                  혜택 아이콘 (선택)
                </Typography>
                {iconPreview && (
                  <Paper sx={{ p: 2, mb: 1, display: 'inline-block' }}>
                    <img
                      src={iconPreview}
                      alt="Icon preview"
                      style={{ width: 48, height: 48, objectFit: 'contain' }}
                    />
                  </Paper>
                )}
                <Button
                  variant="outlined"
                  component="label"
                  startIcon={<UploadIcon />}
                  fullWidth
                  size="small"
                >
                  {iconPreview ? '아이콘 변경' : '아이콘 업로드'}
                  <input
                    type="file"
                    hidden
                    accept="image/*"
                    onChange={handleIconSelect}
                  />
                </Button>
                <Typography variant="caption" color="text.secondary" display="block" mt={1}>
                  SVG, PNG 권장, 최대 1MB
                </Typography>
              </Grid>

              <Grid item xs={6}>
                <Controller
                  name="sort_order"
                  control={control}
                  render={({ field }) => (
                    <TextField
                      {...field}
                      onChange={(e) => field.onChange(parseInt(e.target.value) || 0)}
                      fullWidth
                      label="정렬 순서"
                      type="number"
                    />
                  )}
                />
              </Grid>

              <Grid item xs={6}>
                <Controller
                  name="is_active"
                  control={control}
                  render={({ field }) => (
                    <FormControlLabel
                      control={<Switch {...field} checked={field.value} />}
                      label="활성화"
                    />
                  )}
                />
              </Grid>
            </Grid>
          </DialogContent>
          <DialogActions>
            <Button onClick={handleCloseDialog}>취소</Button>
            <Button type="submit" variant="contained" disabled={isSubmitting}>
              {editingCategory ? '수정' : '추가'}
            </Button>
          </DialogActions>
        </form>
      </Dialog>
    </Paper>
  )
}
