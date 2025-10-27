# Benefit Announcement Table Components

Drag-and-drop sortable table components for managing benefit announcements with inline editing capabilities.

## Components

### 1. AnnouncementTable
Main table component with drag-and-drop sorting functionality.

**Features:**
- Drag-and-drop row reordering using @dnd-kit
- Automatic display order updates via Supabase RPC
- Dynamic columns based on category
- Responsive table layout
- Integration with React Query for data management

**Props:**
```typescript
interface AnnouncementTableProps {
  announcements: BenefitAnnouncement[]
  categoryId?: string
  onEdit?: (id: string) => void
  onDelete?: (id: string) => void
}
```

### 2. SortableRow
Individual draggable table row component.

**Features:**
- Drag handle with visual feedback
- Status chip with color coding
- Date range formatting
- Action buttons (Edit/Delete)
- Double-click to edit inline

**Status Types:**
- 🟢 모집중 (Recruiting) - Green
- 🔴 마감 (Closed) - Red
- ⚫ 임시저장 (Draft) - Gray
- 🔵 예정 (Upcoming) - Blue

### 3. InlineEditCell
Editable table cell with auto-save functionality.

**Features:**
- Double-click to edit
- Auto-save on blur
- Keyboard shortcuts (Enter to save, Esc to cancel)
- Character limit with counter
- Loading indicator during save
- Optimistic UI updates

**Props:**
```typescript
interface InlineEditCellProps {
  announcementId: string
  field: string
  value: string
  multiline?: boolean
  maxLength?: number
}
```

### 4. DynamicColumns
Category-based dynamic column generator.

**Features:**
- Category-specific columns
- Type-aware rendering
- Default fallback columns
- Support for custom fields

**Category Examples:**
- **LH Housing**: 주택유형, 공급면적, 공급세대, 보증금
- **Job Training**: 훈련유형, 기간, 지원금액
- **Financial Support**: 지원유형, 최대금액, 금리

## Installation

Dependencies are already installed:
```bash
npm install @dnd-kit/core @dnd-kit/sortable @dnd-kit/utilities
```

## Usage

### Basic Example

```tsx
import { AnnouncementTable } from '@/components/benefits'
import { useNavigate } from 'react-router-dom'
import { useMutation } from '@tanstack/react-query'

function AnnouncementList() {
  const navigate = useNavigate()
  const { data: announcements } = useQuery({
    queryKey: ['benefit-announcements'],
    queryFn: fetchAnnouncements,
  })

  const handleEdit = (id: string) => {
    navigate(`/benefits/${id}/edit`)
  }

  const handleDelete = async (id: string) => {
    await deleteAnnouncement(id)
  }

  return (
    <AnnouncementTable
      announcements={announcements || []}
      categoryId="lh-housing"
      onEdit={handleEdit}
      onDelete={handleDelete}
    />
  )
}
```

### With Category Filter

```tsx
function FilteredAnnouncementList() {
  const [categoryId, setCategoryId] = useState<string>()

  const { data: announcements } = useQuery({
    queryKey: ['benefit-announcements', categoryId],
    queryFn: () => fetchAnnouncementsByCategory(categoryId),
  })

  return (
    <>
      <Select value={categoryId} onChange={(e) => setCategoryId(e.target.value)}>
        <MenuItem value="lh-housing">LH 주택</MenuItem>
        <MenuItem value="job-training">취업/훈련</MenuItem>
        <MenuItem value="financial-support">금융지원</MenuItem>
      </Select>

      <AnnouncementTable
        announcements={announcements || []}
        categoryId={categoryId}
        onEdit={(id) => navigate(`/benefits/${id}/edit`)}
        onDelete={(id) => deleteAnnouncement(id)}
      />
    </>
  )
}
```

## Required Supabase RPC Function

The drag-and-drop functionality requires a Supabase RPC function:

```sql
CREATE OR REPLACE FUNCTION update_display_orders(orders jsonb)
RETURNS void AS $$
DECLARE
  item jsonb;
BEGIN
  FOR item IN SELECT * FROM jsonb_array_elements(orders)
  LOOP
    UPDATE benefit_announcements
    SET display_order = (item->>'display_order')::integer,
        updated_at = now()
    WHERE id = (item->>'announcement_id')::uuid;
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Inline Editing

Double-click any editable cell to edit inline:

1. **Title Field**: Multiline editing with character limit
2. **Organization Field**: Single-line editing
3. **Other Fields**: Based on field type

**Keyboard Shortcuts:**
- `Enter`: Save changes (single-line only)
- `Esc`: Cancel editing
- `Blur`: Auto-save changes

## Drag-and-Drop Behavior

1. **Activation**: Click and drag the drag handle (⋮⋮)
2. **Visual Feedback**: Row becomes semi-transparent while dragging
3. **Drop Zones**: Valid drop zones highlighted automatically
4. **Auto-Save**: Display order updates immediately after drop
5. **Optimistic UI**: UI updates before server confirmation
6. **Error Handling**: Reverts to original order on error

## API Integration

The components integrate with:

- **React Query**: Data fetching and caching
- **Supabase**: Database operations
- **React Hot Toast**: User notifications

## TypeScript Types

All components are fully typed using:
- `BenefitAnnouncement` from `@/types/database`
- Strict TypeScript mode enabled
- Full IntelliSense support

## Accessibility

- Keyboard navigation support
- ARIA labels for drag handles
- Screen reader announcements
- Focus management
- Semantic HTML structure

## Performance

- **Optimistic Updates**: Instant UI feedback
- **Debounced Saves**: Reduced API calls
- **Virtual Scrolling**: Ready for large datasets
- **Memoization**: Prevents unnecessary re-renders

## Customization

### Custom Columns

Add custom columns by modifying `DynamicColumns.tsx`:

```tsx
if (category.slug === 'custom-category') {
  return [
    { key: 'custom_field', label: 'Custom Label', type: 'text' },
    { key: 'amount', label: 'Amount', type: 'number' },
  ]
}
```

### Custom Status Colors

Modify `STATUS_CONFIG` in `SortableRow.tsx`:

```tsx
const STATUS_CONFIG = {
  custom_status: {
    label: 'Custom',
    color: 'warning',
    icon: '🟡'
  },
}
```

## Testing

Example test cases:

```tsx
describe('AnnouncementTable', () => {
  it('should render announcements', () => {
    render(<AnnouncementTable announcements={mockAnnouncements} />)
    expect(screen.getByText('Test Announcement')).toBeInTheDocument()
  })

  it('should handle drag and drop', async () => {
    const { container } = render(<AnnouncementTable announcements={mockAnnouncements} />)
    // Simulate drag and drop
    // Assert order changed
  })

  it('should save inline edits', async () => {
    render(<InlineEditCell announcementId="1" field="title" value="Test" />)
    // Double-click to edit
    // Change value
    // Assert API called
  })
})
```

## Troubleshooting

### Drag-and-drop not working
- Ensure `@dnd-kit` packages are installed
- Check for CSS conflicts with `position: fixed`
- Verify `id` fields are unique

### Inline edit not saving
- Check Supabase permissions
- Verify field names match database schema
- Check network tab for API errors

### Display order not updating
- Ensure RPC function exists in Supabase
- Check RPC permissions (SECURITY DEFINER)
- Verify `display_order` column exists

## Future Enhancements

- [ ] Bulk editing support
- [ ] Excel/CSV export
- [ ] Advanced filtering
- [ ] Column customization UI
- [ ] Mobile touch support enhancement
- [ ] Undo/redo functionality
- [ ] Real-time collaboration
