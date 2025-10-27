// Edge Function to fetch LH (한국토지주택공사) housing announcements
// API Documentation: OpenAPI활용가이드_한국토지주택공사_분양임대공고조회

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// CORS headers for browser requests
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface LHAnnouncementItem {
  공고번호?: string
  공고명?: string
  공고일자?: string
  지역?: string
  모집시작일?: string
  모집종료일?: string
  입주시작일?: string
  입주종료일?: string
  소재지?: string
  단지명?: string
  공급호수?: number
  상세URL?: string
}

interface LHApiResponse {
  data?: LHAnnouncementItem[]
  datas?: LHAnnouncementItem[]
  body?: {
    items?: LHAnnouncementItem[]
    item?: LHAnnouncementItem[]
  }
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    console.log('🚀 Starting LH announcements fetch...')

    // Get environment variables
    const LH_API_KEY = Deno.env.get('LH_API_KEY')
    const LH_API_URL = Deno.env.get('LH_API_URL') || 'https://apis.data.go.kr/B552555/lhLeaseNoticeInfo1'
    const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
    const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

    if (!LH_API_KEY) {
      throw new Error('LH_API_KEY is not configured')
    }

    // Initialize Supabase client with service role key for admin operations
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

    // Get '주거' parent category and all subcategories
    console.log('📋 Fetching 주거 categories...')
    const { data: parentCategory, error: parentError } = await supabase
      .from('benefit_categories')
      .select('id')
      .eq('slug', 'housing')
      .eq('is_active', true)
      .single()

    if (parentError || !parentCategory) {
      console.error('❌ Failed to find 주거 parent category:', parentError)
      throw new Error('주거 카테고리를 찾을 수 없습니다. 먼저 카테고리를 생성해주세요.')
    }

    const housingParentId = parentCategory.id
    console.log('✅ Found 주거 parent category:', housingParentId)

    // Get all subcategories
    const { data: subcategories, error: subError } = await supabase
      .from('benefit_categories')
      .select('id, name, slug')
      .eq('parent_id', housingParentId)
      .eq('is_active', true)

    if (subError) {
      console.error('❌ Failed to fetch subcategories:', subError)
      throw new Error('하위 카테고리를 가져오는데 실패했습니다.')
    }

    console.log(`✅ Found ${subcategories?.length || 0} subcategories`)

    // Create subcategory mapping by slug
    const categoryMap = new Map<string, string>()
    categoryMap.set('default', housingParentId) // Default to parent
    subcategories?.forEach(cat => {
      categoryMap.set(cat.slug, cat.id)
    })

    console.log('📋 Category mapping:', Array.from(categoryMap.entries()))

    // Fetch LH API data with retry logic
    console.log('📡 Fetching LH API data...')
    const params = new URLSearchParams({
      serviceKey: LH_API_KEY,
      page: '1',
      perPage: '100', // Get up to 100 announcements
    })

    let lhResponse: Response | null = null
    let lastError: Error | null = null
    const maxRetries = 3
    const retryDelay = 2000 // 2 seconds

