/**
 * FileUploader Component - Usage Example
 *
 * This file demonstrates how to use the FileUploader component in your forms
 */

import React, { useState } from 'react';
import { Box, Button, Typography } from '@mui/material';
import { FileUploader } from './FileUploader';
import type { AnnouncementFile } from './FileUploader';

export const FileUploaderExample: React.FC = () => {
  const [files, setFiles] = useState<AnnouncementFile[]>([]);
  const announcementId = 'example-announcement-id'; // Replace with actual ID

  const handleUploadComplete = (uploadedFiles: AnnouncementFile[]) => {
    console.log('Upload complete:', uploadedFiles);
    setFiles(uploadedFiles);
  };

  const handleSubmit = () => {
    // Use the files in your form submission
    console.log('Submitting with files:', files);
    // Example: Save file references to database
    // await saveBenefitAnnouncement({ files });
  };

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h5" gutterBottom>
        File Upload Example
      </Typography>

      {/* Example 1: Image uploads only */}
      <Box sx={{ mb: 4 }}>
        <Typography variant="h6" gutterBottom>
          Image Uploads Only
        </Typography>
        <FileUploader
          announcementId={announcementId}
          onUploadComplete={handleUploadComplete}
          accept="image/*"
          maxFiles={5}
          maxSizeMB={5}
        />
      </Box>

      {/* Example 2: PDF uploads only */}
      <Box sx={{ mb: 4 }}>
        <Typography variant="h6" gutterBottom>
          PDF Uploads Only
        </Typography>
        <FileUploader
          announcementId={announcementId}
          onUploadComplete={handleUploadComplete}
          accept="application/pdf"
          maxFiles={3}
          maxSizeMB={10}
        />
      </Box>

      {/* Example 3: Mixed uploads (default) */}
      <Box sx={{ mb: 4 }}>
        <Typography variant="h6" gutterBottom>
          Images and PDFs
        </Typography>
        <FileUploader
          announcementId={announcementId}
          onUploadComplete={handleUploadComplete}
          accept="image/*,application/pdf"
          maxFiles={10}
          maxSizeMB={10}
        />
      </Box>

      {/* Show uploaded files data */}
      {files.length > 0 && (
        <Box sx={{ mt: 3, p: 2, backgroundColor: 'grey.100', borderRadius: 2 }}>
          <Typography variant="subtitle2" gutterBottom>
            Uploaded Files Data (for form submission):
          </Typography>
          <pre style={{ fontSize: 12, overflow: 'auto' }}>
            {JSON.stringify(files, null, 2)}
          </pre>
        </Box>
      )}

      <Button
        variant="contained"
        onClick={handleSubmit}
        disabled={files.length === 0}
        sx={{ mt: 2 }}
      >
        Submit Form with Files
      </Button>
    </Box>
  );
};

/**
 * Integration with BenefitAnnouncementForm:
 *
 * import { FileUploader, AnnouncementFile } from '@/components/shared';
 *
 * const [announcementFiles, setAnnouncementFiles] = useState<AnnouncementFile[]>([]);
 *
 * <FileUploader
 *   announcementId={announcement.id}
 *   onUploadComplete={setAnnouncementFiles}
 *   accept="image/*,application/pdf"
 *   maxFiles={10}
 *   maxSizeMB={10}
 * />
 *
 * // On form submit, save file references to database:
 * const handleSubmit = async (formData) => {
 *   await supabase.from('benefit_announcements').insert({
 *     ...formData,
 *     files: announcementFiles, // or save to separate announcement_files table
 *   });
 * };
 */
