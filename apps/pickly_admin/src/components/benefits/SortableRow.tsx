import { useState } from 'react'
import {
  TableRow,
  TableCell,
  IconButton,
  Chip,
  Box,
  Typography,
} from '@mui/material'
import {
  DragIndicator as DragIndicatorIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
} from '@mui/icons-material'
import { useSortable } from '@dnd-kit/sortable'
import { CSS } from '@dnd-kit/utilities'
import { format } from 'date-fns'
import { ko } from 'date-fns/locale'
import { InlineEditCell } from './InlineEditCell'
import type { Announcement } from '@/types/database'

interface SortableRowProps {
  announcement: Announcement
  index: number
  dynamicColumns: Array<{ key: string; label: string; type?: string }>
  onEdit?: (id: string) => void
  onDelete?: (id: string) => void
}

type AnnouncementStatus = 'recruiting' | 'closed' | 'draft' | 'upcoming'

interface StatusConfig {
  label: string
  color: 'success' | 'error' | 'default' | 'info'
  icon: string
}

const STATUS_CONFIG: Record<AnnouncementStatus, StatusConfig> = {
  recruiting: { label: '모집중', color: 'success', icon: '🟢' },
  closed: { label: '마감', color: 'error', icon: '🔴' },
  draft: { label: '임시저장', color: 'default', icon: '⚫' },
  upcoming: { label: '예정', color: 'info', icon: '🔵' },
}

export function SortableRow({
  announcement,
  index,
  dynamicColumns,
  onEdit,
  onDelete,
}: SortableRowProps) {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id: announcement.id })

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
    opacity: isDragging ? 0.5 : 1,
  }

  const status = announcement.status as AnnouncementStatus
  const statusConfig = STATUS_CONFIG[status] || STATUS_CONFIG.draft

  const formatDateRange = (start?: string | null, end?: string | null) => {
    if (!start && !end) return '-'

    try {
      const startStr = start ? format(new Date(start), 'yyyy-MM-dd', { locale: ko }) : ''
      const endStr = end ? format(new Date(end), 'yyyy-MM-dd', { locale: ko }) : ''

      if (startStr && endStr) {
        return `${startStr} ~ ${endStr}`
      }
      return startStr || endStr || '-'
    } catch (error) {
      return '-'
    }
  }

  const handleDeleteClick = () => {
    if (confirm(`"${announcement.title}" 공고를 삭제하시겠습니까?`)) {
      onDelete?.(announcement.id)
    }
  }

  return (
    <TableRow
      ref={setNodeRef}
      style={style}
      sx={{
        '&:hover': {
          backgroundColor: 'rgba(0, 0, 0, 0.02)',
        },
      }}
    >
      <TableCell>
        <Box
          sx={{
            display: 'flex',
            alignItems: 'center',
            cursor: 'grab',
            '&:active': { cursor: 'grabbing' },
          }}
          {...attributes}
          {...listeners}
        >
          <DragIndicatorIcon fontSize="small" sx={{ color: 'text.secondary', mr: 0.5 }} />
          <Typography variant="body2" color="text.secondary">
            {index + 1}
          </Typography>
        </Box>
      </TableCell>

      <InlineEditCell
        announcementId={announcement.id}
        field="title"
        value={announcement.title}
        multiline
      />

      <InlineEditCell
        announcementId={announcement.id}
        field="organization"
        value={announcement.organization || '-'}
      />

      <TableCell>
        <Chip
          label={`${statusConfig.icon} ${statusConfig.label}`}
          color={statusConfig.color}
          size="small"
          sx={{ fontWeight: 500 }}
        />
      </TableCell>

      <TableCell>
        <Typography variant="body2" noWrap>
          {formatDateRange(
            announcement.application_period_start,
            announcement.application_period_end
          )}
        </Typography>
      </TableCell>

      {dynamicColumns.map((col) => {
        // Render dynamic columns based on category custom_fields
        // For now, showing placeholder - will be populated based on category schema
        const value = (announcement as any)[col.key] || '-'
        return (
          <TableCell key={col.key}>
            <Typography variant="body2" noWrap>
              {value}
            </Typography>
          </TableCell>
        )
      })}

      <TableCell align="right">
        <Box sx={{ display: 'flex', justifyContent: 'flex-end', gap: 0.5 }}>
          <IconButton
            size="small"
            onClick={() => onEdit?.(announcement.id)}
            title="수정"
          >
            <EditIcon fontSize="small" />
          </IconButton>
          <IconButton
            size="small"
            color="error"
            onClick={handleDeleteClick}
            title="삭제"
          >
            <DeleteIcon fontSize="small" />
          </IconButton>
        </Box>
      </TableCell>
    </TableRow>
  )
}
