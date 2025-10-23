import { useQuery } from '@tanstack/react-query'
import { Box, Grid, Paper, Typography, CircularProgress } from '@mui/material'
import { People as PeopleIcon, Category as CategoryIcon } from '@mui/icons-material'
import { fetchUsers } from '@/api/users'
import { fetchCategories } from '@/api/categories'

function StatCard({ title, value, icon }: { title: string; value: number; icon: React.ReactNode }) {
  return (
    <Paper sx={{ p: 3 }}>
      <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <Box>
          <Typography variant="body2" color="text.secondary" gutterBottom>
            {title}
          </Typography>
          <Typography variant="h4">{value}</Typography>
        </Box>
        <Box sx={{ color: 'primary.main', fontSize: 48 }}>{icon}</Box>
      </Box>
    </Paper>
  )
}

export default function Dashboard() {
  const { data: users, isLoading: usersLoading } = useQuery({
    queryKey: ['users'],
    queryFn: fetchUsers,
  })

  const { data: categories, isLoading: categoriesLoading } = useQuery({
    queryKey: ['categories'],
    queryFn: fetchCategories,
  })

  if (usersLoading || categoriesLoading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', mt: 4 }}>
        <CircularProgress />
      </Box>
    )
  }

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        대시보드
      </Typography>
      <Grid container spacing={3} sx={{ mt: 2 }}>
        <Grid item xs={12} sm={6} md={4}>
          <StatCard title="전체 사용자" value={users?.length || 0} icon={<PeopleIcon fontSize="inherit" />} />
        </Grid>
        <Grid item xs={12} sm={6} md={4}>
          <StatCard title="연령 카테고리" value={categories?.length || 0} icon={<CategoryIcon fontSize="inherit" />} />
        </Grid>
      </Grid>
    </Box>
  )
}