    for (let attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        console.log(`🔄 Attempt ${attempt}/${maxRetries}...`)

        lhResponse = await fetch(`${LH_API_URL}?${params}`, {
          method: 'GET',
          headers: {
            'Accept': 'application/json',
          },
          signal: AbortSignal.timeout(15000), // 15 second timeout
        })

        if (lhResponse.ok) {
          console.log(`✅ LH API responded successfully on attempt ${attempt}`)
          break
        }

        const errorText = await lhResponse.text()
        console.error(`❌ LH API error (attempt ${attempt}):`, lhResponse.status, errorText.substring(0, 200))
        lastError = new Error(`LH API returned status ${lhResponse.status}: ${errorText.substring(0, 100)}`)

        if (attempt < maxRetries) {
          console.log(`⏳ Waiting ${retryDelay}ms before retry...`)
          await new Promise(resolve => setTimeout(resolve, retryDelay))
        }
      } catch (error) {
        console.error(`❌ Network error (attempt ${attempt}):`, error)
        lastError = error instanceof Error ? error : new Error('Unknown network error')

        if (attempt < maxRetries) {
          console.log(`⏳ Waiting ${retryDelay}ms before retry...`)
          await new Promise(resolve => setTimeout(resolve, retryDelay))
        }
      }
    }

    if (!lhResponse || !lhResponse.ok) {
      const errorMessage = lastError?.message || 'LH API 연결 실패'
      throw new Error(`LH API 접속에 ${maxRetries}번 실패했습니다. 외부 API 서버에 문제가 있거나 서비스 키가 유효하지 않을 수 있습니다. 상세: ${errorMessage}`)
    }

    const lhData: LHApiResponse = await lhResponse.json()
    console.log('📦 LH API response received')

    // Extract items from various possible response structures
    let items: LHAnnouncementItem[] = []
    if (lhData.data && Array.isArray(lhData.data)) {
      items = lhData.data
    } else if (lhData.datas && Array.isArray(lhData.datas)) {
      items = lhData.datas
    } else if (lhData.body?.items && Array.isArray(lhData.body.items)) {
      items = lhData.body.items
    } else if (lhData.body?.item && Array.isArray(lhData.body.item)) {
      items = lhData.body.item
    }

    console.log(`📊 Found ${items.length} announcements from LH API`)

    if (items.length === 0) {
      return new Response(
        JSON.stringify({
          success: true,
          message: 'LH API에서 데이터가 없습니다.',
          count: 0
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Transform LH data to our schema with automatic categorization
    const announcements = items.map(item => {
      const title = item.공고명 || '제목 없음'
      const subtitle = item.단지명 || ''
      const fullText = `${title} ${subtitle}`.toLowerCase()

      // Determine subcategory based on keywords in title/subtitle
      let categoryId = categoryMap.get('default')!
      let housingType = 'LH공사'

      if (fullText.includes('행복주택') || fullText.includes('행복')) {
        categoryId = categoryMap.get('housing-happiness') || categoryId
        housingType = '행복주택'
      } else if (fullText.includes('국민임대') || fullText.includes('국민')) {
        categoryId = categoryMap.get('housing-public') || categoryId
        housingType = '국민임대주택'
      } else if (fullText.includes('영구임대') || fullText.includes('영구')) {
        categoryId = categoryMap.get('housing-permanent') || categoryId
        housingType = '영구임대주택'
      } else if (fullText.includes('매입임대') || fullText.includes('매입')) {
        categoryId = categoryMap.get('housing-purchased') || categoryId
        housingType = '매입임대주택'
      } else if (fullText.includes('신혼희망타운') || fullText.includes('신혼') || fullText.includes('희망타운')) {
        categoryId = categoryMap.get('housing-newlywed') || categoryId
        housingType = '신혼희망타운'
      }

      console.log(`📌 Mapping "${title}" → ${housingType} (${categoryId})`)

      return {
        category_id: categoryId,
        external_id: item.공고번호 || null,
        title: title,
        subtitle: item.단지명 || null,
        organization: 'LH 한국토지주택공사',
        application_period_start: item.모집시작일 || null,
        application_period_end: item.모집종료일 || null,
        announcement_date: item.공고일자 || null,
        status: determineStatus(item.모집시작일, item.모집종료일),
        summary: `${item.소재지 || ''} ${item.공급호수 ? `공급호수: ${item.공급호수}세대` : ''}`.trim() || null,
        external_url: item.상세URL || null,
        tags: [item.지역 || '전국', housingType, 'LH공사'].filter(Boolean),
        is_featured: false,
        views_count: 0,
      }
    })

    console.log('💾 Upserting announcements to database...')

    // Upsert to prevent duplicates (using external_id)
    const { data: insertedData, error: insertError } = await supabase
      .from('benefit_announcements')
      .upsert(announcements, {
        onConflict: 'external_id',
        ignoreDuplicates: false
      })
      .select('id, title, external_id')

    if (insertError) {
      console.error('❌ Database insert error:', insertError)
      throw insertError
    }

    const insertedCount = insertedData?.length || 0
    console.log(`✅ Successfully upserted ${insertedCount} announcements`)

    return new Response(
      JSON.stringify({
        success: true,
        message: `LH 공고 ${insertedCount}개를 성공적으로 가져왔습니다.`,
        count: insertedCount,
        announcements: insertedData,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )

  } catch (error) {
    console.error('❌ Error in fetch-lh-announcements:', error)

    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error occurred',
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      }
    )
  }
})

/**
 * Determine announcement status based on recruitment dates
 */
function determineStatus(startDate?: string, endDate?: string): string {
  if (!startDate || !endDate) {
    return 'draft'
  }

  const now = new Date()
  const start = new Date(startDate)
  const end = new Date(endDate)

  if (now < start) {
    return 'upcoming'
  } else if (now > end) {
    return 'closed'
  } else {
    return 'recruiting'
  }
}
