import { useEffect } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { useForm, Controller } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import {
  Box,
  Paper,
  TextField,
  Button,
  Grid,
  Typography,
  CircularProgress,
  MenuItem,
} from '@mui/material'
import toast from 'react-hot-toast'
import {
  fetchBannerById,
  createBanner,
  updateBanner,
} from '@/api/banners'
import { fetchBenefitCategories } from '@/api/categories'
import type { BenefitBannerInsert, BenefitBannerUpdate } from '@/api/banners'

const schema = z.object({
  category_id: z.string().min(1, '카테고리를 선택하세요'),
  title: z.string().min(1, '제목을 입력하세요').max(100, '제목은 100자 이하여야 합니다'),
  subtitle: z.string().max(200, '부제목은 200자 이하여야 합니다').nullable(),
  image_url: z.string().url('유효한 URL을 입력하세요').min(1, '이미지 URL을 입력하세요'),
  background_color: z.string().regex(/^#[0-9A-Fa-f]{6}$/, '유효한 색상 코드를 입력하세요 (예: #E3F2FD)').nullable(),
  link_url: z.string().nullable(),
  display_order: z.number().int().min(0).nullable(),
  is_active: z.boolean(),
})

type FormData = z.infer<typeof schema>

export default function CategoryBannerForm() {
  const { id } = useParams()
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const isEdit = Boolean(id)

  const { data: banner, isLoading: bannerLoading } = useQuery({
    queryKey: ['category-banner', id],
    queryFn: () => fetchBannerById(id!),
    enabled: isEdit,
  })

  const { data: categories = [], isLoading: categoriesLoading } = useQuery({
    queryKey: ['benefit-categories'],
    queryFn: fetchBenefitCategories,
  })

  const {
    control,
    handleSubmit,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({
    resolver: zodResolver(schema),
    defaultValues: {
      category_id: '',
      title: '',
      subtitle: null,
      image_url: '',
      background_color: '#E3F2FD',
      link_url: null,
      display_order: null,
      is_active: true,
    },
  })

  useEffect(() => {
    if (banner) {
      reset({
        category_id: banner.category_id,
        title: banner.title,
        subtitle: banner.subtitle,
        image_url: banner.image_url,
        background_color: '#E3F2FD', // ❌ REMOVED: banner.background_color (field doesn't exist in DB)
        link_url: banner.link_url,
        display_order: banner.display_order,
        is_active: banner.is_active,
      })
    }
  }, [banner, reset])

  const mutation = useMutation({
    mutationFn: (data: FormData) => {
      const payload = {
        category_id: data.category_id,
        title: data.title,
        subtitle: data.subtitle,
        image_url: data.image_url,
        link_url: data.link_url,
        background_color: data.background_color,
        display_order: data.display_order || 0,
        is_active: data.is_active,
      }

      return isEdit
        ? updateBanner(id!, payload as BenefitBannerUpdate)
        : createBanner(payload as BenefitBannerInsert)
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['category-banners'] })
      toast.success(isEdit ? '배너가 수정되었습니다' : '배너가 등록되었습니다')
      navigate('/banners')
    },
    onError: (error: Error) => {
      const message = error.message || (isEdit ? '수정에 실패했습니다' : '등록에 실패했습니다')
      toast.error(message)

      if (message.includes('세션이 만료')) {
        setTimeout(() => navigate('/login'), 2000)
      }
    },
  })

  const onSubmit = (data: FormData) => {
    mutation.mutate(data)
  }

  if (bannerLoading || categoriesLoading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', mt: 4 }}>
        <CircularProgress />
      </Box>
    )
  }

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        {isEdit ? '배너 수정' : '배너 등록'}
      </Typography>

      <Paper sx={{ mt: 2, p: 3 }}>
        <form onSubmit={handleSubmit(onSubmit)}>
          <Grid container spacing={3}>
            <Grid item xs={12} md={6}>
              <Controller
                name="category_id"
                control={control}
                render={({ field }) => (
                  <TextField
                    {...field}
                    select
                    fullWidth
                    label="카테고리"
                    required
                    error={!!errors.category_id}
                    helperText={errors.category_id?.message}
                  >
                    {categories.map((category: any) => (
                      <MenuItem key={category.id} value={category.id}>
                        {category.title}
                      </MenuItem>
                    ))}
                  </TextField>
                )}
              />
            </Grid>

            <Grid item xs={12} md={6}>
              <Controller
                name="display_order"
                control={control}
                render={({ field }) => (
                  <TextField
                    {...field}
                    value={field.value ?? ''}
                    onChange={(e) =>
                      field.onChange(e.target.value ? parseInt(e.target.value) : null)
                    }
                    fullWidth
                    label="표시 순서"
                    type="number"
                    error={!!errors.display_order}
                    helperText={errors.display_order?.message || '작은 숫자일수록 먼저 표시됩니다'}
                  />
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
                    label="제목"
                    required
                    error={!!errors.title}
                    helperText={errors.title?.message}
                  />
                )}
              />
            </Grid>

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
                    error={!!errors.subtitle}
                    helperText={errors.subtitle?.message}
                  />
                )}
              />
            </Grid>

            <Grid item xs={12}>
              <Controller
                name="image_url"
                control={control}
                render={({ field }) => (
                  <TextField
                    {...field}
                    fullWidth
                    label="이미지 URL"
                    required
                    placeholder="https://picsum.photos/seed/example/800/400"
                    error={!!errors.image_url}
                    helperText={errors.image_url?.message || '배너 이미지 URL (권장 크기: 800x400)'}
                  />
                )}
              />
            </Grid>

            <Grid item xs={12} md={6}>
              <Controller
                name="background_color"
                control={control}
                render={({ field }) => (
                  <TextField
                    {...field}
                    value={field.value || ''}
                    fullWidth
                    label="배경 색상"
                    placeholder="#E3F2FD"
                    error={!!errors.background_color}
                    helperText={errors.background_color?.message || '6자리 Hex 색상 코드 (예: #E3F2FD)'}
                  />
                )}
              />
            </Grid>

            <Grid item xs={12} md={6}>
              <Controller
                name="is_active"
                control={control}
                render={({ field }) => (
                  <TextField
                    {...field}
                    select
                    fullWidth
                    label="활성화"
                    value={field.value ? 'true' : 'false'}
                    onChange={(e) => field.onChange(e.target.value === 'true')}
                  >
                    <MenuItem value="true">활성</MenuItem>
                    <MenuItem value="false">비활성</MenuItem>
                  </TextField>
                )}
              />
            </Grid>

            <Grid item xs={12}>
              <Controller
                name="link_url"
                control={control}
                render={({ field }) => (
                  <TextField
                    {...field}
                    value={field.value || ''}
                    fullWidth
                    label="액션 URL"
                    placeholder="/benefits/housing/youth-housing"
                    error={!!errors.link_url}
                    helperText={errors.link_url?.message || '배너 클릭 시 이동할 URL (선택사항)'}
                  />
                )}
              />
            </Grid>
          </Grid>

          <Box sx={{ display: 'flex', gap: 2, justifyContent: 'flex-end', mt: 3 }}>
            <Button variant="outlined" onClick={() => navigate('/banners')}>
              취소
            </Button>
            <Button
              type="submit"
              variant="contained"
              disabled={isSubmitting}
            >
              {isSubmitting ? '저장 중...' : isEdit ? '수정' : '등록'}
            </Button>
          </Box>
        </form>
      </Paper>
    </Box>
  )
}
