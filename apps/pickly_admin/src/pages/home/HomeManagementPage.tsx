/**
 * Home Management Page
 * PRD v9.6 Section 4.1 - Home Section Management
 */

import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import {
  Box,
  Typography,
  Button,
  Paper,
  List,
  ListItem,
  ListItemText,
  ListItemSecondaryAction,
  IconButton,
  Switch,
  Chip,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Select,
  MenuItem,
  FormControl,
  InputLabel,
} from '@mui/material'
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  DragIndicator as DragIcon,
} from '@mui/icons-material'
import { supabase } from '@/lib/supabase'
import type { HomeSection, HomeSectionFormData, SectionType } from '@/types/home'
import toast from 'react-hot-toast'

export default function HomeManagementPage() {
  const queryClient = useQueryClient()
  const [dialogOpen, setDialogOpen] = useState(false)
  const [editingSection, setEditingSection] = useState<HomeSection | null>(null)
  const [formData, setFormData] = useState<HomeSectionFormData>({
    title: '',
    section_type: 'featured',
    description: null,
    sort_order: 0,
    is_active: true,
  })

  // Fetch home sections
  const { data: sections = [], isLoading } = useQuery({
    queryKey: ['home_sections'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('home_sections')
        .select('*')
        .order('sort_order', { ascending: true })

      if (error) throw error
      return data as HomeSection[]
    },
  })

  // Create/Update mutation
  const saveMutation = useMutation({
    mutationFn: async (data: HomeSectionFormData & { id?: string }) => {
      if (data.id) {
        const { error } = await supabase
          .from('home_sections')
          .update(data)
          .eq('id', data.id)
        if (error) throw error
      } else {
        const { error } = await supabase.from('home_sections').insert([data])
        if (error) throw error
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['home_sections'] })
      toast.success(editingSection ? '섹션이 수정되었습니다' : '섹션이 추가되었습니다')
      handleCloseDialog()
    },
    onError: (error: Error) => {
      toast.error(`오류: ${error.message}`)
    },
  })

  // Delete mutation
  const deleteMutation = useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from('home_sections').delete().eq('id', id)
      if (error) throw error
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['home_sections'] })
      toast.success('섹션이 삭제되었습니다')
    },
    onError: (error: Error) => {
      toast.error(`삭제 실패: ${error.message}`)
    },
  })

  // Toggle active status
  const toggleActiveMutation = useMutation({
    mutationFn: async ({ id, is_active }: { id: string; is_active: boolean }) => {
      const { error } = await supabase
        .from('home_sections')
        .update({ is_active })
        .eq('id', id)
      if (error) throw error
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['home_sections'] })
    },
  })

  const handleOpenDialog = (section?: HomeSection) => {
    if (section) {
      setEditingSection(section)
      setFormData({
        title: section.title,
        section_type: section.section_type,
        description: section.description,
        sort_order: section.sort_order,
        is_active: section.is_active,
      })
    } else {
      setEditingSection(null)
      setFormData({
        title: '',
        section_type: 'featured',
        description: null,
        sort_order: sections.length,
        is_active: true,
      })
    }
    setDialogOpen(true)
  }

  const handleCloseDialog = () => {
    setDialogOpen(false)
    setEditingSection(null)
  }

  const handleSave = () => {
    if (!formData.title.trim()) {
      toast.error('섹션 제목을 입력하세요')
      return
    }

    saveMutation.mutate({
      ...formData,
      ...(editingSection && { id: editingSection.id }),
    })
  }

  const handleDelete = (id: string) => {
    if (window.confirm('이 섹션을 삭제하시겠습니까?')) {
      deleteMutation.mutate(id)
    }
  }

  const getSectionTypeLabel = (type: SectionType) => {
    switch (type) {
      case 'community':
        return '인기 커뮤니티 (자동)'
      case 'featured':
        return '추천 콘텐츠 (수동)'
      case 'announcements':
        return '인기 공고 (자동)'
      default:
        return type
    }
  }

  if (isLoading) {
    return (
      <Box sx={{ p: 3 }}>
        <Typography>로딩 중...</Typography>
      </Box>
    )
  }

  return (
    <Box sx={{ p: 3 }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Typography variant="h4">홈 관리</Typography>
        <Button variant="contained" startIcon={<AddIcon />} onClick={() => handleOpenDialog()}>
          섹션 추가
        </Button>
      </Box>

      <Paper>
        <List>
          {sections.map((section) => (
            <ListItem
              key={section.id}
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
                primary={
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <Typography variant="h6">{section.title}</Typography>
                    <Chip
                      label={getSectionTypeLabel(section.section_type)}
                      size="small"
                      color={section.section_type === 'featured' ? 'primary' : 'default'}
                    />
                    {!section.is_active && (
                      <Chip label="비활성" size="small" color="default" variant="outlined" />
                    )}
                  </Box>
                }
                secondary={
                  <Box>
                    <Typography variant="body2" color="text.secondary">
                      {section.description || '설명 없음'}
                    </Typography>
                    <Typography variant="caption" color="text.secondary">
                      정렬 순서: {section.sort_order}
                    </Typography>
                  </Box>
                }
              />
              <ListItemSecondaryAction>
                <Switch
                  checked={section.is_active}
                  onChange={(e) =>
                    toggleActiveMutation.mutate({ id: section.id, is_active: e.target.checked })
                  }
                  color="primary"
                />
                <IconButton onClick={() => handleOpenDialog(section)} sx={{ ml: 1 }}>
                  <EditIcon />
                </IconButton>
                <IconButton onClick={() => handleDelete(section.id)} color="error">
                  <DeleteIcon />
                </IconButton>
              </ListItemSecondaryAction>
            </ListItem>
          ))}
          {sections.length === 0 && (
            <ListItem>
              <ListItemText
                primary="섹션이 없습니다"
                secondary="새 섹션을 추가하려면 '섹션 추가' 버튼을 클릭하세요"
              />
            </ListItem>
          )}
        </List>
      </Paper>

      {/* Create/Edit Dialog */}
      <Dialog open={dialogOpen} onClose={handleCloseDialog} maxWidth="sm" fullWidth>
        <DialogTitle>{editingSection ? '섹션 수정' : '섹션 추가'}</DialogTitle>
        <DialogContent>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, pt: 2 }}>
            <TextField
              label="섹션 제목"
              value={formData.title}
              onChange={(e) => setFormData({ ...formData, title: e.target.value })}
              fullWidth
              required
            />
            <FormControl fullWidth>
              <InputLabel>섹션 타입</InputLabel>
              <Select
                value={formData.section_type}
                label="섹션 타입"
                onChange={(e) =>
                  setFormData({ ...formData, section_type: e.target.value as SectionType })
                }
              >
                <MenuItem value="community">인기 커뮤니티 (자동 노출)</MenuItem>
                <MenuItem value="featured">추천 콘텐츠 (수동 관리)</MenuItem>
                <MenuItem value="announcements">인기 공고 (자동 노출)</MenuItem>
              </Select>
            </FormControl>
            <TextField
              label="설명"
              value={formData.description || ''}
              onChange={(e) => setFormData({ ...formData, description: e.target.value || null })}
              multiline
              rows={3}
              fullWidth
            />
            <TextField
              label="정렬 순서"
              type="number"
              value={formData.sort_order}
              onChange={(e) => setFormData({ ...formData, sort_order: Number(e.target.value) })}
              fullWidth
              helperText="낮은 숫자일수록 먼저 표시됩니다"
            />
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDialog}>취소</Button>
          <Button
            onClick={handleSave}
            variant="contained"
            disabled={saveMutation.isPending}
          >
            {editingSection ? '수정' : '추가'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  )
}
