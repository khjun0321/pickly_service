/**
 * Announcement Manager Component
 * Manages announcements with filtering, thumbnails, and status management
 */

import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import {
  Box,
  Paper,
  Typography,
  Button,
  IconButton,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Chip,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Grid,
  Switch,
  FormControlLabel,
  Select,
  MenuItem,
  FormControl,
  InputLabel,
  CircularProgress,
  Tabs,
  Tab,
} from '@mui/material'
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  Upload as UploadIcon,
  Star,
  StarBorder,
} from '@mui/icons-material'
import { useForm, Controller } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import toast from 'react-hot-toast'
import { supabase } from '@/lib/supabase'
import { uploadAnnouncementThumbnail } from '@/utils/storage'
import type { Announcement, AnnouncementFormData, AnnouncementType, AnnouncementStatus } from '@/types/benefit'

interface AnnouncementManagerProps {
  categoryId: string
  categoryTitle: string
}

const announcementSchema = z.object({
  category_id: z.string().nullable(),
  subcategory_id: z.string().min(1, '하위 카테고리를 선택하세요'),
  title: z.string().min(1, '제목을 입력하세요'),
  organization: z.string().min(1, '기관명을 입력하세요'),
  region: z.string().nullable(),
  thumbnail_url: z.string().nullable(),
  application_start_date: z.string().nullable(),
  status: z.enum(['recruiting', 'closed', 'upcoming', 'draft']),
  is_priority: z.boolean(),
  detail_url: z.string().nullable(),
})

