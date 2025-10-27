import { useState, useCallback, useEffect } from 'react'
import {
  Box,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Typography,
  CircularProgress,
} from '@mui/material'
import {
  DndContext,
  closestCenter,
  KeyboardSensor,
  PointerSensor,
  useSensor,
  useSensors,
} from '@dnd-kit/core'
import type { DragEndEvent } from '@dnd-kit/core'
import {
  arrayMove,
  SortableContext,
  sortableKeyboardCoordinates,
  verticalListSortingStrategy,
} from '@dnd-kit/sortable'
import { restrictToVerticalAxis } from '@dnd-kit/modifiers'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import toast from 'react-hot-toast'
import { SortableRow } from './SortableRow'
import { useDynamicColumns } from './DynamicColumns'
import { supabase } from '@/lib/supabase'
import type { BenefitAnnouncement } from '@/types/database'

interface AnnouncementTableProps {
  categoryId?: string
  onEdit?: (id: string) => void
  onDelete?: (id: string) => void
}

interface UpdateOrdersPayload {
  announcement_id: string
  display_order: number
}

export function AnnouncementTable({
  categoryId,
  onEdit,
  onDelete,
}: AnnouncementTableProps) {
  const queryClient = useQueryClient()

  const { data: announcements = [], isLoading } = useQuery({
    queryKey: ['benefit-announcements', categoryId],
    queryFn: async () => {
      let query = supabase
        .from('benefit_announcements')
        .select('*')
        .order('display_order', { ascending: true, nullsFirst: false })

      if (categoryId) {
        query = query.eq('category_id', categoryId)
      }

      const { data, error } = await query
      if (error) throw error
      return data as BenefitAnnouncement[]
    },
  })

  const [items, setItems] = useState<BenefitAnnouncement[]>([])

  useEffect(() => {
    if (JSON.stringify(items) !== JSON.stringify(announcements)) {
      setItems(announcements)
    }
  }, [announcements]) // eslint-disable-line react-hooks/exhaustive-deps

  const sensors = useSensors(
    useSensor(PointerSensor, {
      activationConstraint: {
        distance: 8,
      },
    }),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    })
  )

  const { mutate: updateDisplayOrders } = useMutation({
    mutationFn: async (orders: UpdateOrdersPayload[]) => {
      const { data, error } = await supabase.rpc('update_display_orders', {
        orders,
      } as any)

      if (error) throw error
      return data
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['benefit-announcements'] })
      toast.success('공고 순서가 업데이트되었습니다')
    },
    onError: (error: Error) => {
      toast.error(`순서 업데이트 실패: ${error.message}`)
      // Revert to original order on error
      setItems(announcements)
    },
  })

  const handleDragEnd = useCallback(
    (event: DragEndEvent) => {
      const { active, over } = event

      if (!over || active.id === over.id) {
        return
      }

      const oldIndex = items.findIndex((item) => item.id === active.id)
      const newIndex = items.findIndex((item) => item.id === over.id)

      const newItems = arrayMove(items, oldIndex, newIndex)
      setItems(newItems)

      // Prepare updated display orders
      const orders: UpdateOrdersPayload[] = newItems.map((item, index) => ({
        announcement_id: item.id,
        display_order: index,
      }))

      // Call RPC to update display orders
      updateDisplayOrders(orders)
    },
    [items, updateDisplayOrders]
  )

  // Get dynamic columns based on category
  const dynamicColumns = useDynamicColumns({ categoryId })

  if (isLoading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', p: 4 }}>
        <CircularProgress />
      </Box>
    )
  }

  return (
    <DndContext
      sensors={sensors}
      collisionDetection={closestCenter}
      onDragEnd={handleDragEnd}
      modifiers={[restrictToVerticalAxis]}
    >
      <TableContainer component={Paper}>
        <Table sx={{ minWidth: 650 }} size="small">
          <TableHead>
            <TableRow sx={{ backgroundColor: 'rgba(0, 0, 0, 0.04)' }}>
              <TableCell sx={{ width: 40 }}>
                <Typography variant="caption" fontWeight="bold">
                  순서
                </Typography>
              </TableCell>
              <TableCell>
                <Typography variant="caption" fontWeight="bold">
                  제목
                </Typography>
              </TableCell>
              <TableCell>
                <Typography variant="caption" fontWeight="bold">
                  기관
                </Typography>
              </TableCell>
              <TableCell>
                <Typography variant="caption" fontWeight="bold">
                  상태
                </Typography>
              </TableCell>
              <TableCell>
                <Typography variant="caption" fontWeight="bold">
                  신청기간
                </Typography>
              </TableCell>
              {dynamicColumns.map((col) => (
                <TableCell key={col.key}>
                  <Typography variant="caption" fontWeight="bold">
                    {col.label}
                  </Typography>
                </TableCell>
              ))}
              <TableCell align="right">
                <Typography variant="caption" fontWeight="bold">
                  작업
                </Typography>
              </TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            <SortableContext
              items={items.map((item) => item.id)}
              strategy={verticalListSortingStrategy}
            >
              {items.map((announcement, index) => (
                <SortableRow
                  key={announcement.id}
                  announcement={announcement}
                  index={index}
                  dynamicColumns={dynamicColumns}
                  onEdit={onEdit}
                  onDelete={onDelete}
                />
              ))}
            </SortableContext>
          </TableBody>
        </Table>
      </TableContainer>
      {items.length === 0 && (
        <Box
          sx={{
            p: 4,
            textAlign: 'center',
            color: 'text.secondary',
          }}
        >
          <Typography variant="body2">공고가 없습니다</Typography>
        </Box>
      )}
    </DndContext>
  )
}
