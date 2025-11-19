/**
 * Announcement Management Page (C 버전용 셸 페이지)
 * Route: /benefits/announcements
 *
 * 역할:
 * - 혜택 카테고리 목록을 왼쪽에 보여줌
 * - 선택된 카테고리에 대해 AnnouncementManager를 렌더링
 * - 실제 공고 CRUD / PDF 업로드 / 상세 내용 관리는 AnnouncementManager.tsx에서 처리
 */

import { useEffect, useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import {
  Box,
  Typography,
  Paper,
  List,
  ListItemButton,
  ListItemText,
  CircularProgress,
  Divider,
} from '@mui/material'
import { supabase } from '@/lib/supabase'
import AnnouncementManager from './components/AnnouncementManager'
import type { BenefitCategory } from '@/types/benefits'

export default function AnnouncementManagementPage() {
  const [selectedCategoryId, setSelectedCategoryId] = useState<string | null>(null)
  const [selectedCategoryTitle, setSelectedCategoryTitle] = useState<string>('')

  // 혜택 카테고리 목록 가져오기
  const {
    data: categories = [],
    isLoading,
    error,
  } = useQuery({
    queryKey: ['benefit_categories'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('benefit_categories')
        .select('*')
        .order('sort_order', { ascending: true })

      if (error) throw error
      return data as BenefitCategory[]
    },
  })

  // 최초 로딩 시, 카테고리가 있으면 첫 번째 카테고리를 자동 선택
  useEffect(() => {
    if (!isLoading && categories.length > 0 && !selectedCategoryId) {
      const first = categories[0]
      setSelectedCategoryId(first.id)
      setSelectedCategoryTitle(first.title)
    }
  }, [isLoading, categories, selectedCategoryId])

  const handleSelectCategory = (cat: BenefitCategory) => {
    setSelectedCategoryId(cat.id)
    setSelectedCategoryTitle(cat.title)
  }

  return (
    <Box sx={{ p: 3 }}>
      {/* 페이지 헤더 */}
      <Box
        sx={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          mb: 3,
        }}
      >
        <Box>
          <Typography variant="h4">공고 관리</Typography>
          <Typography variant="body2" color="text.secondary" sx={{ mt: 0.5 }}>
            혜택 카테고리별로 공고를 등록·수정·삭제하고, 상세 정보 / PDF를 관리합니다.
          </Typography>
        </Box>
      </Box>

      {/* 좌측 카테고리 리스트 + 우측 AnnouncementManager */}
      <Paper sx={{ display: 'flex', minHeight: 480 }}>
        {/* 왼쪽: 카테고리 목록 */}
        <Box sx={{ width: 260, borderRight: 1, borderColor: 'divider' }}>
          <Box sx={{ p: 2, pb: 1 }}>
            <Typography variant="subtitle2" color="text.secondary">
              혜택 카테고리
            </Typography>
          </Box>
          <Divider />

          {isLoading ? (
            <Box sx={{ p: 3, display: 'flex', justifyContent: 'center' }}>
              <CircularProgress size={24} />
            </Box>
          ) : error ? (
            <Box sx={{ p: 3 }}>
              <Typography variant="body2" color="error">
                카테고리 목록을 불러오는 중 오류가 발생했습니다.
              </Typography>
            </Box>
          ) : categories.length === 0 ? (
            <Box sx={{ p: 3 }}>
              <Typography variant="body2" color="text.secondary">
                먼저 &quot;혜택 카테고리 관리&quot;에서 카테고리를 생성해야
                공고를 추가할 수 있습니다.
              </Typography>
            </Box>
          ) : (
            <List dense disablePadding>
              {categories.map((cat) => (
                <ListItemButton
                  key={cat.id}
                  selected={cat.id === selectedCategoryId}
                  onClick={() => handleSelectCategory(cat)}
                >
                  <ListItemText
                    primary={cat.title}
                    secondary={cat.slug}
                    primaryTypographyProps={{ noWrap: true }}
                    secondaryTypographyProps={{ noWrap: true }}
                  />
                </ListItemButton>
              ))}
            </List>
          )}
        </Box>

        {/* 오른쪽: 선택된 카테고리의 공고 관리 */}
        <Box sx={{ flex: 1, p: 2 }}>
          {selectedCategoryId && (
            <AnnouncementManager
              categoryId={selectedCategoryId}
              categoryTitle={selectedCategoryTitle}
            />
          )}

          {!selectedCategoryId && !isLoading && categories.length === 0 && (
            <Typography variant="body2" color="text.secondary">
              왼쪽 메뉴에서 카테고리를 먼저 생성하고 선택해 주세요.
            </Typography>
          )}

          {!selectedCategoryId && !isLoading && categories.length > 0 && (
            <Typography variant="body2" color="text.secondary">
              왼쪽에서 공고를 관리할 카테고리를 선택해 주세요.
            </Typography>
          )}
        </Box>
      </Paper>
    </Box>
  )
}