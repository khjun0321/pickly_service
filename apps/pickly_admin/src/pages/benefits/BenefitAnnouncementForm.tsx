import { useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { useForm, Controller, useFieldArray } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { v4 as uuidv4 } from 'uuid'
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
  fetchAnnouncementById,
  createAnnouncement,
  updateAnnouncement,
} from '@/api/announcements'
import { supabase } from '@/lib/supabase'
import { fetchCategories, fetchSubcategories } from '@/api/categories'
import type { Announcement } from '@/types/database'

// ================================================
// Supabase Storage Upload/Delete Helpers
// ================================================

// Upload file helper function
async function uploadFile(file: File, bucket: string, folder: string): Promise<string> {
  const fileExt = file.name.split('.').pop()
  const fileName = `${folder}/${Date.now()}-${Math.random().toString(36).substring(7)}.${fileExt}`

  const { error: uploadError } = await supabase.storage
    .from(bucket)
    .upload(fileName, file, {
      cacheControl: '3600',
      upsert: false
    })

  if (uploadError) {
    console.error('❌ Storage Upload Error:', uploadError)
    throw uploadError
  }

  const { data: { publicUrl } } = supabase.storage
    .from(bucket)
    .getPublicUrl(fileName)

  console.log('✅ File uploaded:', { fileName, publicUrl })
  return publicUrl
}

// Delete file from storage
async function deleteFile(url: string): Promise<void> {
  try {
    // URL 형식: https://.../storage/v1/object/public/bucket-name/folder/file.ext
    const urlParts = url.split('/storage/v1/object/public/')
    if (urlParts.length < 2) {
      console.warn('⚠️ Invalid storage URL format:', url)
      return
    }

    const [bucket, ...pathParts] = urlParts[1].split('/')
    const filePath = pathParts.join('/')

    const { error } = await supabase.storage
      .from(bucket)
      .remove([filePath])

    if (error) {
      console.error('❌ Storage Delete Error:', error)
      throw error
    }

    console.log('✅ File deleted:', { bucket, filePath })
  } catch (error) {
    console.error('❌ Failed to delete file:', error)
    // Don't throw - allow UI to continue even if deletion fails
  }
}

// ================================================
// Status Mapping Utility (Legacy → New)
// ================================================
// DB에 저장된 구 status 값을 새 제약조건에 맞게 변환
type LegacyStatus = 'active' | 'inactive' | 'draft'
type ValidStatus = 'recruiting' | 'upcoming' | 'closed'

const mapLegacyStatus = (status: string): ValidStatus => {
  const mapping: Record<LegacyStatus, ValidStatus> = {
    active: 'recruiting',
    inactive: 'closed',
    draft: 'upcoming',
  }

  // 이미 새 값이면 그대로 반환
  if (['recruiting', 'upcoming', 'closed'].includes(status)) {
    return status as ValidStatus
  }

  // 구 값이면 매핑
  return mapping[status as LegacyStatus] || 'recruiting'
}

