/**
 * API Source Management Page
 * PRD v9.6 Section 4.3 & 5.5
 * Manages external API sources for benefit data collection
 */

import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import {
  Box,
  Button,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Switch,
  FormControlLabel,
  Typography,
  Chip,
  Grid,
} from '@mui/material'
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  Refresh as RefreshIcon,
} from '@mui/icons-material'
import { supabase } from '@/lib/supabase'
import toast from 'react-hot-toast'
import type { ApiSource, ApiSourceFormData, AuthType, MappingConfig } from '@/types/api'

export default function ApiSourceManagementPage() {
  const queryClient = useQueryClient()
  const [dialogOpen, setDialogOpen] = useState(false)
  const [editingSource, setEditingSource] = useState<ApiSource | null>(null)
  const [formData, setFormData] = useState<ApiSourceFormData>({
    name: '',
    description: null,
    endpoint_url: '',
    auth_type: 'none',
    auth_key: null,
    mapping_config: { fields: {} },
    collection_schedule: null,
    is_active: true,
  })
  const [mappingJson, setMappingJson] = useState('')

  // Fetch API sources
  const { data: apiSources = [], isLoading } = useQuery({
    queryKey: ['api_sources'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('api_sources')
        .select('*')
        .order('created_at', { ascending: false })

      if (error) throw error
      return data as ApiSource[]
    },
  })

  // Create/Update mutation
  const saveMutation = useMutation({
    mutationFn: async (data: ApiSourceFormData & { id?: string }) => {
      if (data.id) {
        const { error } = await supabase
          .from('api_sources')
          .update(data)
          .eq('id', data.id)
        if (error) throw error
      } else {
        const { error } = await supabase.from('api_sources').insert([data])
        if (error) throw error
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['api_sources'] })
      toast.success(editingSource ? 'API 소스가 수정되었습니다' : 'API 소스가 추가되었습니다')
      handleCloseDialog()
    },
    onError: (error: Error) => {
      toast.error(`오류: ${error.message}`)
    },
  })

  // Delete mutation
  const deleteMutation = useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from('api_sources').delete().eq('id', id)
      if (error) throw error
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['api_sources'] })
      toast.success('API 소스가 삭제되었습니다')
    },
    onError: (error: Error) => {
      toast.error(`삭제 실패: ${error.message}`)
    },
  })

  // Toggle active mutation
  const toggleActiveMutation = useMutation({
    mutationFn: async ({ id, is_active }: { id: string; is_active: boolean }) => {
      const { error } = await supabase
        .from('api_sources')
        .update({ is_active })
        .eq('id', id)
      if (error) throw error
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['api_sources'] })
      toast.success('활성화 상태가 변경되었습니다')
    },
    onError: (error: Error) => {
      toast.error(`변경 실패: ${error.message}`)
    },
  })

  const handleOpenDialog = (source?: ApiSource) => {
    if (source) {
      setEditingSource(source)
      setFormData({
        name: source.name,
        description: source.description,
        endpoint_url: source.endpoint_url,
        auth_type: source.auth_type,
        auth_key: source.auth_key,
        mapping_config: source.mapping_config,
        collection_schedule: source.collection_schedule,
        is_active: source.is_active,
      })
      setMappingJson(JSON.stringify(source.mapping_config, null, 2))
    } else {
      setEditingSource(null)
      setFormData({
        name: '',
        description: null,
        endpoint_url: '',
        auth_type: 'none',
        auth_key: null,
        mapping_config: { fields: {} },
        collection_schedule: null,
        is_active: true,
      })
      setMappingJson('{\n  "fields": {},\n  "target_category": ""\n}')
    }
    setDialogOpen(true)
  }

  const handleCloseDialog = () => {
    setDialogOpen(false)
    setEditingSource(null)
  }

  const handleSave = () => {
    // Validate required fields
    if (!formData.name.trim()) {
      toast.error('API 소스 이름을 입력하세요')
      return
    }
    if (!formData.endpoint_url.trim()) {
      toast.error('엔드포인트 URL을 입력하세요')
      return
    }

    // Parse and validate mapping JSON
    let parsedMapping: MappingConfig
    try {
      parsedMapping = JSON.parse(mappingJson)
    } catch (e) {
      toast.error('매핑 설정 JSON이 올바르지 않습니다')
      return
    }

    saveMutation.mutate({
      ...formData,
      mapping_config: parsedMapping,
      ...(editingSource && { id: editingSource.id }),
    })
  }

  const handleDelete = (id: string, name: string) => {
    if (window.confirm(`"${name}" API 소스를 삭제하시겠습니까?`)) {
      deleteMutation.mutate(id)
    }
  }

  const handleToggleActive = (id: string, currentActive: boolean) => {
    toggleActiveMutation.mutate({ id, is_active: !currentActive })
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
          API 소스 관리
        </Typography>
        <Button
          variant="contained"
          startIcon={<AddIcon />}
          onClick={() => handleOpenDialog()}
        >
          새 API 소스 추가
        </Button>
      </Box>

      {/* API Sources Table */}
      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>이름</TableCell>
              <TableCell>설명</TableCell>
              <TableCell>엔드포인트 URL</TableCell>
              <TableCell>인증 방식</TableCell>
              <TableCell>마지막 수집</TableCell>
              <TableCell>상태</TableCell>
              <TableCell align="right">작업</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {apiSources.length === 0 ? (
              <TableRow>
                <TableCell colSpan={7} align="center">
                  등록된 API 소스가 없습니다
                </TableCell>
              </TableRow>
            ) : (
              apiSources.map((source) => (
                <TableRow key={source.id}>
                  <TableCell>{source.name}</TableCell>
                  <TableCell>
                    <Typography variant="body2" color="text.secondary">
                      {source.description || '-'}
                    </Typography>
                  </TableCell>
                  <TableCell>
                    <Typography variant="body2" sx={{ fontFamily: 'monospace', fontSize: '0.85rem' }}>
                      {source.endpoint_url}
                    </Typography>
                  </TableCell>
                  <TableCell>
                    <Chip
                      label={source.auth_type}
                      size="small"
                      color={source.auth_type === 'none' ? 'default' : 'primary'}
                    />
                  </TableCell>
                  <TableCell>
                    {source.last_collected_at ? (
                      <Typography variant="body2" color="text.secondary">
                        {new Date(source.last_collected_at).toLocaleString('ko-KR')}
                      </Typography>
                    ) : (
                      <Typography variant="body2" color="text.disabled">
                        수집 기록 없음
                      </Typography>
                    )}
                  </TableCell>
                  <TableCell>
                    <FormControlLabel
                      control={
                        <Switch
                          checked={source.is_active}
                          onChange={() => handleToggleActive(source.id, source.is_active)}
                          size="small"
                        />
                      }
                      label={source.is_active ? '활성' : '비활성'}
                    />
                  </TableCell>
                  <TableCell align="right">
                    <IconButton size="small" onClick={() => handleOpenDialog(source)}>
                      <EditIcon fontSize="small" />
                    </IconButton>
                    <IconButton
                      size="small"
                      color="error"
                      onClick={() => handleDelete(source.id, source.name)}
                    >
                      <DeleteIcon fontSize="small" />
                    </IconButton>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </TableContainer>

      {/* Create/Edit Dialog */}
      <Dialog open={dialogOpen} onClose={handleCloseDialog} maxWidth="md" fullWidth>
        <DialogTitle>{editingSource ? 'API 소스 수정' : '새 API 소스 추가'}</DialogTitle>
        <DialogContent>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, pt: 2 }}>
            <Grid container spacing={2}>
              <Grid item xs={8}>
                <TextField
                  label="API 소스 이름"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  fullWidth
                  required
                  helperText="예: Public Data Portal - Housing"
                />
              </Grid>
              <Grid item xs={4}>
                <FormControl fullWidth required>
                  <InputLabel>인증 방식</InputLabel>
                  <Select
                    value={formData.auth_type}
                    onChange={(e) =>
                      setFormData({ ...formData, auth_type: e.target.value as AuthType })
                    }
                    label="인증 방식"
                  >
                    <MenuItem value="none">인증 없음</MenuItem>
                    <MenuItem value="api_key">API Key</MenuItem>
                    <MenuItem value="bearer">Bearer Token</MenuItem>
                    <MenuItem value="oauth">OAuth</MenuItem>
                  </Select>
                </FormControl>
              </Grid>
            </Grid>

            <TextField
              label="설명"
              value={formData.description || ''}
              onChange={(e) => setFormData({ ...formData, description: e.target.value || null })}
              fullWidth
              multiline
              rows={2}
              helperText="API 소스에 대한 간단한 설명"
            />

            <TextField
              label="엔드포인트 URL"
              value={formData.endpoint_url}
              onChange={(e) => setFormData({ ...formData, endpoint_url: e.target.value })}
              fullWidth
              required
              helperText="API 엔드포인트 전체 URL"
            />

            {formData.auth_type !== 'none' && (
              <TextField
                label="인증 키"
                value={formData.auth_key || ''}
                onChange={(e) => setFormData({ ...formData, auth_key: e.target.value || null })}
                fullWidth
                type="password"
                helperText="API 인증에 사용할 키 또는 토큰"
              />
            )}

            <TextField
              label="수집 스케줄 (Cron)"
              value={formData.collection_schedule || ''}
              onChange={(e) =>
                setFormData({ ...formData, collection_schedule: e.target.value || null })
              }
              fullWidth
              helperText='예: "0 0 * * *" (매일 자정) - 향후 자동 수집에 사용'
            />

            <Box>
              <Typography variant="subtitle2" gutterBottom>
                매핑 설정 (JSON)
              </Typography>
              <TextField
                value={mappingJson}
                onChange={(e) => setMappingJson(e.target.value)}
                fullWidth
                multiline
                rows={10}
                sx={{ fontFamily: 'monospace', fontSize: '0.9rem' }}
                helperText='API 응답 필드 → DB 필드 매핑 설정 (JSON 형식)'
              />
            </Box>

            <FormControlLabel
              control={
                <Switch
                  checked={formData.is_active}
                  onChange={(e) => setFormData({ ...formData, is_active: e.target.checked })}
                />
              }
              label="활성화"
            />
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDialog}>취소</Button>
          <Button onClick={handleSave} variant="contained" disabled={saveMutation.isPending}>
            {editingSource ? '수정' : '추가'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  )
}
