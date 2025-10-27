import { useEffect, useState } from 'react'
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
import { Upload as UploadIcon } from '@mui/icons-material'
import toast from 'react-hot-toast'
import { supabase } from '@/lib/supabase'
import { fetchCategoryById, createCategory, updateCategory } from '@/api/categories'

const schema = z.object({
  title: z.string().min(1, '제목을 입력하세요'),
  description: z.string().min(1, '설명을 입력하세요'),
  icon_component: z.string().optional().default('default'), // 선택사항으로 변경
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

  const [iconFile, setIconFile] = useState<File | null>(null)
  const [iconPreview, setIconPreview] = useState<string | null>(null)

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
      icon_component: 'default', // 기본값 설정
      icon_url: null,
      min_age: null,
      max_age: null,
      sort_order: 0,
      is_active: true,
    },
  })

  useEffect(() => {
    if (category) {
      // ✅ FIXED: Map category fields to form data, ensuring type compatibility
      reset({
        title: category.title,
        description: category.description,
        icon_component: category.icon_component,
        icon_url: category.icon_url,
        min_age: category.min_age,
        max_age: category.max_age,
        sort_order: category.sort_order ?? 0, // Convert null to 0
        is_active: category.is_active ?? true, // Convert null to true
      })
      if (category.icon_url) {
        setIconPreview(category.icon_url)
      }
    }
  }, [category, reset])

  const handleIconSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (!file) return

    // SVG 파일만 허용
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

  const mutation = useMutation({
    mutationFn: async (data: FormData) => {
      let iconUrl = data.icon_url

      // Upload icon to Storage if file is selected
      if (iconFile) {
        const fileExt = iconFile.name.split('.').pop()
        const fileName = `age-category-${Date.now()}.${fileExt}`
        const filePath = `icons/age-categories/${fileName}`

        const { error: uploadError } = await supabase.storage
          .from('pickly-storage')
          .upload(filePath, iconFile, {
            upsert: true,
            contentType: iconFile.type,
          })

        if (uploadError) throw uploadError

        const { data: urlData } = supabase.storage
          .from('pickly-storage')
          .getPublicUrl(filePath)

        iconUrl = urlData.publicUrl
      }

      const updateData = {
        ...data,
        icon_url: iconUrl,
      }

      return isEdit ? updateCategory(id!, updateData) : createCategory(updateData)
    },
    onMutate: async (newData) => {
      // Cancel outgoing refetches
      await queryClient.cancelQueries({ queryKey: ['categories'] })

      // Snapshot previous value
      const previousCategories = queryClient.getQueryData(['categories'])

      // Optimistically update
      if (isEdit) {
        queryClient.setQueryData(['categories'], (old: any) => {
          return old?.map((cat: any) =>
            cat.id === id ? { ...cat, ...newData } : cat
          )
        })
      }

      return { previousCategories }
    },
    onError: (error: Error, _newData, context: any) => { // ✅ FIXED: Prefixed unused param with _
      // Rollback on error
      queryClient.setQueryData(['categories'], context.previousCategories)
      const message = error.message || (isEdit ? '수정에 실패했습니다' : '등록에 실패했습니다')
      toast.error(message)

      if (message.includes('세션이 만료')) {
        setTimeout(() => navigate('/login'), 2000)
      }
    },
    onSuccess: async () => {
      toast.success(isEdit ? '카테고리가 수정되었습니다' : '카테고리가 등록되었습니다')

      // Wait a bit for optimistic update to show
      await new Promise(resolve => setTimeout(resolve, 100))

      navigate('/categories')
    },
    onSettled: () => {
      // Refetch in background
      queryClient.invalidateQueries({ queryKey: ['categories'] })
      queryClient.invalidateQueries({ queryKey: ['category', id] })
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
            {/* icon_component는 레거시 필드로 숨김 처리 */}
            <Grid item xs={12}>
              <Box>
                <Typography variant="body2" gutterBottom>
                  아이콘 SVG 업로드 (선택)
                </Typography>
                {iconPreview && (
                  <Paper sx={{ p: 2, mb: 2, display: 'inline-block' }}>
                    <img
                      src={iconPreview}
                      alt="Icon preview"
                      style={{ width: '64px', height: '64px', objectFit: 'contain' }}
                    />
                  </Paper>
                )}
                <Box sx={{ display: 'flex', gap: 2, alignItems: 'center' }}>
                  <Button
                    variant="outlined"
                    component="label"
                    startIcon={<UploadIcon />}
                  >
                    {iconPreview ? 'SVG 변경' : 'SVG 업로드'}
                    <input
                      type="file"
                      hidden
                      accept=".svg,image/svg+xml"
                      onChange={handleIconSelect}
                    />
                  </Button>
                  <Controller
                    name="icon_url"
                    control={control}
                    render={({ field }) => (
                      <TextField
                        {...field}
                        value={field.value || ''}
                        fullWidth
                        label="또는 URL 직접 입력"
                        size="small"
                        error={!!errors.icon_url}
                        helperText={errors.icon_url?.message}
                      />
                    )}
                  />
                </Box>
                <Typography variant="caption" color="text.secondary" sx={{ mt: 1, display: 'block' }}>
                  SVG 파일을 업로드하면 자동으로 Supabase Storage에 저장됩니다. 최대 1MB (SVG만 가능)
                </Typography>
              </Box>
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