export default function AnnouncementManager({ categoryId, categoryTitle }: AnnouncementManagerProps) {
  const queryClient = useQueryClient()
  const [dialogOpen, setDialogOpen] = useState(false)
  const [editingAnnouncement, setEditingAnnouncement] = useState<Announcement | null>(null)
  const [thumbnailFile, setThumbnailFile] = useState<File | null>(null)
  const [thumbnailPreview, setThumbnailPreview] = useState<string | null>(null)
  const [statusFilter, setStatusFilter] = useState<AnnouncementStatus | 'all'>('all')

  // Fetch benefit subcategories for this category
  const { data: subcategories = [] } = useQuery({
    queryKey: ['benefit_subcategories', categoryId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('benefit_subcategories')
        .select('*')
        .eq('category_id', categoryId)
        .eq('is_active', true)
        .order('sort_order', { ascending: true })

      if (error) throw error
      return data
    },
  })

  // Fetch announcements
  const { data: announcements = [], isLoading } = useQuery({
    queryKey: ['announcements', categoryId, statusFilter],
    queryFn: async () => {
      let query = supabase
        .from('announcements')
        .select('*')
        .eq('category_id', categoryId)
        .order('is_priority', { ascending: false })
        .order('application_start_date', { ascending: false })

      if (statusFilter !== 'all') {
        query = query.eq('status', statusFilter)
      }

      const { data, error } = await query

      if (error) throw error
      return data as Announcement[]
    },
  })

  const {
    control,
    handleSubmit,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<AnnouncementFormData>({
    resolver: zodResolver(announcementSchema),
    defaultValues: {
      category_id: categoryId,
      subcategory_id: '',
      title: '',
      organization: '',
      region: null,
      thumbnail_url: null,
      application_start_date: null,
      status: 'recruiting',
      is_priority: false,
      detail_url: null,
    },
  })

  // Save mutation
  const saveMutation = useMutation({
    mutationFn: async (formData: AnnouncementFormData) => {
      let thumbnailUrl = formData.thumbnail_url

      if (thumbnailFile) {
        const uploadResult = await uploadAnnouncementThumbnail(thumbnailFile)
        thumbnailUrl = uploadResult.url
      }

      const dataToSave = {
        ...formData,
        thumbnail_url: thumbnailUrl,
      }

      if (editingAnnouncement) {
        const { data, error } = await supabase
          .from('announcements')
          .update(dataToSave)
          .eq('id', editingAnnouncement.id)
          .select()
          .single()

        if (error) throw error
        return data
      } else {
        const { data, error } = await supabase
          .from('announcements')
          .insert(dataToSave)
          .select()
          .single()

        if (error) throw error
        return data
      }
    },
    onSuccess: () => {
      toast.success(editingAnnouncement ? '공고가 수정되었습니다' : '공고가 추가되었습니다')
      queryClient.invalidateQueries({ queryKey: ['announcements', categoryId] })
      handleCloseDialog()
    },
    onError: (error: Error) => {
      toast.error(error.message || '저장에 실패했습니다')
    },
  })

  // Delete mutation
  const deleteMutation = useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase
        .from('announcements')
        .delete()
        .eq('id', id)

      if (error) throw error
    },
    onSuccess: () => {
      toast.success('공고가 삭제되었습니다')
      queryClient.invalidateQueries({ queryKey: ['announcements', categoryId] })
    },
    onError: (error: Error) => {
      toast.error(error.message || '삭제에 실패했습니다')
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
      queryClient.invalidateQueries({ queryKey: ['announcements', categoryId] })
    },
  })

  const handleOpenDialog = (announcement?: Announcement) => {
    if (announcement) {
      setEditingAnnouncement(announcement)
      reset({
        category_id: announcement.category_id || categoryId,
        subcategory_id: announcement.subcategory_id || '',
        title: announcement.title,
        organization: announcement.organization,
        region: announcement.region,
        thumbnail_url: announcement.thumbnail_url,
        application_start_date: announcement.application_start_date,
        status: announcement.status,
        is_priority: announcement.is_priority,
        detail_url: announcement.detail_url,
      })
      setThumbnailPreview(announcement.thumbnail_url)
    } else {
      setEditingAnnouncement(null)
      reset({
        category_id: categoryId,
        subcategory_id: subcategories.length > 0 ? subcategories[0].id : '',
        title: '',
        organization: '',
        region: null,
        thumbnail_url: null,
        application_start_date: new Date().toISOString().split('T')[0],
        status: 'recruiting',
        is_priority: false,
        detail_url: null,
      })
      setThumbnailPreview(null)
    }
    setThumbnailFile(null)
    setDialogOpen(true)
  }

  const handleCloseDialog = () => {
    setDialogOpen(false)
    setEditingAnnouncement(null)
    setThumbnailFile(null)
    setThumbnailPreview(null)
    reset()
  }

  const handleThumbnailSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (!file) return

    if (!file.type.startsWith('image/')) {
      toast.error('이미지 파일만 업로드 가능합니다')
      return
    }

    if (file.size > 3 * 1024 * 1024) {
      toast.error('파일 크기는 3MB 이하여야 합니다')
      return
    }

    setThumbnailFile(file)
    setThumbnailPreview(URL.createObjectURL(file))
  }

  const handleDelete = async (announcement: Announcement) => {
    if (!window.confirm(`"${announcement.title}" 공고를 삭제하시겠습니까?`)) {
      return
    }
    deleteMutation.mutate(announcement.id)
  }

  const handleTogglePriority = (announcement: Announcement) => {
    togglePriorityMutation.mutate({ id: announcement.id, is_priority: !announcement.is_priority })
  }

  const onSubmit = (data: AnnouncementFormData) => {
    saveMutation.mutate(data)
  }

  const getStatusColor = (status: AnnouncementStatus) => {
    switch (status) {
      case 'recruiting':
        return 'success'
      case 'closed':
        return 'error'
      case 'upcoming':
        return 'info'
      case 'draft':
        return 'default'
      default:
        return 'default'
    }
  }

  const getStatusLabel = (status: AnnouncementStatus) => {
    switch (status) {
      case 'recruiting':
        return '모집중'
      case 'closed':
        return '마감'
      case 'upcoming':
        return '예정'
      case 'draft':
        return '임시저장'
      default:
        return status
    }
  }

  return (
    <Paper sx={{ p: 3 }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2 }}>
        <Typography variant="h6">공고 목록 ({categoryTitle})</Typography>
        <Button
          variant="contained"
          size="small"
          startIcon={<AddIcon />}
          onClick={() => handleOpenDialog()}
          disabled={subcategories.length === 0}
        >
          공고 추가
        </Button>
      </Box>

      {subcategories.length === 0 && (
        <Box sx={{ p: 3, textAlign: 'center' }}>
          <Typography color="text.secondary">
            공고를 추가하려면 먼저 하위 카테고리가 필요합니다
          </Typography>
        </Box>
      )}

      {subcategories.length > 0 && (
        <>
          <Tabs
            value={statusFilter}
            onChange={(_, newValue) => setStatusFilter(newValue)}
            sx={{ mb: 2 }}
          >
            <Tab label="전체" value="all" />
            <Tab label="모집중" value="recruiting" />
            <Tab label="마감" value="closed" />
            <Tab label="예정" value="upcoming" />
            <Tab label="임시저장" value="draft" />
          </Tabs>

          {isLoading ? (
            <Box sx={{ display: 'flex', justifyContent: 'center', p: 3 }}>
              <CircularProgress />
            </Box>
          ) : (
            <TableContainer>
              <Table size="small">
                <TableHead>
                  <TableRow>
                    <TableCell width={40}></TableCell>
                    <TableCell width={80}>썸네일</TableCell>
                    <TableCell>제목</TableCell>
                    <TableCell width={100}>기관</TableCell>
                    <TableCell width={80}>지역</TableCell>
                    <TableCell width={100}>게시일</TableCell>
                    <TableCell width={80}>상태</TableCell>
                    <TableCell width={120}>작업</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {announcements.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={8} align="center">
                        등록된 공고가 없습니다
                      </TableCell>
                    </TableRow>
                  ) : (
                    announcements.map((announcement) => (
                      <TableRow key={announcement.id}>
                        <TableCell>
                          <IconButton
                            size="small"
                            onClick={() => handleTogglePriority(announcement)}
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
                        </TableCell>
                        <TableCell>
                          <Typography variant="body2" color="text.secondary">
                            {announcement.organization}
                          </Typography>
                        </TableCell>
                        <TableCell>
                          <Typography variant="body2" color="text.secondary">
                            {announcement.region || '-'}
                          </Typography>
                        </TableCell>
                        <TableCell>
                          <Typography variant="body2" color="text.secondary">
                            {announcement.application_start_date || '-'}
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
                          <IconButton size="small" onClick={() => handleOpenDialog(announcement)}>
                            <EditIcon fontSize="small" />
                          </IconButton>
                          <IconButton size="small" color="error" onClick={() => handleDelete(announcement)}>
                            <DeleteIcon fontSize="small" />
                          </IconButton>
                        </TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>
            </TableContainer>
          )}
        </>
      )}

      {/* Add/Edit Dialog */}
      <Dialog open={dialogOpen} onClose={handleCloseDialog} maxWidth="md" fullWidth>
        <DialogTitle>{editingAnnouncement ? '공고 수정' : '공고 추가'}</DialogTitle>
        <form onSubmit={handleSubmit(onSubmit)}>
          <DialogContent>
            <Grid container spacing={2}>
              <Grid item xs={12}>
                <Controller
                  name="subcategory_id"
                  control={control}
                  render={({ field }) => (
                    <FormControl fullWidth error={!!errors.subcategory_id}>
                      <InputLabel>하위 카테고리</InputLabel>
                      <Select {...field} label="하위 카테고리">
                        {subcategories.map((subcategory) => (
                          <MenuItem key={subcategory.id} value={subcategory.id}>
                            {subcategory.name}
                          </MenuItem>
                        ))}
                      </Select>
                      {errors.subcategory_id && (
                        <Typography variant="caption" color="error">
                          {errors.subcategory_id.message}
                        </Typography>
                      )}
                    </FormControl>
                  )}
                />
              </Grid>

              <Grid item xs={12}>
                <Controller
                  name="title"
                  control={control}
                  render={({ field }) => (
                    <TextField
                      {...field}
                      fullWidth
                      label="공고 제목"
                      error={!!errors.title}
                      helperText={errors.title?.message}
                    />
                  )}
                />
              </Grid>

              <Grid item xs={6}>
                <Controller
                  name="organization"
                  control={control}
                  render={({ field }) => (
                    <TextField
                      {...field}
                      fullWidth
                      label="발행 기관"
                      error={!!errors.organization}
                      helperText={errors.organization?.message}
                      placeholder="예: LH, SH, GH"
                    />
                  )}
                />
              </Grid>

              <Grid item xs={6}>
                <Controller
                  name="region"
                  control={control}
                  render={({ field }) => (
                    <TextField
                      {...field}
                      value={field.value || ''}
                      fullWidth
                      label="지역 (선택)"
                      placeholder="예: 서울, 경기"
                    />
                  )}
                />
              </Grid>

              <Grid item xs={12}>
                <Typography variant="body2" gutterBottom>
                  썸네일 이미지 업로드
                </Typography>
                {thumbnailPreview && (
                  <Paper sx={{ p: 2, mb: 1, display: 'inline-block' }}>
                    <img
                      src={thumbnailPreview}
                      alt="Thumbnail preview"
                      style={{ maxWidth: '100%', maxHeight: 150, objectFit: 'contain' }}
                    />
                  </Paper>
                )}
                <Button
                  variant="outlined"
                  component="label"
                  startIcon={<UploadIcon />}
                  fullWidth
                >
                  {thumbnailPreview ? '썸네일 변경' : '썸네일 업로드'}
                  <input
                    type="file"
                    hidden
                    accept="image/*"
                    onChange={handleThumbnailSelect}
                  />
                </Button>
                <Typography variant="caption" color="text.secondary" display="block" mt={1}>
                  이미지 파일, 최대 3MB
                </Typography>
              </Grid>

              <Grid item xs={6}>
                <Controller
                  name="application_start_date"
                  control={control}
                  render={({ field }) => (
                    <TextField
                      {...field}
                      value={field.value || ''}
                      fullWidth
                      label="신청 시작일"
                      type="date"
                      InputLabelProps={{ shrink: true }}
                    />
                  )}
                />
              </Grid>

              <Grid item xs={6}>
                <Controller
                  name="status"
                  control={control}
                  render={({ field }) => (
                    <FormControl fullWidth>
                      <InputLabel>상태</InputLabel>
                      <Select {...field} label="상태">
                        <MenuItem value="recruiting">모집중</MenuItem>
                        <MenuItem value="closed">마감</MenuItem>
                        <MenuItem value="upcoming">예정</MenuItem>
                        <MenuItem value="draft">임시저장</MenuItem>
                      </Select>
                    </FormControl>
                  )}
                />
              </Grid>

              <Grid item xs={12}>
                <Controller
                  name="detail_url"
                  control={control}
                  render={({ field }) => (
                    <TextField
                      {...field}
                      value={field.value || ''}
                      fullWidth
                      label="상세 페이지 URL (선택)"
                      placeholder="https://example.com/announcement/123"
                    />
                  )}
                />
              </Grid>

              <Grid item xs={12}>
                <Controller
                  name="is_priority"
                  control={control}
                  render={({ field }) => (
                    <FormControlLabel
                      control={<Switch {...field} checked={field.value} />}
                      label="우선 표시 (상단 고정)"
                    />
                  )}
                />
              </Grid>
            </Grid>
          </DialogContent>
          <DialogActions>
            <Button onClick={handleCloseDialog}>취소</Button>
            <Button type="submit" variant="contained" disabled={isSubmitting}>
              {editingAnnouncement ? '수정' : '추가'}
            </Button>
          </DialogActions>
        </form>
      </Dialog>
    </Paper>
  )
}
