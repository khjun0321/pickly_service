import { useQuery } from '@tanstack/react-query'
import { Box, Typography, Paper, CircularProgress } from '@mui/material'
import { DataGrid } from '@mui/x-data-grid'
import type { GridColDef } from '@mui/x-data-grid'
import { fetchUsers } from '@/api/users'

export default function UserList() {
  const { data: users, isLoading } = useQuery({
    queryKey: ['users'],
    queryFn: fetchUsers,
  })

  const columns: GridColDef[] = [
    { field: 'name', headerName: '이름', flex: 1 },
    { field: 'age', headerName: '나이', width: 100 },
    { field: 'gender', headerName: '성별', width: 100 },
    { field: 'region_sido', headerName: '시/도', width: 120 },
    { field: 'region_sigungu', headerName: '시/군/구', width: 120 },
    {
      field: 'onboarding_completed',
      headerName: '온보딩 완료',
      width: 120,
      renderCell: (params) => (params.value ? '완료' : '미완료'),
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
      <Typography variant="h4" gutterBottom>
        사용자 목록
      </Typography>
      <Paper sx={{ mt: 2, height: 600 }}>
        <DataGrid
          rows={users || []}
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
