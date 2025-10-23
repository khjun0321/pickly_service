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
  FormControlLabel,
  Switch,
  CircularProgress,
} from '@mui/material'
import toast from 'react-hot-toast'
import { fetchCategoryById, createCategory, updateCategory } from '@/api/categories'

const schema = z.object({
  title: z.string().min(1, '제목을 입력하세요'),
  description: z.string().min(1, '설명을 입력하세요'),
  icon_component: z.string().min(1, '아이콘 컴포넌트를 입력하세요'),
  icon_url: z.string().nullable(),
  min_age: z.number().int().min(0, '0 이상의 숫자를 입력하세요').nullable(),
  max_age: z.number().int().min(0, '0 이상의 숫자를 입력하세요').nullable(),
  sort_order: z.number().int().min(0, '0 이상의 숫자를 입력하세요'),
  is_active: z.boolean(),
})

type FormData = z.infer<typeof schema>

export default function CategoryForm() {
  const { id } = useParams()
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const isEdit = Boolean(id)

  const { data: category, isLoading: categoryLoading } = useQuery({
    queryKey: ['category', id],
    queryFn: () => fetchCategoryById(id!),
    enabled: isEdit,
  })

  const {
    control,
    handleSubmit,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({
    resolver: zodResolver(schema),
    defaultValues: {
      title: '',
      description: '',
      icon_component: '',
      icon_url: null,
      min_age: null,
      max_age: null,
      sort_order: 0,
      is_active: true,
    },
  })

  useEffect(() => {
    if (category) {
      reset(category)
    }
  }, [category, reset])

  const mutation = useMutation({
    mutationFn: (data: FormData) =>
      isEdit ? updateCategory(id!, data) : createCategory(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['categories'] })
      toast.success(isEdit ? '카테고리가 수정되었습니다' : '카테고리가 등록되었습니다')
      navigate('/categories')
    },
    onError: (error: Error) => {
      const message = error.message || (isEdit ? '수정에 실패했습니다' : '등록에 실패했습니다')
      toast.error(message)

      // 세션 만료 시 로그인 페이지로 리다이렉트
      if (message.includes('세션이 만료')) {
        setTimeout(() => navigate('/login'), 2000)
      }
    },
  })

  if (categoryLoading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', mt: 4 }}>
        <CircularProgress />
      </Box>
    )
  }

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        {isEdit ? '카테고리 수정' : '카테고리 등록'}
      </Typography>
      <Paper sx={{ p: 3, mt: 2 }}>
        <form onSubmit={handleSubmit((data) => mutation.mutate(data))}>
          <Grid container spacing={3}>
            <Grid item xs={12}>
              <Controller
                name="title"
                control={control}
                render={({ field }) => (
                  <TextField
                    {...field}
                    fullWidth
                    label="제목"
                    error={!!errors.title}
                    helperText={errors.title?.message}
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
                    fullWidth
                    label="설명"
                    multiline
                    rows={3}
                    error={!!errors.description}
                    helperText={errors.description?.message}
                  />
                )}
              />
            </Grid>
            <Grid item xs={12} md={6}>
              <Controller
                name="icon_component"
                control={control}
                render={({ field }) => (
                  <TextField
                    {...field}
                    fullWidth
                    label="아이콘 컴포넌트"
                    error={!!errors.icon_component}
                    helperText={errors.icon_component?.message}
                  />
                )}
              />
            </Grid>
            <Grid item xs={12} md={6}>
              <Controller
                name="icon_url"
                control={control}
                render={({ field }) => (
                  <TextField
                    {...field}
                    value={field.value || ''}
                    fullWidth
                    label="아이콘 URL (선택)"
                    error={!!errors.icon_url}
                    helperText={errors.icon_url?.message}
                  />
                )}
              />
            </Grid>
            <Grid item xs={12} md={4}>
              <Controller
                name="min_age"
                control={control}
                render={({ field }) => (
                  <TextField
                    {...field}
                    value={field.value || ''}
                    onChange={(e) => field.onChange(e.target.value ? parseInt(e.target.value) : null)}
                    fullWidth
                    label="최소 나이 (선택)"
                    type="number"
                    error={!!errors.min_age}
                    helperText={errors.min_age?.message}
                  />
                )}
              />
            </Grid>
            <Grid item xs={12} md={4}>
              <Controller
                name="max_age"
                control={control}
                render={({ field }) => (
                  <TextField
                    {...field}
                    value={field.value || ''}
                    onChange={(e) => field.onChange(e.target.value ? parseInt(e.target.value) : null)}
                    fullWidth
                    label="최대 나이 (선택)"
                    type="number"
                    error={!!errors.max_age}
                    helperText={errors.max_age?.message}
                  />
                )}
              />
            </Grid>
            <Grid item xs={12} md={4}>
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
                    error={!!errors.sort_order}
                    helperText={errors.sort_order?.message}
                  />
                )}
              />
            </Grid>
            <Grid item xs={12}>
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
            <Grid item xs={12}>
              <Box sx={{ display: 'flex', gap: 2, justifyContent: 'flex-end' }}>
                <Button
                  type="submit"
                  variant="contained"
                  disabled={isSubmitting}
                >
                  {isEdit ? '수정' : '등록'}
                </Button>
                <Button variant="outlined" onClick={() => navigate('/categories')}>
                  취소
                </Button>
              </Box>
            </Grid>
          </Grid>
        </form>
      </Paper>
    </Box>
  )
}
