/**
 * Benefit Dashboard (v9.0)
 * Main dashboard for managing top-level benefit categories
 * Displays CRUD interface for benefit_categories table
 *
 * Clicking a category row navigates to /benefits/manage/:slug
 * which shows the 3-layer structure: Banners, Details, Announcements
 */

import { Box, Typography } from '@mui/material'
import BenefitCategoryManager from './BenefitCategoryManager'

export default function BenefitDashboard() {
  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" gutterBottom>
        혜택 관리
      </Typography>
      <Typography variant="body2" color="text.secondary" gutterBottom>
        혜택 카테고리를 관리합니다 (v9.0) - 카테고리 행을 클릭하면 배너/정책/공고 관리 페이지로 이동합니다
      </Typography>

      <Box sx={{ mt: 3 }}>
        <BenefitCategoryManager />
      </Box>
    </Box>
  )
}
