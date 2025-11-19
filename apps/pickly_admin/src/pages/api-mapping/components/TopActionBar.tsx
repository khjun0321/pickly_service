import React from 'react'
import { Button, Stack, Typography } from '@mui/material'

interface TopActionBarProps {
  title: string
  onAdd?: () => void
}

export const TopActionBar: React.FC<TopActionBarProps> = ({ title, onAdd }) => (
  <Stack direction="row" alignItems="center" justifyContent="space-between" mb={2}>
    <Typography variant="h5">{title}</Typography>
    {onAdd && <Button variant="contained" onClick={onAdd}>+ 추가</Button>}
  </Stack>
)
