/**
 * Announcement List Component (v9.0)
 * Displays and manages announcements for a specific benefit detail (policy)
 * Filtered by benefit_detail_id
 */

import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import {
  Box,
  Button,
  IconButton,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Chip,
  Typography,
  CircularProgress,
} from '@mui/material'
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  Visibility as VisibilityIcon,
} from '@mui/icons-material'
import toast from 'react-hot-toast'
import { supabase } from '@/lib/supabase'
import AnnouncementModal from './AnnouncementModal'
import type { BenefitAnnouncement } from '@/types/benefit'

interface AnnouncementListProps {
  detailId: string
  categoryId: string
  detailTitle: string
}

export default function AnnouncementList({ detailId, categoryId, detailTitle }: AnnouncementListProps) {
  const queryClient = useQueryClient()
  const [modalOpen, setModalOpen] = useState(false)
  const [editingAnnouncement, setEditingAnnouncement] = useState<BenefitAnnouncement | null>(null)

  // Fetch announcements for this specific benefit detail
  const { data: announcements = [], isLoading } = useQuery({
    queryKey: ['benefit_announcements', detailId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('benefit_announcements')
        .select('*')
        .eq('benefit_detail_id', detailId)
        .order('display_order', { ascending: true })
        .order('created_at', { ascending: false })

      if (error) throw error
      return data as BenefitAnnouncement[]
    },
  })

  // Delete mutation
  const deleteMutation = useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase
        .from('benefit_announcements')
        .delete()
        .eq('id', id)

      if (error) throw error
    },
    onSuccess: () => {
      toast.success('공고가 삭제되었습니다')
      queryClient.invalidateQueries({ queryKey: ['benefit_announcements', detailId] })
    },
    onError: (error: Error) => {
      toast.error(error.message || '삭제에 실패했습니다')
    },
  })

  const handleOpenModal = (announcement?: BenefitAnnouncement) => {
    setEditingAnnouncement(announcement || null)
    setModalOpen(true)
  }

  const handleCloseModal = () => {
    setModalOpen(false)
    setEditingAnnouncement(null)
  }

  const handleDelete = async (announcement: BenefitAnnouncement) => {
    if (!window.confirm(`"${announcement.title}" 공고를 삭제하시겠습니까?`)) {
      return
    }
    deleteMutation.mutate(announcement.id)
  }

  const getStatusChip = (status: string) => {
    const statusMap: Record<string, { label: string; color: 'success' | 'error' | 'warning' | 'default' }> = {
      published: { label: '게시됨', color: 'success' },
      draft: { label: '임시저장', color: 'default' },
      archived: { label: '보관됨', color: 'warning' },
    }

    const statusInfo = statusMap[status] || { label: status, color: 'default' as const }
    return <Chip label={statusInfo.label} color={statusInfo.color} size="small" />
  }

  return (
    <Box>
      {/* Header */}
      <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2 }}>
        <Typography variant="body2" color="text.secondary">
          {detailTitle} - 총 {announcements.length}개 공고
        </Typography>
        <Button
          variant="contained"
          size="small"
          startIcon={<AddIcon />}
          onClick={() => handleOpenModal()}
        >
          공고 추가
        </Button>
      </Box>

      {/* Loading State */}
      {isLoading ? (
        <Box sx={{ display: 'flex', justifyContent: 'center', p: 3 }}>
          <CircularProgress />
        </Box>
      ) : (
        /* Announcements Table */
        <TableContainer>
          <Table size="small">
            <TableHead>
              <TableRow>
                <TableCell width={60}>썸네일</TableCell>
                <TableCell>공고 제목</TableCell>
                <TableCell width={120}>모집기관</TableCell>
                <TableCell width={100}>지역</TableCell>
                <TableCell width={120}>모집기간</TableCell>
                <TableCell width={80}>조회수</TableCell>
                <TableCell width={80}>상태</TableCell>
                <TableCell width={120}>작업</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {announcements.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={8} align="center" sx={{ py: 4 }}>
                    <Typography color="text.secondary">
                      등록된 공고가 없습니다
                    </Typography>
                  </TableCell>
                </TableRow>
              ) : (
                announcements.map((announcement) => (
                  <TableRow key={announcement.id} hover>
                    <TableCell>
                      {announcement.thumbnail_url ? (
                        <Box
                          component="img"
                          src={announcement.thumbnail_url}
                          alt={announcement.title}
                          sx={{
                            width: 50,
                            height: 50,
                            objectFit: 'cover',
                            borderRadius: 1,
                          }}
                        />
                      ) : (
                        <Box
                          sx={{
                            width: 50,
                            height: 50,
                            bgcolor: 'grey.200',
                            borderRadius: 1,
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                          }}
                        >
                          <VisibilityIcon fontSize="small" color="disabled" />
                        </Box>
                      )}
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2" fontWeight="medium">
                        {announcement.title}
                      </Typography>
                      {announcement.subtitle && (
                        <Typography variant="caption" color="text.secondary" display="block">
                          {announcement.subtitle}
                        </Typography>
                      )}
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2">{announcement.organization}</Typography>
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2" color="text.secondary">
                        {announcement.custom_data?.region || '-'}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2" fontSize="0.75rem">
                        {announcement.application_period_start && announcement.application_period_end
                          ? `${announcement.application_period_start} ~ ${announcement.application_period_end}`
                          : '-'}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2">{announcement.views_count}</Typography>
                    </TableCell>
                    <TableCell>{getStatusChip(announcement.status)}</TableCell>
                    <TableCell>
                      <IconButton size="small" onClick={() => handleOpenModal(announcement)}>
                        <EditIcon fontSize="small" />
                      </IconButton>
                      <IconButton
                        size="small"
                        color="error"
                        onClick={() => handleDelete(announcement)}
                      >
                        <DeleteIcon fontSize="small" />
                      </IconButton>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </TableContainer>
      )}

      {/* Add/Edit Modal */}
      <AnnouncementModal
        open={modalOpen}
        onClose={handleCloseModal}
        detailId={detailId}
        categoryId={categoryId}
        editingAnnouncement={editingAnnouncement}
      />
    </Box>
  )
}
