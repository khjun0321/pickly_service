/**
 * Banner Manager Component
 * Manages category banners with image upload and carousel display
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
  Select,
  MenuItem,
  FormControl,
  InputLabel,
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
import { uploadBenefitBanner } from '@/utils/storage'
import type { CategoryBanner, CategoryBannerFormData } from '@/types/benefit'

interface BannerManagerProps {
  categoryId: string
  categoryTitle: string
}

const bannerSchema = z.object({
  benefit_category_id: z.string(),
  title: z.string().min(1, '제목을 입력하세요'),
  subtitle: z.string().nullable(),
  image_url: z.string().nullable(),
  link_type: z.enum(['internal', 'external', 'none']),
  link_target: z.string().nullable(),
  sort_order: z.number().int().min(0),
  is_active: z.boolean(),
})

export default function BannerManager({ categoryId, categoryTitle }: BannerManagerProps) {
  const queryClient = useQueryClient()
  const [dialogOpen, setDialogOpen] = useState(false)
  const [editingBanner, setEditingBanner] = useState<CategoryBanner | null>(null)
  const [imageFile, setImageFile] = useState<File | null>(null)
  const [imagePreview, setImagePreview] = useState<string | null>(null)

  // Fetch banners
  const { data: banners = [], isLoading } = useQuery({
    queryKey: ['category_banners', categoryId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('category_banners')
        .select('*')
        .eq('benefit_category_id', categoryId)
        .order('sort_order', { ascending: true })

      if (error) throw error
      return data as CategoryBanner[]
    },
  })

  const {
    control,
    handleSubmit,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<CategoryBannerFormData>({
    resolver: zodResolver(bannerSchema),
    defaultValues: {
      benefit_category_id: categoryId,
      title: '',
      subtitle: null,
      image_url: null,
      link_type: 'none',
      link_target: null,
      sort_order: 0,
      is_active: true,
    },
  })

  // Save mutation
  const saveMutation = useMutation({
    mutationFn: async (formData: CategoryBannerFormData) => {
      let imageUrl = formData.image_url

      if (imageFile) {
        const uploadResult = await uploadBenefitBanner(imageFile)
        imageUrl = uploadResult.url
      }

      const dataToSave = {
        ...formData,
        image_url: imageUrl,
      }

      if (editingBanner) {
        const { data, error } = await supabase
          .from('category_banners')
          .update(dataToSave)
          .eq('id', editingBanner.id)
          .select()
          .single()

        if (error) throw error
        return data
      } else {
        const { data, error } = await supabase
          .from('category_banners')
          .insert(dataToSave)
          .select()
          .single()

        if (error) throw error
        return data
      }
    },
    onSuccess: () => {
      toast.success(editingBanner ? '배너가 수정되었습니다' : '배너가 추가되었습니다')
      queryClient.invalidateQueries({ queryKey: ['category_banners', categoryId] })
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
        .from('category_banners')
        .delete()
        .eq('id', id)

      if (error) throw error
    },
    onSuccess: () => {
      toast.success('배너가 삭제되었습니다')
      queryClient.invalidateQueries({ queryKey: ['category_banners', categoryId] })
    },
    onError: (error: Error) => {
      toast.error(error.message || '삭제에 실패했습니다')
    },
  })

  // Reorder mutation
  const reorderMutation = useMutation({
    mutationFn: async ({ id, newOrder }: { id: string; newOrder: number }) => {
      const { error } = await supabase
        .from('category_banners')
        .update({ sort_order: newOrder })
        .eq('id', id)

      if (error) throw error
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['category_banners', categoryId] })
    },
  })

  const handleOpenDialog = (banner?: CategoryBanner) => {
    if (banner) {
      setEditingBanner(banner)
      reset({
        benefit_category_id: banner.benefit_category_id,
        title: banner.title,
        subtitle: banner.subtitle,
        image_url: banner.image_url,
        link_type: banner.link_type,
        link_target: banner.link_target,
        sort_order: banner.sort_order,
        is_active: banner.is_active,
      })
      setImagePreview(banner.image_url)
    } else {
      setEditingBanner(null)
      reset({
        benefit_category_id: categoryId,
        title: '',
        subtitle: null,
        image_url: null,
        link_type: 'none',
        link_target: null,
        sort_order: banners.length,
        is_active: true,
      })
      setImagePreview(null)
    }
    setImageFile(null)
    setDialogOpen(true)
  }

  const handleCloseDialog = () => {
    setDialogOpen(false)
    setEditingBanner(null)
    setImageFile(null)
    setImagePreview(null)
    reset()
  }

  const handleImageSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
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

    setImageFile(file)
    setImagePreview(URL.createObjectURL(file))
  }

  const handleDelete = async (banner: CategoryBanner) => {
    if (!window.confirm(`"${banner.title}" 배너를 삭제하시겠습니까?`)) {
      return
    }
    deleteMutation.mutate(banner.id)
  }

  const handleMoveUp = (banner: CategoryBanner, index: number) => {
    if (index === 0) return
    reorderMutation.mutate({ id: banner.id, newOrder: banner.sort_order - 1 })
    reorderMutation.mutate({ id: banners[index - 1].id, newOrder: banners[index - 1].sort_order + 1 })
  }

  const handleMoveDown = (banner: CategoryBanner, index: number) => {
    if (index === banners.length - 1) return
    reorderMutation.mutate({ id: banner.id, newOrder: banner.sort_order + 1 })
    reorderMutation.mutate({ id: banners[index + 1].id, newOrder: banners[index + 1].sort_order - 1 })
  }

  const onSubmit = (data: CategoryBannerFormData) => {
    saveMutation.mutate(data)
  }

  return (
    <Paper sx={{ p: 3, mb: 3 }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2 }}>
        <Typography variant="h6">배너 관리 ({categoryTitle})</Typography>
        <Button
          variant="contained"
          size="small"
          startIcon={<AddIcon />}
          onClick={() => handleOpenDialog()}
        >
          배너 추가
        </Button>
      </Box>

      {isLoading ? (
        <Box sx={{ display: 'flex', justifyContent: 'center', p: 3 }}>
          <CircularProgress />
        </Box>
      ) : (
        <TableContainer>
          <Table size="small">
            <TableHead>
              <TableRow>
                <TableCell width={80}>미리보기</TableCell>
                <TableCell>제목</TableCell>
                <TableCell>부제목</TableCell>
                <TableCell width={100}>링크 타입</TableCell>
                <TableCell width={80}>순서</TableCell>
                <TableCell width={80}>상태</TableCell>
                <TableCell width={150}>작업</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {banners.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={7} align="center">
                    등록된 배너가 없습니다
                  </TableCell>
                </TableRow>
              ) : (
                banners.map((banner, index) => (
                  <TableRow key={banner.id}>
                    <TableCell>
                      {banner.image_url && (
                        <Box
                          component="img"
                          src={banner.image_url}
                          alt={banner.title}
                          sx={{ width: 60, height: 40, objectFit: 'cover', borderRadius: 1 }}
                        />
                      )}
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2" fontWeight="medium">
                        {banner.title}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2" color="text.secondary">
                        {banner.subtitle || '-'}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Chip label={banner.link_type} size="small" />
                    </TableCell>
                    <TableCell>{banner.sort_order}</TableCell>
                    <TableCell>
                      <Chip
                        label={banner.is_active ? '활성' : '비활성'}
                        color={banner.is_active ? 'success' : 'default'}
                        size="small"
                      />
                    </TableCell>
                    <TableCell>
                      <IconButton size="small" onClick={() => handleMoveUp(banner, index)} disabled={index === 0}>
                        <ArrowUpward fontSize="small" />
                      </IconButton>
                      <IconButton size="small" onClick={() => handleMoveDown(banner, index)} disabled={index === banners.length - 1}>
                        <ArrowDownward fontSize="small" />
                      </IconButton>
                      <IconButton size="small" onClick={() => handleOpenDialog(banner)}>
                        <EditIcon fontSize="small" />
                      </IconButton>
                      <IconButton size="small" color="error" onClick={() => handleDelete(banner)}>
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
      <Dialog open={dialogOpen} onClose={handleCloseDialog} maxWidth="md" fullWidth>
        <DialogTitle>{editingBanner ? '배너 수정' : '배너 추가'}</DialogTitle>
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
                  name="subtitle"
                  control={control}
                  render={({ field }) => (
                    <TextField
                      {...field}
                      value={field.value || ''}
                      fullWidth
                      label="부제목 (선택)"
                    />
                  )}
                />
              </Grid>

              <Grid item xs={12}>
                <Typography variant="body2" gutterBottom>
                  배너 이미지 업로드
                </Typography>
                {imagePreview && (
                  <Paper sx={{ p: 2, mb: 1, display: 'inline-block' }}>
                    <img
                      src={imagePreview}
                      alt="Banner preview"
                      style={{ maxWidth: '100%', maxHeight: 200, objectFit: 'contain' }}
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
                    accept="image/*"
                    onChange={handleImageSelect}
                  />
                </Button>
                <Typography variant="caption" color="text.secondary" display="block" mt={1}>
                  이미지 파일, 최대 5MB
                </Typography>
              </Grid>

              <Grid item xs={6}>
                <Controller
                  name="link_type"
                  control={control}
                  render={({ field }) => (
                    <FormControl fullWidth>
                      <InputLabel>링크 타입</InputLabel>
                      <Select {...field} label="링크 타입">
                        <MenuItem value="none">없음</MenuItem>
                        <MenuItem value="internal">앱 내부</MenuItem>
                        <MenuItem value="external">외부 URL</MenuItem>
                      </Select>
                    </FormControl>
                  )}
                />
              </Grid>

              <Grid item xs={6}>
                <Controller
                  name="link_target"
                  control={control}
                  render={({ field }) => (
                    <TextField
                      {...field}
                      value={field.value || ''}
                      fullWidth
                      label="링크 경로/URL"
                    />
                  )}
                />
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
              {editingBanner ? '수정' : '추가'}
            </Button>
          </DialogActions>
        </form>
      </Dialog>
    </Paper>
  )
}