const schema = z.object({
  // Basic Info
  title: z.string().min(1, '제목을 입력하세요'),
  subtitle: z.string().nullable(),
  category_id: z.string().min(1, '카테고리를 선택하세요'),
  subcategory_id: z.string().nullable(),
  organization: z.string().nullable(),
  status: z.string().min(1, '상태를 선택하세요'),
  content: z.string().nullable(),

  // Images & Files
  thumbnail_url: z.string().nullable(),
  external_url: z.string().nullable(),
  detail_url: z.string().nullable(),
  link_type: z.string().nullable(),

  // Location & Region
  region: z.string().nullable(),

  // Dates
  application_start_date: z.string().nullable(),
  application_end_date: z.string().nullable(),
  deadline_date: z.string().nullable(),

  // Tags & Settings
  tags: z.array(z.string()),
  is_featured: z.boolean(),
  is_home_visible: z.boolean(),
  is_priority: z.boolean(),
  display_priority: z.number().int().min(0),
  views_count: z.number().int().min(0),

  // ✅ v9.15.0 details - 범용 공고 확장 필드
  details: z.array(z.object({
    field_key: z.string(),
    field_value: z.string(),
    field_type: z.enum(['text', 'number', 'date', 'link', 'json'])
  })).optional().default([])
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

export default function AnnouncementForm() {
  // ================================================
  // 1️⃣ Router & State (최상단)
  // ================================================
  const { id } = useParams()
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const isEdit = Boolean(id)
  const [currentTab, setCurrentTab] = useState(0)
  const [uploadingImage, setUploadingImage] = useState(false)
  const [uploadingFloorPlans, setUploadingFloorPlans] = useState(false)
  const [uploadingPdf, setUploadingPdf] = useState(false)
  const [floorPlanUrls, setFloorPlanUrls] = useState<string[]>([])
  const [pdfUrl, setPdfUrl] = useState<string>('')
  const [description, setDescription] = useState<string>('')

  // ================================================
  // 2️⃣ Data Fetching (useQuery)
  // ================================================
  const { data: announcement, isLoading: announcementLoading } = useQuery({
    queryKey: ['benefit-announcement', id],
    queryFn: () => fetchAnnouncementById(id!),
    enabled: isEdit,
  })

  const { data: categories = [], isLoading: categoriesLoading } = useQuery({
    queryKey: ['benefit-categories'],
    queryFn: fetchCategories,
  })

  // ✅ announcement_details 가져오기 (Edit 모드)
  const { data: announcementDetails = [] } = useQuery({
    queryKey: ['announcement-details', id],
    queryFn: async () => {
      if (!id) return []
      const { data, error } = await supabase
        .from('announcement_details')
        .select('*')
        .eq('announcement_id', id)

      if (error) throw error
      return data || []
    },
    enabled: isEdit && Boolean(id),
  })

  // ================================================
  // 3️⃣ useForm 호출 (watch 사용 전 필수!)
  // ================================================
  const {
    control,
    handleSubmit,
    reset,
    setValue,
    watch,
    register,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({
    resolver: zodResolver(schema),
    defaultValues: {
      title: '',
      subtitle: null,
      category_id: '',
      subcategory_id: null,
      organization: null,
      status: 'recruiting',
      content: null,
      thumbnail_url: null,
      external_url: null,
      detail_url: null,
      link_type: null,
      region: null,
      application_start_date: null,
      application_end_date: null,
      deadline_date: null,
      tags: [],
      is_featured: false,
      is_home_visible: false,
      is_priority: false,
      display_priority: 0,
      views_count: 0,
      details: []
    },
  })

  // ================================================
  // 4️⃣ watch 사용 (useForm 이후!)
  // ================================================
  const selectedCategoryId = watch('category_id')
  const thumbnailUrl = watch('thumbnail_url')

  // ================================================
  // 5️⃣ Dependent Queries (watch 기반)
  // ================================================
  const { data: subcategories = [], isLoading: subcategoriesLoading } = useQuery({
    queryKey: ['benefit-subcategories', selectedCategoryId],
    queryFn: () => fetchSubcategories(selectedCategoryId),
    enabled: !!selectedCategoryId,
  })

  // ================================================
  // 6️⃣ useFieldArray (control 사용)
  // ================================================
  const { fields: tagFields, append: appendTag, remove: removeTag } = useFieldArray({
    control,
    // @ts-ignore
    name: 'tags',
  })

  const { fields: detailFields, append: appendDetail, remove: removeDetail } = useFieldArray({
    control,
    // @ts-ignore
    name: 'details',
  })

  // ================================================
  // 7️⃣ useEffect (side effects)
  // ================================================

  // category_id 변경 시 subcategory_id 초기화
  useEffect(() => {
    if (selectedCategoryId) {
      setValue('subcategory_id', null)
    }
  }, [selectedCategoryId, setValue])

  // 편집 모드: 기존 데이터 로드
  useEffect(() => {
    if (announcement && announcementDetails) {
      // ✅ Status 매핑: DB의 구 값을 새 제약조건에 맞게 변환
      const mappedStatus = mapLegacyStatus(announcement.status)

      // ✅ announcement_details에서 특수 필드 추출
      const floorPlans: string[] = []
      let pdfFileUrl = ''
      let descriptionText = ''
      const otherDetails: Array<{field_key: string, field_value: string, field_type: 'text' | 'number' | 'date' | 'link' | 'json'}> = []

      announcementDetails.forEach((detail: any) => {
        if (detail.field_key === 'floor_plan_image') {
          floorPlans.push(detail.field_value)
        } else if (detail.field_key === 'announcement_pdf') {
          pdfFileUrl = detail.field_value
        } else if (detail.field_key === 'description') {
          descriptionText = detail.field_value
        } else {
          otherDetails.push({
            field_key: detail.field_key,
            field_value: detail.field_value,
            field_type: detail.field_type || 'text',
          })
        }
      })

      // 상태 업데이트
      setFloorPlanUrls(floorPlans)
      setPdfUrl(pdfFileUrl)
      setDescription(descriptionText)

      // 🟦 디버그 로그: 편집 모드 데이터 로드
      console.log('🟦 [EDIT-MODE LOADED]', {
        announcementId: announcement.id,
        originalStatus: announcement.status,
        mappedStatus: mappedStatus,
        willUseId: announcement.id,
        detailsCount: announcementDetails.length,
        floorPlansCount: floorPlans.length,
        hasPdf: !!pdfFileUrl,
        hasDescription: !!descriptionText,
      })

      reset({
        title: announcement.title,
        subtitle: announcement.subtitle || null,
        category_id: announcement.category_id || '',
        subcategory_id: announcement.subcategory_id || null,
        organization: announcement.organization || null,
        status: mappedStatus, // ✅ 매핑된 status 사용
        content: announcement.content || null,
        thumbnail_url: announcement.thumbnail_url || null,
        external_url: announcement.external_url || null,
        detail_url: announcement.detail_url || null,
        link_type: announcement.link_type || null,
        region: announcement.region || null,
        application_start_date: announcement.application_start_date || null,
        application_end_date: announcement.application_end_date || null,
        deadline_date: announcement.deadline_date || null,
        tags: announcement.tags || [],
        is_featured: announcement.is_featured ?? false,
        is_home_visible: announcement.is_home_visible ?? false,
        is_priority: announcement.is_priority ?? false,
        display_priority: announcement.display_priority || 0,
        views_count: announcement.views_count || 0,
        details: otherDetails, // ✅ 기타 details 매핑
      } as FormData)
    }
  }, [announcement, announcementDetails, reset])

  // ================================================
  // 8️⃣ Mutations & Handlers
  // ================================================

  const mutation = useMutation({
    mutationFn: async (data: FormData) => {
      const { details, ...formData } = data

      // ✅ ID 생성 로직: 편집이면 기존 ID (우선순위 높음), 신규면 UUID 생성
      const announcementId =
        (isEdit && announcement?.id) ? announcement.id : // ✅ 1순위: DB에서 가져온 ID
        (isEdit && id) ? id :                           // ✅ 2순위: URL 파라미터 ID
        uuidv4()                                        // ✅ 3순위: 신규 생성 시 UUID

      // ✅ announcement payload (허용 필드만 명시)
      const p_announcement = {
        id: announcementId, // ✅ 절대 null이 아님!
        title: formData.title,
        subtitle: formData.subtitle,
        category_id: formData.category_id,
        subcategory_id: formData.subcategory_id || null,
        organization: formData.organization,
        status: formData.status,
        content: formData.content || null,
        thumbnail_url: formData.thumbnail_url,
        external_url: formData.external_url,
        detail_url: formData.detail_url || null,
        link_type: formData.link_type || null,
        region: formData.region || null,
        application_start_date: formData.application_start_date || null,
        application_end_date: formData.application_end_date || null,
        deadline_date: formData.deadline_date || null,
        tags: formData.tags || [],
        is_featured: formData.is_featured ?? false,
        is_home_visible: formData.is_home_visible ?? false,
        is_priority: formData.is_priority ?? false,
        display_priority: formData.display_priority || 0,
        views_count: formData.views_count || 0,
      }

      // ✅ details payload - 기본 details + 평형 이미지 + PDF + Description
      const p_details = [
        ...(details || []).map(d => ({
          field_key: d.field_key,
          field_value: d.field_value,
          field_type: d.field_type,
        })),
        // ✅ 평형 이미지들 추가
        ...floorPlanUrls.map(url => ({
          field_key: 'floor_plan_image',
          field_value: url,
          field_type: 'link' as const,
        })),
        // ✅ PDF 추가
        ...(pdfUrl ? [{
          field_key: 'announcement_pdf',
          field_value: pdfUrl,
          field_type: 'link' as const,
        }] : []),
        // ✅ Description 추가
        ...(description ? [{
          field_key: 'description',
          field_value: description,
          field_type: 'text' as const,
        }] : []),
      ]

      // 🟧 디버깅 로그: RPC 전송 직전 최종 Payload 확인
      console.log('🟧 [FINAL RPC PAYLOAD]', {
        mode: isEdit ? 'EDIT' : 'CREATE',
        id: p_announcement.id,
        idSource: (isEdit && announcement?.id) ? 'DB' : (isEdit && id) ? 'URL' : 'NEW_UUID',
        status: p_announcement.status,
        statusOriginal: formData.status,
        title: p_announcement.title,
        fullPayload: p_announcement,
      })
      console.log('🟧 [RPC DETAILS]', {
        detailsCount: p_details.length,
        details: p_details,
      })

      // RPC 호출
      const { data: resultId, error } = await supabase.rpc('save_announcement_with_details', {
        p_announcement,
        p_details,
      })

      if (error) {
        console.error('❌ RPC Error:', error)
        throw error
      }

      console.log('✅ RPC Success:', resultId)
      return resultId
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
      // ✅ Edit 모드에서 기존 썸네일이 있으면 삭제
      const oldThumbnailUrl = thumbnailUrl
      if (oldThumbnailUrl && isEdit) {
        console.log('🗑️ Deleting old thumbnail:', oldThumbnailUrl)
        await deleteFile(oldThumbnailUrl)
      }

      // ✅ 새 썸네일 업로드
      const url = await uploadFile(file, 'benefit-images', 'thumbnails')
      setValue('thumbnail_url', url)
      toast.success('이미지가 업로드되었습니다')
    } catch (error) {
      console.error('Upload error:', error)
      toast.error('이미지 업로드에 실패했습니다')
    } finally {
      setUploadingImage(false)
    }
  }

  // ✅ 평형 이미지 업로드 (여러 개)
  const handleFloorPlanUpload = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const files = event.target.files
    if (!files || files.length === 0) return

    setUploadingFloorPlans(true)
    try {
      const uploadPromises = Array.from(files).map(file => {
        if (!file.type.startsWith('image/')) {
          throw new Error('이미지 파일만 업로드 가능합니다')
        }
        return uploadFile(file, 'benefit-images', 'floor-plans')
      })

      const urls = await Promise.all(uploadPromises)
      setFloorPlanUrls(prev => [...prev, ...urls])
      toast.success(`${urls.length}개의 평형 이미지가 업로드되었습니다`)
    } catch (error) {
      toast.error('평형 이미지 업로드에 실패했습니다')
    } finally {
      setUploadingFloorPlans(false)
      // Reset input
      event.target.value = ''
    }
  }

  // ✅ 평형 이미지 삭제 (Storage에서도 삭제)
  const handleRemoveFloorPlan = async (index: number) => {
    const urlToDelete = floorPlanUrls[index]

    // UI 먼저 업데이트
    setFloorPlanUrls(prev => prev.filter((_, i) => i !== index))
    toast.success('평형 이미지가 삭제되었습니다')

    // Storage에서도 삭제 (백그라운드)
    await deleteFile(urlToDelete)
  }

  // ✅ PDF 업로드 (Edit 모드에서 교체 지원)
  const handlePdfUpload = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (!file) return

    if (file.type !== 'application/pdf') {
      toast.error('PDF 파일만 업로드 가능합니다')
      return
    }

    setUploadingPdf(true)
    try {
      // ✅ Edit 모드에서 기존 PDF가 있으면 삭제
      const oldPdfUrl = pdfUrl
      if (oldPdfUrl && isEdit) {
        console.log('🗑️ Deleting old PDF:', oldPdfUrl)
        await deleteFile(oldPdfUrl)
      }

      // ✅ 새 PDF 업로드
      const url = await uploadFile(file, 'benefit-documents', 'pdfs')
      setPdfUrl(url)
      toast.success('PDF가 업로드되었습니다')
    } catch (error) {
      console.error('PDF upload error:', error)
      toast.error('PDF 업로드에 실패했습니다')
    } finally {
      setUploadingPdf(false)
      event.target.value = ''
    }
  }

  // ✅ PDF 삭제 (Storage에서도 삭제)
  const handleRemovePdf = async () => {
    const urlToDelete = pdfUrl

    // UI 먼저 업데이트
    setPdfUrl('')
    toast.success('PDF가 삭제되었습니다')

    // Storage에서도 삭제 (백그라운드)
    if (urlToDelete) {
      await deleteFile(urlToDelete)
    }
  }

  const onSubmit = (data: FormData) => {
    mutation.mutate(data)
  }

  const onSaveDraft = () => {
    setValue('status', 'upcoming')
    handleSubmit(onSubmit)()
  }

  const onPublish = () => {
    setValue('status', 'recruiting')
    handleSubmit(onSubmit)()
  }

  // ================================================
  // 9️⃣ Loading State
  // ================================================
  if (announcementLoading || categoriesLoading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', mt: 4 }}>
        <CircularProgress />
      </Box>
    )
  }

  // ================================================
  // 🔟 Render
  // ================================================
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
          <Tab label="이미지 & 링크" />
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
                    name="subcategory_id"
                    control={control}
                    render={({ field }) => (
                      <TextField
                        {...field}
                        select
                        fullWidth
                        label="하위분류"
                        disabled={!selectedCategoryId || subcategoriesLoading}
                        error={!!errors.subcategory_id}
                        helperText={errors.subcategory_id?.message || (selectedCategoryId ? '' : '먼저 대분류를 선택하세요')}
                        value={field.value || ''}
                        onChange={(e) => {
                          field.onChange(e.target.value || null)
                        }}
                      >
                        <MenuItem value="">선택 안 함</MenuItem>
                        {subcategories.map((sub: any) => (
                          <MenuItem key={sub.id} value={sub.id}>
                            {sub.name}
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
                        <MenuItem value="recruiting">모집중</MenuItem>
                        <MenuItem value="upcoming">예정</MenuItem>
                        <MenuItem value="closed">마감</MenuItem>
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
              </Grid>
            </TabPanel>

            {/* Tab 2: Images & Links */}
            <TabPanel value={currentTab} index={1}>
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
                  {thumbnailUrl && (
                    <Box sx={{ mt: 2 }}>
                      <img
                        src={thumbnailUrl}
                        alt="Thumbnail preview"
                        style={{ maxWidth: '300px', maxHeight: '200px', objectFit: 'contain' }}
                      />
                    </Box>
                  )}
                </Grid>

                {/* ✅ 평형 이미지 업로드 (여러 개) */}
                <Grid item xs={12}>
                  <Typography variant="subtitle2" gutterBottom>
                    평형 이미지 (여러 개 업로드 가능)
                  </Typography>
                  <Box sx={{ display: 'flex', gap: 2, alignItems: 'flex-start', mb: 2 }}>
                    <Button
                      variant="outlined"
                      component="label"
                      startIcon={<UploadIcon />}
                      disabled={uploadingFloorPlans}
                    >
                      {uploadingFloorPlans ? '업로드 중...' : '평형 이미지 업로드'}
                      <input
                        type="file"
                        hidden
                        multiple
                        accept="image/*"
                        onChange={handleFloorPlanUpload}
                      />
                    </Button>
                  </Box>
                  {floorPlanUrls.length > 0 && (
                    <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 2 }}>
                      {floorPlanUrls.map((url, index) => (
                        <Box key={index} sx={{ position: 'relative' }}>
                          <img
                            src={url}
                            alt={`Floor plan ${index + 1}`}
                            style={{ width: '200px', height: '150px', objectFit: 'cover', borderRadius: '8px' }}
                          />
                          <IconButton
                            size="small"
                            sx={{
                              position: 'absolute',
                              top: 4,
                              right: 4,
                              bgcolor: 'error.main',
                              color: 'white',
                              '&:hover': { bgcolor: 'error.dark' },
                            }}
                            onClick={() => handleRemoveFloorPlan(index)}
                          >
                            <DeleteIcon fontSize="small" />
                          </IconButton>
                        </Box>
                      ))}
                    </Box>
                  )}
                </Grid>

                {/* ✅ PDF 업로드 */}
                <Grid item xs={12}>
                  <Typography variant="subtitle2" gutterBottom>
                    공고문 PDF
                  </Typography>
                  <Box sx={{ display: 'flex', gap: 2, alignItems: 'center', mb: 2 }}>
                    <Button
                      variant="outlined"
                      component="label"
                      startIcon={<UploadIcon />}
                      disabled={uploadingPdf}
                    >
                      {uploadingPdf ? '업로드 중...' : 'PDF 업로드'}
                      <input
                        type="file"
                        hidden
                        accept="application/pdf"
                        onChange={handlePdfUpload}
                      />
                    </Button>
                    {pdfUrl && (
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                        <Typography variant="body2" color="success.main">
                          PDF 업로드 완료
                        </Typography>
                        <IconButton
                          size="small"
                          color="error"
                          onClick={handleRemovePdf}
                        >
                          <DeleteIcon fontSize="small" />
                        </IconButton>
                      </Box>
                    )}
                  </Box>
                  {pdfUrl && (
                    <Typography variant="caption" sx={{ display: 'block', mt: 1, wordBreak: 'break-all' }}>
                      {pdfUrl}
                    </Typography>
                  )}
                </Grid>

                {/* ✅ 상세 내용 (Description) */}
                <Grid item xs={12}>
                  <Typography variant="subtitle2" gutterBottom>
                    상세 내용 (Description)
                  </Typography>
                  <TextField
                    fullWidth
                    multiline
                    rows={6}
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                    placeholder="공고에 대한 상세 설명을 입력하세요..."
                    variant="outlined"
                  />
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

                {/* ✅ v9.15.0 details - 범용 공고 확장 필드 */}
                <Grid item xs={12}>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2, mt: 3 }}>
                    <Typography variant="subtitle1">추가 필드 (범용 공고 확장)</Typography>
                    <Button
                      variant="outlined"
                      size="small"
                      startIcon={<AddIcon />}
                      onClick={() => appendDetail({ field_key: '', field_value: '', field_type: 'text' })}
                    >
                      필드 추가
                    </Button>
                  </Box>
                  {detailFields.map((field, index) => (
                    <Grid container spacing={2} key={field.id} sx={{ mb: 2 }}>
                      <Grid item xs={12} md={3}>
                        <TextField
                          {...register(`details.${index}.field_key` as const)}
                          fullWidth
                          label="필드 키"
                          placeholder="예: 지원금액"
                          size="small"
                        />
                      </Grid>
                      <Grid item xs={12} md={4}>
                        <TextField
                          {...register(`details.${index}.field_value` as const)}
                          fullWidth
                          label="값"
                          placeholder="예: 300000 또는 JSON"
                          size="small"
                          multiline
                          rows={1}
                        />
                      </Grid>
                      <Grid item xs={12} md={3}>
                        <TextField
                          {...register(`details.${index}.field_type` as const)}
                          select
                          fullWidth
                          label="타입"
                          size="small"
                          defaultValue="text"
                        >
                          <MenuItem value="text">text</MenuItem>
                          <MenuItem value="number">number</MenuItem>
                          <MenuItem value="date">date</MenuItem>
                          <MenuItem value="link">link</MenuItem>
                          <MenuItem value="json">json</MenuItem>
                        </TextField>
                      </Grid>
                      <Grid item xs={12} md={2}>
                        <IconButton color="error" onClick={() => removeDetail(index)}>
                          <DeleteIcon />
                        </IconButton>
                      </Grid>
                    </Grid>
                  ))}
                  {detailFields.length === 0 && (
                    <FormHelperText>
                      추가 버튼을 눌러 카테고리별 특수 필드를 입력하세요 (교육기간, 지원금액, 할인율 등)
                    </FormHelperText>
                  )}
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
