/**
 * Announcement Modal Component (v9.0)
 * Form modal for creating/editing benefit announcements
 * Uses React Hook Form + Zod validation
 */

import { useEffect, useState } from 'react'
import { useQueryClient, useMutation } from '@tanstack/react-query'
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Grid,
  Button,
  Typography,
  Paper,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Switch,
  FormControlLabel,
} from '@mui/material'
import { Upload as UploadIcon } from '@mui/icons-material'
import { useForm, Controller } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import toast from 'react-hot-toast'
import { supabase } from '@/lib/supabase'
import { uploadAnnouncementThumbnail } from '@/utils/storage'
import type { BenefitAnnouncement } from '@/types/benefit'

const announcementSchema = z.object({
  category_id: z.string(),
  benefit_detail_id: z.string(),
  title: z.string().min(1, '제목을 입력하세요'),
  subtitle: z.string().nullable(),
  organization: z.string().min(1, '모집기관을 입력하세요'),
  summary: z.string().nullable(),
  thumbnail_url: z.string().nullable(),
  external_url: z.string().url('올바른 URL을 입력하세요').or(z.literal('')).nullable(),
  application_period_start: z.string().nullable(),
  application_period_end: z.string().nullable(),
  status: z.enum(['draft', 'published', 'archived']),
  is_featured: z.boolean(),
  display_order: z.number().int().min(0),
  region: z.string().nullable(),
})

type AnnouncementFormData = z.infer<typeof announcementSchema>

interface AnnouncementModalProps {
  open: boolean
  onClose: () => void
  detailId: string
  categoryId: string
  editingAnnouncement: BenefitAnnouncement | null
}

