/**
 * Benefit Dashboard (v8.1)
 * Main dashboard with category tabs for unified benefit management
 */

import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import {
  Box,
  Paper,
  Tabs,
  Tab,
  Typography,
  CircularProgress,
  Alert,
} from '@mui/material'
import { supabase } from '@/lib/supabase'
import BannerManager from './components/BannerManager'
import ProgramManager from './components/ProgramManager'
import AnnouncementManager from './components/AnnouncementManager'
import type { BenefitCategory } from '@/types/benefit'

// Category slugs in display order
const CATEGORY_SLUGS = [
  'popular',
  'housing',
  'education',
  'health',
  'transportation',
  'welfare',
  'employment',
  'support',
  'culture',
]

const CATEGORY_TITLES: Record<string, string> = {
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

export default function BenefitDashboard() {
  const [selectedTab, setSelectedTab] = useState(0)

  // Fetch all benefit categories
  const { data: categories = [], isLoading, error } = useQuery({
    queryKey: ['benefit_categories'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('benefit_categories')
        .select('*')
        .eq('is_active', true)
        .order('sort_order', { ascending: true })

      if (error) throw error

      // Filter to only main categories (matching our slug list)
      const mainCategories = data.filter((cat: BenefitCategory) =>
        CATEGORY_SLUGS.includes(cat.slug)
      )

      // Sort by our predefined order
      return mainCategories.sort(
        (a: BenefitCategory, b: BenefitCategory) =>
          CATEGORY_SLUGS.indexOf(a.slug) - CATEGORY_SLUGS.indexOf(b.slug)
      ) as BenefitCategory[]
    },
  })

  const handleTabChange = (_event: React.SyntheticEvent, newValue: number) => {
    setSelectedTab(newValue)
  }

  if (isLoading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '60vh' }}>
        <CircularProgress />
      </Box>
    )
  }

  if (error) {
    return (
      <Box sx={{ p: 3 }}>
        <Alert severity="error">
          카테고리를 불러올 수 없습니다: {(error as Error)?.message || '알 수 없는 오류'}
        </Alert>
      </Box>
    )
  }

  if (categories.length === 0) {
    return (
      <Box sx={{ p: 3 }}>
        <Alert severity="warning">등록된 카테고리가 없습니다</Alert>
      </Box>
    )
  }

  const selectedCategory = categories[selectedTab]

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" gutterBottom>
        혜택 관리 대시보드
      </Typography>
      <Typography variant="body2" color="text.secondary" gutterBottom>
        카테고리별 배너, 프로그램, 공고를 통합 관리합니다 (v8.1)
      </Typography>

      <Paper sx={{ mt: 3 }}>
        <Tabs
          value={selectedTab}
          onChange={handleTabChange}
          variant="scrollable"
          scrollButtons="auto"
          sx={{
            borderBottom: 1,
            borderColor: 'divider',
            '& .MuiTab-root': {
              minWidth: 100,
              fontWeight: 'medium',
            },
          }}
        >
          {categories.map((category) => (
            <Tab
              key={category.id}
              label={CATEGORY_TITLES[category.slug] || category.title}
            />
          ))}
        </Tabs>

        <Box sx={{ p: 3 }}>
          {selectedCategory && (
            <>
              {/* Banner Management */}
              <BannerManager
                categoryId={selectedCategory.id}
                categoryTitle={CATEGORY_TITLES[selectedCategory.slug] || selectedCategory.title}
              />

              {/* Program Management (v8.1) */}
              <ProgramManager
                categoryId={selectedCategory.id}
                categoryTitle={CATEGORY_TITLES[selectedCategory.slug] || selectedCategory.title}
              />

              {/* Announcement Management */}
              <AnnouncementManager
                categoryId={selectedCategory.id}
                categoryTitle={CATEGORY_TITLES[selectedCategory.slug] || selectedCategory.title}
              />
            </>
          )}
        </Box>
      </Paper>
    </Box>
  )
}
