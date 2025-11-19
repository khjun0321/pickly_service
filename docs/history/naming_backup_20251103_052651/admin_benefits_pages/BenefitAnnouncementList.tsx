import { useState, useMemo } from 'react'
import { useNavigate } from 'react-router-dom'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import {
  Box,
  Button,
  Paper,
  IconButton,
  CircularProgress,
  Typography,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Chip,
  Stack,
  ToggleButton,
  ToggleButtonGroup,
} from '@mui/material'
import { DataGrid } from '@mui/x-data-grid'
import type { GridColDef } from '@mui/x-data-grid'
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
} from '@mui/icons-material'
import { format } from 'date-fns'
import { ko } from 'date-fns/locale'
import toast from 'react-hot-toast'
import {
  fetchAnnouncements as fetchAnnouncements,
  deleteAnnouncement as deleteAnnouncement,
  fetchLHAnnouncements,
  fetchLHStyleAnnouncements
} from '@/api/announcements'
// import type { Announcement } from '@/types/database' // ❌ REMOVED: Unused import
import { Download as DownloadIcon } from '@mui/icons-material'

type AnnouncementStatus = 'recruiting' | 'closed' | 'draft' | 'upcoming'

interface StatusConfig {
  label: string
  color: 'success' | 'error' | 'default' | 'info'
  icon: string
}

const STATUS_CONFIG: Record<AnnouncementStatus, StatusConfig> = {
  recruiting: { label: '모집중', color: 'success', icon: '🟢' },
  closed: { label: '마감', color: 'error', icon: '🔴' },
  draft: { label: '임시저장', color: 'default', icon: '⚫' },
  upcoming: { label: '예정', color: 'info', icon: '🔵' },
}

const STATUS_OPTIONS = [
  { value: 'all', label: '전체' },
  { value: 'recruiting', label: '모집중' },
  { value: 'closed', label: '마감' },
  { value: 'draft', label: '임시저장' },
  { value: 'upcoming', label: '예정' },
]

