/**
 * BannerManager Integration Example
 *
 * This file demonstrates how to integrate the BannerManager component
 * into your category management pages.
 */

import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import {
  Box,
  Paper,
  Typography,
  Grid,
  TextField,
  Button,
  Divider,
} from '@mui/material'
import toast from 'react-hot-toast'
import BannerManager from '@/components/benefits/BannerManager'
import { supabase } from '@/lib/supabase'
import type { BenefitCategory, BenefitCategoryUpdate } from '@/types/database'

// Example API function to fetch category
async function fetchCategoryById(id: string): Promise<BenefitCategory> {
  const { data, error } = await supabase
    .from('benefit_categories')
    .select('*')
    .eq('id', id)
    .single()

  if (error) throw error
  return data
}

// Example API function to update category
async function updateCategory(
  id: string,
  updates: BenefitCategoryUpdate
): Promise<BenefitCategory> {
  const { data, error } = await supabase
    .from('benefit_categories')
    .update(updates)
    .eq('id', id)
    .select()
    .single()

  if (error) throw error
  return data
}

/**
 * Example 1: Category Edit Page with Banner Management
 */
export function CategoryEditPage({ categoryId }: { categoryId: string }) {
  const queryClient = useQueryClient()

  // Fetch category data
  const { data: category, isLoading } = useQuery({
    queryKey: ['category', categoryId],
    queryFn: () => fetchCategoryById(categoryId),
  })

  // Update category mutation
  const updateMutation = useMutation({
    mutationFn: (updates: BenefitCategoryUpdate) =>
      updateCategory(categoryId, updates),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['category', categoryId] })
      toast.success('Category updated successfully')
    },
    onError: (error: Error) => {
      toast.error(`Update failed: ${error.message}`)
    },
  })

  if (isLoading) return <div>Loading...</div>
  if (!category) return <div>Category not found</div>

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" gutterBottom>
        Edit Category: {category.name}
      </Typography>

      <Grid container spacing={3}>
        {/* Basic Category Information */}
        <Grid item xs={12} md={6}>
          <Paper sx={{ p: 3 }}>
            <Typography variant="h6" gutterBottom>
              Basic Information
            </Typography>
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
              <TextField
                label="Name"
                value={category.name}
                disabled
              />
              <TextField
                label="Slug"
                value={category.slug}
                disabled
              />
              <TextField
                label="Description"
                value={category.description || ''}
                multiline
                rows={3}
                disabled
              />
            </Box>
          </Paper>
        </Grid>

        {/* Banner Management */}
        <Grid item xs={12} md={6}>
          <BannerManager
            category={category}
            onUpdate={() => {
              queryClient.invalidateQueries({ queryKey: ['category', categoryId] })
            }}
          />
        </Grid>
      </Grid>
    </Box>
  )
}

/**
 * Example 2: Category List with Banner Status
 */
export function CategoryListWithBanners() {
  const { data: categories = [], isLoading } = useQuery({
    queryKey: ['categories'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('benefit_categories')
        .select('*')
        .order('display_order')

      if (error) throw error
      return data as BenefitCategory[]
    },
  })

  if (isLoading) return <div>Loading...</div>

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" gutterBottom>
        Categories
      </Typography>

      <Grid container spacing={2}>
        {categories.map((category) => (
          <Grid item xs={12} md={6} key={category.id}>
            <Paper sx={{ p: 2 }}>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2 }}>
                <Typography variant="h6">{category.name}</Typography>
                <Box
                  sx={{
                    px: 1,
                    py: 0.5,
                    borderRadius: 1,
                    bgcolor: category.banner_image_url ? 'success.light' : 'grey.300',
                    color: category.banner_image_url ? 'success.dark' : 'text.secondary',
                    fontSize: '0.75rem',
                    fontWeight: 'bold',
                  }}
                >
                  {category.banner_image_url ? 'Banner Active' : 'No Banner'}
                </Box>
              </Box>

              {category.banner_image_url && (
                <Box sx={{ mb: 2 }}>
                  <img
                    src={category.banner_image_url}
                    alt={`${category.name} banner`}
                    style={{
                      width: '100%',
                      height: '150px',
                      objectFit: 'cover',
                      borderRadius: '4px',
                    }}
                  />
                  {category.banner_link_url && (
                    <Typography variant="caption" color="text.secondary" sx={{ mt: 1 }}>
                      Links to: {category.banner_link_url}
                    </Typography>
                  )}
                </Box>
              )}

              <Button
                variant="outlined"
                size="small"
                href={`/categories/${category.id}/edit`}
              >
                Edit Category
              </Button>
            </Paper>
          </Grid>
        ))}
      </Grid>
    </Box>
  )
}

