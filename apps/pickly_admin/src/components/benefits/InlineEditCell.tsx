import { useState, useRef, useEffect } from 'react'
import {
  TableCell,
  TextField,
  Typography,
  Box,
  CircularProgress,
} from '@mui/material'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import toast from 'react-hot-toast'
import { supabase } from '@/lib/supabase'

interface InlineEditCellProps {
  announcementId: string
  field: string
  value: string
  multiline?: boolean
  maxLength?: number
}

export function InlineEditCell({
  announcementId,
  field,
  value,
  multiline = false,
  maxLength = 200,
}: InlineEditCellProps) {
  const [isEditing, setIsEditing] = useState(false)
  const [editValue, setEditValue] = useState(value)
  const inputRef = useRef<HTMLInputElement>(null)
  const queryClient = useQueryClient()

  const updateMutation = useMutation({
    mutationFn: async (newValue: string) => {
      const updateData: Record<string, string> = { [field]: newValue }

      const { data, error } = await supabase
        .from('benefit_announcements')
        .update(updateData)
        .eq('id', announcementId)
        .select()
        .single()

      if (error) throw error
      return data
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['benefit-announcements'] })
      setIsEditing(false)
      toast.success('수정되었습니다')
    },
    onError: (error: Error) => {
      toast.error(`수정 실패: ${error.message}`)
      setEditValue(value) // Revert to original value
    },
  })

  useEffect(() => {
    if (isEditing && inputRef.current) {
      inputRef.current.focus()
      inputRef.current.select()
    }
  }, [isEditing])

  useEffect(() => {
    setEditValue(value)
  }, [value])

  const handleDoubleClick = () => {
    setIsEditing(true)
  }

  const handleBlur = () => {
    if (editValue !== value && editValue.trim() !== '') {
      updateMutation.mutate(editValue.trim())
    } else {
      setIsEditing(false)
      setEditValue(value)
    }
  }

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !multiline) {
      e.preventDefault()
      handleBlur()
    } else if (e.key === 'Escape') {
      setIsEditing(false)
      setEditValue(value)
    }
  }

  if (isEditing) {
    return (
      <TableCell>
        <Box sx={{ position: 'relative', minWidth: 120 }}>
          <TextField
            inputRef={inputRef}
            value={editValue}
            onChange={(e) => setEditValue(e.target.value.slice(0, maxLength))}
            onBlur={handleBlur}
            onKeyDown={handleKeyDown}
            multiline={multiline}
            maxRows={multiline ? 3 : 1}
            size="small"
            fullWidth
            disabled={updateMutation.isPending}
            InputProps={{
              sx: {
                fontSize: '0.875rem',
              },
              endAdornment: updateMutation.isPending && (
                <CircularProgress size={16} sx={{ ml: 1 }} />
              ),
            }}
            helperText={multiline ? `${editValue.length}/${maxLength}` : undefined}
          />
        </Box>
      </TableCell>
    )
  }

  return (
    <TableCell
      onDoubleClick={handleDoubleClick}
      sx={{
        cursor: 'pointer',
        '&:hover': {
          backgroundColor: 'rgba(0, 0, 0, 0.02)',
        },
      }}
      title="더블클릭하여 수정"
    >
      <Typography
        variant="body2"
        sx={{
          display: multiline ? '-webkit-box' : 'block',
          WebkitLineClamp: multiline ? 2 : undefined,
          WebkitBoxOrient: multiline ? 'vertical' : undefined,
          overflow: 'hidden',
          textOverflow: 'ellipsis',
          maxWidth: '300px',
        }}
      >
        {value || '-'}
      </Typography>
    </TableCell>
  )
}
