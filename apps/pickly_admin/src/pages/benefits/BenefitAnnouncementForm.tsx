import { useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { useForm, Controller, useFieldArray } from 'react-hook-form'
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
  Tabs,
  Tab,
  MenuItem,
  IconButton,
  FormHelperText,
} from '@mui/material'
import { Add as AddIcon, Delete as DeleteIcon, Upload as UploadIcon } from '@mui/icons-material'
import toast from 'react-hot-toast'
import {
  fetchAnnouncementById as fetchBenefitAnnouncementById,
  createAnnouncement as createBenefitAnnouncement,
  updateAnnouncement as updateBenefitAnnouncement,
} from '@/api/announcements'
import { supabase } from '@/lib/supabase'
import { fetchCategories } from '@/api/categories'
import type { BenefitAnnouncement } from '@/types/database'

// Upload file helper function
async function uploadFile(file: File, bucket: string, folder: string): Promise<string> {
  const fileExt = file.name.split('.').pop()
  const fileName = `${folder}/${Date.now()}-${Math.random().toString(36).substring(7)}.${fileExt}`

  const { error: uploadError, data } = await supabase.storage
    .from(bucket)
    .upload(fileName, file, {
      cacheControl: '3600',
      upsert: false
    })

  if (uploadError) {
    throw uploadError
  }

  const { data: { publicUrl } } = supabase.storage
    .from(bucket)
    .getPublicUrl(fileName)

  return publicUrl
}

const schema = z.object({
  // Basic Info
  title: z.string().min(1, '제목을 입력하세요'),
  subtitle: z.string().nullable(),
  category_id: z.string().min(1, '카테고리를 선택하세요'),
  organization: z.string().nullable(),
  description: z.string().nullable(),
  status: z.string().min(1, '상태를 선택하세요'),

  // Dates
  application_start_date: z.string().nullable(),
  application_end_date: z.string().nullable(),
  announcement_date: z.string().nullable(),
  move_in_date: z.string().nullable(),

  // Images & Files
  thumbnail_url: z.string().nullable(),
  external_url: z.string().nullable(),

  // Requirements
  min_age: z.number().int().min(0).nullable(),
  max_age: z.number().int().min(0).nullable(),
  income_requirement: z.string().nullable(),
  household_requirement: z.string().nullable(),
  special_conditions: z.any().nullable(),

  // Location & Supply
  location: z.string().nullable(),
  supply_count: z.number().int().min(0).nullable(),

  // Contact & Documents
  contact_info: z.any().nullable(),
  documents_required: z.array(z.string()).nullable(),

  // Tags & Settings
  tags: z.array(z.string()).nullable(),
  is_featured: z.boolean(),
  is_active: z.boolean(),
})

type FormData = z.infer<typeof schema>

interface TabPanelProps {
  children?: React.ReactNode
  index: number
  value: number
}

function TabPanel(props: TabPanelProps) {
  const { children, value, index, ...other } = props

  return (
    <div
      role="tabpanel"
      hidden={value !== index}
      id={`tabpanel-${index}`}
      aria-labelledby={`tab-${index}`}
      {...other}
    >
      {value === index && <Box sx={{ py: 3 }}>{children}</Box>}
    </div>
  )
}

