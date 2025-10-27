import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import {
  Box,
  Paper,
  Tabs,
  Tab,
  Typography,
  CircularProgress,
  Button,
} from '@mui/material'
import { Add as AddIcon } from '@mui/icons-material'
import toast from 'react-hot-toast'
import { fetchBenefitCategories } from '@/api/benefits'
import { deleteAnnouncement as deleteBenefitAnnouncement } from '@/api/announcements'
import BenefitBannerManager from '@/components/benefits/BenefitBannerManager'
import { AnnouncementTable } from '@/components/benefits/AnnouncementTable'

interface TabPanelProps {
  children?: React.ReactNode
  index: number
  value: number
}

function TabPanel(props: TabPanelProps) {
  const { children, value, index, ...other } = props

  return (
    <div
      role="tabpanel"
      hidden={value !== index}
      id={`benefit-tabpanel-${index}`}
      aria-labelledby={`benefit-tab-${index}`}
      {...other}
    >
      {value === index && <Box sx={{ py: 3 }}>{children}</Box>}
    </div>
  )
}

export default function BenefitManagementPage() {
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const [activeTab, setActiveTab] = useState(0)

  const { data: categories, isLoading } = useQuery({
    queryKey: ['benefit-categories'],
    queryFn: fetchBenefitCategories,
  })

  const deleteMutation = useMutation({
    mutationFn: deleteBenefitAnnouncement,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['benefit-announcements'] })
      toast.success('공고가 삭제되었습니다')
    },
    onError: (error: Error) => {
      toast.error(`삭제에 실패했습니다: ${error.message}`)
    },
  })

  const handleTabChange = (_: React.SyntheticEvent, newValue: number) => {
    setActiveTab(newValue)
  }

  const handleCreateAnnouncement = () => {
    const currentCategory = categories?.[activeTab]
    if (currentCategory) {
      navigate(`/benefits/announcements/new?categoryId=${currentCategory.id}`)
    } else {
      navigate('/benefits/announcements/new')
    }
  }

  const handleEdit = (id: string) => {
    navigate(`/benefits/announcements/${id}/edit`)
  }

  const handleDelete = (id: string) => {
    deleteMutation.mutate(id)
  }

  if (isLoading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', mt: 4 }}>
        <CircularProgress />
      </Box>
    )
  }

  if (!categories || categories.length === 0) {
    return (
      <Box>
        <Typography variant="h4" gutterBottom>
          혜택 관리
        </Typography>
        <Paper sx={{ p: 4, textAlign: 'center' }}>
          <Typography variant="body1" color="text.secondary">
            등록된 혜택 카테고리가 없습니다.
          </Typography>
          <Button
            variant="contained"
            sx={{ mt: 2 }}
            onClick={() => navigate('/benefits/categories')}
          >
            카테고리 관리로 이동
          </Button>
        </Paper>
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
          mb: 3,
        }}
      >
        <Typography variant="h4">혜택 관리</Typography>
        <Button
          variant="contained"
          startIcon={<AddIcon />}
          onClick={handleCreateAnnouncement}
        >
          새 공고
        </Button>
      </Box>

      <Paper>
        <Tabs
          value={activeTab}
          onChange={handleTabChange}
          variant="scrollable"
          scrollButtons="auto"
          sx={{
            borderBottom: 1,
            borderColor: 'divider',
          }}
        >
          {categories.map((category, index) => (
            <Tab
              key={category.id}
              label={category.name}
              id={`benefit-tab-${index}`}
              aria-controls={`benefit-tabpanel-${index}`}
            />
          ))}
        </Tabs>

        {categories.map((category, index) => (
          <TabPanel value={activeTab} index={index} key={category.id}>
            <Box sx={{ px: 3 }}>
              <Box sx={{ mb: 4 }}>
                <Typography variant="h6" gutterBottom>
                  배너 관리
                </Typography>
                <BenefitBannerManager category={category} />
              </Box>

              <Box>
                <Typography variant="h6" gutterBottom>
                  공고 목록
                </Typography>
                <AnnouncementTable
                  categoryId={category.id}
                  onEdit={handleEdit}
                  onDelete={handleDelete}
                />
              </Box>
            </Box>
          </TabPanel>
        ))}
      </Paper>
    </Box>
  )
}
