/**
 * Benefit Dashboard (v8.1)
 * Main dashboard for managing top-level benefit categories
 * Displays CRUD interface for benefit_categories table
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
        혜택 카테고리를 관리합니다 (v8.1)
      </Typography>

      <Box sx={{ mt: 3 }}>
        <BenefitCategoryManager />
      </Box>
    </Box>
  )
}