export default function AnnouncementList() {
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const [statusFilter, setStatusFilter] = useState('all')
  const [viewMode, setViewMode] = useState<'benefit' | 'lh'>('benefit')

  const { data: benefitAnnouncements, isLoading: isBenefitLoading } = useQuery({
    queryKey: ['benefit-announcements'],
    queryFn: () => fetchAnnouncements(),
    enabled: viewMode === 'benefit',
  })

  const { data: lhAnnouncements, isLoading: isLHLoading } = useQuery({
    queryKey: ['lh-announcements'],
    queryFn: fetchLHStyleAnnouncements,
    enabled: viewMode === 'lh',
  })

  const announcements = viewMode === 'benefit' ? benefitAnnouncements : lhAnnouncements
  const isLoading = viewMode === 'benefit' ? isBenefitLoading : isLHLoading

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

  const filteredAnnouncements = useMemo(() => {
    if (!announcements) return []

    return announcements.filter((announcement) => {
      // Note: Using category_id for filtering - you may want to join with benefit_categories table
      // For now, filtering by status only until category mapping is implemented
      const statusMatch =
        statusFilter === 'all' || announcement.status === statusFilter
      return statusMatch
    })
  }, [announcements, statusFilter])

  const handleDelete = (id: string, title: string) => {
    if (confirm(`"${title}" 공고를 삭제하시겠습니까?`)) {
      deleteMutation.mutate(id)
    }
  }

  const columns: GridColDef[] = [
    {
      field: 'title',
      headerName: '제목',
      flex: 2,
      minWidth: 200,
      renderCell: (params) => (
        <Box>
          <Typography variant="body2" sx={{ fontWeight: 500 }}>
            {params.value}
          </Typography>
          {params.row.subtitle && (
            <Typography variant="caption" color="text.secondary" sx={{ display: 'block' }}>
              {params.row.subtitle}
            </Typography>
          )}
        </Box>
      ),
    },
    {
      field: 'organization',
      headerName: '기관',
      flex: 1,
      minWidth: 150,
    },
    {
      field: 'status',
      headerName: '상태',
      width: 120,
      renderCell: (params) => {
        const status = params.value as AnnouncementStatus
        const config = STATUS_CONFIG[status]
        return (
          <Chip
            label={`${config.icon} ${config.label}`}
            color={config.color}
            size="small"
            sx={{ fontWeight: 500 }}
          />
        )
      },
    },
    {
      field: 'category_id',
      headerName: '카테고리 ID',
      width: 120,
      renderCell: (params) => (
        <Typography variant="body2" noWrap>
          {params.value ? params.value.slice(0, 8) + '...' : '-'}
        </Typography>
      ),
    },
    {
      field: 'application_start_date',
      headerName: '신청 시작일',
      width: 140,
      valueFormatter: (params) => {
        if (!params.value) return '-'
        return format(new Date(params.value), 'yyyy-MM-dd', { locale: ko })
      },
    },
    {
      field: 'application_end_date',
      headerName: '신청 마감일',
      width: 140,
      valueFormatter: (params) => {
        if (!params.value) return '-'
        return format(new Date(params.value), 'yyyy-MM-dd', { locale: ko })
      },
    },
    {
      field: 'view_count',
      headerName: '조회수',
      width: 100,
      align: 'center',
      headerAlign: 'center',
      valueFormatter: (value) => (value || 0).toLocaleString(),
    },
    {
      field: 'created_at',
      headerName: '등록일',
      width: 140,
      valueFormatter: (params) => {
        if (!params.value) return '-'
        return format(new Date(params.value), 'yyyy-MM-dd HH:mm', { locale: ko })
      },
    },
    {
      field: 'actions',
      headerName: '작업',
      width: 120,
      sortable: false,
      renderCell: (params) => (
        <Box>
          <IconButton
            size="small"
            onClick={() => navigate(`/benefits/announcements/${params.row.id}/edit`)}
            title="수정"
          >
            <EditIcon />
          </IconButton>
          <IconButton
            size="small"
            color="error"
            onClick={() => handleDelete(params.row.id, params.row.title)}
            title="삭제"
          >
            <DeleteIcon />
          </IconButton>
        </Box>
      ),
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
          {viewMode === 'benefit' && (
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
            onClick={() => navigate('/benefits/new')}
          >
            새 공고
          </Button>
        </Stack>
      </Box>

      <Paper sx={{ p: 2, mb: 2 }}>
        <Stack direction="row" spacing={2} alignItems="center">
          <ToggleButtonGroup
            value={viewMode}
            exclusive
            onChange={(_, newMode) => {
              if (newMode !== null) {
                setViewMode(newMode)
              }
            }}
            size="small"
          >
            <ToggleButton value="benefit">
              기존 공고
            </ToggleButton>
            <ToggleButton value="lh">
              LH 공고
            </ToggleButton>
          </ToggleButtonGroup>

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

          <Typography variant="body2" sx={{ alignSelf: 'center' }}>
            총 <strong>{filteredAnnouncements.length}</strong>개 공고
          </Typography>
        </Stack>
      </Paper>

      <Paper sx={{ height: 650 }}>
        <DataGrid
          rows={filteredAnnouncements}
          columns={columns}
          pageSizeOptions={[10, 25, 50, 100]}
          initialState={{
            pagination: {
              paginationModel: { pageSize: 25 },
            },
          }}
          disableRowSelectionOnClick
          sx={{
            '& .MuiDataGrid-cell': {
              borderBottom: '1px solid rgba(224, 224, 224, 1)',
            },
            '& .MuiDataGrid-columnHeaders': {
              backgroundColor: 'rgba(0, 0, 0, 0.04)',
              borderBottom: '2px solid rgba(224, 224, 224, 1)',
            },
          }}
        />
      </Paper>
    </Box>
  )
}
