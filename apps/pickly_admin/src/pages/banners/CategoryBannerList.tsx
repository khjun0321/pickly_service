import { useState, useMemo } from 'react'
import { useNavigate } from 'react-router-dom'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import {
  Box,
  Button,
  Paper,
  IconButton,
  CircularProgress,
  Typography,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Chip,
  Stack,
} from '@mui/material'
import { DataGrid } from '@mui/x-data-grid'
import type { GridColDef, GridValueGetterParams } from '@mui/x-data-grid'
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  DragIndicator as DragIcon,
} from '@mui/icons-material'
import toast from 'react-hot-toast'
import {
  fetchAllBanners,
  deleteBanner,
  reorderBanners,
} from '@/api/banners'
import { fetchBenefitCategories } from '@/api/categories'

export default function CategoryBannerList() {
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const [categoryFilter, setCategoryFilter] = useState('all')
  const [draggedId, setDraggedId] = useState<string | null>(null)

  const { data: banners, isLoading: bannersLoading } = useQuery({
    queryKey: ['category-banners'],
    queryFn: fetchAllBanners,
  })

  const { data: categories, isLoading: categoriesLoading } = useQuery({
    queryKey: ['benefit-categories'],
    queryFn: fetchBenefitCategories,
  })

  const deleteMutation = useMutation({
    mutationFn: deleteBanner,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['category-banners'] })
      toast.success('배너가 삭제되었습니다')
    },
    onError: (error: Error) => {
      toast.error(`삭제에 실패했습니다: ${error.message}`)
    },
  })

  const reorderMutation = useMutation({
    mutationFn: reorderBanners,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['category-banners'] })
      toast.success('배너 순서가 변경되었습니다')
    },
    onError: (error: Error) => {
      toast.error(`순서 변경에 실패했습니다: ${error.message}`)
    },
  })

  const filteredBanners = useMemo(() => {
    if (!banners) return []

    return banners
      .filter((banner) => {
        if (categoryFilter === 'all') return true
        return banner.category_id === categoryFilter
      })
      .sort((a, b) => a.display_order - b.display_order)
  }, [banners, categoryFilter])

  const handleDelete = (id: string, title: string) => {
    if (confirm(`"${title}" 배너를 삭제하시겠습니까?`)) {
      deleteMutation.mutate(id)
    }
  }

  const handleDragStart = (id: string) => {
    setDraggedId(id)
  }

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault()
  }

  const handleDrop = async (targetId: string) => {
    if (!draggedId || draggedId === targetId) return

    const currentBanners = filteredBanners
    const draggedIndex = currentBanners.findIndex((b) => b.id === draggedId)
    const targetIndex = currentBanners.findIndex((b) => b.id === targetId)

    if (draggedIndex === -1 || targetIndex === -1) return

    // Create new order
    const reordered = [...currentBanners]
    const [removed] = reordered.splice(draggedIndex, 1)
    reordered.splice(targetIndex, 0, removed)

    // Update display_order
    const updates = reordered.map((banner, index) => ({
      id: banner.id,
      display_order: index + 1,
    }))

    setDraggedId(null)
    await reorderMutation.mutateAsync(updates)
  }

  const columns: GridColDef[] = [
    {
      field: 'drag',
      headerName: '',
      width: 50,
      sortable: false,
      renderCell: (params) => (
        <Box
          draggable
          onDragStart={() => handleDragStart(params.row.id)}
          onDragOver={handleDragOver}
          onDrop={() => handleDrop(params.row.id)}
          sx={{ cursor: 'grab', display: 'flex', alignItems: 'center' }}
        >
          <DragIcon />
        </Box>
      ),
    },
    {
      field: 'display_order',
      headerName: '순서',
      width: 80,
      align: 'center',
      headerAlign: 'center',
    },
    {
      field: 'title',
      headerName: '제목',
      flex: 2,
      minWidth: 200,
      renderCell: (params) => (
        <Box>
          <Typography variant="body2" sx={{ fontWeight: 500 }}>
            {params.value}
          </Typography>
          {params.row.subtitle && (
            <Typography variant="caption" color="text.secondary" sx={{ display: 'block' }}>
              {params.row.subtitle}
            </Typography>
          )}
        </Box>
      ),
    },
    {
      field: 'category_name',
      headerName: '카테고리',
      flex: 1,
      minWidth: 120,
      valueGetter: (params: GridValueGetterParams) => {
        const cat = categories?.find((c: any) => c.id === params.row.category_id)
        return cat?.title || '-'
      },
    },
    {
      field: 'background_color',
      headerName: '배경색',
      width: 100,
      renderCell: (params) => (
        <Box
          sx={{
            width: 40,
            height: 24,
            backgroundColor: params.value || '#E3F2FD',
            border: '1px solid #ddd',
            borderRadius: 1,
          }}
        />
      ),
    },
    {
      field: 'is_active',
      headerName: '상태',
      width: 100,
      renderCell: (params) => (
        <Chip
          label={params.value ? '활성' : '비활성'}
          color={params.value ? 'success' : 'default'}
          size="small"
        />
      ),
    },
    {
      field: 'actions',
      headerName: '작업',
      width: 120,
      sortable: false,
      renderCell: (params) => (
        <Box>
          <IconButton
            size="small"
            onClick={() => navigate(`/banners/${params.row.id}/edit`)}
            title="수정"
          >
            <EditIcon />
          </IconButton>
          <IconButton
            size="small"
            color="error"
            onClick={() => handleDelete(params.row.id, params.row.title)}
            title="삭제"
          >
            <DeleteIcon />
          </IconButton>
        </Box>
      ),
    },
  ]

  if (bannersLoading || categoriesLoading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', mt: 4 }}>
        <CircularProgress />
      </Box>
    )
  }

  return (
    <Box>
      <Box
        sx={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          mb: 2,
        }}
      >
        <Typography variant="h4">카테고리 배너</Typography>
        <Button
          variant="contained"
          startIcon={<AddIcon />}
          onClick={() => navigate('/banners/new')}
        >
          새 배너
        </Button>
      </Box>

      <Paper sx={{ p: 2, mb: 2 }}>
        <Stack direction="row" spacing={2} alignItems="center">
          <FormControl sx={{ minWidth: 200 }}>
            <InputLabel id="category-filter-label">카테고리</InputLabel>
            <Select
              labelId="category-filter-label"
              id="category-filter"
              value={categoryFilter}
              label="카테고리"
              onChange={(e) => setCategoryFilter(e.target.value)}
              size="small"
            >
              <MenuItem value="all">전체</MenuItem>
              {categories?.map((category) => (
                <MenuItem key={category.id} value={category.id}>
                  {category.title}
                </MenuItem>
              ))}
            </Select>
          </FormControl>

          <Box sx={{ flexGrow: 1 }} />

          <Typography variant="body2" sx={{ alignSelf: 'center' }}>
            총 <strong>{filteredBanners.length}</strong>개 배너
          </Typography>
        </Stack>
      </Paper>

      <Paper sx={{ height: 650 }}>
        <DataGrid
          rows={filteredBanners}
          columns={columns}
          pageSizeOptions={[10, 25, 50]}
          initialState={{
            pagination: {
              paginationModel: { pageSize: 25 },
            },
          }}
          disableRowSelectionOnClick
          sx={{
            '& .MuiDataGrid-cell': {
              borderBottom: '1px solid rgba(224, 224, 224, 1)',
            },
            '& .MuiDataGrid-columnHeaders': {
              backgroundColor: 'rgba(0, 0, 0, 0.04)',
              borderBottom: '2px solid rgba(224, 224, 224, 1)',
            },
          }}
        />
      </Paper>

      <Box sx={{ mt: 2, p: 2, bgcolor: 'info.light', borderRadius: 1 }}>
        <Typography variant="body2" color="info.dark">
          💡 <strong>팁:</strong> 드래그 아이콘(⋮⋮)을 드래그해서 배너 순서를 변경할 수 있습니다.
        </Typography>
      </Box>
    </Box>
  )
}
