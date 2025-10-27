import { useNavigate } from 'react-router-dom'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Box, Button, Paper, IconButton, CircularProgress, Typography } from '@mui/material'
import { DataGrid } from '@mui/x-data-grid'
import type { GridColDef } from '@mui/x-data-grid'
import { Add as AddIcon, Edit as EditIcon, Delete as DeleteIcon } from '@mui/icons-material'
import toast from 'react-hot-toast'
import { fetchCategories, deleteCategory } from '@/api/categories'

export default function CategoryList() {
  const navigate = useNavigate()
  const queryClient = useQueryClient()

  const { data: categories, isLoading } = useQuery({
    queryKey: ['categories'],
    queryFn: fetchCategories,
    staleTime: 0,
    refetchOnWindowFocus: true,
  })

  const deleteMutation = useMutation({
    mutationFn: deleteCategory,
    onMutate: async (deletedId) => {
      // Cancel outgoing refetches
      await queryClient.cancelQueries({ queryKey: ['categories'] })

      // Snapshot previous value
      const previousCategories = queryClient.getQueryData(['categories'])

      // Optimistically update to the new value
      queryClient.setQueryData(['categories'], (old: any) => {
        return old?.filter((cat: any) => cat.id !== deletedId)
      })

      // Return context with previous value
      return { previousCategories }
    },
    onError: (error: Error, _deletedId, context: any) => { // ✅ FIXED: Prefixed unused param with _
      // Rollback on error
      queryClient.setQueryData(['categories'], context.previousCategories)
      console.error('❌ Category deletion error:', error)
      toast.error(`삭제에 실패했습니다: ${error.message}`)
    },
    onSuccess: () => {
      toast.success('카테고리가 삭제되었습니다')
    },
    onSettled: () => {
      // Refetch in background to ensure consistency
      queryClient.invalidateQueries({ queryKey: ['categories'] })
    },
  })

  const columns: GridColDef[] = [
    { field: 'title', headerName: '제목', flex: 1 },
    { field: 'description', headerName: '설명', flex: 2 },
    { field: 'min_age', headerName: '최소 나이', width: 100 },
    { field: 'max_age', headerName: '최대 나이', width: 100 },
    { field: 'sort_order', headerName: '정렬 순서', width: 100 },
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
            onClick={() => navigate(`/categories/${params.row.id}/edit`)}
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
        <Typography variant="h4">연령 카테고리</Typography>
        <Button
          variant="contained"
          startIcon={<AddIcon />}
          onClick={() => navigate('/categories/new')}
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
    </Box>
  )
}