/**
 * Example 3: Standalone Banner Management Modal
 */
export function BannerManagementModal({
  categoryId,
  open,
  onClose,
}: {
  categoryId: string
  open: boolean
  onClose: () => void
}) {
  const { data: category } = useQuery({
    queryKey: ['category', categoryId],
    queryFn: () => fetchCategoryById(categoryId),
    enabled: open,
  })

  if (!category) return null

  return (
    <Box
      sx={{
        position: 'fixed',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        bgcolor: 'rgba(0,0,0,0.5)',
        display: open ? 'flex' : 'none',
        alignItems: 'center',
        justifyContent: 'center',
        zIndex: 1300,
      }}
      onClick={onClose}
    >
      <Paper
        sx={{ p: 3, maxWidth: 800, width: '90%' }}
        onClick={(e) => e.stopPropagation()}
      >
        <Typography variant="h6" gutterBottom>
          Banner Management: {category.name}
        </Typography>
        <Divider sx={{ my: 2 }} />
        <BannerManager
          category={category}
          onUpdate={() => {
            toast.success('Banner updated')
            onClose()
          }}
        />
        <Box sx={{ display: 'flex', justifyContent: 'flex-end', mt: 2 }}>
          <Button onClick={onClose}>Close</Button>
        </Box>
      </Paper>
    </Box>
  )
}

/**
 * Example 4: Quick Banner Toggle in Table
 */
export function CategoryTableWithQuickBannerToggle() {
  const queryClient = useQueryClient()
  const [expandedCategory, setExpandedCategory] = useState<string | null>(null)

  const { data: categories = [] } = useQuery({
    queryKey: ['categories'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('benefit_categories')
        .select('*')
        .order('display_order')

      if (error) throw error
      return data as BenefitCategory[]
    },
  })

  const toggleMutation = useMutation({
    mutationFn: async ({ id, enabled }: { id: string; enabled: boolean }) => {
      const { error } = await supabase
        .from('benefit_categories')
        .update({
          banner_image_url: enabled ? null : undefined,
          banner_link_url: enabled ? null : undefined,
        })
        .eq('id', id)

      if (error) throw error
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['categories'] })
      toast.success('Banner status updated')
    },
  })

  return (
    <Box sx={{ p: 3 }}>
      {categories.map((category) => (
        <Paper key={category.id} sx={{ p: 2, mb: 2 }}>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <Typography variant="h6">{category.name}</Typography>
            <Box>
              <Button
                size="small"
                onClick={() =>
                  setExpandedCategory(
                    expandedCategory === category.id ? null : category.id
                  )
                }
              >
                {expandedCategory === category.id ? 'Hide' : 'Show'} Banner Settings
              </Button>
            </Box>
          </Box>

          {expandedCategory === category.id && (
            <Box sx={{ mt: 2 }}>
              <BannerManager
                category={category}
                onUpdate={() => {
                  queryClient.invalidateQueries({ queryKey: ['categories'] })
                }}
              />
            </Box>
          )}
        </Paper>
      ))}
    </Box>
  )
}

/**
 * Example 5: Banner Preview Component
 * Use this to display banners on the frontend
 */
export function BannerDisplay({ category }: { category: BenefitCategory }) {
  if (!category.banner_image_url) return null

  const handleClick = () => {
    if (category.banner_link_url) {
      window.location.href = category.banner_link_url
    }
  }

  return (
    <Box
      onClick={handleClick}
      sx={{
        cursor: category.banner_link_url ? 'pointer' : 'default',
        borderRadius: 2,
        overflow: 'hidden',
        mb: 3,
        '&:hover': category.banner_link_url
          ? {
              opacity: 0.9,
              transform: 'scale(1.02)',
              transition: 'all 0.2s',
            }
          : {},
      }}
    >
      <img
        src={category.banner_image_url}
        alt={`${category.name} banner`}
        style={{
          width: '100%',
          height: 'auto',
          display: 'block',
        }}
      />
    </Box>
  )
}
