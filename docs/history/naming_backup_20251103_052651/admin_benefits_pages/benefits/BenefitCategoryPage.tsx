import { useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
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
import { Download as DownloadIcon } from '@mui/icons-material'
import { supabase } from '@/lib/supabase'
import {
  deleteAnnouncement as deleteAnnouncement,
  fetchLHAnnouncements
} from '@/api/announcements'
import { AnnouncementTable } from '@/components/benefits/AnnouncementTable'
import MultiBannerManager from '@/components/benefits/MultiBannerManager'
import type { BenefitCategory } from '@/types/database'

interface TabPanelProps {
  children?: React.ReactNode
  index: number
  value: number
}

function TabPanel(props: TabPanelProps) {
  const { children, value, index, ...other } = props

  if (value !== index) {
    return null
  }

  return (
    <div
      role="tabpanel"
      id={`benefit-tabpanel-${index}`}
      aria-labelledby={`benefit-tab-${index}`}
      {...other}
    >
      <Box sx={{ py: 3 }}>{children}</Box>
    </div>
  )
}

const CATEGORY_NAMES: Record<string, string> = {
  popular: '인기',
  housing: '주거',
  education: '교육',
  health: '건강',
  transportation: '교통',
  welfare: '복지',
  employment: '취업',
  support: '지원',
  culture: '문화',
}

export default function BenefitCategoryPage() {
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const { categorySlug } = useParams<{ categorySlug: string }>()
  const [activeTab, setActiveTab] = useState(0)

  // Fetch parent category
  const { data: parentCategory, isLoading: categoryLoading, error: categoryError } = useQuery({
    queryKey: ['benefit-category', categorySlug],
    queryFn: async () => {
      console.log('🔍 Fetching parent category for slug:', categorySlug)
      if (!categorySlug) throw new Error('Category slug is required')

      const { data, error } = await supabase
        .from('benefit_categories')
        .select('*')
        .eq('slug', categorySlug)
        .is('parent_id', null)
        .single()

      console.log('📦 Parent category query result:', { data, error })
      if (error) {
        console.error('❌ Parent category fetch error:', error)
        throw error
      }
      console.log('✅ Fetched parent category:', data)
      return data as BenefitCategory
    },
    enabled: !!categorySlug,
  })

  console.log('BenefitCategoryPage render:', {
    categorySlug,
    parentCategory,
    categoryLoading,
    categoryError
  })

  // Fetch sub-categories
  const { data: subCategories, isLoading } = useQuery({
    queryKey: ['benefit-subcategories', parentCategory?.id],
    queryFn: async () => {
      if (!parentCategory?.id) return []

      const { data, error } = await supabase
        .from('benefit_categories')
        .select('*')
        .eq('parent_id', parentCategory.id)
        .order('display_order')

      if (error) throw error
      return data as BenefitCategory[]
    },
    enabled: !!parentCategory?.id,
  })

  const deleteMutation = useMutation({
    mutationFn: deleteAnnouncement,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['benefit-announcements'] })
      toast.success('공고가 삭제되었습니다')
    },
    onError: (error: Error) => {
      toast.error(`삭제에 실패했습니다: ${error.message}`)
    },
  })

  const fetchLHMutation = useMutation({
    mutationFn: fetchLHAnnouncements,
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ['benefit-announcements'] })
      toast.success(data?.message || 'LH 공고를 성공적으로 불러왔습니다')
    },
    onError: (error: Error) => {
      toast.error(`LH 공고 불러오기 실패: ${error.message}`)
    },
  })

  const handleTabChange = (_: React.SyntheticEvent, newValue: number) => {
    setActiveTab(newValue)
  }

  const handleCreateAnnouncement = () => {
    const currentSubCategory = subCategories?.[activeTab]
    if (currentSubCategory) {
      navigate(`/benefits/announcements/new?categoryId=${currentSubCategory.id}`)
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

  // 하위 카테고리가 없어도 부모 카테고리의 배너는 관리할 수 있어야 함
  if (!subCategories || subCategories.length === 0) {
    return (
      <Box>
        <Typography variant="h4" gutterBottom>
          {CATEGORY_NAMES[categorySlug || ''] || '혜택 관리'}
        </Typography>

        {/* 배너 관리 - 부모 카테고리 */}
        {parentCategory && (
          <Paper sx={{ p: 3, mb: 3 }}>
            <Typography variant="h6" gutterBottom>
              배너 관리
            </Typography>
            <MultiBannerManager category={parentCategory} />
          </Paper>
        )}

        <Paper sx={{ p: 4, textAlign: 'center' }}>
          <Typography variant="body1" color="text.secondary">
            등록된 하위 카테고리가 없습니다.
          </Typography>
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
        <Typography variant="h4">
          {CATEGORY_NAMES[categorySlug || '']} 관리
        </Typography>
        <Box sx={{ display: 'flex', gap: 2 }}>
          {/* LH 공고 불러오기 버튼 (주거 카테고리에서만 표시) */}
          {categorySlug === 'housing' && (
            <Button
              variant="outlined"
              startIcon={<DownloadIcon />}
              onClick={() => fetchLHMutation.mutate()}
              disabled={fetchLHMutation.isPending}
            >
              {fetchLHMutation.isPending ? 'LH 공고 불러오는 중...' : 'LH 공고 불러오기'}
            </Button>
          )}
          <Button
            variant="contained"
            startIcon={<AddIcon />}
            onClick={handleCreateAnnouncement}
          >
            새 공고
          </Button>
        </Box>
      </Box>

      {/* 배너 관리 - 부모 카테고리 전체에 대한 배너 (여러 개 등록 가능) */}
      {categoryLoading && (
        <Paper sx={{ p: 3, mb: 3 }}>
          <Typography>카테고리 로딩 중...</Typography>
        </Paper>
      )}
      {categoryError && (
        <Paper sx={{ p: 3, mb: 3 }}>
          <Typography color="error">
            카테고리 로딩 실패: {categoryError instanceof Error ? categoryError.message : '알 수 없는 오류'}
          </Typography>
        </Paper>
      )}
      {parentCategory ? (
        <Paper sx={{ p: 3, mb: 3 }}>
          <Typography variant="h6" gutterBottom>
            배너 관리 - {parentCategory.name} ({parentCategory.id})
          </Typography>
          <MultiBannerManager category={parentCategory} />
        </Paper>
      ) : !categoryLoading && !categoryError && (
        <Paper sx={{ p: 3, mb: 3 }}>
          <Typography color="warning.main">
            부모 카테고리를 찾을 수 없습니다: {categorySlug}
          </Typography>
        </Paper>
      )}

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
          {subCategories.map((category, index) => (
            <Tab
              key={category.id}
              label={category.name}
              id={`benefit-tab-${index}`}
              aria-controls={`benefit-tabpanel-${index}`}
            />
          ))}
        </Tabs>

        {subCategories.map((category, index) => (
          <TabPanel value={activeTab} index={index} key={category.id}>
            <Box sx={{ px: 3 }}>
              <Typography variant="h6" gutterBottom>
                공고 목록
              </Typography>
              <AnnouncementTable
                categoryId={category.id}
                onEdit={handleEdit}
                onDelete={handleDelete}
              />
            </Box>
          </TabPanel>
        ))}
      </Paper>
    </Box>
  )
}
