/**
 * Announcement Types (Tabs) Management Page
 *
 * Features:
 * - List announcements (read-only)
 * - Add/Edit/Delete announcement tabs (types)
 * - Upload floor plan images
 * - Upload PDFs for custom content
 * - Manage custom_content JSON (images, PDFs, extra notes)
 * - Dynamic form builder for custom content
 */

import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import {
  Box,
  Paper,
  Button,
  Typography,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Grid,
  IconButton,
  Chip,
  Select,
  MenuItem,
  FormControl,
  InputLabel,
  CircularProgress,
  Alert,
  Divider,
  Stack,
} from '@mui/material'
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  Image as ImageIcon,
  PictureAsPdf as PdfIcon,
} from '@mui/icons-material'
import { useForm, Controller } from 'react-hook-form'
import toast from 'react-hot-toast'
import { supabase } from '@/lib/supabase'
import type { Json } from '@/types/database'
import { uploadFloorPlanImage, uploadAnnouncementPDF, uploadCustomContentImage } from '@/utils/storage'
import type {
  Announcement,
  AnnouncementTab,
  AnnouncementTabFormData,
  AgeCategory,
  CustomContent,
  IncomeCondition,
} from '@/types/announcement'

export default function AnnouncementTypesPage() {
  const queryClient = useQueryClient()
  const [selectedAnnouncement, setSelectedAnnouncement] = useState<string | null>(null)
  const [dialogOpen, setDialogOpen] = useState(false)
  const [editingTab, setEditingTab] = useState<AnnouncementTab | null>(null)
  const [floorPlanFile, setFloorPlanFile] = useState<File | null>(null)
  const [customImages, setCustomImages] = useState<File[]>([])
  const [customPdfs, setCustomPdfs] = useState<File[]>([])

  // Fetch announcements
  const { data: announcements = [], isLoading: loadingAnnouncements } = useQuery({
    queryKey: ['announcements'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('announcements')
        .select('id, title, organization, status, created_at')
        .order('created_at', { ascending: false })

      if (error) throw error
      return data as Announcement[]
    },
  })

  // Fetch age categories
  const { data: ageCategories = [] } = useQuery({
    queryKey: ['age_categories'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('age_categories')
        .select('*')
        .eq('is_active', true)
        .order('sort_order')

      if (error) throw error
      return data as AgeCategory[]
    },
  })

  // Fetch tabs for selected announcement
  const { data: tabs = [], isLoading: loadingTabs } = useQuery({
    queryKey: ['announcement_tabs', selectedAnnouncement],
    queryFn: async () => {
      if (!selectedAnnouncement) return []

      const { data, error } = await supabase
        .from('announcement_tabs')
        .select('*, age_categories(title)')
        .eq('announcement_id', selectedAnnouncement)
        .order('display_order')

      if (error) throw error
      return data as (AnnouncementTab & { age_categories?: { title: string } })[]
    },
    enabled: !!selectedAnnouncement,
  })

  // Form handling
  const {
    control,
    handleSubmit,
    reset,
    watch,
    setValue,
    formState: { errors, isSubmitting },
  } = useForm<AnnouncementTabFormData>({
    defaultValues: {
      announcement_id: '',
      age_category_id: null,
      tab_name: '',
      unit_type: null,
      supply_count: null,
      floor_plan_image_url: null,
      income_conditions: null,
      additional_info: null,
      display_order: 0,
    },
  })

  const watchedIncomeConditions = watch('income_conditions')

  // Save mutation
  const saveMutation = useMutation({
    mutationFn: async (formData: AnnouncementTabFormData) => {
      let floorPlanUrl = formData.floor_plan_image_url

      // Upload floor plan if file selected
      if (floorPlanFile) {
        const uploadResult = await uploadFloorPlanImage(floorPlanFile, formData.announcement_id)
        floorPlanUrl = uploadResult.url
      }

      // Upload custom images
      const customImagesUrls = await Promise.all(
        customImages.map(async (file, index) => {
          const result = await uploadCustomContentImage(file, formData.announcement_id)
          return {
            url: result.url,
            caption: '',
            order: index,
          }
        })
      )

      // Upload custom PDFs
      const customPdfsUrls = await Promise.all(
        customPdfs.map(async (file, index) => {
          const result = await uploadAnnouncementPDF(file, formData.announcement_id)
          return {
            url: result.url,
            title: file.name,
            order: index,
          }
        })
      )

      // Build custom content
      const customContent: CustomContent = {
        images: [...(formData.additional_info?.images || []), ...customImagesUrls],
        pdfs: [...(formData.additional_info?.pdfs || []), ...customPdfsUrls],
        extra_notes: formData.additional_info?.extra_notes || '',
      }

      const dataToSave = {
        announcement_id: formData.announcement_id,
        age_category_id: formData.age_category_id,
        tab_name: formData.tab_name,
        unit_type: formData.unit_type,
        supply_count: formData.supply_count,
        floor_plan_image_url: floorPlanUrl,
        income_conditions: formData.income_conditions as Json,
        additional_info: customContent as Json,
        display_order: formData.display_order,
      }

      if (editingTab) {
        // Update
        const { data, error } = await supabase
          .from('announcement_tabs')
          .update(dataToSave)
          .eq('id', editingTab.id)
          .select()
          .single()

        if (error) throw error
        return data
      } else {
        // Insert
        const { data, error } = await supabase
          .from('announcement_tabs')
          .insert(dataToSave)
          .select()
          .single()

        if (error) throw error
        return data
      }
    },
    onSuccess: () => {
      toast.success(editingTab ? '탭이 수정되었습니다' : '탭이 추가되었습니다')
      queryClient.invalidateQueries({ queryKey: ['announcement_tabs', selectedAnnouncement] })
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
        .from('announcement_tabs')
        .delete()
        .eq('id', id)

      if (error) throw error
    },
    onSuccess: () => {
      toast.success('탭이 삭제되었습니다')
      queryClient.invalidateQueries({ queryKey: ['announcement_tabs', selectedAnnouncement] })
    },
    onError: (error: Error) => {
      toast.error(error.message || '삭제에 실패했습니다')
    },
  })

  const handleOpenDialog = (tab?: AnnouncementTab) => {
    if (!selectedAnnouncement) {
      toast.error('공고를 먼저 선택해주세요')
      return
    }

    if (tab) {
      setEditingTab(tab)
      reset({
        announcement_id: tab.announcement_id || selectedAnnouncement,
        age_category_id: tab.age_category_id,
        tab_name: tab.tab_name,
        unit_type: tab.unit_type,
        supply_count: tab.supply_count,
        floor_plan_image_url: tab.floor_plan_image_url,
        income_conditions: tab.income_conditions as IncomeCondition[] | null,
        additional_info: tab.additional_info as CustomContent | null,
        display_order: tab.display_order,
      })
    } else {
      setEditingTab(null)
      reset({
        announcement_id: selectedAnnouncement,
        age_category_id: null,
        tab_name: '',
        unit_type: null,
        supply_count: null,
        floor_plan_image_url: null,
        income_conditions: null,
        additional_info: null,
        display_order: tabs.length,
      })
    }

    setFloorPlanFile(null)
    setCustomImages([])
    setCustomPdfs([])
    setDialogOpen(true)
  }

  const handleCloseDialog = () => {
    setDialogOpen(false)
    setEditingTab(null)
    setFloorPlanFile(null)
    setCustomImages([])
    setCustomPdfs([])
    reset()
  }

  const handleDelete = async (tab: AnnouncementTab) => {
    if (!window.confirm(`"${tab.tab_name}" 탭을 삭제하시겠습니까?`)) {
      return
    }
    deleteMutation.mutate(tab.id)
  }

  const onSubmit = (data: AnnouncementTabFormData) => {
    saveMutation.mutate(data)
  }

  const addIncomeCondition = () => {
    const current = watchedIncomeConditions || []
    setValue('income_conditions', [...current, { description: '', min_income: undefined, max_income: undefined }])
  }

  const removeIncomeCondition = (index: number) => {
    const current = watchedIncomeConditions || []
    setValue('income_conditions', current.filter((_, i) => i !== index))
  }

  if (loadingAnnouncements) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', mt: 4 }}>
        <CircularProgress />
      </Box>
    )
  }

  return (
    <Box>
      <Box sx={{ mb: 3 }}>
        <Typography variant="h4" gutterBottom>
          공고 유형(탭) 관리
        </Typography>
        <Typography variant="body2" color="text.secondary">
          공고별로 여러 유형(탭)을 추가하고 도면, PDF, 수입 조건 등을 관리할 수 있습니다
        </Typography>
      </Box>

      <Grid container spacing={3}>
        {/* Announcements List */}
        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 2 }}>
            <Typography variant="h6" gutterBottom>
              공고 목록
            </Typography>
            <Box sx={{ maxHeight: 600, overflow: 'auto' }}>
              {announcements.map((announcement) => (
                <Paper
                  key={announcement.id}
                  sx={{
                    p: 2,
                    mb: 1,
                    cursor: 'pointer',
                    bgcolor: selectedAnnouncement === announcement.id ? 'primary.50' : 'background.paper',
                    border: '1px solid',
                    borderColor: selectedAnnouncement === announcement.id ? 'primary.main' : 'divider',
                    '&:hover': {
                      borderColor: 'primary.main',
                    },
                  }}
                  onClick={() => setSelectedAnnouncement(announcement.id)}
                >
                  <Typography variant="subtitle2" noWrap>
                    {announcement.title}
                  </Typography>
                  <Typography variant="caption" color="text.secondary">
                    {announcement.organization}
                  </Typography>
                </Paper>
              ))}
            </Box>
          </Paper>
        </Grid>

        {/* Tabs for Selected Announcement */}
        <Grid item xs={12} md={8}>
          {selectedAnnouncement ? (
            <Paper sx={{ p: 2 }}>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2 }}>
                <Typography variant="h6">유형(탭) 목록</Typography>
                <Button
                  variant="contained"
                  startIcon={<AddIcon />}
                  onClick={() => handleOpenDialog()}
                >
                  탭 추가
                </Button>
              </Box>

              {loadingTabs ? (
                <CircularProgress />
              ) : tabs.length === 0 ? (
                <Alert severity="info">등록된 탭이 없습니다</Alert>
              ) : (
                <TableContainer>
                  <Table>
                    <TableHead>
                      <TableRow>
                        <TableCell>탭 이름</TableCell>
                        <TableCell>연령대</TableCell>
                        <TableCell>유형</TableCell>
                        <TableCell>공급 수</TableCell>
                        <TableCell>순서</TableCell>
                        <TableCell width={100}>작업</TableCell>
                      </TableRow>
                    </TableHead>
                    <TableBody>
                      {tabs.map((tab) => (
                        <TableRow key={tab.id} hover>
                          <TableCell>{tab.tab_name}</TableCell>
                          <TableCell>
                            {tab.age_categories?.title || '-'}
                          </TableCell>
                          <TableCell>{tab.unit_type || '-'}</TableCell>
                          <TableCell>{tab.supply_count || '-'}</TableCell>
                          <TableCell>
                            <Chip label={tab.display_order} size="small" />
                          </TableCell>
                          <TableCell>
                            <IconButton
                              size="small"
                              onClick={() => handleOpenDialog(tab)}
                            >
                              <EditIcon fontSize="small" />
                            </IconButton>
                            <IconButton
                              size="small"
                              color="error"
                              onClick={() => handleDelete(tab)}
                            >
                              <DeleteIcon fontSize="small" />
                            </IconButton>
                          </TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </TableContainer>
              )}
            </Paper>
          ) : (
            <Alert severity="info">왼쪽에서 공고를 선택해주세요</Alert>
          )}
        </Grid>
      </Grid>

      {/* Add/Edit Dialog */}
      <Dialog
        open={dialogOpen}
        onClose={handleCloseDialog}
        maxWidth="md"
        fullWidth
      >
        <DialogTitle>
          {editingTab ? '탭 수정' : '탭 추가'}
        </DialogTitle>
        <form onSubmit={handleSubmit(onSubmit)}>
          <DialogContent>
            <Grid container spacing={2}>
              {/* Basic Info */}
              <Grid item xs={12}>
                <Controller
                  name="tab_name"
                  control={control}
                  rules={{ required: '탭 이름을 입력하세요' }}
                  render={({ field }) => (
                    <TextField
                      {...field}
                      fullWidth
                      label="탭 이름"
                      error={!!errors.tab_name}
                      helperText={errors.tab_name?.message}
                    />
                  )}
                />
              </Grid>

              <Grid item xs={6}>
                <Controller
                  name="age_category_id"
                  control={control}
                  render={({ field }) => (
                    <FormControl fullWidth>
                      <InputLabel>연령대 카테고리</InputLabel>
                      <Select {...field} label="연령대 카테고리" value={field.value || ''}>
                        <MenuItem value="">선택 안함</MenuItem>
                        {ageCategories.map((cat) => (
                          <MenuItem key={cat.id} value={cat.id}>
                            {cat.title}
                          </MenuItem>
                        ))}
                      </Select>
                    </FormControl>
                  )}
                />
              </Grid>

              <Grid item xs={6}>
                <Controller
                  name="unit_type"
                  control={control}
                  render={({ field }) => (
                    <TextField
                      {...field}
                      value={field.value || ''}
                      fullWidth
                      label="주택 유형 (예: 전용 59㎡)"
                    />
                  )}
                />
              </Grid>

              <Grid item xs={6}>
                <Controller
                  name="supply_count"
                  control={control}
                  render={({ field }) => (
                    <TextField
                      {...field}
                      value={field.value || ''}
                      onChange={(e) => field.onChange(e.target.value ? parseInt(e.target.value) : null)}
                      fullWidth
                      label="공급 수량"
                      type="number"
                    />
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
                      label="표시 순서"
                      type="number"
                    />
                  )}
                />
              </Grid>

              {/* Floor Plan Upload */}
              <Grid item xs={12}>
                <Divider sx={{ my: 1 }} />
                <Typography variant="subtitle2" gutterBottom>
                  도면 이미지
                </Typography>
                <Button
                  variant="outlined"
                  component="label"
                  startIcon={<ImageIcon />}
                  fullWidth
                >
                  {floorPlanFile ? floorPlanFile.name : '도면 이미지 업로드'}
                  <input
                    type="file"
                    hidden
                    accept="image/*"
                    onChange={(e) => setFloorPlanFile(e.target.files?.[0] || null)}
                  />
                </Button>
              </Grid>

              {/* Income Conditions */}
              <Grid item xs={12}>
                <Divider sx={{ my: 1 }} />
                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <Typography variant="subtitle2">소득 조건</Typography>
                  <Button size="small" onClick={addIncomeCondition}>
                    조건 추가
                  </Button>
                </Box>
                {watchedIncomeConditions && watchedIncomeConditions.length > 0 && (
                  <Stack spacing={1} sx={{ mt: 1 }}>
                    {watchedIncomeConditions.map((_, index) => (
                      <Box key={index} sx={{ display: 'flex', gap: 1, alignItems: 'center' }}>
                        <TextField
                          size="small"
                          label="설명"
                          value={watchedIncomeConditions[index].description || ''}
                          onChange={(e) => {
                            const updated = [...watchedIncomeConditions]
                            updated[index].description = e.target.value
                            setValue('income_conditions', updated)
                          }}
                          sx={{ flex: 1 }}
                        />
                        <IconButton size="small" color="error" onClick={() => removeIncomeCondition(index)}>
                          <DeleteIcon fontSize="small" />
                        </IconButton>
                      </Box>
                    ))}
                  </Stack>
                )}
              </Grid>

              {/* Custom Content */}
              <Grid item xs={12}>
                <Divider sx={{ my: 1 }} />
                <Typography variant="subtitle2" gutterBottom>
                  추가 이미지
                </Typography>
                <Button
                  variant="outlined"
                  component="label"
                  startIcon={<ImageIcon />}
                  fullWidth
                >
                  이미지 추가 ({customImages.length})
                  <input
                    type="file"
                    hidden
                    accept="image/*"
                    multiple
                    onChange={(e) => {
                      const files = Array.from(e.target.files || [])
                      setCustomImages((prev) => [...prev, ...files])
                    }}
                  />
                </Button>
              </Grid>

              <Grid item xs={12}>
                <Typography variant="subtitle2" gutterBottom>
                  PDF 파일
                </Typography>
                <Button
                  variant="outlined"
                  component="label"
                  startIcon={<PdfIcon />}
                  fullWidth
                >
                  PDF 추가 ({customPdfs.length})
                  <input
                    type="file"
                    hidden
                    accept="application/pdf"
                    multiple
                    onChange={(e) => {
                      const files = Array.from(e.target.files || [])
                      setCustomPdfs((prev) => [...prev, ...files])
                    }}
                  />
                </Button>
              </Grid>

              <Grid item xs={12}>
                <Controller
                  name="additional_info"
                  control={control}
                  render={({ field }) => (
                    <TextField
                      value={field.value?.extra_notes || ''}
                      onChange={(e) => {
                        const current = field.value || {}
                        field.onChange({
                          ...current,
                          extra_notes: e.target.value,
                        })
                      }}
                      fullWidth
                      label="추가 메모"
                      multiline
                      rows={3}
                    />
                  )}
                />
              </Grid>
            </Grid>
          </DialogContent>
          <DialogActions>
            <Button onClick={handleCloseDialog}>취소</Button>
            <Button
              type="submit"
              variant="contained"
              disabled={isSubmitting}
            >
              {editingTab ? '수정' : '추가'}
            </Button>
          </DialogActions>
        </form>
      </Dialog>
    </Box>
  )
}
