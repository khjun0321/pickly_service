/**
 * Announcement Tabs Component (v9.0)
 * Displays policy-based tabs for announcement management
 * Each tab shows announcements for a specific benefit detail (e.g., 행복주택, 국민임대주택)
 */

import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import {
  Box,
  Paper,
  Typography,
  Tabs,
  Tab,
  CircularProgress,
  Alert,
} from '@mui/material'
import { supabase } from '@/lib/supabase'
import AnnouncementList from './AnnouncementList'
import type { BenefitDetail } from '@/types/benefit'

interface AnnouncementTabsProps {
  categoryId: string
  categoryTitle: string
}

export default function AnnouncementTabs({ categoryId, categoryTitle }: AnnouncementTabsProps) {
  const [selectedDetailId, setSelectedDetailId] = useState<string | null>(null)

  // Fetch benefit details (policies) for this category
  const { data: details = [], isLoading } = useQuery({
    queryKey: ['benefit_details', categoryId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('benefit_details')
        .select('*')
        .eq('benefit_category_id', categoryId)
        .eq('is_active', true)
        .order('sort_order', { ascending: true })

      if (error) throw error
      return data as BenefitDetail[]
    },
  })

  // Auto-select first detail when data loads
  if (details.length > 0 && !selectedDetailId) {
    setSelectedDetailId(details[0].id)
  }

  const handleTabChange = (_: React.SyntheticEvent, newDetailId: string) => {
    setSelectedDetailId(newDetailId)
  }

  if (isLoading) {
    return (
      <Paper sx={{ p: 3 }}>
        <Box sx={{ display: 'flex', justifyContent: 'center', p: 3 }}>
          <CircularProgress />
        </Box>
      </Paper>
    )
  }

  if (details.length === 0) {
    return (
      <Paper sx={{ p: 3 }}>
        <Typography variant="h6" gutterBottom>
          공고 관리 ({categoryTitle})
        </Typography>
        <Alert severity="info">
          공고를 관리하려면 먼저 정책(상세)을 생성하세요.
          <br />
          예: 행복주택, 국민임대주택, 영구임대주택
        </Alert>
      </Paper>
    )
  }

  return (
    <Paper sx={{ p: 3 }}>
      <Typography variant="h6" gutterBottom>
        공고 관리 ({categoryTitle})
      </Typography>
      <Typography variant="body2" color="text.secondary" gutterBottom sx={{ mb: 2 }}>
        정책별로 공고를 관리합니다
      </Typography>

      {/* Policy Tabs */}
      <Tabs
        value={selectedDetailId || false}
        onChange={handleTabChange}
        sx={{ borderBottom: 1, borderColor: 'divider', mb: 3 }}
        variant="scrollable"
        scrollButtons="auto"
      >
        {details.map((detail) => (
          <Tab
            key={detail.id}
            label={detail.title}
            value={detail.id}
            sx={{ textTransform: 'none', fontWeight: 'medium' }}
          />
        ))}
      </Tabs>

      {/* Announcement List for Selected Policy */}
      {selectedDetailId && (
        <AnnouncementList
          detailId={selectedDetailId}
          categoryId={categoryId}
          detailTitle={details.find(d => d.id === selectedDetailId)?.title || ''}
        />
      )}
    </Paper>
  )
}
