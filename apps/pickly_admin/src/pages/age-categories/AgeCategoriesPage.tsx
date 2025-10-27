/**
 * Age Categories Management Page
 *
 * Features:
 * - List all age categories with sorting
 * - Add/Edit/Delete operations
 * - SVG icon upload to Supabase Storage
 * - Drag & drop reordering
 */

import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import {
  Box,
  Paper,
  Button,
  Typography,
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
  Alert,
} from '@mui/material'
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  Upload as UploadIcon,
  DragIndicator as DragIcon,
} from '@mui/icons-material'
import { useForm, Controller } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import toast from 'react-hot-toast'
import { supabase } from '@/lib/supabase'
import { uploadAgeCategoryIcon } from '@/utils/storage'
import type { AgeCategory, AgeCategoryFormData } from '@/types/announcement'

// Validation schema
const ageCategorySchema = z.object({
  title: z.string().min(1, '제목을 입력하세요'),
  description: z.string().min(1, '설명을 입력하세요'),
  icon_component: z.string().default('default'),
  icon_url: z.string().nullable(),
  min_age: z.number().int().min(0).nullable(),
  max_age: z.number().int().min(0).nullable(),
  sort_order: z.number().int().min(0),
  is_active: z.boolean(),
})

export default function AgeCategoriesPage() {
  const queryClient = useQueryClient()
  const [dialogOpen, setDialogOpen] = useState(false)
  const [editingCategory, setEditingCategory] = useState<AgeCategory | null>(null)
  const [iconFile, setIconFile] = useState<File | null>(null)
  const [iconPreview, setIconPreview] = useState<string | null>(null)

  // Fetch age categories
  const { data: categories = [], isLoading, error } = useQuery({
    queryKey: ['age_categories'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('age_categories')
        .select('*')
        .order('sort_order', { ascending: true })

      if (error) throw error
      return data as AgeCategory[]
    },
  })

  // Form handling
  const {
    control,
    handleSubmit,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<AgeCategoryFormData>({
    resolver: zodResolver(ageCategorySchema),
    defaultValues: {
      title: '',
      description: '',
      icon_component: 'default',
      icon_url: null,
      min_age: null,
      max_age: null,
      sort_order: 0,
      is_active: true,
    },
  })

  // Create/Update mutation
  const saveMutation = useMutation({
    mutationFn: async (formData: AgeCategoryFormData) => {
      let iconUrl = formData.icon_url

      // Upload icon if file selected
      if (iconFile) {
        const uploadResult = await uploadAgeCategoryIcon(iconFile)
        iconUrl = uploadResult.url
      }

      const dataToSave = {
        ...formData,
        icon_url: iconUrl,
        icon_component: formData.icon_component || 'default',
      }

      if (editingCategory) {
        // Update existing
        const { data, error } = await supabase
          .from('age_categories')
          .update(dataToSave)
          .eq('id', editingCategory.id)
          .select()
          .single()

        if (error) throw error
        return data
      } else {
        // Create new
        const { data, error } = await supabase
          .from('age_categories')
          .insert(dataToSave)
          .select()
          .single()

        if (error) throw error
        return data
      }
    },
    onSuccess: () => {
      toast.success(editingCategory ? '카테고리가 수정되었습니다' : '카테고리가 추가되었습니다')
      queryClient.invalidateQueries({ queryKey: ['age_categories'] })
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
        .from('age_categories')
        .delete()
        .eq('id', id)

      if (error) throw error
    },
    onSuccess: () => {
      toast.success('카테고리가 삭제되었습니다')
      queryClient.invalidateQueries({ queryKey: ['age_categories'] })
    },
    onError: (error: Error) => {
      toast.error(error.message || '삭제에 실패했습니다')
    },
  })

  const handleOpenDialog = (category?: AgeCategory) => {
    if (category) {
      setEditingCategory(category)
      reset({
        title: category.title,
        description: category.description,
        icon_component: category.icon_component,
        icon_url: category.icon_url,
        min_age: category.min_age,
        max_age: category.max_age,
        sort_order: category.sort_order ?? 0,
        is_active: category.is_active ?? true,
      })
      setIconPreview(category.icon_url)
    } else {
      setEditingCategory(null)
      reset({
        title: '',
        description: '',
        icon_component: 'default',
        icon_url: null,
        min_age: null,
        max_age: null,
        sort_order: categories.length,
        is_active: true,
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

    if (file.type !== 'image/svg+xml') {
      toast.error('SVG 파일만 업로드 가능합니다')
      return
    }

    if (file.size > 1 * 1024 * 1024) {
      toast.error('파일 크기는 1MB 이하여야 합니다')
      return
    }

    setIconFile(file)
    setIconPreview(URL.createObjectURL(file))
  }

  const handleDelete = async (category: AgeCategory) => {
    if (!window.confirm(`"${category.title}" 카테고리를 삭제하시겠습니까?`)) {
      return
    }
    deleteMutation.mutate(category.id)
  }

  const onSubmit = (data: AgeCategoryFormData) => {
    saveMutation.mutate(data)
  }

  if (isLoading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', mt: 4 }}>
        <CircularProgress />
      </Box>
    )
  }

  if (error) {
    return (
      <Alert severity="error">
        데이터를 불러오는데 실패했습니다: {(error as Error).message}
      </Alert>
    )
  }

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 3 }}>
        <Typography variant="h4">연령대 카테고리 관리</Typography>
        <Button
          variant="contained"
          startIcon={<AddIcon />}
          onClick={() => handleOpenDialog()}
        >
          카테고리 추가
        </Button>
      </Box>

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell width={50}></TableCell>
              <TableCell>아이콘</TableCell>
              <TableCell>제목</TableCell>
              <TableCell>설명</TableCell>
              <TableCell>연령대</TableCell>
              <TableCell>순서</TableCell>
              <TableCell>상태</TableCell>
              <TableCell width={120}>작업</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {categories.length === 0 ? (
              <TableRow>
                <TableCell colSpan={8} align="center">
                  등록된 카테고리가 없습니다
                </TableCell>
              </TableRow>
            ) : (
              categories.map((category) => (
                <TableRow key={category.id} hover>
                  <TableCell>
                    <DragIcon sx={{ color: 'text.disabled', cursor: 'move' }} />
                  </TableCell>
                  <TableCell>
                    {category.icon_url ? (
                      <Box
                        component="img"
                        src={category.icon_url}
                        alt={category.title}
                        sx={{ width: 40, height: 40, objectFit: 'contain' }}
                      />
                    ) : (
                      <Box
                        sx={{
                          width: 40,
                          height: 40,
                          bgcolor: 'grey.200',
                          borderRadius: 1,
                        }}
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
                      {category.description}
                    </Typography>
                  </TableCell>
                  <TableCell>
                    <Typography variant="body2">
                      {category.min_age ?? '?'} - {category.max_age ?? '?'}세
                    </Typography>
                  </TableCell>
                  <TableCell>
                    <Chip label={category.sort_order} size="small" />
                  </TableCell>
                  <TableCell>
                    <Chip
                      label={category.is_active ? '활성' : '비활성'}
                      color={category.is_active ? 'success' : 'default'}
                      size="small"
                    />
                  </TableCell>
                  <TableCell>
                    <IconButton
                      size="small"
                      onClick={() => handleOpenDialog(category)}
                    >
                      <EditIcon fontSize="small" />
                    </IconButton>
                    <IconButton
                      size="small"
                      color="error"
                      onClick={() => handleDelete(category)}
                    >
                      <DeleteIcon fontSize="small" />
                    </IconButton>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </TableContainer>

      {/* Add/Edit Dialog */}
      <Dialog
        open={dialogOpen}
        onClose={handleCloseDialog}
        maxWidth="md"
        fullWidth
      >
        <DialogTitle>
          {editingCategory ? '카테고리 수정' : '카테고리 추가'}
        </DialogTitle>
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
                      label="제목"
                      error={!!errors.title}
                      helperText={errors.title?.message}
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
                      fullWidth
                      label="설명"
                      multiline
                      rows={2}
                      error={!!errors.description}
                      helperText={errors.description?.message}
                    />
                  )}
                />
              </Grid>

              <Grid item xs={12}>
                <Typography variant="body2" gutterBottom>
                  아이콘 SVG 업로드
                </Typography>
                {iconPreview && (
                  <Paper sx={{ p: 2, mb: 1, display: 'inline-block' }}>
                    <img
                      src={iconPreview}
                      alt="Icon preview"
                      style={{ width: 64, height: 64, objectFit: 'contain' }}
                    />
                  </Paper>
                )}
                <Button
                  variant="outlined"
                  component="label"
                  startIcon={<UploadIcon />}
                  fullWidth
                >
                  {iconPreview ? 'SVG 변경' : 'SVG 업로드'}
                  <input
                    type="file"
                    hidden
                    accept=".svg,image/svg+xml"
                    onChange={handleIconSelect}
                  />
                </Button>
                <Typography variant="caption" color="text.secondary" display="block" mt={1}>
                  SVG 파일만 가능, 최대 1MB
                </Typography>
              </Grid>

              <Grid item xs={6}>
                <Controller
                  name="min_age"
                  control={control}
                  render={({ field }) => (
                    <TextField
                      {...field}
                      value={field.value ?? ''}
                      onChange={(e) => field.onChange(e.target.value ? parseInt(e.target.value) : null)}
                      fullWidth
                      label="최소 나이"
                      type="number"
                      error={!!errors.min_age}
                      helperText={errors.min_age?.message}
                    />
                  )}
                />
              </Grid>

              <Grid item xs={6}>
                <Controller
                  name="max_age"
                  control={control}
                  render={({ field }) => (
                    <TextField
                      {...field}
                      value={field.value ?? ''}
                      onChange={(e) => field.onChange(e.target.value ? parseInt(e.target.value) : null)}
                      fullWidth
                      label="최대 나이"
                      type="number"
                      error={!!errors.max_age}
                      helperText={errors.max_age?.message}
                    />
                  )}
                />
              </Grid>

              <Grid item xs={12}>
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
                      error={!!errors.sort_order}
                      helperText={errors.sort_order?.message}
                    />
                  )}
                />
              </Grid>

              <Grid item xs={12}>
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
            <Button
              type="submit"
              variant="contained"
              disabled={isSubmitting}
            >
              {editingCategory ? '수정' : '추가'}
            </Button>
          </DialogActions>
        </form>
      </Dialog>
    </Box>
  )
}
