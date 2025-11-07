import React from 'react'
import { Chip } from '@mui/material'

export const StatusBadge = ({ status }: { status: 'active' | 'inactive' }) => (
  <Chip
    label={status === 'active' ? '활성' : '비활성'}
    color={status === 'active' ? 'success' : 'default'}
    size="small"
  />
)