export default function BenefitAnnouncementForm() {
  const { id } = useParams()
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const isEdit = Boolean(id)
  const [currentTab, setCurrentTab] = useState(0)
  const [uploadingImage, setUploadingImage] = useState(false)

  const { data: announcement, isLoading: announcementLoading } = useQuery({
    queryKey: ['benefit-announcement', id],
    queryFn: () => fetchBenefitAnnouncementById(id!),
    enabled: isEdit,
  })

  const { data: categories = [], isLoading: categoriesLoading } = useQuery({
    queryKey: ['categories'],
    queryFn: fetchCategories,
  })

  const {
    control,
    handleSubmit,
    reset,
    setValue,
    watch,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({
    resolver: zodResolver(schema),
    defaultValues: {
      title: '',
      subtitle: null,
      category_id: '',
      organization: null,
      description: null,
      status: 'draft',
      application_start_date: null,
      application_end_date: null,
      announcement_date: null,
      move_in_date: null,
      thumbnail_url: null,
      external_url: null,
      min_age: null,
      max_age: null,
      income_requirement: null,
      household_requirement: null,
      special_conditions: null,
      location: null,
      supply_count: null,
      contact_info: null,
      documents_required: [],
      tags: [],
      is_featured: false,
      is_active: true,
    },
  })

  const { fields: docFields, append: appendDoc, remove: removeDoc } = useFieldArray({
    control,
    name: 'documents_required',
  })

  const { fields: tagFields, append: appendTag, remove: removeTag } = useFieldArray({
    control,
    name: 'tags',
  })

  useEffect(() => {
    if (announcement) {
      reset({
        title: announcement.title,
        subtitle: announcement.subtitle,
        category_id: announcement.category_id,
        organization: announcement.organization,
        description: announcement.description,
        status: announcement.status,
        application_start_date: announcement.application_start_date,
        application_end_date: announcement.application_end_date,
        announcement_date: announcement.announcement_date,
        move_in_date: announcement.move_in_date,
        thumbnail_url: announcement.thumbnail_url,
        external_url: announcement.external_url,
        min_age: announcement.min_age,
        max_age: announcement.max_age,
        income_requirement: announcement.income_requirement,
        household_requirement: announcement.household_requirement,
        special_conditions: announcement.special_conditions,
        location: announcement.location,
        supply_count: announcement.supply_count,
        contact_info: announcement.contact_info,
        documents_required: announcement.documents_required || [],
        tags: announcement.tags || [],
        is_featured: announcement.is_featured,
        is_active: announcement.is_active,
      })
    }
  }, [announcement, reset])

  const mutation = useMutation({
    mutationFn: (data: FormData) => {
      const payload = data as unknown as Omit<BenefitAnnouncement, 'id' | 'created_at' | 'updated_at' | 'view_count' | 'bookmark_count'>
      return isEdit
        ? updateBenefitAnnouncement(id!, payload)
        : createBenefitAnnouncement(payload)
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['benefit-announcements'] })
      toast.success(isEdit ? '공고가 수정되었습니다' : '공고가 등록되었습니다')
      navigate('/benefits')
    },
    onError: (error: Error) => {
      const message = error.message || (isEdit ? '수정에 실패했습니다' : '등록에 실패했습니다')
      toast.error(message)

      if (message.includes('세션이 만료')) {
        setTimeout(() => navigate('/login'), 2000)
      }
    },
  })

  const handleImageUpload = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (!file) return

    if (!file.type.startsWith('image/')) {
      toast.error('이미지 파일만 업로드 가능합니다')
      return
    }

    setUploadingImage(true)
    try {
      const url = await uploadFile(file, 'benefit-images', 'thumbnails')
      setValue('thumbnail_url', url)
      toast.success('이미지가 업로드되었습니다')
    } catch (error) {
      toast.error('이미지 업로드에 실패했습니다')
    } finally {
      setUploadingImage(false)
    }
  }

  const onSubmit = (data: FormData) => {
    mutation.mutate(data)
  }

  const onSaveDraft = () => {
    setValue('status', 'draft')
    handleSubmit(onSubmit)()
  }

  const onPublish = () => {
    setValue('status', 'active')
    handleSubmit(onSubmit)()
  }

  if (announcementLoading || categoriesLoading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', mt: 4 }}>
        <CircularProgress />
      </Box>
    )
  }

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        {isEdit ? '공고 수정' : '공고 등록'}
      </Typography>

      <Paper sx={{ mt: 2 }}>
        <Tabs
          value={currentTab}
          onChange={(_, newValue) => setCurrentTab(newValue)}
          sx={{ borderBottom: 1, borderColor: 'divider' }}
        >
          <Tab label="기본 정보" />
          <Tab label="날짜" />
          <Tab label="이미지 & 링크" />
          <Tab label="자격 요건" />
          <Tab label="위치 & 공급" />
          <Tab label="문서 & 연락처" />
        </Tabs>

        <Box sx={{ p: 3 }}>
          <form onSubmit={handleSubmit(onSubmit)}>
            {/* Tab 1: Basic Info */}
            <TabPanel value={currentTab} index={0}>
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
                        {categories.map((category) => (
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
                    name="organization"
                    control={control}
                    render={({ field }) => (
                      <TextField
                        {...field}
                        value={field.value || ''}
                        fullWidth
                        label="주관 기관"
                        error={!!errors.organization}
                        helperText={errors.organization?.message}
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
                        label="상세 설명"
                        multiline
                        rows={6}
                        error={!!errors.description}
                        helperText={errors.description?.message}
                      />
                    )}
                  />
                </Grid>

                <Grid item xs={12} md={6}>
                  <Controller
                    name="status"
                    control={control}
                    render={({ field }) => (
                      <TextField
                        {...field}
                        select
                        fullWidth
                        label="상태"
                        required
                        error={!!errors.status}
                        helperText={errors.status?.message}
                      >
                        <MenuItem value="draft">임시저장</MenuItem>
                        <MenuItem value="active">활성</MenuItem>
                        <MenuItem value="inactive">비활성</MenuItem>
                        <MenuItem value="archived">보관</MenuItem>
                      </TextField>
                    )}
                  />
                </Grid>

                <Grid item xs={12} md={3}>
                  <Controller
                    name="is_featured"
                    control={control}
                    render={({ field }) => (
                      <TextField
                        {...field}
                        select
                        fullWidth
                        label="추천 공고"
                        value={field.value ? 'true' : 'false'}
                        onChange={(e) => field.onChange(e.target.value === 'true')}
                      >
                        <MenuItem value="true">예</MenuItem>
                        <MenuItem value="false">아니오</MenuItem>
                      </TextField>
                    )}
                  />
                </Grid>

                <Grid item xs={12} md={3}>
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
                        <MenuItem value="true">예</MenuItem>
                        <MenuItem value="false">아니오</MenuItem>
                      </TextField>
                    )}
                  />
                </Grid>
              </Grid>
            </TabPanel>

            {/* Tab 2: Dates */}
            <TabPanel value={currentTab} index={1}>
              <Grid container spacing={3}>
                <Grid item xs={12} md={6}>
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
                        error={!!errors.application_start_date}
                        helperText={errors.application_start_date?.message}
                      />
                    )}
                  />
                </Grid>

                <Grid item xs={12} md={6}>
                  <Controller
                    name="application_end_date"
                    control={control}
                    render={({ field }) => (
                      <TextField
                        {...field}
                        value={field.value || ''}
                        fullWidth
                        label="신청 종료일"
                        type="date"
                        InputLabelProps={{ shrink: true }}
                        error={!!errors.application_end_date}
                        helperText={errors.application_end_date?.message}
                      />
                    )}
                  />
                </Grid>

                <Grid item xs={12} md={6}>
                  <Controller
                    name="announcement_date"
                    control={control}
                    render={({ field }) => (
                      <TextField
                        {...field}
                        value={field.value || ''}
                        fullWidth
                        label="발표일"
                        type="date"
                        InputLabelProps={{ shrink: true }}
                        error={!!errors.announcement_date}
                        helperText={errors.announcement_date?.message}
                      />
                    )}
                  />
                </Grid>

                <Grid item xs={12} md={6}>
                  <Controller
                    name="move_in_date"
                    control={control}
                    render={({ field }) => (
                      <TextField
                        {...field}
                        value={field.value || ''}
                        fullWidth
                        label="입주일"
                        type="date"
                        InputLabelProps={{ shrink: true }}
                        error={!!errors.move_in_date}
                        helperText={errors.move_in_date?.message}
                      />
                    )}
                  />
                </Grid>
              </Grid>
            </TabPanel>

            {/* Tab 3: Images & Links */}
            <TabPanel value={currentTab} index={2}>
              <Grid container spacing={3}>
                <Grid item xs={12}>
                  <Typography variant="subtitle1" gutterBottom>
                    썸네일 이미지
                  </Typography>
                  <Box sx={{ display: 'flex', gap: 2, alignItems: 'center', mb: 2 }}>
                    <Button
                      variant="outlined"
                      component="label"
                      startIcon={<UploadIcon />}
                      disabled={uploadingImage}
                    >
                      {uploadingImage ? '업로드 중...' : '이미지 업로드'}
                      <input
                        type="file"
                        hidden
                        accept="image/*"
                        onChange={handleImageUpload}
                      />
                    </Button>
                    <Controller
                      name="thumbnail_url"
                      control={control}
                      render={({ field }) => (
                        <TextField
                          {...field}
                          value={field.value || ''}
                          fullWidth
                          label="썸네일 URL (또는 직접 입력)"
                          error={!!errors.thumbnail_url}
                          helperText={errors.thumbnail_url?.message}
                        />
                      )}
                    />
                  </Box>
                  {watch('thumbnail_url') && (
                    <Box sx={{ mt: 2 }}>
                      <img
                        src={watch('thumbnail_url')!}
                        alt="Thumbnail preview"
                        style={{ maxWidth: '300px', maxHeight: '200px', objectFit: 'contain' }}
                      />
                    </Box>
                  )}
                </Grid>

                <Grid item xs={12}>
                  <Controller
                    name="external_url"
                    control={control}
                    render={({ field }) => (
                      <TextField
                        {...field}
                        value={field.value || ''}
                        fullWidth
                        label="외부 링크 URL"
                        placeholder="https://example.com/announcement"
                        error={!!errors.external_url}
                        helperText={errors.external_url?.message}
                      />
                    )}
                  />
                </Grid>

                <Grid item xs={12}>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2 }}>
                    <Typography variant="subtitle1">태그</Typography>
                    <Button
                      variant="outlined"
                      size="small"
                      startIcon={<AddIcon />}
                      onClick={() => appendTag('')}
                    >
                      추가
                    </Button>
                  </Box>
                  {tagFields.map((field, index) => (
                    <Box key={field.id} sx={{ display: 'flex', gap: 1, mb: 2 }}>
                      <Controller
                        name={`tags.${index}`}
                        control={control}
                        render={({ field }) => (
                          <TextField {...field} fullWidth label={`태그 ${index + 1}`} />
                        )}
                      />
                      <IconButton color="error" onClick={() => removeTag(index)}>
                        <DeleteIcon />
                      </IconButton>
                    </Box>
                  ))}
                  {tagFields.length === 0 && (
                    <FormHelperText>추가 버튼을 눌러 태그를 입력하세요</FormHelperText>
                  )}
                </Grid>
              </Grid>
            </TabPanel>

            {/* Tab 4: Requirements */}
            <TabPanel value={currentTab} index={3}>
              <Grid container spacing={3}>
                <Grid item xs={12} md={6}>
                  <Controller
                    name="min_age"
                    control={control}
                    render={({ field }) => (
                      <TextField
                        {...field}
                        value={field.value || ''}
                        onChange={(e) =>
                          field.onChange(e.target.value ? parseInt(e.target.value) : null)
                        }
                        fullWidth
                        label="최소 나이"
                        type="number"
                        error={!!errors.min_age}
                        helperText={errors.min_age?.message}
                      />
                    )}
                  />
                </Grid>

                <Grid item xs={12} md={6}>
                  <Controller
                    name="max_age"
                    control={control}
                    render={({ field }) => (
                      <TextField
                        {...field}
                        value={field.value || ''}
                        onChange={(e) =>
                          field.onChange(e.target.value ? parseInt(e.target.value) : null)
                        }
                        fullWidth
                        label="최대 나이"
                        type="number"
                        error={!!errors.max_age}
                        helperText={errors.max_age?.message}
                      />
                    )}
                  />
                </Grid>

                <Grid item xs={12}>
                  <Controller
                    name="income_requirement"
                    control={control}
                    render={({ field }) => (
                      <TextField
                        {...field}
                        value={field.value || ''}
                        fullWidth
                        label="소득 요건"
                        multiline
                        rows={3}
                        error={!!errors.income_requirement}
                        helperText={errors.income_requirement?.message}
                      />
                    )}
                  />
                </Grid>

                <Grid item xs={12}>
                  <Controller
                    name="household_requirement"
                    control={control}
                    render={({ field }) => (
                      <TextField
                        {...field}
                        value={field.value || ''}
                        fullWidth
                        label="가구 요건"
                        multiline
                        rows={3}
                        error={!!errors.household_requirement}
                        helperText={errors.household_requirement?.message}
                      />
                    )}
                  />
                </Grid>

                <Grid item xs={12}>
                  <Controller
                    name="special_conditions"
                    control={control}
                    render={({ field }) => (
                      <TextField
                        {...field}
                        value={
                          field.value
                            ? typeof field.value === 'string'
                              ? field.value
                              : JSON.stringify(field.value, null, 2)
                            : ''
                        }
                        onChange={(e) => {
                          try {
                            const parsed = JSON.parse(e.target.value)
                            field.onChange(parsed)
                          } catch {
                            field.onChange(e.target.value || null)
                          }
                        }}
                        fullWidth
                        label="특별 조건 (JSON 형식)"
                        multiline
                        rows={4}
                        error={!!errors.special_conditions}
                        helperText={errors.special_conditions?.message || 'JSON 형식으로 입력하거나 일반 텍스트를 입력하세요'}
                      />
                    )}
                  />
                </Grid>
              </Grid>
            </TabPanel>

            {/* Tab 5: Location & Supply */}
            <TabPanel value={currentTab} index={4}>
              <Grid container spacing={3}>
                <Grid item xs={12}>
                  <Controller
                    name="location"
                    control={control}
                    render={({ field }) => (
                      <TextField
                        {...field}
                        value={field.value || ''}
                        fullWidth
                        label="위치"
                        error={!!errors.location}
                        helperText={errors.location?.message}
                      />
                    )}
                  />
                </Grid>

                <Grid item xs={12}>
                  <Controller
                    name="supply_count"
                    control={control}
                    render={({ field }) => (
                      <TextField
                        {...field}
                        value={field.value || ''}
                        onChange={(e) =>
                          field.onChange(e.target.value ? parseInt(e.target.value) : null)
                        }
                        fullWidth
                        label="공급 세대 수"
                        type="number"
                        error={!!errors.supply_count}
                        helperText={errors.supply_count?.message}
                      />
                    )}
                  />
                </Grid>
              </Grid>
            </TabPanel>

            {/* Tab 6: Documents & Contact */}
            <TabPanel value={currentTab} index={5}>
              <Grid container spacing={3}>
                <Grid item xs={12}>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2 }}>
                    <Typography variant="subtitle1">필요 서류</Typography>
                    <Button
                      variant="outlined"
                      size="small"
                      startIcon={<AddIcon />}
                      onClick={() => appendDoc('')}
                    >
                      추가
                    </Button>
                  </Box>
                  {docFields.map((field, index) => (
                    <Box key={field.id} sx={{ display: 'flex', gap: 1, mb: 2 }}>
                      <Controller
                        name={`documents_required.${index}`}
                        control={control}
                        render={({ field }) => (
                          <TextField {...field} fullWidth label={`서류 ${index + 1}`} />
                        )}
                      />
                      <IconButton color="error" onClick={() => removeDoc(index)}>
                        <DeleteIcon />
                      </IconButton>
                    </Box>
                  ))}
                  {docFields.length === 0 && (
                    <FormHelperText>추가 버튼을 눌러 필요 서류를 입력하세요</FormHelperText>
                  )}
                </Grid>

                <Grid item xs={12}>
                  <Controller
                    name="contact_info"
                    control={control}
                    render={({ field }) => (
                      <TextField
                        {...field}
                        value={
                          field.value
                            ? typeof field.value === 'string'
                              ? field.value
                              : JSON.stringify(field.value, null, 2)
                            : ''
                        }
                        onChange={(e) => {
                          try {
                            const parsed = JSON.parse(e.target.value)
                            field.onChange(parsed)
                          } catch {
                            field.onChange(e.target.value || null)
                          }
                        }}
                        fullWidth
                        label="연락처 정보 (JSON 형식)"
                        multiline
                        rows={4}
                        error={!!errors.contact_info}
                        helperText={errors.contact_info?.message || 'JSON 형식: {"phone": "02-1234-5678", "email": "contact@example.com"}'}
                      />
                    )}
                  />
                </Grid>
              </Grid>
            </TabPanel>

            {/* Action Buttons */}
            <Box sx={{ display: 'flex', gap: 2, justifyContent: 'flex-end', mt: 3 }}>
              <Button variant="outlined" onClick={() => navigate('/benefits')}>
                취소
              </Button>
              <Button
                variant="outlined"
                color="secondary"
                onClick={onSaveDraft}
                disabled={isSubmitting}
              >
                임시저장
              </Button>
              <Button
                type="button"
                variant="contained"
                onClick={onPublish}
                disabled={isSubmitting}
              >
                {isEdit ? '수정' : '게시'}
              </Button>
            </Box>
          </form>
        </Box>
      </Paper>
    </Box>
  )
}
