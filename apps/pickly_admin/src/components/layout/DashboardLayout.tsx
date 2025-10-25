import { useState } from 'react'
import { Outlet } from 'react-router-dom'
import { Box, Toolbar, Alert } from '@mui/material'
import Header from '@/components/common/Header'
import Sidebar from '@/components/common/Sidebar'
import { useAuth } from '@/hooks/useAuth'

const DRAWER_WIDTH = 240

export default function DashboardLayout() {
  const [mobileOpen, setMobileOpen] = useState(false)
  const { isDevMode } = useAuth()

  const handleDrawerToggle = () => {
    setMobileOpen(!mobileOpen)
  }

  return (
    <Box sx={{ display: 'flex', height: '100vh' }}>
      <Header onMenuClick={handleDrawerToggle} />
      <Sidebar
        mobileOpen={mobileOpen}
        onDrawerToggle={handleDrawerToggle}
        drawerWidth={DRAWER_WIDTH}
      />
      <Box
        component="main"
        sx={{
          flexGrow: 1,
          p: 3,
          width: { sm: `calc(100% - ${DRAWER_WIDTH}px)` },
          height: '100vh',
          overflow: 'auto', // 스크롤 활성화
        }}
      >
        <Toolbar />
        {isDevMode && (
          <Alert severity="warning" sx={{ mb: 3 }}>
            🚨 개발 모드: 인증이 비활성화되었습니다 (dev@pickly.com으로 로그인됨)
          </Alert>
        )}
        <Outlet />
      </Box>
    </Box>
  )
}
