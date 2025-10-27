/**
 * INTEGRATION EXAMPLE
 *
 * This file shows how to integrate the AnnouncementTable component
 * into the BenefitAnnouncementList page.
 *
 * Replace the existing DataGrid in BenefitAnnouncementList.tsx with this code.
 */

import { useState, useMemo } from 'react'
import { useNavigate } from 'react-router-dom'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import {
  Box,
  Button,
  Paper,
  CircularProgress,
  Typography,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Stack,
  ToggleButtonGroup,
  ToggleButton,
} from '@mui/material'
import {
  Add as AddIcon,
  Download as DownloadIcon,
  ViewList as ViewListIcon,
  TableChart as TableChartIcon,
} from '@mui/icons-material'
import toast from 'react-hot-toast'
import {
  fetchAnnouncements as fetchBenefitAnnouncements,
  deleteAnnouncement as deleteBenefitAnnouncement,
  fetchLHAnnouncements
} from '@/api/announcements'
import { AnnouncementTable } from '@/components/benefits'

const STATUS_OPTIONS = [
  { value: 'all', label: '전체' },
  { value: 'recruiting', label: '모집중' },
  { value: 'closed', label: '마감' },
  { value: 'draft', label: '임시저장' },
  { value: 'upcoming', label: '예정' },
]

export default function BenefitAnnouncementList() {
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const [statusFilter, setStatusFilter] = useState('all')
  const [viewMode, setViewMode] = useState<'table' | 'grid'>('table')

  const { data: announcements, isLoading } = useQuery({
    queryKey: ['benefit-announcements'],
    queryFn: fetchBenefitAnnouncements,
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

  const filteredAnnouncements = useMemo(() => {
    if (!announcements) return []

    return announcements.filter((announcement) => {
      const statusMatch =
        statusFilter === 'all' || announcement.status === statusFilter
      return statusMatch
    })
  }, [announcements, statusFilter])

  const handleDelete = (id: string) => {
    deleteMutation.mutate(id)
  }

  const handleEdit = (id: string) => {
    navigate(`/benefits/${id}/edit`)
  }

  if (isLoading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', mt: 4 }}>
        <CircularProgress />
      </Box>
    )
  }

  return (
    <Box>
      {/* Header */}
      <Box
        sx={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          mb: 2,
        }}
      >
        <Typography variant="h4">혜택 공고</Typography>
        <Stack direction="row" spacing={2}>
          <Button
            variant="outlined"
            startIcon={<DownloadIcon />}
            onClick={() => fetchLHMutation.mutate()}
            disabled={fetchLHMutation.isPending}
          >
            {fetchLHMutation.isPending ? 'LH 공고 불러오는 중...' : 'LH 공고 불러오기'}
          </Button>
          <Button
            variant="contained"
            startIcon={<AddIcon />}
            onClick={() => navigate('/benefits/new')}
          >
            새 공고
          </Button>
        </Stack>
      </Box>

      {/* Filters */}
      <Paper sx={{ p: 2, mb: 2 }}>
        <Stack direction="row" spacing={2} alignItems="center">
          <FormControl sx={{ minWidth: 150 }}>
            <InputLabel id="status-filter-label">상태</InputLabel>
            <Select
              labelId="status-filter-label"
              id="status-filter"
              value={statusFilter}
              label="상태"
              onChange={(e) => setStatusFilter(e.target.value)}
              size="small"
            >
              {STATUS_OPTIONS.map((option) => (
                <MenuItem key={option.value} value={option.value}>
                  {option.label}
                </MenuItem>
              ))}
            </Select>
          </FormControl>

          <Box sx={{ flexGrow: 1 }} />

          {/* View Mode Toggle */}
          <ToggleButtonGroup
            value={viewMode}
            exclusive
            onChange={(_, newMode) => newMode && setViewMode(newMode)}
            size="small"
          >
            <ToggleButton value="table" aria-label="table view">
              <ViewListIcon />
            </ToggleButton>
            <ToggleButton value="grid" aria-label="grid view">
              <TableChartIcon />
            </ToggleButton>
          </ToggleButtonGroup>

          <Typography variant="body2" sx={{ alignSelf: 'center' }}>
            총 <strong>{filteredAnnouncements.length}</strong>개 공고
          </Typography>
        </Stack>
      </Paper>

      {/* Table View - Drag & Drop Enabled */}
      {viewMode === 'table' ? (
        <AnnouncementTable
          announcements={filteredAnnouncements}
          onEdit={handleEdit}
          onDelete={handleDelete}
        />
      ) : (
        // Grid View - Keep existing DataGrid for comparison
        <Paper sx={{ p: 2 }}>
          <Typography variant="body2" color="text.secondary">
            Grid view - Original DataGrid can be shown here
          </Typography>
        </Paper>
      )}
    </Box>
  )
}

/**
 * STEP-BY-STEP INTEGRATION GUIDE:
 *
 * 1. Import the AnnouncementTable component:
 *    import { AnnouncementTable } from '@/components/benefits'
 *
 * 2. Add view mode state:
 *    const [viewMode, setViewMode] = useState<'table' | 'grid'>('table')
 *
 * 3. Replace the DataGrid section with:
 *    <AnnouncementTable
 *      announcements={filteredAnnouncements}
 *      onEdit={handleEdit}
 *      onDelete={handleDelete}
 *    />
 *
 * 4. Add the Supabase RPC function (see README.md)
 *
 * 5. Test drag-and-drop functionality:
 *    - Click and drag the drag handle (⋮⋮)
 *    - Drop the row in a new position
 *    - Verify the order updates in the database
 *
 * 6. Test inline editing:
 *    - Double-click a title or organization cell
 *    - Edit the value
 *    - Press Enter or click outside to save
 *
 * FEATURES GAINED:
 * ✅ Drag-and-drop row reordering
 * ✅ Inline cell editing
 * ✅ Auto-save on blur
 * ✅ Optimistic UI updates
 * ✅ Loading states
 * ✅ Error handling with toast notifications
 * ✅ Keyboard shortcuts (Enter, Esc)
 * ✅ Visual feedback during drag
 * ✅ Category-based dynamic columns
 * ✅ Responsive design
 */
