/**
 * Benefit Management Page (v9.0)
 * Manages a single benefit category with its banners, details, and announcements
 *
 * Hierarchy:
 * - benefit_categories (top-level category, e.g. 주거, 교육)
 *   ├─ category_banners (carousel banners for the category)
 *   ├─ benefit_details (policies like 행복주택, 국민임대주택)
 *   └─ announcements (individual announcements)
 *
 * Route: /benefits/manage/:categorySlug
 */

import { useParams } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import { Box, Typography, CircularProgress, Alert } from '@mui/material'
import { supabase } from '@/lib/supabase'
import BannerManager from './components/BannerManager'
import BenefitDetailManager from './components/BenefitDetailManager'
import AnnouncementManager from './components/AnnouncementManager'
import type { BenefitCategory } from '@/types/benefit'

// Category slug mapping
const CATEGORY_SLUGS: Record<string, string> = {
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

export default function BenefitManagementPage() {
  const { categorySlug } = useParams<{ categorySlug: string }>()

  // Get category title from slug
  const categoryTitle = categorySlug ? CATEGORY_SLUGS[categorySlug] : null

  // Fetch category by title
  const { data: category, isLoading, error } = useQuery({
    queryKey: ['benefit_category', categoryTitle],
    queryFn: async () => {
      if (!categoryTitle) throw new Error('Invalid category')

      const { data, error } = await supabase
        .from('benefit_categories')
        .select('*')
        .eq('title', categoryTitle)
        .single()

      if (error) throw error
      return data as BenefitCategory
    },
    enabled: !!categoryTitle,
  })

  if (!categorySlug || !categoryTitle) {
    return (
      <Box sx={{ p: 3 }}>
        <Alert severity="error">잘못된 카테고리입니다</Alert>
      </Box>
    )
  }

  if (isLoading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '60vh' }}>
        <CircularProgress />
      </Box>
    )
  }

  if (error || !category) {
    return (
      <Box sx={{ p: 3 }}>
        <Alert severity="error">
          카테고리를 불러올 수 없습니다: {(error as Error)?.message || '알 수 없는 오류'}
        </Alert>
      </Box>
    )
  }

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" gutterBottom>
        {categoryTitle} 혜택 관리
      </Typography>
      <Typography variant="body2" color="text.secondary" gutterBottom>
        배너, 정책, 공고를 통합 관리합니다 (v9.0)
      </Typography>

      <Box sx={{ mt: 3 }}>
        {/* 1. Banner Management Section */}
        <BannerManager categoryId={category.id} categoryTitle={categoryTitle} />

        {/* 2. Benefit Detail Management Section (NEW in v9.0) */}
        <BenefitDetailManager categoryId={category.id} categoryTitle={categoryTitle} />

        {/* 3. Announcement Management Section */}
        <AnnouncementManager categoryId={category.id} categoryTitle={categoryTitle} />
      </Box>
    </Box>
  )
}
