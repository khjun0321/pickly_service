/**
 * Benefit Detail Modal Component
 * Form modal for creating/editing benefit details (policies/programs)
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
  Switch,
  FormControlLabel,
  Button,
  Typography,
  Paper,
} from '@mui/material'
import { Upload as UploadIcon } from '@mui/icons-material'
import { useForm, Controller } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import toast from 'react-hot-toast'
import { supabase } from '@/lib/supabase'
import { uploadBenefitIcon } from '@/utils/storage'
import type { BenefitDetail, BenefitDetailFormData } from '@/types/benefit'

const detailSchema = z.object({
  benefit_category_id: z.string(),
  title: z.string().min(1, '정책명을 입력하세요'),
  description: z.string().nullable(),
  icon_url: z.string().nullable(),
  sort_order: z.number().int().min(0),
  is_active: z.boolean(),
})

interface BenefitDetailModalProps {
  open: boolean
  onClose: () => void
  categoryId: string
  editingDetail: BenefitDetail | null
  detailsCount: number
}

export default function BenefitDetailModal({
  open,
  onClose,
  categoryId,
  editingDetail,
  detailsCount,
}: BenefitDetailModalProps) {
  const queryClient = useQueryClient()
  const [iconFile, setIconFile] = useState<File | null>(null)
  const [iconPreview, setIconPreview] = useState<string | null>(null)

  const {
    control,
    handleSubmit,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<BenefitDetailFormData>({
    resolver: zodResolver(detailSchema),
    defaultValues: {
      benefit_category_id: categoryId,
      title: '',
      description: null,
      icon_url: null,
      sort_order: 0,
      is_active: true,
    },
  })

  // Reset form when dialog opens/closes or editing detail changes
  useEffect(() => {
    if (open) {
      if (editingDetail) {
        reset({
          benefit_category_id: editingDetail.benefit_category_id,
          title: editingDetail.title,
          description: editingDetail.description,
          icon_url: editingDetail.icon_url,
          sort_order: editingDetail.sort_order,
          is_active: editingDetail.is_active,
        })
        setIconPreview(editingDetail.icon_url)
      } else {
        reset({
          benefit_category_id: categoryId,
          title: '',
          description: null,
          icon_url: null,
          sort_order: detailsCount,
          is_active: true,
        })
        setIconPreview(null)
      }
      setIconFile(null)
    }
  }, [open, editingDetail, categoryId, detailsCount, reset])

  // Save mutation
  const saveMutation = useMutation({
    mutationFn: async (formData: BenefitDetailFormData) => {
      let iconUrl = formData.icon_url

      // Upload icon if file is selected
      if (iconFile) {
        try {
          const uploadResult = await uploadBenefitIcon(iconFile)
          iconUrl = uploadResult.url
        } catch (error) {
          console.error('Icon upload failed:', error)
          toast.error('아이콘 업로드에 실패했습니다')
        }
      }

      const dataToSave = {
        ...formData,
        icon_url: iconUrl,
      }

      if (editingDetail) {
        // Update existing
        const { data, error } = await supabase
          .from('benefit_details')
          .update(dataToSave)
          .eq('id', editingDetail.id)
          .select()
          .single()

        if (error) throw error
        return data
      } else {
        // Insert new
        const { data, error } = await supabase
          .from('benefit_details')
          .insert(dataToSave)
          .select()
          .single()

        if (error) throw error
        return data
      }
    },
    onSuccess: () => {
      toast.success(editingDetail ? '정책이 수정되었습니다' : '정책이 추가되었습니다')
      queryClient.invalidateQueries({ queryKey: ['benefit_details', categoryId] })
      onClose()
    },
    onError: (error: Error) => {
      toast.error(error.message || '저장에 실패했습니다')
    },
  })

  const handleIconSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (!file) return

    // Validate SVG file type (following age category pattern)
    if (file.type !== 'image/svg+xml') {
      toast.error('SVG 파일만 업로드 가능합니다')
      return
    }

    if (file.size > 1 * 1024 * 1024) {
      toast.error('파일 크기는 1MB 이하여야 합니다')
      return
    }

    setIconFile(file)
    setIconPreview(URL.createObjectURL(file))
  }

  const onSubmit = (data: BenefitDetailFormData) => {
    saveMutation.mutate(data)
  }

  return (
    <Dialog open={open} onClose={onClose} maxWidth="sm" fullWidth>
      <DialogTitle>{editingDetail ? '정책 수정' : '정책 추가'}</DialogTitle>
      <form onSubmit={handleSubmit(onSubmit)}>
        <DialogContent>
          <Grid container spacing={2}>
            <Grid item xs={12}>
              <Controller
                name="title"
                control={control}
                render={({ field }) => (
                  <TextField
                    {...field}
                    fullWidth
                    label="정책명"
                    error={!!errors.title}
                    helperText={errors.title?.message}
                    placeholder="예: 행복주택, 국민임대주택"
                  />
                )}
              />
            </Grid>

            <Grid item xs={12}>
              <Controller
                name="description"
                control={control}
                render={({ field }) => (
                  <TextField
                    {...field}
                    value={field.value || ''}
                    fullWidth
                    label="설명 (선택)"
                    multiline
                    rows={2}
                    placeholder="정책 설명"
                  />
                )}
              />
            </Grid>

            <Grid item xs={12}>
              <Typography variant="body2" gutterBottom>
                아이콘 SVG 업로드
              </Typography>
              {iconPreview && (
                <Paper sx={{ p: 2, mb: 1, display: 'inline-block' }}>
                  <img
                    src={iconPreview}
                    alt="Icon preview"
                    style={{ width: 64, height: 64, objectFit: 'contain' }}
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
                {iconPreview ? 'SVG 변경' : 'SVG 업로드'}
                <input
                  type="file"
                  hidden
                  accept=".svg,image/svg+xml"
                  onChange={handleIconSelect}
                />
              </Button>
              <Typography variant="caption" color="text.secondary" display="block" mt={1}>
                SVG 파일만 가능, 최대 1MB
              </Typography>
            </Grid>

            <Grid item xs={6}>
              <Controller
                name="sort_order"
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

            <Grid item xs={6}>
              <Controller
                name="is_active"
                control={control}
                render={({ field }) => (
                  <FormControlLabel
                    control={<Switch {...field} checked={field.value} />}
                    label="활성화"
                  />
                )}
              />
            </Grid>
          </Grid>
        </DialogContent>
        <DialogActions>
          <Button onClick={onClose}>취소</Button>
          <Button type="submit" variant="contained" disabled={isSubmitting}>
            {editingDetail ? '수정' : '추가'}
          </Button>
        </DialogActions>
      </form>
    </Dialog>
  )
}
