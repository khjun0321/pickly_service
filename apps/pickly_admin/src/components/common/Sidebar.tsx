import { useState } from 'react'
import { useNavigate, useLocation } from 'react-router-dom'
import {
  Drawer,
  Box,
  Toolbar,
  List,
  ListItem,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Collapse,
} from '@mui/material'
import {
  Dashboard as DashboardIcon,
  People as PeopleIcon,
  Category as CategoryIcon,
  CardGiftcard as CardGiftcardIcon,
  ExpandLess,
  ExpandMore,
  FolderSpecial as FolderIcon,
  Tab as TabIcon,
} from '@mui/icons-material'

interface SidebarProps {
  mobileOpen: boolean
  onDrawerToggle: () => void
  drawerWidth: number
}

const menuItems = [
  { text: '대시보드', icon: <DashboardIcon />, path: '/' },
  { text: '사용자', icon: <PeopleIcon />, path: '/users' },
  { text: '연령대 관리', icon: <FolderIcon />, path: '/age-categories' },
  { text: '공고 유형 관리', icon: <TabIcon />, path: '/announcement-types' },
]

const benefitMenuItems = [
  { text: '인기', icon: <CategoryIcon />, path: '/benefits/manage/popular' },
  { text: '주거', icon: <CategoryIcon />, path: '/benefits/manage/housing' },
  { text: '교육', icon: <CategoryIcon />, path: '/benefits/manage/education' },
  { text: '건강', icon: <CategoryIcon />, path: '/benefits/manage/health' },
  { text: '교통', icon: <CategoryIcon />, path: '/benefits/manage/transportation' },
  { text: '복지', icon: <CategoryIcon />, path: '/benefits/manage/welfare' },
  { text: '취업', icon: <CategoryIcon />, path: '/benefits/manage/employment' },
  { text: '지원', icon: <CategoryIcon />, path: '/benefits/manage/support' },
  { text: '문화', icon: <CategoryIcon />, path: '/benefits/manage/culture' },
]

export default function Sidebar({ mobileOpen, onDrawerToggle, drawerWidth }: SidebarProps) {
  const navigate = useNavigate()
  const location = useLocation()
  const [benefitMenuOpen, setBenefitMenuOpen] = useState(
    location.pathname.startsWith('/benefits')
  )

  const handleBenefitMenuToggle = () => {
    setBenefitMenuOpen(!benefitMenuOpen)
  }

  const drawer = (
    <div>
      <Toolbar />
      <Box sx={{ overflow: 'auto' }}>
        <List>
          {menuItems.map((item) => (
            <ListItem key={item.text} disablePadding>
              <ListItemButton
                selected={location.pathname === item.path}
                onClick={() => {
                  navigate(item.path)
                  onDrawerToggle()
                }}
              >
                <ListItemIcon>{item.icon}</ListItemIcon>
                <ListItemText primary={item.text} />
              </ListItemButton>
            </ListItem>
          ))}
          <ListItem disablePadding>
            <ListItemButton onClick={handleBenefitMenuToggle}>
              <ListItemIcon>
                <CardGiftcardIcon />
              </ListItemIcon>
              <ListItemText primary="혜택 관리" />
              {benefitMenuOpen ? <ExpandLess /> : <ExpandMore />}
            </ListItemButton>
          </ListItem>
          <Collapse in={benefitMenuOpen} timeout="auto" unmountOnExit>
            <List component="div" disablePadding>
              {benefitMenuItems.map((item) => (
                <ListItem key={item.text} disablePadding>
                  <ListItemButton
                    sx={{ pl: 4 }}
                    selected={location.pathname === item.path}
                    onClick={() => {
                      navigate(item.path)
                      onDrawerToggle()
                    }}
                  >
                    <ListItemIcon>{item.icon}</ListItemIcon>
                    <ListItemText primary={item.text} />
                  </ListItemButton>
                </ListItem>
              ))}
            </List>
          </Collapse>
        </List>
      </Box>
    </div>
  )

  return (
    <Box
      component="nav"
      sx={{ width: { sm: drawerWidth }, flexShrink: { sm: 0 } }}
    >
      {/* Mobile drawer */}
      <Drawer
        variant="temporary"
        open={mobileOpen}
        onClose={onDrawerToggle}
        ModalProps={{
          keepMounted: true, // Better open performance on mobile.
        }}
        sx={{
          display: { xs: 'block', sm: 'none' },
          '& .MuiDrawer-paper': { boxSizing: 'border-box', width: drawerWidth },
        }}
      >
        {drawer}
      </Drawer>
      {/* Desktop drawer */}
      <Drawer
        variant="permanent"
        sx={{
          display: { xs: 'none', sm: 'block' },
          '& .MuiDrawer-paper': { boxSizing: 'border-box', width: drawerWidth },
        }}
        open
      >
        {drawer}
      </Drawer>
    </Box>
  )
}
