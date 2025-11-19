import React, { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'
import type { ApiSource } from '@/types/api'
import { DataTable } from './components/DataTable'
import { TopActionBar } from './components/TopActionBar'

export default function ApiSourcesPage() {
  const [sources, setSources] = useState<ApiSource[]>([])

  const loadSources = async () => {
    const { data } = await supabase
      .from('api_sources')
      .select('*')
      .order('created_at', { ascending: false })
    setSources(data ?? [])
  }

  useEffect(() => {
    loadSources()
  }, [])

  return (
    <div>
      <TopActionBar title="API 소스 관리" onAdd={() => alert('추가 모달 준비중')} />
      <DataTable
        data={sources}
        columns={[
          { key: 'name', label: '이름' },
          { key: 'api_url', label: 'API URL' },
          { key: 'status', label: '상태' },
          { key: 'last_collected_at', label: '마지막 수집' },
        ]}
      />
    </div>
  )
}
