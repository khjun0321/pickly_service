/**
 * Program Manager Component (v8.1)
 * Manages benefit_programs (프로그램 관리)
 * Replaces the old AnnouncementTypeManager
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
import type { BenefitProgram, BenefitProgramFormData } from '@/types/benefit'

interface ProgramManagerProps {
  categoryId: string
  categoryTitle: string
}

const programSchema = z.object({
  benefit_category_id: z.string(),
  title: z.string().min(1, '프로그램명을 입력하세요'),
  description: z.string().nullable(),
  icon_url: z.string().nullable(),
  sort_order: z.number().int().min(0),
  is_active: z.boolean(),
})

export default function ProgramManager({ categoryId, categoryTitle }: ProgramManagerProps) {
  const queryClient = useQueryClient()
  const [dialogOpen, setDialogOpen] = useState(false)
  const [editingProgram, setEditingProgram] = useState<BenefitProgram | null>(null)
  const [iconFile, setIconFile] = useState<File | null>(null)
  const [iconPreview, setIconPreview] = useState<string | null>(null)

  // Fetch programs
  const { data: programs = [], isLoading } = useQuery({
    queryKey: ['benefit_programs', categoryId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('benefit_programs')
        .select('*')
        .eq('benefit_category_id', categoryId)
        .order('sort_order', { ascending: true })

      if (error) throw error
      return data as BenefitProgram[]
    },
  })

  const {
    control,
    handleSubmit,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<BenefitProgramFormData>({
    resolver: zodResolver(programSchema),
    defaultValues: {
      benefit_category_id: categoryId,
      title: '',
      description: null,
      icon_url: null,
      sort_order: 0,
      is_active: true,
    },
  })

  // Save mutation
  const saveMutation = useMutation({
    mutationFn: async (formData: BenefitProgramFormData) => {
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

      if (editingProgram) {
        const { data, error } = await supabase
          .from('benefit_programs')
          .update(dataToSave)
          .eq('id', editingProgram.id)
          .select()
          .single()

        if (error) throw error
        return data
      } else {
        const { data, error } = await supabase
          .from('benefit_programs')
          .insert(dataToSave)
          .select()
          .single()

        if (error) throw error
        return data
      }
    },
    onSuccess: () => {
      toast.success(editingProgram ? '프로그램이 수정되었습니다' : '프로그램이 추가되었습니다')
      queryClient.invalidateQueries({ queryKey: ['benefit_programs', categoryId] })
      handleCloseDialog()
    },
    onError: (error: Error) => {
      toast.error(error.message || '저장에 실패했습니다')
    },
  })

  // Delete mutation
  const deleteMutation = useMutation({
    mutationFn: async (id: string) => {
      const { error} = await supabase
        .from('benefit_programs')
        .delete()
        .eq('id', id)

      if (error) throw error
    },
    onSuccess: () => {
      toast.success('프로그램이 삭제되었습니다')
      queryClient.invalidateQueries({ queryKey: ['benefit_programs', categoryId] })
    },
    onError: (error: Error) => {
      toast.error(error.message || '삭제에 실패했습니다')
    },
  })

  // Reorder mutation
  const reorderMutation = useMutation({
    mutationFn: async ({ id, newOrder }: { id: string; newOrder: number }) => {
      const { error } = await supabase
        .from('benefit_programs')
        .update({ sort_order: newOrder })
        .eq('id', id)

      if (error) throw error
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['benefit_programs', categoryId] })
    },
  })

  const handleOpenDialog = (program?: BenefitProgram) => {
    if (program) {
      setEditingProgram(program)
      reset({
        benefit_category_id: program.benefit_category_id,
        title: program.title,
        description: program.description,
        icon_url: program.icon_url,
        sort_order: program.sort_order,
        is_active: program.is_active,
      })
      setIconPreview(program.icon_url)
    } else {
      setEditingProgram(null)
      reset({
        benefit_category_id: categoryId,
        title: '',
        description: null,
        icon_url: null,
        sort_order: programs.length,
        is_active: true,
      })
      setIconPreview(null)
    }
    setIconFile(null)
    setDialogOpen(true)
  }

  const handleCloseDialog = () => {
    setDialogOpen(false)
    setEditingProgram(null)
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

  const handleDelete = async (program: BenefitProgram) => {
    if (!window.confirm(`"${program.title}" 프로그램을 삭제하시겠습니까?`)) {
      return
    }
    deleteMutation.mutate(program.id)
  }

  const handleMoveUp = (program: BenefitProgram, index: number) => {
    if (index === 0) return
    reorderMutation.mutate({ id: program.id, newOrder: program.sort_order - 1 })
    reorderMutation.mutate({ id: programs[index - 1].id, newOrder: programs[index - 1].sort_order + 1 })
  }

  const handleMoveDown = (program: BenefitProgram, index: number) => {
    if (index === programs.length - 1) return
    reorderMutation.mutate({ id: program.id, newOrder: program.sort_order + 1 })
    reorderMutation.mutate({ id: programs[index + 1].id, newOrder: programs[index + 1].sort_order - 1 })
  }

  const onSubmit = (data: BenefitProgramFormData) => {
    saveMutation.mutate(data)
  }

  return (
    <Paper sx={{ p: 3, mb: 3 }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2 }}>
        <Typography variant="h6">프로그램 관리 ({categoryTitle})</Typography>
        <Button
          variant="contained"
          size="small"
          startIcon={<AddIcon />}
          onClick={() => handleOpenDialog()}
        >
          프로그램 추가
        </Button>
      </Box>

      <Typography variant="body2" color="text.secondary" gutterBottom>
        예: 청년, 신혼부부, 고령자 등 대상 프로그램
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
                <TableCell>프로그램명</TableCell>
                <TableCell>설명</TableCell>
                <TableCell width={80}>순서</TableCell>
                <TableCell width={80}>상태</TableCell>
                <TableCell width={150}>작업</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {programs.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={6} align="center">
                    등록된 프로그램이 없습니다
                  </TableCell>
                </TableRow>
              ) : (
                programs.map((program, index) => (
                  <TableRow key={program.id}>
                    <TableCell>
                      {program.icon_url && (
                        <Box
                          component="img"
                          src={program.icon_url}
                          alt={program.title}
                          sx={{ width: 32, height: 32, objectFit: 'contain' }}
                        />
                      )}
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2" fontWeight="medium">
                        {program.title}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2" color="text.secondary">
                        {program.description || '-'}
                      </Typography>
                    </TableCell>
                    <TableCell>{program.sort_order}</TableCell>
                    <TableCell>
                      <Chip
                        label={program.is_active ? '활성' : '비활성'}
                        color={program.is_active ? 'success' : 'default'}
                        size="small"
                      />
                    </TableCell>
                    <TableCell>
                      <IconButton size="small" onClick={() => handleMoveUp(program, index)} disabled={index === 0}>
                        <ArrowUpward fontSize="small" />
                      </IconButton>
                      <IconButton size="small" onClick={() => handleMoveDown(program, index)} disabled={index === programs.length - 1}>
                        <ArrowDownward fontSize="small" />
                      </IconButton>
                      <IconButton size="small" onClick={() => handleOpenDialog(program)}>
                        <EditIcon fontSize="small" />
                      </IconButton>
                      <IconButton size="small" color="error" onClick={() => handleDelete(program)}>
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
        <DialogTitle>{editingProgram ? '프로그램 수정' : '프로그램 추가'}</DialogTitle>
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
                      label="프로그램명"
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
                      placeholder="프로그램 대상 및 특징 설명"
                    />
                  )}
                />
              </Grid>

              <Grid item xs={12}>
                <Typography variant="body2" gutterBottom>
                  프로그램 아이콘 (선택)
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
              {editingProgram ? '수정' : '추가'}
            </Button>
          </DialogActions>
        </form>
      </Dialog>
    </Paper>
  )
}
