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
  Home as HomeIcon,
  CardGiftcard as CardGiftcardIcon,
  Api as ApiIcon,
  People as PeopleIcon,
  Category as CategoryIcon,
  ViewModule as ViewModuleIcon,
  Image as ImageIcon,
  Announcement as AnnouncementIcon,
  ExpandLess,
  ExpandMore,
} from '@mui/icons-material'

interface SidebarProps {
  mobileOpen: boolean
  onDrawerToggle: () => void
  drawerWidth: number
}

// PRD v9.6 Section 4 - Admin Structure (matching Flutter app)
const menuItems = [
  { text: '대시보드', icon: <DashboardIcon />, path: '/' },
  { text: '홈 관리', icon: <HomeIcon />, path: '/home-management' },
]

// Benefits Management submenu (PRD v9.6 Section 4.2)
const benefitMenuItems = [
  { text: '대분류 관리', icon: <CategoryIcon />, path: '/benefits/categories' },
  { text: '하위분류 관리', icon: <ViewModuleIcon />, path: '/benefits/subcategories' },
  { text: '배너 관리', icon: <ImageIcon />, path: '/benefits/banners' },
  { text: '공고 관리', icon: <AnnouncementIcon />, path: '/benefits/announcements' },
]

// Bottom menu items
const bottomMenuItems = [
  { text: 'API 관리', icon: <ApiIcon />, path: '/api-management' },
  { text: '사용자·권한', icon: <PeopleIcon />, path: '/users' },
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
          {/* Main menu items */}
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

          {/* Benefits Management (collapsible) */}
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

          {/* Bottom menu items */}
          {bottomMenuItems.map((item) => (
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
