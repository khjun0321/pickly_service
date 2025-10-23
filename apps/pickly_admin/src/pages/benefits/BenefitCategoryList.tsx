import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import {
  Box,
  Button,
  Paper,
  IconButton,
  CircularProgress,
  Typography,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Switch,
  FormControlLabel,
} from '@mui/material'
import { DataGrid } from '@mui/x-data-grid'
import type { GridColDef } from '@mui/x-data-grid'
import { Add as AddIcon, Edit as EditIcon, Delete as DeleteIcon } from '@mui/icons-material'
import toast from 'react-hot-toast'
import { useForm, Controller } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import {
  fetchBenefitCategories,
  createBenefitCategory,
  updateBenefitCategory,
  deleteBenefitCategory,
} from '@/api/benefits'
import type { BenefitCategory } from '@/types/database'

const benefitCategorySchema = z.object({
  name: z.string().min(1, '카테고리 이름을 입력해주세요'),
  description: z.string().nullable().optional(),
  icon: z.string().nullable().optional(),
  color: z.string().nullable().optional(),
  sort_order: z.number().min(0, '표시 순서는 0 이상이어야 합니다'),
  is_active: z.boolean(),
})

type BenefitCategoryFormData = z.infer<typeof benefitCategorySchema>

export default function BenefitCategoryList() {
  const queryClient = useQueryClient()
  const [dialogOpen, setDialogOpen] = useState(false)
  const [editingCategory, setEditingCategory] = useState<BenefitCategory | null>(null)

  const {
    control,
    handleSubmit,
    reset,
    formState: { errors },
  } = useForm<BenefitCategoryFormData>({
    resolver: zodResolver(benefitCategorySchema),
    defaultValues: {
      name: '',
      description: '',
      icon: '',
      color: '',
      sort_order: 0,
      is_active: true,
    },
  })

  const { data: categories, isLoading } = useQuery({
    queryKey: ['benefit-categories'],
    queryFn: fetchBenefitCategories,
  })

  const createMutation = useMutation({
    mutationFn: createBenefitCategory,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['benefit-categories'] })
      toast.success('카테고리가 생성되었습니다')
      handleCloseDialog()
    },
    onError: (error: Error) => {
      toast.error(error.message || '생성에 실패했습니다')
    },
  })

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: Partial<BenefitCategory> }) =>
      updateBenefitCategory(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['benefit-categories'] })
      toast.success('카테고리가 수정되었습니다')
      handleCloseDialog()
    },
    onError: (error: Error) => {
      toast.error(error.message || '수정에 실패했습니다')
    },
  })

  const deleteMutation = useMutation({
    mutationFn: deleteBenefitCategory,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['benefit-categories'] })
      toast.success('카테고리가 삭제되었습니다')
    },
    onError: () => {
      toast.error('삭제에 실패했습니다')
    },
  })

  const handleOpenDialog = (category?: BenefitCategory) => {
    if (category) {
      setEditingCategory(category)
      reset({
        name: category.name,
        description: category.description || '',
        icon: category.icon || '',
        color: category.color || '',
        sort_order: category.sort_order,
        is_active: category.is_active,
      })
    } else {
      setEditingCategory(null)
      reset({
        name: '',
        description: '',
        icon: '',
        color: '',
        sort_order: categories?.length || 0,
        is_active: true,
      })
    }
    setDialogOpen(true)
  }

  const handleCloseDialog = () => {
    setDialogOpen(false)
    setEditingCategory(null)
    reset()
  }

  const onSubmit = (data: BenefitCategoryFormData) => {
    const payload = {
      name: data.name,
      description: data.description || null,
      icon: data.icon || null,
      color: data.color || null,
      sort_order: data.sort_order,
      is_active: data.is_active,
    }

    if (editingCategory) {
      updateMutation.mutate({ id: editingCategory.id, data: payload })
    } else {
      createMutation.mutate(payload)
    }
  }

  const columns: GridColDef[] = [
    { field: 'name', headerName: '카테고리 이름', flex: 1 },
    { field: 'description', headerName: '설명', flex: 2 },
    { field: 'icon', headerName: '아이콘', width: 120 },
    { field: 'color', headerName: '색상', width: 100 },
    { field: 'sort_order', headerName: '표시 순서', width: 120 },
    {
      field: 'is_active',
      headerName: '활성화',
      width: 100,
      renderCell: (params) => (params.value ? '활성' : '비활성'),
    },
    {
      field: 'actions',
      headerName: '작업',
      width: 120,
      sortable: false,
      renderCell: (params) => (
        <>
          <IconButton
            size="small"
            onClick={() => handleOpenDialog(params.row as BenefitCategory)}
          >
            <EditIcon />
          </IconButton>
          <IconButton
            size="small"
            color="error"
            onClick={() => {
              if (confirm('정말 삭제하시겠습니까?')) {
                deleteMutation.mutate(params.row.id)
              }
            }}
          >
            <DeleteIcon />
          </IconButton>
        </>
      ),
    },
  ]

  if (isLoading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', mt: 4 }}>
        <CircularProgress />
      </Box>
    )
  }

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
        <Typography variant="h4">혜택 카테고리</Typography>
        <Button
          variant="contained"
          startIcon={<AddIcon />}
          onClick={() => handleOpenDialog()}
        >
          새 카테고리
        </Button>
      </Box>

      <Paper sx={{ height: 600 }}>
        <DataGrid
          rows={categories || []}
          columns={columns}
          pageSizeOptions={[10, 25, 50]}
          initialState={{
            pagination: {
              paginationModel: { pageSize: 25 },
            },
          }}
        />
      </Paper>

      <Dialog open={dialogOpen} onClose={handleCloseDialog} maxWidth="sm" fullWidth>
        <DialogTitle>
          {editingCategory ? '카테고리 수정' : '새 카테고리'}
        </DialogTitle>
        <form onSubmit={handleSubmit(onSubmit)}>
          <DialogContent>
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
              <Controller
                name="name"
                control={control}
                render={({ field }) => (
                  <TextField
                    {...field}
                    label="카테고리 이름"
                    required
                    error={!!errors.name}
                    helperText={errors.name?.message}
                    fullWidth
                  />
                )}
              />

              <Controller
                name="description"
                control={control}
                render={({ field }) => (
                  <TextField
                    {...field}
                    label="설명"
                    multiline
                    rows={3}
                    fullWidth
                  />
                )}
              />

              <Controller
                name="icon"
                control={control}
                render={({ field }) => (
                  <TextField
                    {...field}
                    label="아이콘"
                    placeholder="예: home, school, work"
                    fullWidth
                  />
                )}
              />

              <Controller
                name="color"
                control={control}
                render={({ field }) => (
                  <TextField
                    {...field}
                    label="색상"
                    placeholder="예: #FF5722"
                    fullWidth
                  />
                )}
              />

              <Controller
                name="sort_order"
                control={control}
                render={({ field }) => (
                  <TextField
                    {...field}
                    label="표시 순서"
                    type="number"
                    required
                    error={!!errors.sort_order}
                    helperText={errors.sort_order?.message}
                    fullWidth
                    onChange={(e) => field.onChange(parseInt(e.target.value, 10))}
                  />
                )}
              />

              <Controller
                name="is_active"
                control={control}
                render={({ field }) => (
                  <FormControlLabel
                    control={
                      <Switch
                        {...field}
                        checked={field.value}
                      />
                    }
                    label="활성화"
                  />
                )}
              />
            </Box>
          </DialogContent>
          <DialogActions>
            <Button onClick={handleCloseDialog}>취소</Button>
            <Button
              type="submit"
              variant="contained"
              disabled={createMutation.isPending || updateMutation.isPending}
            >
              {editingCategory ? '수정' : '생성'}
            </Button>
          </DialogActions>
        </form>
      </Dialog>
    </Box>
  )
}
