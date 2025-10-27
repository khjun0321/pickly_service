import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { QueryClientProvider } from '@tanstack/react-query'
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'
import { ThemeProvider, CssBaseline } from '@mui/material'
import { Toaster } from 'react-hot-toast'
import { theme } from '@/styles/theme'
import { queryClient } from '@/lib/queryClient'
import PrivateRoute from '@/components/common/PrivateRoute'
import DashboardLayout from '@/components/layout/DashboardLayout'
import Login from '@/pages/auth/Login'
import Dashboard from '@/pages/dashboard/Dashboard'
import UserList from '@/pages/users/UserList'
import CategoryList from '@/pages/categories/CategoryList'
import CategoryForm from '@/pages/categories/CategoryForm'
import BenefitCategoryList from '@/pages/benefits/BenefitCategoryList'
import BenefitAnnouncementList from '@/pages/benefits/BenefitAnnouncementList'
import BenefitAnnouncementForm from '@/pages/benefits/BenefitAnnouncementForm'
import BenefitCategoryPage from '@/pages/benefits/BenefitCategoryPage'
import AnnouncementEditCompletePage from '@/pages/benefits/AnnouncementEditCompletePage'
import AgeCategoriesPage from '@/pages/age-categories/AgeCategoriesPage'
import AnnouncementTypesPage from '@/pages/announcement-types/AnnouncementTypesPage'

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider theme={theme}>
        <CssBaseline />
        <BrowserRouter>
          <Routes>
            <Route path="/login" element={<Login />} />
            <Route
              path="/"
              element={
                <PrivateRoute>
                  <DashboardLayout />
                </PrivateRoute>
              }
            >
              <Route index element={<Dashboard />} />
              <Route path="users" element={<UserList />} />
              <Route path="categories" element={<CategoryList />} />
              <Route path="categories/new" element={<CategoryForm />} />
              <Route path="categories/:id/edit" element={<CategoryForm />} />
              <Route path="age-categories" element={<AgeCategoriesPage />} />
              <Route path="announcement-types" element={<AnnouncementTypesPage />} />
              <Route path="benefits/:categorySlug" element={<BenefitCategoryPage />} />
              <Route path="benefits/categories" element={<BenefitCategoryList />} />
              <Route path="benefits/announcements" element={<BenefitAnnouncementList />} />
              <Route path="benefits/announcements/new" element={<BenefitAnnouncementForm />} />
              <Route path="benefits/announcements/:id/edit" element={<AnnouncementEditCompletePage />} />
            </Route>
            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </BrowserRouter>
        <Toaster position="top-right" />
      </ThemeProvider>
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  )
}

export default App
