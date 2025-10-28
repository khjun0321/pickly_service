/**
 * Benefit Detail Manager Component
 * Manages benefit_details (policies/programs like 행복주택, 국민임대주택)
 * v9.0 - New 3-layer structure
 */

import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import {
  Box,
  Paper,
  Typography,
  Button,
  IconButton,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Chip,
  CircularProgress,
} from '@mui/material'
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  ArrowUpward,
  ArrowDownward,
  DragIndicator as DragIcon,
} from '@mui/icons-material'
import toast from 'react-hot-toast'
import { supabase } from '@/lib/supabase'
import BenefitDetailModal from './BenefitDetailModal'
import type { BenefitDetail } from '@/types/benefit'

interface BenefitDetailManagerProps {
  categoryId: string
  categoryTitle: string
}

export default function BenefitDetailManager({ categoryId, categoryTitle }: BenefitDetailManagerProps) {
  const queryClient = useQueryClient()
  const [dialogOpen, setDialogOpen] = useState(false)
  const [editingDetail, setEditingDetail] = useState<BenefitDetail | null>(null)

  // Fetch benefit details for this category
  const { data: details = [], isLoading } = useQuery({
    queryKey: ['benefit_details', categoryId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('benefit_details')
        .select('*')
        .eq('benefit_category_id', categoryId)
        .order('sort_order', { ascending: true })

      if (error) throw error
      return data as BenefitDetail[]
    },
  })

  // Delete mutation
  const deleteMutation = useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase
        .from('benefit_details')
        .delete()
        .eq('id', id)

      if (error) throw error
    },
    onSuccess: () => {
      toast.success('정책이 삭제되었습니다')
      queryClient.invalidateQueries({ queryKey: ['benefit_details', categoryId] })
    },
    onError: (error: Error) => {
      toast.error(error.message || '삭제에 실패했습니다')
    },
  })

  // Reorder mutation
  const reorderMutation = useMutation({
    mutationFn: async ({ id, newOrder }: { id: string; newOrder: number }) => {
      const { error } = await supabase
        .from('benefit_details')
        .update({ sort_order: newOrder })
        .eq('id', id)

      if (error) throw error
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['benefit_details', categoryId] })
    },
  })

  const handleOpenDialog = (detail?: BenefitDetail) => {
    setEditingDetail(detail || null)
    setDialogOpen(true)
  }

  const handleCloseDialog = () => {
    setDialogOpen(false)
    setEditingDetail(null)
  }

  const handleDelete = async (detail: BenefitDetail) => {
    if (!window.confirm(`"${detail.title}" 정책을 삭제하시겠습니까?`)) {
      return
    }
    deleteMutation.mutate(detail.id)
  }

  const handleMoveUp = (detail: BenefitDetail, index: number) => {
    if (index === 0) return
    reorderMutation.mutate({ id: detail.id, newOrder: detail.sort_order - 1 })
    reorderMutation.mutate({ id: details[index - 1].id, newOrder: details[index - 1].sort_order + 1 })
  }

  const handleMoveDown = (detail: BenefitDetail, index: number) => {
    if (index === details.length - 1) return
    reorderMutation.mutate({ id: detail.id, newOrder: detail.sort_order + 1 })
    reorderMutation.mutate({ id: details[index + 1].id, newOrder: details[index + 1].sort_order - 1 })
  }

  return (
    <Paper sx={{ p: 3, mb: 3 }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2 }}>
        <Typography variant="h6">정책(상세) 관리 ({categoryTitle})</Typography>
        <Button
          variant="contained"
          size="small"
          startIcon={<AddIcon />}
          onClick={() => handleOpenDialog()}
        >
          정책 추가
        </Button>
      </Box>

      <Typography variant="body2" color="text.secondary" gutterBottom>
        예: 행복주택, 국민임대주택, 영구임대주택
      </Typography>

      {isLoading ? (
        <Box sx={{ display: 'flex', justifyContent: 'center', p: 3 }}>
          <CircularProgress />
        </Box>
      ) : (
        <TableContainer>
          <Table size="small">
            <TableHead>
              <TableRow>
                <TableCell width={50}></TableCell>
                <TableCell width={60}>아이콘</TableCell>
                <TableCell>정책명</TableCell>
                <TableCell>설명</TableCell>
                <TableCell width={80}>순서</TableCell>
                <TableCell width={80}>상태</TableCell>
                <TableCell width={150}>작업</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {details.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={7} align="center">
                    등록된 정책이 없습니다
                  </TableCell>
                </TableRow>
              ) : (
                details.map((detail, index) => (
                  <TableRow key={detail.id} hover>
                    <TableCell>
                      <DragIcon sx={{ color: 'text.disabled', cursor: 'move' }} />
                    </TableCell>
                    <TableCell>
                      {detail.icon_url ? (
                        <Box
                          component="img"
                          src={detail.icon_url}
                          alt={detail.title}
                          sx={{ width: 40, height: 40, objectFit: 'contain' }}
                        />
                      ) : (
                        <Box
                          sx={{
                            width: 40,
                            height: 40,
                            bgcolor: 'grey.200',
                            borderRadius: 1,
                          }}
                        />
                      )}
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2" fontWeight="medium">
                        {detail.title}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2" color="text.secondary">
                        {detail.description || '-'}
                      </Typography>
                    </TableCell>
                    <TableCell>{detail.sort_order}</TableCell>
                    <TableCell>
                      <Chip
                        label={detail.is_active ? '활성' : '비활성'}
                        color={detail.is_active ? 'success' : 'default'}
                        size="small"
                      />
                    </TableCell>
                    <TableCell>
                      <IconButton size="small" onClick={() => handleMoveUp(detail, index)} disabled={index === 0}>
                        <ArrowUpward fontSize="small" />
                      </IconButton>
                      <IconButton size="small" onClick={() => handleMoveDown(detail, index)} disabled={index === details.length - 1}>
                        <ArrowDownward fontSize="small" />
                      </IconButton>
                      <IconButton size="small" onClick={() => handleOpenDialog(detail)}>
                        <EditIcon fontSize="small" />
                      </IconButton>
                      <IconButton size="small" color="error" onClick={() => handleDelete(detail)}>
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

      {/* Add/Edit Dialog */}
      <BenefitDetailModal
        open={dialogOpen}
        onClose={handleCloseDialog}
        categoryId={categoryId}
        editingDetail={editingDetail}
        detailsCount={details.length}
      />
    </Paper>
  )
}
