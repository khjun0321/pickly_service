import React, { useState } from 'react'
import { Dialog, DialogTitle, DialogContent, DialogActions, Button, TextField } from '@mui/material'

interface JsonEditorProps {
  open: boolean
  initialValue: object
  onClose: () => void
  onSave: (data: object) => void
}

export const JsonEditor: React.FC<JsonEditorProps> = ({ open, initialValue, onClose, onSave }) => {
  const [text, setText] = useState(JSON.stringify(initialValue, null, 2))
  const [error, setError] = useState<string | null>(null)

  const handleSave = () => {
    try {
      const parsed = JSON.parse(text)
      onSave(parsed)
      setError(null)
      onClose()
    } catch {
      setError('유효하지 않은 JSON 형식입니다.')
    }
  }

  return (
    <Dialog open={open} onClose={onClose} maxWidth="md" fullWidth>
      <DialogTitle>매핑 규칙 편집기</DialogTitle>
      <DialogContent>
        <TextField
          fullWidth
          multiline
          minRows={15}
          value={text}
          onChange={(e) => setText(e.target.value)}
          error={!!error}
          helperText={error ?? 'JSON 형식으로 작성하세요'}
        />
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose}>취소</Button>
        <Button variant="contained" onClick={handleSave}>저장</Button>
      </DialogActions>
    </Dialog>
  )
}
