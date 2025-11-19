import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { supabase } from '@/lib/supabase'
import { Box, TextField, Button, Typography, Paper, Alert, Container } from '@mui/material'
import { LockOutlined as LockIcon } from '@mui/icons-material'

export default function LoginPage() {
  const navigate = useNavigate()
  const [email, setEmail] = useState('admin@pickly.com')
  const [password, setPassword] = useState('pickly2025!')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError(null)

    try {
      const { data, error: signInError } = await supabase.auth.signInWithPassword({
        email,
        password,
      })

      if (signInError) throw signInError

      if (data.session) {
        console.log('✅ 로그인 성공:', data.session.user.email)
        console.log('✅ Role:', data.session.user.role)
        navigate('/')
      }
    } catch (err: unknown) {
      console.error('❌ 로그인 실패:', err)
      setError(err instanceof Error ? err.message : '로그인에 실패했습니다')
    } finally {
      setLoading(false)
    }
  }

  return (
    <Container component="main" maxWidth="xs">
      <Box
        sx={{
          marginTop: 8,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
        }}
      >
        <Paper elevation={3} sx={{ padding: 4, width: '100%' }}>
          <Box
            sx={{
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              gap: 2,
            }}
          >
            <Box
              sx={{
                bgcolor: 'primary.main',
                borderRadius: '50%',
                p: 1,
              }}
            >
              <LockIcon sx={{ color: 'white', fontSize: 32 }} />
            </Box>

            <Typography component="h1" variant="h5">
              Pickly Admin 로그인
            </Typography>

            {error && (
              <Alert severity="error" sx={{ width: '100%' }}>
                {error}
              </Alert>
            )}

            <Box component="form" onSubmit={handleLogin} sx={{ mt: 1, width: '100%' }}>
              <TextField
                margin="normal"
                required
                fullWidth
                id="email"
                label="Email Address"
                name="email"
                autoComplete="email"
                autoFocus
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />
              <TextField
                margin="normal"
                required
                fullWidth
                name="password"
                label="Password"
                type="password"
                id="password"
                autoComplete="current-password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
              <Button
                type="submit"
                fullWidth
                variant="contained"
                sx={{ mt: 3, mb: 2 }}
                disabled={loading}
              >
                {loading ? '로그인 중...' : '로그인'}
              </Button>

              <Box sx={{ mt: 2, p: 2, bgcolor: 'grey.100', borderRadius: 1 }}>
                <Typography variant="caption" display="block" gutterBottom>
                  <strong>Admin 계정:</strong>
                </Typography>
                <Typography variant="caption" display="block">
                  Email: admin@pickly.com
                </Typography>
                <Typography variant="caption" display="block">
                  Password: pickly2025!
                </Typography>
              </Box>
            </Box>
          </Box>
        </Paper>
      </Box>
    </Container>
  )
}
