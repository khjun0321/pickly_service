import { useMemo } from 'react'
import { useQuery } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase'
import type { BenefitCategory } from '@/types/database'

interface DynamicColumn {
  key: string
  label: string
  type?: string
}

interface DynamicColumnsProps {
  categoryId?: string
}

export function useDynamicColumns({ categoryId }: DynamicColumnsProps) {
  const { data: category } = useQuery({
    queryKey: ['benefit-category', categoryId],
    queryFn: async () => {
      if (!categoryId) return null

      const { data, error } = await supabase
        .from('benefit_categories')
        .select('*')
        .eq('id', categoryId)
        .single()

      if (error) throw error
      return data as BenefitCategory
    },
    enabled: !!categoryId,
  })

  const dynamicColumns = useMemo<DynamicColumn[]>(() => {
    if (!category) {
      // Default columns when no category is selected
      return [
        { key: 'tags', label: '태그', type: 'array' },
        { key: 'views_count', label: '조회수', type: 'number' },
      ]
    }

    // Parse custom_fields from category metadata
    // Example custom_fields structure:
    // {
    //   "housing_type": { "label": "주택유형", "type": "select", "options": ["아파트", "빌라"] },
    //   "supply_area": { "label": "공급면적", "type": "number", "unit": "m²" },
    //   "deposit": { "label": "보증금", "type": "number", "unit": "만원" }
    // }

    // Note: benefit_categories table doesn't have custom_fields yet
    // This is a placeholder for when the schema is extended
    // For now, return housing-specific columns for LH housing category

    // Placeholder for future custom_fields implementation
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const customFields: Record<string, unknown> = {}

    if (category.slug === 'lh-housing' || category.name.includes('주택')) {
      return [
        { key: 'housing_type', label: '주택유형', type: 'text' },
        { key: 'supply_area', label: '공급면적', type: 'number' },
        { key: 'supply_count', label: '공급세대', type: 'number' },
        { key: 'deposit', label: '보증금', type: 'number' },
      ]
    }

    if (category.slug === 'job-training' || category.name.includes('취업')) {
      return [
        { key: 'training_type', label: '훈련유형', type: 'text' },
        { key: 'duration', label: '기간', type: 'text' },
        { key: 'support_amount', label: '지원금액', type: 'number' },
      ]
    }

    if (category.slug === 'financial-support' || category.name.includes('금융')) {
      return [
        { key: 'support_type', label: '지원유형', type: 'text' },
        { key: 'max_amount', label: '최대금액', type: 'number' },
        { key: 'interest_rate', label: '금리', type: 'text' },
      ]
    }

    // Default columns
    return [
      { key: 'tags', label: '태그', type: 'array' },
      { key: 'views_count', label: '조회수', type: 'number' },
    ]
  }, [category])

  return dynamicColumns
}
