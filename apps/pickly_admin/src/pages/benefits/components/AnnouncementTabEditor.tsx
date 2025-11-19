import { useState, useEffect } from 'react'
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  TextField,
  IconButton,
  Box,
  Typography,
  Paper,
  Divider,
  Stack,
} from '@mui/material'
import {
  Add as AddIcon,
  Delete as DeleteIcon,
  ArrowUpward as ArrowUpIcon,
  ArrowDownward as ArrowDownIcon,
  CloudUpload as UploadIcon,
} from '@mui/icons-material'
import { useMutation, useQuery } from '@tanstack/react-query'
import toast from 'react-hot-toast'
import { supabase } from '@/lib/supabase'

// ================================================================
// TypeScript Interfaces
// ================================================================

interface TabImage {
  url: string
  caption: string
  sort_order: number
}

interface TabContent {
  section_title: string
  section_body: string
  sort_order: number
}

interface Tab {
  id?: string // Optional - only exists for loaded tabs
  title: string
  sort_order: number
  contents: TabContent[]
  images: TabImage[]
}

interface AnnouncementTabEditorProps {
  open: boolean
  onClose: () => void
  announcementId: string | null
  announcementTitle?: string
}

// ================================================================
// Main Component
// ================================================================

export default function AnnouncementTabEditor({
  open,
  onClose,
  announcementId,
  announcementTitle = '',
}: AnnouncementTabEditorProps) {
  const [tabs, setTabs] = useState<Tab[]>([])

  // ================================================================
  // Load Existing Tabs
  // ================================================================

  const { refetch: loadTabs } = useQuery({
    queryKey: ['announcement-tabs', announcementId],
    queryFn: async () => {
      if (!announcementId) return []

      // Fetch tabs
      const { data: tabsData, error: tabsError } = await supabase
        .from('announcement_tabs')
        .select('*')
        .eq('announcement_id', announcementId)
        .order('display_order', { ascending: true })

      if (tabsError) throw tabsError

      // For each tab, fetch contents and images
      const tabsWithDetails = await Promise.all(
        (tabsData || []).map(async (tab) => {
          // Fetch contents
          const { data: contentsData } = await supabase
            .from('announcement_tab_contents')
            .select('*')
            .eq('tab_id', tab.id)
            .order('sort_order', { ascending: true })

          // Fetch images
          const { data: imagesData } = await supabase
            .from('announcement_tab_images')
            .select('*')
            .eq('tab_id', tab.id)
            .order('sort_order', { ascending: true })

          return {
            id: tab.id,
            title: tab.tab_name,
            sort_order: tab.display_order,
            contents: (contentsData || []).map((c) => ({
              section_title: c.section_title || '',
              section_body: c.section_body || '',
              sort_order: c.sort_order || 0,
            })),
            images: (imagesData || []).map((img) => ({
              url: img.image_url,
              caption: img.caption || '',
              sort_order: img.sort_order || 0,
            })),
          } as Tab
        })
      )

      return tabsWithDetails
    },
    enabled: false, // Manual trigger
  })

  // Load tabs when dialog opens
  useEffect(() => {
    if (open && announcementId) {
      loadTabs().then(({ data }) => {
        if (data) {
          setTabs(data)
        }
      })
    } else if (!open) {
      // Reset on close
      setTabs([])
    }
  }, [open, announcementId, loadTabs])

  // ================================================================
  // Save Tabs Mutation
  // ================================================================

  const saveTabsMutation = useMutation({
    mutationFn: async (tabsToSave: Tab[]) => {
      if (!announcementId) {
        throw new Error('No announcement ID')
      }

      // Convert to RPC format
      const p_tabs = tabsToSave.map((tab) => ({
        title: tab.title,
        sort_order: tab.sort_order,
        contents: tab.contents.map((c) => ({
          section_title: c.section_title,
          section_body: c.section_body,
          sort_order: c.sort_order,
        })),
        images: tab.images.map((img) => ({
          image_url: img.url,
          caption: img.caption,
          sort_order: img.sort_order,
        })),
      }))

      const { error } = await supabase.rpc('save_announcement_tabs', {
        p_announcement_id: announcementId,
        p_tabs: p_tabs,
      })

      if (error) throw error
    },
    onSuccess: () => {
      toast.success('탭이 저장되었습니다')
      onClose()
    },
    onError: (error: Error) => {
      toast.error(error.message || '탭 저장에 실패했습니다')
    },
  })

  // ================================================================
  // Tab Management Functions
  // ================================================================

  const handleAddTab = () => {
    setTabs([
      ...tabs,
      {
        title: '',
        sort_order: tabs.length,
        contents: [],
        images: [],
      },
    ])
  }

  const handleRemoveTab = (index: number) => {
    setTabs(tabs.filter((_, i) => i !== index))
  }

  const handleMoveTabUp = (index: number) => {
    if (index === 0) return
    const newTabs = [...tabs]
    ;[newTabs[index - 1], newTabs[index]] = [newTabs[index], newTabs[index - 1]]
    // Update sort_order
    newTabs.forEach((tab, i) => {
      tab.sort_order = i
    })
    setTabs(newTabs)
  }

  const handleMoveTabDown = (index: number) => {
    if (index === tabs.length - 1) return
    const newTabs = [...tabs]
    ;[newTabs[index], newTabs[index + 1]] = [newTabs[index + 1], newTabs[index]]
    // Update sort_order
    newTabs.forEach((tab, i) => {
      tab.sort_order = i
    })
    setTabs(newTabs)
  }

  const handleUpdateTabTitle = (index: number, title: string) => {
    const newTabs = [...tabs]
    newTabs[index].title = title
    setTabs(newTabs)
  }

  // ================================================================
  // Content Management Functions
  // ================================================================

  const handleAddContent = (tabIndex: number) => {
    const newTabs = [...tabs]
    newTabs[tabIndex].contents.push({
      section_title: '',
      section_body: '',
      sort_order: newTabs[tabIndex].contents.length,
    })
    setTabs(newTabs)
  }

  const handleRemoveContent = (tabIndex: number, contentIndex: number) => {
    const newTabs = [...tabs]
    newTabs[tabIndex].contents = newTabs[tabIndex].contents.filter(
      (_, i) => i !== contentIndex
    )
    setTabs(newTabs)
  }

  const handleUpdateContent = (
    tabIndex: number,
    contentIndex: number,
    field: 'section_title' | 'section_body',
    value: string
  ) => {
    const newTabs = [...tabs]
    newTabs[tabIndex].contents[contentIndex][field] = value
    setTabs(newTabs)
  }

  // ================================================================
  // Image Management Functions
  // ================================================================

  const handleImageUpload = async (
    tabIndex: number,
    event: React.ChangeEvent<HTMLInputElement>
  ) => {
    const file = event.target.files?.[0]
    if (!file) return

    if (!file.type.startsWith('image/')) {
      toast.error('이미지 파일만 업로드할 수 있습니다.')
      return
    }

    if (file.size > 5 * 1024 * 1024) {
      toast.error('이미지 파일 크기는 5MB 이하만 가능합니다.')
      return
    }

    const fileExt = file.name.split('.').pop()
    const filePath = `tabs/${Date.now()}-${Math.random().toString(36).substring(2, 8)}.${fileExt}`

    const { error: uploadError } = await supabase.storage
      .from('benefit-images')
      .upload(filePath, file, {
        cacheControl: '3600',
        upsert: false,
      })

    if (uploadError) {
      toast.error('이미지 업로드에 실패했습니다.')
      return
    }

    const { data: urlData } = supabase.storage
      .from('benefit-images')
      .getPublicUrl(filePath)

    const newTabs = [...tabs]
    newTabs[tabIndex].images.push({
      url: urlData.publicUrl,
      caption: '',
      sort_order: newTabs[tabIndex].images.length,
    })
    setTabs(newTabs)
    toast.success('이미지가 업로드되었습니다.')
  }

  const handleRemoveImage = (tabIndex: number, imageIndex: number) => {
    const newTabs = [...tabs]
    newTabs[tabIndex].images = newTabs[tabIndex].images.filter(
      (_, i) => i !== imageIndex
    )
    setTabs(newTabs)
  }

  const handleUpdateImageCaption = (
    tabIndex: number,
    imageIndex: number,
    caption: string
  ) => {
    const newTabs = [...tabs]
    newTabs[tabIndex].images[imageIndex].caption = caption
    setTabs(newTabs)
  }

  // ================================================================
  // Save Handler
  // ================================================================

  const handleSave = () => {
    // Validation
    for (const tab of tabs) {
      if (!tab.title.trim()) {
        toast.error('모든 탭의 제목을 입력해주세요.')
        return
      }
    }

    saveTabsMutation.mutate(tabs)
  }

  // ================================================================
  // Render
  // ================================================================

  return (
    <Dialog open={open} onClose={onClose} maxWidth="md" fullWidth>
      <DialogTitle>
        평형 탭 관리
        {announcementTitle && (
          <Typography variant="body2" color="text.secondary">
            공고: {announcementTitle}
          </Typography>
        )}
      </DialogTitle>

      <DialogContent dividers>
        <Stack spacing={2}>
          {/* Add Tab Button */}
          <Button
            variant="outlined"
            startIcon={<AddIcon />}
            onClick={handleAddTab}
            fullWidth
          >
            새 탭 추가
          </Button>

          {/* Tabs List */}
          {tabs.map((tab, tabIndex) => (
            <Paper key={tabIndex} sx={{ p: 2 }} elevation={2}>
              {/* Tab Header */}
              <Box display="flex" alignItems="center" gap={1} mb={2}>
                <TextField
                  label="탭 제목"
                  value={tab.title}
                  onChange={(e) => handleUpdateTabTitle(tabIndex, e.target.value)}
                  size="small"
                  fullWidth
                  placeholder="예: 84㎡A"
                />
                <IconButton
                  onClick={() => handleMoveTabUp(tabIndex)}
                  disabled={tabIndex === 0}
                  size="small"
                >
                  <ArrowUpIcon />
                </IconButton>
                <IconButton
                  onClick={() => handleMoveTabDown(tabIndex)}
                  disabled={tabIndex === tabs.length - 1}
                  size="small"
                >
                  <ArrowDownIcon />
                </IconButton>
                <IconButton
                  onClick={() => handleRemoveTab(tabIndex)}
                  color="error"
                  size="small"
                >
                  <DeleteIcon />
                </IconButton>
              </Box>

              <Divider sx={{ my: 2 }} />

              {/* Contents Section */}
              <Typography variant="subtitle2" gutterBottom>
                텍스트 섹션
              </Typography>
              <Stack spacing={1} mb={2}>
                {tab.contents.map((content, contentIndex) => (
                  <Box key={contentIndex} display="flex" gap={1}>
                    <TextField
                      label="섹션 제목"
                      value={content.section_title}
                      onChange={(e) =>
                        handleUpdateContent(
                          tabIndex,
                          contentIndex,
                          'section_title',
                          e.target.value
                        )
                      }
                      size="small"
                      sx={{ width: '30%' }}
                    />
                    <TextField
                      label="섹션 내용"
                      value={content.section_body}
                      onChange={(e) =>
                        handleUpdateContent(
                          tabIndex,
                          contentIndex,
                          'section_body',
                          e.target.value
                        )
                      }
                      size="small"
                      multiline
                      rows={2}
                      fullWidth
                    />
                    <IconButton
                      onClick={() => handleRemoveContent(tabIndex, contentIndex)}
                      color="error"
                      size="small"
                    >
                      <DeleteIcon />
                    </IconButton>
                  </Box>
                ))}
                <Button
                  variant="text"
                  startIcon={<AddIcon />}
                  onClick={() => handleAddContent(tabIndex)}
                  size="small"
                >
                  섹션 추가
                </Button>
              </Stack>

              <Divider sx={{ my: 2 }} />

              {/* Images Section */}
              <Typography variant="subtitle2" gutterBottom>
                이미지
              </Typography>
              <Stack spacing={1}>
                {tab.images.map((image, imageIndex) => (
                  <Box key={imageIndex} display="flex" gap={1} alignItems="center">
                    <Box
                      component="img"
                      src={image.url}
                      alt={image.caption}
                      sx={{
                        width: 80,
                        height: 80,
                        objectFit: 'cover',
                        borderRadius: 1,
                      }}
                    />
                    <TextField
                      label="이미지 설명"
                      value={image.caption}
                      onChange={(e) =>
                        handleUpdateImageCaption(tabIndex, imageIndex, e.target.value)
                      }
                      size="small"
                      fullWidth
                    />
                    <IconButton
                      onClick={() => handleRemoveImage(tabIndex, imageIndex)}
                      color="error"
                      size="small"
                    >
                      <DeleteIcon />
                    </IconButton>
                  </Box>
                ))}
                <Button
                  variant="text"
                  startIcon={<UploadIcon />}
                  component="label"
                  size="small"
                >
                  이미지 업로드
                  <input
                    type="file"
                    hidden
                    accept="image/*"
                    onChange={(e) => handleImageUpload(tabIndex, e)}
                  />
                </Button>
              </Stack>
            </Paper>
          ))}

          {tabs.length === 0 && (
            <Typography color="text.secondary" align="center" py={4}>
              탭을 추가하여 평형별 상세 정보를 관리하세요.
            </Typography>
          )}
        </Stack>
      </DialogContent>

      <DialogActions>
        <Button onClick={onClose}>취소</Button>
        <Button
          onClick={handleSave}
          variant="contained"
          disabled={saveTabsMutation.isPending}
        >
          {saveTabsMutation.isPending ? '저장 중...' : '저장'}
        </Button>
      </DialogActions>
    </Dialog>
  )
}
