/**
 * Announcement Type Manager Component
 * Manages announcement types (filters) for each benefit category
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
  ArrowUpward,
  ArrowDownward,
} from '@mui/icons-material'
import { useForm, Controller } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import toast from 'react-hot-toast'
import { supabase } from '@/lib/supabase'
import type { AnnouncementType, AnnouncementTypeFormData } from '@/types/benefit'

interface AnnouncementTypeManagerProps {
  categoryId: string
  categoryTitle: string
}

const typeSchema = z.object({
  benefit_category_id: z.string(),
  title: z.string().min(1, '제목을 입력하세요'),
  description: z.string().nullable(),
  sort_order: z.number().int().min(0),
  is_active: z.boolean(),
})

export default function AnnouncementTypeManager({ categoryId, categoryTitle }: AnnouncementTypeManagerProps) {
  const queryClient = useQueryClient()
  const [dialogOpen, setDialogOpen] = useState(false)
  const [editingType, setEditingType] = useState<AnnouncementType | null>(null)

  // Fetch types
  const { data: types = [], isLoading } = useQuery({
    queryKey: ['announcement_types', categoryId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('announcement_types')
        .select('*')
        .eq('benefit_category_id', categoryId)
        .order('sort_order', { ascending: true })

      if (error) throw error
      return data as AnnouncementType[]
    },
  })

  const {
    control,
    handleSubmit,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<AnnouncementTypeFormData>({
    resolver: zodResolver(typeSchema),
    defaultValues: {
      benefit_category_id: categoryId,
      title: '',
      description: null,
      sort_order: 0,
      is_active: true,
    },
  })

  // Save mutation
  const saveMutation = useMutation({
    mutationFn: async (formData: AnnouncementTypeFormData) => {
      if (editingType) {
        const { data, error } = await supabase
          .from('announcement_types')
          .update(formData)
          .eq('id', editingType.id)
          .select()
          .single()

        if (error) throw error
        return data
      } else {
        const { data, error } = await supabase
          .from('announcement_types')
          .insert(formData)
          .select()
          .single()

        if (error) throw error
        return data
      }
    },
    onSuccess: () => {
      toast.success(editingType ? '공고유형이 수정되었습니다' : '공고유형이 추가되었습니다')
      queryClient.invalidateQueries({ queryKey: ['announcement_types', categoryId] })
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
        .from('announcement_types')
        .delete()
        .eq('id', id)

      if (error) throw error
    },
    onSuccess: () => {
      toast.success('공고유형이 삭제되었습니다')
      queryClient.invalidateQueries({ queryKey: ['announcement_types', categoryId] })
    },
    onError: (error: Error) => {
      toast.error(error.message || '삭제에 실패했습니다')
    },
  })

  // Toggle active mutation
  const toggleActiveMutation = useMutation({
    mutationFn: async ({ id, is_active }: { id: string; is_active: boolean }) => {
      const { error } = await supabase
        .from('announcement_types')
        .update({ is_active })
        .eq('id', id)

      if (error) throw error
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['announcement_types', categoryId] })
    },
  })

  // Reorder mutation
  const reorderMutation = useMutation({
    mutationFn: async ({ id, newOrder }: { id: string; newOrder: number }) => {
      const { error } = await supabase
        .from('announcement_types')
        .update({ sort_order: newOrder })
        .eq('id', id)

      if (error) throw error
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['announcement_types', categoryId] })
    },
  })

  const handleOpenDialog = (type?: AnnouncementType) => {
    if (type) {
      setEditingType(type)
      reset({
        benefit_category_id: type.benefit_category_id,
        title: type.title,
        description: type.description,
        sort_order: type.sort_order,
        is_active: type.is_active,
      })
    } else {
      setEditingType(null)
      reset({
        benefit_category_id: categoryId,
        title: '',
        description: null,
        sort_order: types.length,
        is_active: true,
      })
    }
    setDialogOpen(true)
  }

  const handleCloseDialog = () => {
    setDialogOpen(false)
    setEditingType(null)
    reset()
  }

  const handleDelete = async (type: AnnouncementType) => {
    if (!window.confirm(`"${type.title}" 공고유형을 삭제하시겠습니까?`)) {
      return
    }
    deleteMutation.mutate(type.id)
  }

  const handleToggleActive = (type: AnnouncementType) => {
    toggleActiveMutation.mutate({ id: type.id, is_active: !type.is_active })
  }

  const handleMoveUp = (type: AnnouncementType, index: number) => {
    if (index === 0) return
    reorderMutation.mutate({ id: type.id, newOrder: type.sort_order - 1 })
    reorderMutation.mutate({ id: types[index - 1].id, newOrder: types[index - 1].sort_order + 1 })
  }

  const handleMoveDown = (type: AnnouncementType, index: number) => {
    if (index === types.length - 1) return
    reorderMutation.mutate({ id: type.id, newOrder: type.sort_order + 1 })
    reorderMutation.mutate({ id: types[index + 1].id, newOrder: types[index + 1].sort_order - 1 })
  }

  const onSubmit = (data: AnnouncementTypeFormData) => {
    saveMutation.mutate(data)
  }

  return (
    <Paper sx={{ p: 3, mb: 3 }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2 }}>
        <Typography variant="h6">공고 유형 관리 ({categoryTitle})</Typography>
        <Button
          variant="contained"
          size="small"
          startIcon={<AddIcon />}
          onClick={() => handleOpenDialog()}
        >
          유형 추가
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
                <TableCell>유형명</TableCell>
                <TableCell>설명</TableCell>
                <TableCell width={80}>순서</TableCell>
                <TableCell width={80}>상태</TableCell>
                <TableCell width={150}>작업</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {types.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={5} align="center">
                    등록된 공고유형이 없습니다
                  </TableCell>
                </TableRow>
              ) : (
                types.map((type, index) => (
                  <TableRow key={type.id}>
                    <TableCell>
                      <Typography variant="body2" fontWeight="medium">
                        {type.title}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2" color="text.secondary">
                        {type.description || '-'}
                      </Typography>
                    </TableCell>
                    <TableCell>{type.sort_order}</TableCell>
                    <TableCell>
                      <Switch
                        size="small"
                        checked={type.is_active}
                        onChange={() => handleToggleActive(type)}
                      />
                    </TableCell>
                    <TableCell>
                      <IconButton size="small" onClick={() => handleMoveUp(type, index)} disabled={index === 0}>
                        <ArrowUpward fontSize="small" />
                      </IconButton>
                      <IconButton size="small" onClick={() => handleMoveDown(type, index)} disabled={index === types.length - 1}>
                        <ArrowDownward fontSize="small" />
                      </IconButton>
                      <IconButton size="small" onClick={() => handleOpenDialog(type)}>
                        <EditIcon fontSize="small" />
                      </IconButton>
                      <IconButton size="small" color="error" onClick={() => handleDelete(type)}>
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
        <DialogTitle>{editingType ? '공고유형 수정' : '공고유형 추가'}</DialogTitle>
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
                      label="유형명"
                      error={!!errors.title}
                      helperText={errors.title?.message}
                      placeholder="예: 청년, 신혼부부, 고령자"
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
              {editingType ? '수정' : '추가'}
            </Button>
          </DialogActions>
        </form>
      </Dialog>
    </Paper>
  )
}