export default function AnnouncementModal({
  open,
  onClose,
  detailId,
  categoryId,
  editingAnnouncement,
}: AnnouncementModalProps) {
  const queryClient = useQueryClient()
  const [thumbnailFile, setThumbnailFile] = useState<File | null>(null)
  const [thumbnailPreview, setThumbnailPreview] = useState<string | null>(null)

  const {
    control,
    handleSubmit,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<AnnouncementFormData>({
    resolver: zodResolver(announcementSchema),
    defaultValues: {
      category_id: categoryId,
      benefit_detail_id: detailId,
      title: '',
      subtitle: null,
      organization: '',
      summary: null,
      thumbnail_url: null,
      external_url: null,
      application_period_start: null,
      application_period_end: null,
      status: 'draft',
      is_featured: false,
      display_order: 0,
      region: null,
    },
  })

  // Reset form when dialog opens/closes or editing announcement changes
  useEffect(() => {
    if (open) {
      if (editingAnnouncement) {
        reset({
          category_id: editingAnnouncement.category_id,
          benefit_detail_id: editingAnnouncement.benefit_detail_id || detailId,
          title: editingAnnouncement.title,
          subtitle: editingAnnouncement.subtitle,
          organization: editingAnnouncement.organization,
          summary: editingAnnouncement.summary,
          thumbnail_url: editingAnnouncement.thumbnail_url,
          external_url: editingAnnouncement.external_url,
          application_period_start: editingAnnouncement.application_period_start,
          application_period_end: editingAnnouncement.application_period_end,
          status: editingAnnouncement.status as 'draft' | 'published' | 'archived',
          is_featured: editingAnnouncement.is_featured,
          display_order: editingAnnouncement.display_order,
          region: (editingAnnouncement.custom_data as any)?.region || null,
        })
        setThumbnailPreview(editingAnnouncement.thumbnail_url)
      } else {
        reset({
          category_id: categoryId,
          benefit_detail_id: detailId,
          title: '',
          subtitle: null,
          organization: '',
          summary: null,
          thumbnail_url: null,
          external_url: null,
          application_period_start: null,
          application_period_end: null,
          status: 'draft',
          is_featured: false,
          display_order: 0,
          region: null,
        })
        setThumbnailPreview(null)
      }
      setThumbnailFile(null)
    }
  }, [open, editingAnnouncement, categoryId, detailId, reset])

  // Save mutation
  const saveMutation = useMutation({
    mutationFn: async (formData: AnnouncementFormData) => {
      let thumbnailUrl = formData.thumbnail_url

      // Upload thumbnail if file is selected
      if (thumbnailFile) {
        try {
          const uploadResult = await uploadAnnouncementThumbnail(thumbnailFile)
          thumbnailUrl = uploadResult.url
        } catch (error) {
          console.error('Thumbnail upload failed:', error)
          toast.error('썸네일 업로드에 실패했습니다')
        }
      }

      // Prepare data with custom_data for region
      const dataToSave = {
        category_id: formData.category_id,
        benefit_detail_id: formData.benefit_detail_id,
        title: formData.title,
        subtitle: formData.subtitle,
        organization: formData.organization,
        summary: formData.summary,
        thumbnail_url: thumbnailUrl,
        external_url: formData.external_url,
        application_period_start: formData.application_period_start,
        application_period_end: formData.application_period_end,
        status: formData.status,
        is_featured: formData.is_featured,
        display_order: formData.display_order,
        custom_data: {
          region: formData.region,
        },
      }

      if (editingAnnouncement) {
        // Update existing
        const { data, error } = await supabase
          .from('benefit_announcements')
          .update(dataToSave)
          .eq('id', editingAnnouncement.id)
          .select()
          .single()

        if (error) throw error
        return data
      } else {
        // Insert new
        const { data, error } = await supabase
          .from('benefit_announcements')
          .insert(dataToSave)
          .select()
          .single()

        if (error) throw error
        return data
      }
    },
    onSuccess: () => {
      toast.success(editingAnnouncement ? '공고가 수정되었습니다' : '공고가 추가되었습니다')
      queryClient.invalidateQueries({ queryKey: ['benefit_announcements', detailId] })
      onClose()
    },
    onError: (error: Error) => {
      toast.error(error.message || '저장에 실패했습니다')
    },
  })

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

  const onSubmit = (data: AnnouncementFormData) => {
    saveMutation.mutate(data)
  }

  return (
    <Dialog open={open} onClose={onClose} maxWidth="md" fullWidth>
      <DialogTitle>{editingAnnouncement ? '공고 수정' : '공고 추가'}</DialogTitle>
      <form onSubmit={handleSubmit(onSubmit)}>
        <DialogContent>
          <Grid container spacing={2}>
            {/* Title */}
            <Grid item xs={12}>
              <Controller
                name="title"
                control={control}
                render={({ field }) => (
                  <TextField
                    {...field}
                    fullWidth
                    label="공고 제목 *"
                    error={!!errors.title}
                    helperText={errors.title?.message}
                    placeholder="예: LH 행복주택 12월 모집공고"
                  />
                )}
              />
            </Grid>

            {/* Subtitle */}
            <Grid item xs={12}>
              <Controller
                name="subtitle"
                control={control}
                render={({ field }) => (
                  <TextField
                    {...field}
                    value={field.value || ''}
                    fullWidth
                    label="부제목"
                    placeholder="공고 부제목 (선택)"
                  />
                )}
              />
            </Grid>

            {/* Organization & Region */}
            <Grid item xs={6}>
              <Controller
                name="organization"
                control={control}
                render={({ field }) => (
                  <TextField
                    {...field}
                    fullWidth
                    label="모집기관 *"
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
                    label="지역"
                    placeholder="예: 서울, 경기, 전국"
                  />
                )}
              />
            </Grid>

            {/* Summary */}
            <Grid item xs={12}>
              <Controller
                name="summary"
                control={control}
                render={({ field }) => (
                  <TextField
                    {...field}
                    value={field.value || ''}
                    fullWidth
                    label="요약 설명"
                    multiline
                    rows={2}
                    placeholder="공고 요약 설명"
                  />
                )}
              />
            </Grid>

            {/* Thumbnail Upload */}
            <Grid item xs={12}>
              <Typography variant="body2" gutterBottom>
                썸네일 이미지
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
                size="small"
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

            {/* Application Period */}
            <Grid item xs={6}>
              <Controller
                name="application_period_start"
                control={control}
                render={({ field }) => (
                  <TextField
                    {...field}
                    value={field.value || ''}
                    fullWidth
                    label="모집 시작일"
                    type="date"
                    InputLabelProps={{ shrink: true }}
                  />
                )}
              />
            </Grid>

            <Grid item xs={6}>
              <Controller
                name="application_period_end"
                control={control}
                render={({ field }) => (
                  <TextField
                    {...field}
                    value={field.value || ''}
                    fullWidth
                    label="모집 종료일"
                    type="date"
                    InputLabelProps={{ shrink: true }}
                  />
                )}
              />
            </Grid>

            {/* External URL */}
            <Grid item xs={12}>
              <Controller
                name="external_url"
                control={control}
                render={({ field }) => (
                  <TextField
                    {...field}
                    value={field.value || ''}
                    fullWidth
                    label="상세 페이지 URL"
                    error={!!errors.external_url}
                    helperText={errors.external_url?.message}
                    placeholder="https://www.lh.or.kr/..."
                  />
                )}
              />
            </Grid>

            {/* Status & Display Order */}
            <Grid item xs={6}>
              <Controller
                name="status"
                control={control}
                render={({ field }) => (
                  <FormControl fullWidth>
                    <InputLabel>상태</InputLabel>
                    <Select {...field} label="상태">
                      <MenuItem value="draft">임시저장</MenuItem>
                      <MenuItem value="published">게시됨</MenuItem>
                      <MenuItem value="archived">보관됨</MenuItem>
                    </Select>
                  </FormControl>
                )}
              />
            </Grid>

            <Grid item xs={6}>
              <Controller
                name="display_order"
                control={control}
                render={({ field }) => (
                  <TextField
                    {...field}
                    onChange={(e) => field.onChange(parseInt(e.target.value) || 0)}
                    fullWidth
                    label="정렬 순서"
                    type="number"
                  />
                )}
              />
            </Grid>

            {/* Featured Toggle */}
            <Grid item xs={12}>
              <Controller
                name="is_featured"
                control={control}
                render={({ field }) => (
                  <FormControlLabel
                    control={<Switch {...field} checked={field.value} />}
                    label="인기 공고로 표시"
                  />
                )}
              />
            </Grid>
          </Grid>
        </DialogContent>
        <DialogActions>
          <Button onClick={onClose}>취소</Button>
          <Button type="submit" variant="contained" disabled={isSubmitting}>
            {editingAnnouncement ? '수정' : '추가'}
          </Button>
        </DialogActions>
      </form>
    </Dialog>
  )
}
