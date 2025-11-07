import React, { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'
import type { MappingConfig } from '@/types/api'
import { DataTable } from './components/DataTable'
import { TopActionBar } from './components/TopActionBar'
import { JsonEditor } from './components/JsonEditor'

export default function MappingConfigPage() {
  const [configs, setConfigs] = useState<MappingConfig[]>([])
  const [editing, setEditing] = useState<MappingConfig | null>(null)

  const loadConfigs = async () => {
    const { data } = await supabase.from('mapping_config').select('*')
    setConfigs(data ?? [])
  }

  useEffect(() => {
    loadConfigs()
  }, [])

  return (
    <div>
      <TopActionBar title="매핑 규칙 관리" />
      <DataTable
        data={configs}
        columns={[
          { key: 'source_id', label: '소스 ID' },
          { key: 'updated_at', label: '수정일' },
        ]}
        onEdit={(row) => setEditing(row)}
      />
      {editing && (
        <JsonEditor
          open={!!editing}
          initialValue={editing.mapping_rules}
          onClose={() => setEditing(null)}
          onSave={async (data) => {
            await supabase
              .from('mapping_config')
              .update({ mapping_rules: data })
              .eq('id', editing.id)
            loadConfigs()
          }}
        />
      )}
    </div>
  )
}
