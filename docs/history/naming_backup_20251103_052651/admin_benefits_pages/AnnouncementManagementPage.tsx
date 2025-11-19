/**
 * Announcement Management Page
 * PRD v9.6 Section 4.2 & 5.4 - Complete Announcement Management
 * Route: /benefits/announcements
 */

import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import {
  Box,
  Typography,
  Button,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  IconButton,
  Chip,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  FormControlLabel,
  Switch,
  Select,
  MenuItem,
  FormControl,
  InputLabel,
  Grid,
  Tabs,
  Tab,
} from '@mui/material'
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  Star,
  StarBorder,
  List as ListIcon,
} from '@mui/icons-material'
import { supabase } from '@/lib/supabase'
import ImageUploader from '@/components/common/ImageUploader'
import AnnouncementTabEditor from '@/components/benefits/AnnouncementTabEditor'
import type { Announcement, AnnouncementFormData, BenefitCategory, BenefitSubcategory, AnnouncementStatus, LinkType } from '@/types/benefits'
import toast from 'react-hot-toast'

export default function AnnouncementManagementPage() {
  const queryClient = useQueryClient()
  const [dialogOpen, setDialogOpen] = useState(false)
  const [tabEditorOpen, setTabEditorOpen] = useState(false)
  const [editingAnnouncement, setEditingAnnouncement] = useState<Announcement | null>(null)
  const [selectedAnnouncementForTabs, setSelectedAnnouncementForTabs] = useState<string | null>(null)

  // Filters
  const [categoryFilter, setCategoryFilter] = useState<string>('all')
  const [subcategoryFilter, setSubcategoryFilter] = useState<string>('all')
  const [statusFilter, setStatusFilter] = useState<AnnouncementStatus | 'all'>('all')
  const [priorityFilter, setPriorityFilter] = useState<boolean | 'all'>('all')

  const [formData, setFormData] = useState<AnnouncementFormData>({
    title: '',
    subtitle: null,
    organization: '',
    category_id: null,
    subcategory_id: null,
    thumbnail_url: null,
    external_url: null,
    detail_url: null,
    status: 'recruiting',
    is_featured: false,
    is_home_visible: false,
    is_priority: false,
    display_priority: 0,
    tags: null,
    content: null,
    region: null,
    application_start_date: null,
    application_end_date: null,
    deadline_date: null,
    link_type: 'none',
  })

  // Fetch categories
  const { data: categories = [] } = useQuery({
    queryKey: ['benefit_categories'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('benefit_categories')
        .select('*')
        .order('sort_order', { ascending: true })

      if (error) throw error
      return data as BenefitCategory[]
    },
  })

  // Fetch subcategories
  const { data: subcategories = [] } = useQuery({
    queryKey: ['benefit_subcategories', categoryFilter],
    queryFn: async () => {
      let query = supabase
        .from('benefit_subcategories')
        .select('*')
        .order('sort_order', { ascending: true })

      if (categoryFilter !== 'all') {
        query = query.eq('category_id', categoryFilter)
      }

      const { data, error} = await query
      if (error) throw error
      return data as BenefitSubcategory[]
    },
  })

  // Fetch announcements with filters
  const { data: announcements = [], isLoading } = useQuery({
    queryKey: ['announcements', categoryFilter, subcategoryFilter, statusFilter, priorityFilter],
    queryFn: async () => {
      let query = supabase
        .from('announcements')
        .select(`
          *,
          category:benefit_categories(id, title, slug),
          subcategory:benefit_subcategories(id, name, slug)
        `)
        .order('is_priority', { ascending: false })
        .order('application_start_date', { ascending: false })

      if (categoryFilter !== 'all') {
        query = query.eq('category_id', categoryFilter)
      }
      if (subcategoryFilter !== 'all') {
        query = query.eq('subcategory_id', subcategoryFilter)
      }
      if (statusFilter !== 'all') {
        query = query.eq('status', statusFilter)
      }
      if (priorityFilter !== 'all') {
        query = query.eq('is_priority', priorityFilter)
      }

      const { data, error } = await query
      if (error) throw error
      return data as Announcement[]
    },
  })

  // Create/Update mutation
  const saveMutation = useMutation({
    mutationFn: async (data: AnnouncementFormData & { id?: string }) => {
      if (data.id) {
        const { error } = await supabase
          .from('announcements')
          .update(data)
          .eq('id', data.id)
        if (error) throw error
      } else {
        const { error } = await supabase.from('announcements').insert([data])
        if (error) throw error
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['announcements'] })
      toast.success(editingAnnouncement ? '공고가 수정되었습니다' : '공고가 추가되었습니다')
      handleCloseDialog()
    },
    onError: (error: Error) => {
      toast.error(`오류: ${error.message}`)
    },
  })

  // Delete mutation
  const deleteMutation = useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from('announcements').delete().eq('id', id)
      if (error) throw error
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['announcements'] })
      toast.success('공고가 삭제되었습니다')
    },
    onError: (error: Error) => {
      toast.error(`삭제 실패: ${error.message}`)
    },
  })

  // Toggle priority mutation
  const togglePriorityMutation = useMutation({
    mutationFn: async ({ id, is_priority }: { id: string; is_priority: boolean }) => {
      const { error } = await supabase
        .from('announcements')
        .update({ is_priority })
        .eq('id', id)
      if (error) throw error
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['announcements'] })
    },
  })

  const handleOpenDialog = (announcement?: Announcement) => {
    if (announcement) {
      setEditingAnnouncement(announcement)
      setFormData({
        title: announcement.title,
        subtitle: announcement.subtitle,
        organization: announcement.organization,
        category_id: announcement.category_id,
        subcategory_id: announcement.subcategory_id,
        thumbnail_url: announcement.thumbnail_url,
        external_url: announcement.external_url,
        detail_url: announcement.detail_url,
        status: announcement.status,
        is_featured: announcement.is_featured,
        is_home_visible: announcement.is_home_visible,
        is_priority: announcement.is_priority,
        display_priority: announcement.display_priority,
        tags: announcement.tags,
        content: announcement.content,
        region: announcement.region,
        application_start_date: announcement.application_start_date,
        application_end_date: announcement.application_end_date,
        deadline_date: announcement.deadline_date,
        link_type: announcement.link_type,
      })
    } else {
      setEditingAnnouncement(null)
      setFormData({
        title: '',
        subtitle: null,
        organization: '',
        category_id: categoryFilter !== 'all' ? categoryFilter : null,
        subcategory_id: subcategoryFilter !== 'all' ? subcategoryFilter : null,
        thumbnail_url: null,
        external_url: null,
        detail_url: null,
        status: 'recruiting',
        is_featured: false,
        is_home_visible: false,
        is_priority: false,
        display_priority: 0,
        tags: null,
        content: null,
        region: null,
        application_start_date: null,
        application_end_date: null,
        deadline_date: null,
        link_type: 'none',
      })
    }
    setDialogOpen(true)
  }

  const handleCloseDialog = () => {
    setDialogOpen(false)
    setEditingAnnouncement(null)
  }

  const handleSave = () => {
    // Validation
    if (!formData.title.trim()) {
      toast.error('제목을 입력하세요')
      return
    }
    if (!formData.organization.trim()) {
      toast.error('기관명을 입력하세요')
      return
    }
    if (!formData.category_id) {
      toast.error('카테고리를 선택하세요')
      return
    }
    if (!formData.subcategory_id) {
      toast.error('하위분류를 선택하세요')
      return
    }

    saveMutation.mutate({
      ...formData,
      ...(editingAnnouncement && { id: editingAnnouncement.id }),
    })
  }

  const handleDelete = (id: string) => {
    if (window.confirm('이 공고를 삭제하시겠습니까? 관련된 탭 정보도 함께 삭제됩니다.')) {
      deleteMutation.mutate(id)
    }
  }

  const handleOpenTabEditor = (announcementId: string) => {
    setSelectedAnnouncementForTabs(announcementId)
    setTabEditorOpen(true)
  }

  const getStatusColor = (status: AnnouncementStatus) => {
    switch (status) {
      case 'recruiting': return 'success'
      case 'closed': return 'error'
      case 'upcoming': return 'info'
      case 'draft': return 'default'
      default: return 'default'
    }
  }

  const getStatusLabel = (status: AnnouncementStatus) => {
    switch (status) {
      case 'recruiting': return '모집중'
      case 'closed': return '마감'
      case 'upcoming': return '예정'
      case 'draft': return '임시저장'
      default: return status
    }
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
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Box>
          <Typography variant="h4">공고 관리</Typography>
          <Typography variant="body2" color="text.secondary" sx={{ mt: 0.5 }}>
            PRD v9.6 Section 4.2 & 5.4 - 공고 및 탭 통합 관리
          </Typography>
        </Box>
        <Button variant="contained" startIcon={<AddIcon />} onClick={() => handleOpenDialog()}>
          공고 추가
        </Button>
      </Box>

      {/* Filters */}
      <Paper sx={{ p: 2, mb: 3 }}>
        <Grid container spacing={2}>
          <Grid item xs={12} sm={6} md={3}>
            <FormControl fullWidth size="small">
              <InputLabel>카테고리</InputLabel>
              <Select
                value={categoryFilter}
                onChange={(e) => {
                  setCategoryFilter(e.target.value)
                  setSubcategoryFilter('all')
                }}
                label="카테고리"
              >
                <MenuItem value="all">전체</MenuItem>
                {categories.map((cat) => (
                  <MenuItem key={cat.id} value={cat.id}>{cat.title}</MenuItem>
                ))}
              </Select>
            </FormControl>
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <FormControl fullWidth size="small">
              <InputLabel>하위분류</InputLabel>
              <Select
                value={subcategoryFilter}
                onChange={(e) => setSubcategoryFilter(e.target.value)}
                label="하위분류"
                disabled={categoryFilter === 'all'}
              >
                <MenuItem value="all">전체</MenuItem>
                {subcategories.map((sub) => (
                  <MenuItem key={sub.id} value={sub.id}>{sub.name}</MenuItem>
                ))}
              </Select>
            </FormControl>
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <Tabs
              value={statusFilter}
              onChange={(_, newValue) => setStatusFilter(newValue)}
              variant="scrollable"
              scrollButtons="auto"
            >
              <Tab label="전체" value="all" />
              <Tab label="모집중" value="recruiting" />
              <Tab label="마감" value="closed" />
              <Tab label="예정" value="upcoming" />
              <Tab label="임시저장" value="draft" />
            </Tabs>
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <FormControl fullWidth size="small">
              <InputLabel>우선표시</InputLabel>
              <Select
                value={priorityFilter}
                onChange={(e) => setPriorityFilter(e.target.value)}
                label="우선표시"
              >
                <MenuItem value="all">전체</MenuItem>
                <MenuItem value={true}>우선표시만</MenuItem>
                <MenuItem value={false}>일반</MenuItem>
              </Select>
            </FormControl>
          </Grid>
        </Grid>
      </Paper>

      {/* Announcements Table */}
      <Paper>
        <TableContainer>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell width={40}></TableCell>
                <TableCell width={80}>썸네일</TableCell>
                <TableCell>제목</TableCell>
                <TableCell width={100}>카테고리</TableCell>
                <TableCell width={100}>하위분류</TableCell>
                <TableCell width={100}>기관</TableCell>
                <TableCell width={100}>신청기간</TableCell>
                <TableCell width={80}>상태</TableCell>
                <TableCell width={150}>작업</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {announcements.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={9} align="center">
                    등록된 공고가 없습니다
                  </TableCell>
                </TableRow>
              ) : (
                announcements.map((announcement) => (
                  <TableRow key={announcement.id}>
                    <TableCell>
                      <IconButton
                        size="small"
                        onClick={() => togglePriorityMutation.mutate({
                          id: announcement.id,
                          is_priority: !announcement.is_priority
                        })}
                        color={announcement.is_priority ? 'warning' : 'default'}
                      >
                        {announcement.is_priority ? <Star fontSize="small" /> : <StarBorder fontSize="small" />}
                      </IconButton>
                    </TableCell>
                    <TableCell>
                      {announcement.thumbnail_url && (
                        <Box
                          component="img"
                          src={announcement.thumbnail_url}
                          alt={announcement.title}
                          sx={{ width: 60, height: 40, objectFit: 'cover', borderRadius: 1 }}
                        />
                      )}
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2" fontWeight="medium">
                        {announcement.title}
                      </Typography>
                      {announcement.subtitle && (
                        <Typography variant="caption" color="text.secondary">
                          {announcement.subtitle}
                        </Typography>
                      )}
                    </TableCell>
                    <TableCell>
                      <Chip label={announcement.category?.title || '-'} size="small" />
                    </TableCell>
                    <TableCell>
                      <Chip label={announcement.subcategory?.name || '-'} size="small" variant="outlined" />
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2">{announcement.organization}</Typography>
                    </TableCell>
                    <TableCell>
                      <Typography variant="caption">
                        {announcement.application_start_date
                          ? new Date(announcement.application_start_date).toLocaleDateString()
                          : '-'}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Chip
                        label={getStatusLabel(announcement.status)}
                        color={getStatusColor(announcement.status)}
                        size="small"
                      />
                    </TableCell>
                    <TableCell>
                      <IconButton size="small" onClick={() => handleOpenTabEditor(announcement.id)}>
                        <ListIcon fontSize="small" />
                      </IconButton>
                      <IconButton size="small" onClick={() => handleOpenDialog(announcement)}>
                        <EditIcon fontSize="small" />
                      </IconButton>
                      <IconButton size="small" color="error" onClick={() => handleDelete(announcement.id)}>
                        <DeleteIcon fontSize="small" />
                      </IconButton>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </TableContainer>
      </Paper>

      {/* Create/Edit Dialog */}
      <Dialog open={dialogOpen} onClose={handleCloseDialog} maxWidth="md" fullWidth>
        <DialogTitle>{editingAnnouncement ? '공고 수정' : '공고 추가'}</DialogTitle>
        <DialogContent>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, pt: 2 }}>
            <Grid container spacing={2}>
              <Grid item xs={6}>
                <FormControl fullWidth required>
                  <InputLabel>카테고리</InputLabel>
                  <Select
                    value={formData.category_id || ''}
                    onChange={(e) => {
                      setFormData({ ...formData, category_id: e.target.value, subcategory_id: null })
                    }}
                    label="카테고리"
                  >
                    <MenuItem value="">선택하세요</MenuItem>
                    {categories.map((cat) => (
                      <MenuItem key={cat.id} value={cat.id}>{cat.title}</MenuItem>
                    ))}
                  </Select>
                </FormControl>
              </Grid>
              <Grid item xs={6}>
                <FormControl fullWidth required>
                  <InputLabel>하위분류</InputLabel>
                  <Select
                    value={formData.subcategory_id || ''}
                    onChange={(e) => setFormData({ ...formData, subcategory_id: e.target.value })}
                    label="하위분류"
                    disabled={!formData.category_id}
                  >
                    <MenuItem value="">선택하세요</MenuItem>
                    {subcategories
                      .filter(sub => sub.category_id === formData.category_id)
                      .map((sub) => (
                        <MenuItem key={sub.id} value={sub.id}>{sub.name}</MenuItem>
                      ))}
                  </Select>
                </FormControl>
              </Grid>
            </Grid>

            <TextField
              label="공고 제목"
              value={formData.title}
              onChange={(e) => setFormData({ ...formData, title: e.target.value })}
              fullWidth
              required
            />

            <TextField
              label="부제목"
              value={formData.subtitle || ''}
              onChange={(e) => setFormData({ ...formData, subtitle: e.target.value || null })}
              fullWidth
            />

            <Grid container spacing={2}>
              <Grid item xs={6}>
                <TextField
                  label="기관명"
                  value={formData.organization}
                  onChange={(e) => setFormData({ ...formData, organization: e.target.value })}
                  fullWidth
                  required
                />
              </Grid>
              <Grid item xs={6}>
                <TextField
                  label="지역"
                  value={formData.region || ''}
                  onChange={(e) => setFormData({ ...formData, region: e.target.value || null })}
                  fullWidth
                />
              </Grid>
            </Grid>

            <ImageUploader
              bucket="benefit-thumbnails"
              currentImageUrl={formData.thumbnail_url}
              onUploadComplete={(url) => {
                setFormData({ ...formData, thumbnail_url: url })
              }}
              onDelete={() => {
                setFormData({ ...formData, thumbnail_url: null })
              }}
              label="썸네일 이미지"
              helperText="공고 썸네일 이미지를 업로드하세요 (권장 크기: 800x600px)"
              acceptedFormats={['image/jpeg', 'image/png', 'image/webp']}
            />

            <Grid container spacing={2}>
              <Grid item xs={6}>
                <TextField
                  label="신청 시작일"
                  type="date"
                  value={formData.application_start_date || ''}
                  onChange={(e) => setFormData({ ...formData, application_start_date: e.target.value || null })}
                  fullWidth
                  InputLabelProps={{ shrink: true }}
                />
              </Grid>
              <Grid item xs={6}>
                <TextField
                  label="신청 마감일"
                  type="date"
                  value={formData.application_end_date || ''}
                  onChange={(e) => setFormData({ ...formData, application_end_date: e.target.value || null })}
                  fullWidth
                  InputLabelProps={{ shrink: true }}
                />
              </Grid>
            </Grid>

            <FormControl fullWidth>
              <InputLabel>상태</InputLabel>
              <Select
                value={formData.status}
                onChange={(e) => setFormData({ ...formData, status: e.target.value as AnnouncementStatus })}
                label="상태"
              >
                <MenuItem value="recruiting">모집중</MenuItem>
                <MenuItem value="closed">마감</MenuItem>
                <MenuItem value="upcoming">예정</MenuItem>
                <MenuItem value="draft">임시저장</MenuItem>
              </Select>
            </FormControl>

            <TextField
              label="외부 URL"
              value={formData.external_url || ''}
              onChange={(e) => setFormData({ ...formData, external_url: e.target.value || null })}
              fullWidth
              helperText="공고 상세 페이지 외부 링크"
            />

            <FormControlLabel
              control={
                <Switch
                  checked={formData.is_priority}
                  onChange={(e) => setFormData({ ...formData, is_priority: e.target.checked })}
                />
              }
              label="우선 표시 (상단 고정)"
            />

            <FormControlLabel
              control={
                <Switch
                  checked={formData.is_home_visible}
                  onChange={(e) => setFormData({ ...formData, is_home_visible: e.target.checked })}
                />
              }
              label="홈 화면 노출"
            />

            <FormControlLabel
              control={
                <Switch
                  checked={formData.is_featured}
                  onChange={(e) => setFormData({ ...formData, is_featured: e.target.checked })}
                />
              }
              label="추천 공고"
            />
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDialog}>취소</Button>
          <Button
            onClick={handleSave}
            variant="contained"
            disabled={saveMutation.isPending}
          >
            {editingAnnouncement ? '수정' : '추가'}
          </Button>
        </DialogActions>
      </Dialog>

      {/* Tab Editor Dialog */}
      {selectedAnnouncementForTabs && (
        <AnnouncementTabEditor
          open={tabEditorOpen}
          announcementId={selectedAnnouncementForTabs}
          onClose={() => {
            setTabEditorOpen(false)
            setSelectedAnnouncementForTabs(null)
          }}
        />
      )}
    </Box>
  )
}
