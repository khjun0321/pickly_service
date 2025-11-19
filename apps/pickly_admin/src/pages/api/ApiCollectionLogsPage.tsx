/**
 * API Collection Logs Page
 * PRD v9.6 Section 4.3.2 & 5.5
 * Displays execution history for API data collection
 */

import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import {
  Box,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Typography,
  Chip,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Grid,
  TextField,
  Button,
} from '@mui/material'
import { Refresh as RefreshIcon } from '@mui/icons-material'
import { supabase } from '@/lib/supabase'
import type { CollectionLog, ApiSource } from '@/types/api'

export default function ApiCollectionLogsPage() {
  const [statusFilter, setStatusFilter] = useState<string>('all')
  const [apiSourceFilter, setApiSourceFilter] = useState<string>('all')
  const [dateFrom, setDateFrom] = useState<string>('')
  const [dateTo, setDateTo] = useState<string>('')

  // Fetch API sources for filter dropdown
  const { data: apiSources = [] } = useQuery({
    queryKey: ['api_sources'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('api_sources')
        .select('id, name')
        .order('name')
      if (error) throw error
      return data as Pick<ApiSource, 'id' | 'name'>[]
    },
  })

  // Fetch collection logs with filters
  const { data: logs = [], isLoading, refetch } = useQuery({
    queryKey: ['api_collection_logs', statusFilter, apiSourceFilter, dateFrom, dateTo],
    queryFn: async () => {
      let query = supabase
        .from('api_collection_logs')
        .select(`
          *,
          api_sources (
            name
          )
        `)
        .order('started_at', { ascending: false })

      // Apply status filter
      if (statusFilter !== 'all') {
        query = query.eq('status', statusFilter)
      }

      // Apply API source filter
      if (apiSourceFilter !== 'all') {
        query = query.eq('api_source_id', apiSourceFilter)
      }

      // Apply date range filter
      if (dateFrom) {
        query = query.gte('started_at', new Date(dateFrom).toISOString())
      }
      if (dateTo) {
        query = query.lte('started_at', new Date(dateTo).toISOString())
      }

      const { data, error } = await query
      if (error) throw error
      return data as (CollectionLog & { api_sources: { name: string } })[]
    },
  })

  const getStatusColor = (status: string): 'success' | 'warning' | 'error' | 'info' => {
    switch (status) {
      case 'success':
        return 'success'
      case 'partial':
        return 'warning'
      case 'failed':
        return 'error'
      case 'running':
        return 'info'
      default:
        return 'info'
    }
  }

  const getStatusLabel = (status: string): string => {
    switch (status) {
      case 'success':
        return '성공'
      case 'partial':
        return '부분 성공'
      case 'failed':
        return '실패'
      case 'running':
        return '실행 중'
      default:
        return status
    }
  }

  const formatDuration = (startedAt: string, completedAt: string | null): string => {
    if (!completedAt) return '진행 중...'

    const start = new Date(startedAt)
    const end = new Date(completedAt)
    const durationMs = end.getTime() - start.getTime()
    const seconds = Math.floor(durationMs / 1000)

    if (seconds < 60) return `${seconds}초`
    const minutes = Math.floor(seconds / 60)
    const remainingSeconds = seconds % 60
    return `${minutes}분 ${remainingSeconds}초`
  }

  const handleClearFilters = () => {
    setStatusFilter('all')
    setApiSourceFilter('all')
    setDateFrom('')
    setDateTo('')
  }

  if (isLoading) {
    return (
      <Box sx={{ p: 3 }}>
        <Typography>로딩 중...</Typography>
      </Box>
    )
  }

  return (
    <Box sx={{ p: 3 }}>
      {/* Header */}
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Typography variant="h4" component="h1">
          API 수집 로그
        </Typography>
        <Button
          variant="outlined"
          startIcon={<RefreshIcon />}
          onClick={() => refetch()}
        >
          새로고침
        </Button>
      </Box>

      {/* Filters */}
      <Paper sx={{ p: 2, mb: 3 }}>
        <Typography variant="h6" gutterBottom>
          필터
        </Typography>
        <Grid container spacing={2}>
          <Grid item xs={12} sm={6} md={3}>
            <FormControl fullWidth size="small">
              <InputLabel>상태</InputLabel>
              <Select
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
                label="상태"
              >
                <MenuItem value="all">전체</MenuItem>
                <MenuItem value="running">실행 중</MenuItem>
                <MenuItem value="success">성공</MenuItem>
                <MenuItem value="partial">부분 성공</MenuItem>
                <MenuItem value="failed">실패</MenuItem>
              </Select>
            </FormControl>
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <FormControl fullWidth size="small">
              <InputLabel>API 소스</InputLabel>
              <Select
                value={apiSourceFilter}
                onChange={(e) => setApiSourceFilter(e.target.value)}
                label="API 소스"
              >
                <MenuItem value="all">전체</MenuItem>
                {apiSources.map((source) => (
                  <MenuItem key={source.id} value={source.id}>
                    {source.name}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
          </Grid>
          <Grid item xs={12} sm={6} md={2}>
            <TextField
              label="시작일"
              type="date"
              size="small"
              fullWidth
              value={dateFrom}
              onChange={(e) => setDateFrom(e.target.value)}
              InputLabelProps={{ shrink: true }}
            />
          </Grid>
          <Grid item xs={12} sm={6} md={2}>
            <TextField
              label="종료일"
              type="date"
              size="small"
              fullWidth
              value={dateTo}
              onChange={(e) => setDateTo(e.target.value)}
              InputLabelProps={{ shrink: true }}
            />
          </Grid>
          <Grid item xs={12} sm={12} md={2}>
            <Button
              variant="outlined"
              fullWidth
              onClick={handleClearFilters}
              sx={{ height: '40px' }}
            >
              필터 초기화
            </Button>
          </Grid>
        </Grid>
      </Paper>

      {/* Collection Logs Table */}
      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>API 소스</TableCell>
              <TableCell>상태</TableCell>
              <TableCell align="right">수집</TableCell>
              <TableCell align="right">처리</TableCell>
              <TableCell align="right">실패</TableCell>
              <TableCell align="right">성공률</TableCell>
              <TableCell>소요 시간</TableCell>
              <TableCell>시작 시각</TableCell>
              <TableCell>에러 메시지</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {logs.length === 0 ? (
              <TableRow>
                <TableCell colSpan={9} align="center">
                  수집 로그가 없습니다
                </TableCell>
              </TableRow>
            ) : (
              logs.map((log) => {
                const successRate = log.records_fetched > 0
                  ? ((log.records_processed / log.records_fetched) * 100).toFixed(1)
                  : '0.0'

                return (
                  <TableRow key={log.id}>
                    <TableCell>
                      <Typography variant="body2" fontWeight="medium">
                        {log.api_sources.name}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Chip
                        label={getStatusLabel(log.status)}
                        color={getStatusColor(log.status)}
                        size="small"
                      />
                    </TableCell>
                    <TableCell align="right">
                      <Typography variant="body2">{log.records_fetched.toLocaleString()}</Typography>
                    </TableCell>
                    <TableCell align="right">
                      <Typography variant="body2" color="success.main">
                        {log.records_processed.toLocaleString()}
                      </Typography>
                    </TableCell>
                    <TableCell align="right">
                      <Typography variant="body2" color="error.main">
                        {log.records_failed.toLocaleString()}
                      </Typography>
                    </TableCell>
                    <TableCell align="right">
                      <Typography
                        variant="body2"
                        color={parseFloat(successRate) >= 90 ? 'success.main' : 'warning.main'}
                      >
                        {successRate}%
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2" color="text.secondary">
                        {formatDuration(log.started_at, log.completed_at)}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2" color="text.secondary">
                        {new Date(log.started_at).toLocaleString('ko-KR')}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      {log.error_message ? (
                        <Typography
                          variant="body2"
                          color="error.main"
                          sx={{
                            maxWidth: '250px',
                            overflow: 'hidden',
                            textOverflow: 'ellipsis',
                            whiteSpace: 'nowrap',
                          }}
                          title={log.error_message}
                        >
                          {log.error_message}
                        </Typography>
                      ) : (
                        <Typography variant="body2" color="text.disabled">
                          -
                        </Typography>
                      )}
                    </TableCell>
                  </TableRow>
                )
              })
            )}
          </TableBody>
        </Table>
      </TableContainer>
    </Box>
  )
}
