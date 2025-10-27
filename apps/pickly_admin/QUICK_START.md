# Quick Start Guide - Announcement Table

## 🚀 1-Minute Setup

### Step 1: Run Database Migration
```bash
# Option A: Using Supabase CLI
supabase db push supabase/migrations/20250124_update_display_orders_rpc.sql

# Option B: Manual (Supabase Dashboard > SQL Editor)
# Copy and paste the SQL from the migration file
```

### Step 2: Import Component
```tsx
import { AnnouncementTable } from '@/components/benefits'
```

### Step 3: Use Component
```tsx
<AnnouncementTable
  announcements={announcements}
  onEdit={(id) => navigate(`/benefits/${id}/edit`)}
  onDelete={(id) => deleteAnnouncement(id)}
/>
```

## ✨ Features

### Drag-and-Drop
- Click and drag the **⋮⋮** handle
- Drop to reorder
- Auto-saves to database

### Inline Editing
- **Double-click** any cell to edit
- Press **Enter** to save (single-line)
- Press **Esc** to cancel
- Auto-saves on blur

### Status Colors
- 🟢 **모집중** (Recruiting)
- 🔴 **마감** (Closed)
- ⚫ **임시저장** (Draft)
- 🔵 **예정** (Upcoming)

## 📦 What's Included

```
src/components/benefits/
├── AnnouncementTable.tsx    ← Main component
├── SortableRow.tsx           ← Drag-and-drop row
├── InlineEditCell.tsx        ← Editable cell
├── DynamicColumns.tsx        ← Category columns
├── index.ts                  ← Exports
├── README.md                 ← Full docs
└── INTEGRATION_EXAMPLE.tsx   ← Integration guide
```

## 🔑 Key Props

```typescript
interface AnnouncementTableProps {
  announcements: BenefitAnnouncement[]  // Required
  categoryId?: string                   // Optional
  onEdit?: (id: string) => void        // Optional
  onDelete?: (id: string) => void      // Optional
}
```

## 🎯 Common Tasks

### Filter by Category
```tsx
const [categoryId, setCategoryId] = useState('lh-housing')

<AnnouncementTable
  announcements={announcements}
  categoryId={categoryId}
/>
```

### Custom Edit Handler
```tsx
const handleEdit = (id: string) => {
  navigate(`/benefits/${id}/edit`)
}

<AnnouncementTable
  announcements={announcements}
  onEdit={handleEdit}
/>
```

### Custom Delete Handler
```tsx
const handleDelete = async (id: string) => {
  await deleteAnnouncement(id)
  queryClient.invalidateQueries(['announcements'])
}

<AnnouncementTable
  announcements={announcements}
  onDelete={handleDelete}
/>
```

## 🐛 Troubleshooting

### Drag not working?
```bash
# Check dependencies installed
npm list @dnd-kit/core @dnd-kit/sortable
```

### Order not saving?
```sql
-- Check RPC function exists
SELECT routine_name
FROM information_schema.routines
WHERE routine_name = 'update_display_orders';
```

### Inline edit not working?
```tsx
// Verify Supabase client configured
import { supabase } from '@/lib/supabase'
```

## 📚 Full Documentation

See `README.md` for complete documentation including:
- Advanced usage
- API reference
- Testing guide
- Customization options
- TypeScript types

## 🎓 Learn More

- **Component Docs**: `src/components/benefits/README.md`
- **Integration Guide**: `src/components/benefits/INTEGRATION_EXAMPLE.tsx`
- **Implementation Summary**: `ANNOUNCEMENT_TABLE_IMPLEMENTATION.md`

---

**Ready to use!** All components created and dependencies installed. ✅
