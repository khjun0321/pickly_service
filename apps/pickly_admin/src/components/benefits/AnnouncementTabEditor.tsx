/**
 * Announcement Tab Editor Component
 * PRD v9.6 Section 4.2 & 5.4 - Announcement Tabs Management
 * Manages announcement_tabs 1:N relationship
 */

import { useState, useEffect } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  Box,
  Typography,
  TextField,
  IconButton,
  List,
  ListItem,
  ListItemText,
  ListItemSecondaryAction,
  Paper,
  Grid,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
} from '@mui/material'
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  DragIndicator as DragIcon,
  ArrowUpward as ArrowUpIcon,
  ArrowDownward as ArrowDownIcon,
} from '@mui/icons-material'
import { supabase } from '@/lib/supabase'
import ImageUploader from '@/components/common/ImageUploader'
import type { AnnouncementTab, AnnouncementTabFormData } from '@/types/benefits'
import toast from 'react-hot-toast'

interface AnnouncementTabEditorProps {
  open: boolean
  announcementId: string
  onClose: () => void
}

export default function AnnouncementTabEditor({ open, announcementId, onClose }: AnnouncementTabEditorProps) {
  const queryClient = useQueryClient()
  const [tabDialogOpen, setTabDialogOpen] = useState(false)
  const [editingTab, setEditingTab] = useState<AnnouncementTab | null>(null)
  const [formData, setFormData] = useState<AnnouncementTabFormData>({
    announcement_id: announcementId,
    tab_name: '',
    age_category_id: null,
    unit_type: null,
    floor_plan_image_url: null,
    supply_count: null,
    income_conditions: null,
    additional_info: null,
    display_order: 0,
  })

  // Fetch announcement tabs
  const { data: tabs = [], isLoading } = useQuery({
    queryKey: ['announcement_tabs', announcementId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('announcement_tabs')
        .select('*')
        .eq('announcement_id', announcementId)
        .order('display_order', { ascending: true })

      if (error) throw error
      return data as AnnouncementTab[]
    },
    enabled: open && !!announcementId,
  })

  // Fetch age categories for dropdown
  const { data: ageCategories = [] } = useQuery({
    queryKey: ['age_categories'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('age_categories')
        .select('*')
        .order('min_age', { ascending: true })

      if (error) throw error
      return data
    },
  })

  // Create/Update mutation
  const saveMutation = useMutation({
    mutationFn: async (data: AnnouncementTabFormData & { id?: string }) => {
      if (data.id) {
        const { error } = await supabase
          .from('announcement_tabs')
          .update(data)
          .eq('id', data.id)
        if (error) throw error
      } else {
        const { error } = await supabase.from('announcement_tabs').insert([data])
        if (error) throw error
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['announcement_tabs', announcementId] })
      toast.success(editingTab ? '탭이 수정되었습니다' : '탭이 추가되었습니다')
      handleCloseTabDialog()
    },
    onError: (error: Error) => {
      toast.error(`오류: ${error.message}`)
    },
  })

  // Delete mutation
  const deleteMutation = useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from('announcement_tabs').delete().eq('id', id)
      if (error) throw error
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['announcement_tabs', announcementId] })
      toast.success('탭이 삭제되었습니다')
    },
    onError: (error: Error) => {
      toast.error(`삭제 실패: ${error.message}`)
    },
  })

  // Reorder mutation
  const reorderMutation = useMutation({
    mutationFn: async (updates: { id: string; display_order: number }[]) => {
      const promises = updates.map(({ id, display_order }) =>
        supabase.from('announcement_tabs').update({ display_order }).eq('id', id)
      )
      const results = await Promise.all(promises)
      const error = results.find((r) => r.error)?.error
      if (error) throw error
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['announcement_tabs', announcementId] })
    },
    onError: (error: Error) => {
      toast.error(`순서 변경 실패: ${error.message}`)
    },
  })

  const handleOpenTabDialog = (tab?: AnnouncementTab) => {
    if (tab) {
      setEditingTab(tab)
      setFormData({
        announcement_id: tab.announcement_id || announcementId,
        tab_name: tab.tab_name,
        age_category_id: tab.age_category_id,
        unit_type: tab.unit_type,
        floor_plan_image_url: tab.floor_plan_image_url,
        supply_count: tab.supply_count,
        income_conditions: tab.income_conditions,
        additional_info: tab.additional_info,
        display_order: tab.display_order,
      })
    } else {
      setEditingTab(null)
      setFormData({
        announcement_id: announcementId,
        tab_name: '',
        age_category_id: null,
        unit_type: null,
        floor_plan_image_url: null,
        supply_count: null,
        income_conditions: null,
        additional_info: null,
        display_order: tabs.length,
      })
    }
    setTabDialogOpen(true)
  }

  const handleCloseTabDialog = () => {
    setTabDialogOpen(false)
    setEditingTab(null)
  }

  const handleSaveTab = () => {
    if (!formData.tab_name.trim()) {
      toast.error('탭 이름을 입력하세요')
      return
    }

    saveMutation.mutate({
      ...formData,
      ...(editingTab && { id: editingTab.id }),
    })
  }

  const handleDeleteTab = (id: string) => {
    if (window.confirm('이 탭을 삭제하시겠습니까?')) {
      deleteMutation.mutate(id)
    }
  }

  const handleMoveTab = (index: number, direction: 'up' | 'down') => {
    const newIndex = direction === 'up' ? index - 1 : index + 1
    if (newIndex < 0 || newIndex >= tabs.length) return

    const newTabs = [...tabs]
    const [moved] = newTabs.splice(index, 1)
    newTabs.splice(newIndex, 0, moved)

    const updates = newTabs.map((tab, idx) => ({
      id: tab.id,
      display_order: idx,
    }))

    reorderMutation.mutate(updates)
  }

  if (isLoading) {
    return (
      <Dialog open={open} onClose={onClose} maxWidth="md" fullWidth>
        <DialogTitle>탭 관리</DialogTitle>
        <DialogContent>
          <Typography>로딩 중...</Typography>
        </DialogContent>
      </Dialog>
    )
  }

  return (
    <>
      <Dialog open={open} onClose={onClose} maxWidth="md" fullWidth>
        <DialogTitle>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <Typography variant="h6">공고 탭 관리</Typography>
            <Button
              variant="contained"
              size="small"
              startIcon={<AddIcon />}
              onClick={() => handleOpenTabDialog()}
            >
              탭 추가
            </Button>
          </Box>
        </DialogTitle>
        <DialogContent>
          <Paper sx={{ mt: 2 }}>
            <List>
              {tabs.length === 0 ? (
                <ListItem>
                  <ListItemText
                    primary="등록된 탭이 없습니다"
                    secondary="새 탭을 추가하려면 '탭 추가' 버튼을 클릭하세요"
                  />
                </ListItem>
              ) : (
                tabs.map((tab, index) => (
                  <ListItem
                    key={tab.id}
                    sx={{
                      borderBottom: '1px solid',
                      borderColor: 'divider',
                      '&:last-child': { borderBottom: 'none' },
                    }}
                  >
                    <IconButton sx={{ mr: 1, cursor: 'grab' }}>
                      <DragIcon />
                    </IconButton>
                    <ListItemText
                      primary={tab.tab_name}
                      secondary={
                        <>
                          {tab.unit_type && `유형: ${tab.unit_type}`}
                          {tab.supply_count && ` | 공급: ${tab.supply_count}호`}
                          {tab.age_category_id && ` | 연령 필터 적용`}
                        </>
                      }
                    />
                    <ListItemSecondaryAction>
                      <IconButton
                        size="small"
                        onClick={() => handleMoveTab(index, 'up')}
                        disabled={index === 0}
                      >
                        <ArrowUpIcon fontSize="small" />
                      </IconButton>
                      <IconButton
                        size="small"
                        onClick={() => handleMoveTab(index, 'down')}
                        disabled={index === tabs.length - 1}
                      >
                        <ArrowDownIcon fontSize="small" />
                      </IconButton>
                      <IconButton size="small" onClick={() => handleOpenTabDialog(tab)}>
                        <EditIcon fontSize="small" />
                      </IconButton>
                      <IconButton size="small" color="error" onClick={() => handleDeleteTab(tab.id)}>
                        <DeleteIcon fontSize="small" />
                      </IconButton>
                    </ListItemSecondaryAction>
                  </ListItem>
                ))
              )}
            </List>
          </Paper>
        </DialogContent>
        <DialogActions>
          <Button onClick={onClose}>닫기</Button>
        </DialogActions>
      </Dialog>

      {/* Tab Add/Edit Dialog */}
      <Dialog open={tabDialogOpen} onClose={handleCloseTabDialog} maxWidth="sm" fullWidth>
        <DialogTitle>{editingTab ? '탭 수정' : '탭 추가'}</DialogTitle>
        <DialogContent>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, pt: 2 }}>
            <TextField
              label="탭 이름"
              value={formData.tab_name}
              onChange={(e) => setFormData({ ...formData, tab_name: e.target.value })}
              fullWidth
              required
              helperText="예: 청년형, 신혼부부형, 고령자형"
            />

            <FormControl fullWidth>
              <InputLabel>연령 카테고리 (선택)</InputLabel>
              <Select
                value={formData.age_category_id || ''}
                onChange={(e) => setFormData({ ...formData, age_category_id: e.target.value || null })}
                label="연령 카테고리 (선택)"
              >
                <MenuItem value="">선택 안함</MenuItem>
                {ageCategories.map((cat: any) => (
                  <MenuItem key={cat.id} value={cat.id}>
                    {cat.name} ({cat.min_age}-{cat.max_age}세)
                  </MenuItem>
                ))}
              </Select>
            </FormControl>

            <TextField
              label="세대 유형 (선택)"
              value={formData.unit_type || ''}
              onChange={(e) => setFormData({ ...formData, unit_type: e.target.value || null })}
              fullWidth
              helperText="예: 1인가구, 2인가구, 신혼부부"
            />

            <TextField
              label="공급 호수 (선택)"
              type="number"
              value={formData.supply_count || ''}
              onChange={(e) => setFormData({ ...formData, supply_count: e.target.value ? Number(e.target.value) : null })}
              fullWidth
            />

            <ImageUploader
              bucket="benefit-thumbnails"
              currentImageUrl={formData.floor_plan_image_url}
              onUploadComplete={(url) => {
                setFormData({ ...formData, floor_plan_image_url: url })
              }}
              onDelete={() => {
                setFormData({ ...formData, floor_plan_image_url: null })
              }}
              label="평면도 이미지 (선택)"
              helperText="평면도 또는 도면 이미지를 업로드하세요"
              acceptedFormats={['image/jpeg', 'image/png', 'image/webp']}
            />

            <TextField
              label="소득 조건 (JSON, 선택)"
              value={formData.income_conditions ? JSON.stringify(formData.income_conditions) : ''}
              onChange={(e) => {
                try {
                  const parsed = e.target.value ? JSON.parse(e.target.value) : null
                  setFormData({ ...formData, income_conditions: parsed })
                } catch {
                  // Invalid JSON, ignore
                }
              }}
              fullWidth
              multiline
              rows={2}
              helperText='예: {"min": 0, "max": 100, "type": "중위소득"}'
            />

            <TextField
              label="추가 정보 (JSON, 선택)"
              value={formData.additional_info ? JSON.stringify(formData.additional_info) : ''}
              onChange={(e) => {
                try {
                  const parsed = e.target.value ? JSON.parse(e.target.value) : null
                  setFormData({ ...formData, additional_info: parsed })
                } catch {
                  // Invalid JSON, ignore
                }
              }}
              fullWidth
              multiline
              rows={2}
              helperText='예: {"deposit": "1억원", "rent": "20만원"}'
            />
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseTabDialog}>취소</Button>
          <Button
            onClick={handleSaveTab}
            variant="contained"
            disabled={saveMutation.isPending}
          >
            {editingTab ? '수정' : '추가'}
          </Button>
        </DialogActions>
      </Dialog>
    </>
  )
}
