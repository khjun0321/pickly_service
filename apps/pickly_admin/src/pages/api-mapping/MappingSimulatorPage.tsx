import React, { useState } from 'react'
import { Box, Button, Grid, TextField, Typography, Paper } from '@mui/material'

export default function MappingSimulatorPage() {
  const [inputJson, setInputJson] = useState('{}')
  const [outputJson, setOutputJson] = useState('{}')

  const handleTest = () => {
    try {
      const parsed = JSON.parse(inputJson)
      // 간단한 매핑 예시 (Phase 6.3 에서 실제 규칙 반영)
      const transformed = { title: parsed['공고명'] ?? '(제목 없음)' }
      setOutputJson(JSON.stringify(transformed, null, 2))
    } catch {
      setOutputJson('❌ 유효하지 않은 JSON 형식입니다.')
    }
  }

  return (
    <Box>
      <Typography variant="h5" mb={2}>매핑 시뮬레이터</Typography>
      <Grid container spacing={2}>
        <Grid item xs={6}>
          <Paper sx={{ p: 2 }}>
            <Typography>원본 JSON</Typography>
            <TextField
              fullWidth
              multiline
              minRows={15}
              value={inputJson}
              onChange={(e) => setInputJson(e.target.value)}
            />
          </Paper>
        </Grid>
        <Grid item xs={6}>
          <Paper sx={{ p: 2 }}>
            <Typography>변환 결과</Typography>
            <TextField fullWidth multiline minRows={15} value={outputJson} InputProps={{ readOnly: true }} />
          </Paper>
        </Grid>
      </Grid>
      <Button variant="contained" sx={{ mt: 2 }} onClick={handleTest}>테스트 실행</Button>
    </Box>
  )
}
