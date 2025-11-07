import React from 'react'
import { Table, TableBody, TableCell, TableHead, TableRow, Button } from '@mui/material'

interface DataTableProps<T> {
  data: T[]
  columns: { key: keyof T; label: string }[]
  onEdit?: (row: T) => void
  onDelete?: (row: T) => void
}

export function DataTable<T extends { id: string }>({
  data,
  columns,
  onEdit,
  onDelete,
}: DataTableProps<T>) {
  return (
    <Table>
      <TableHead>
        <TableRow>
          {columns.map((c) => (
            <TableCell key={String(c.key)}>{c.label}</TableCell>
          ))}
          {(onEdit || onDelete) && <TableCell>Actions</TableCell>}
        </TableRow>
      </TableHead>
      <TableBody>
        {data.map((row) => (
          <TableRow key={row.id}>
            {columns.map((c) => (
              <TableCell key={String(c.key)}>{String(row[c.key])}</TableCell>
            ))}
            {(onEdit || onDelete) && (
              <TableCell>
                {onEdit && <Button onClick={() => onEdit(row)}>Edit</Button>}
                {onDelete && <Button onClick={() => onDelete(row)}>Delete</Button>}
              </TableCell>
            )}
          </TableRow>
        ))}
      </TableBody>
    </Table>
  )
}
