import React, { useState, useCallback } from 'react';
import { useDropzone } from 'react-dropzone';
import {
  Box,
  Typography,
  LinearProgress,
  IconButton,
  ImageList,
  ImageListItem,
  ImageListItemBar,
  Paper,
  Alert,
  Chip,
} from '@mui/material';
import {
  CloudUpload as CloudUploadIcon,
  Delete as DeleteIcon,
  InsertDriveFile as FileIcon,
  Image as ImageIcon,
} from '@mui/icons-material';
import { supabase } from '@/lib/supabase';

export interface AnnouncementFile {
  id: string;
  file_name: string;
  file_path: string;
  file_url: string;
  file_type: string;
  file_size: number;
}

interface FileUploaderProps {
  announcementId: string;
  onUploadComplete: (files: AnnouncementFile[]) => void;
  accept?: string;
  maxFiles?: number;
  maxSizeMB?: number;
}

interface UploadingFile {
  file: File;
  progress: number;
  preview?: string;
  error?: string;
  uploaded?: AnnouncementFile;
}

export const FileUploader: React.FC<FileUploaderProps> = ({
  announcementId,
  onUploadComplete,
  accept = 'image/*,application/pdf',
  maxFiles = 10,
  maxSizeMB = 10,
}) => {
  const [uploadingFiles, setUploadingFiles] = useState<UploadingFile[]>([]);
  const [uploadedFiles, setUploadedFiles] = useState<AnnouncementFile[]>([]);
  const [error, setError] = useState<string | null>(null);

  const maxSizeBytes = maxSizeMB * 1024 * 1024;

  const onDrop = useCallback(
    async (acceptedFiles: File[]) => {
      setError(null);

      // Validate file count
      const totalFiles = uploadedFiles.length + acceptedFiles.length;
      if (totalFiles > maxFiles) {
        setError(`Maximum ${maxFiles} files allowed`);
        return;
      }

      // Validate file sizes
      const oversizedFiles = acceptedFiles.filter((file) => file.size > maxSizeBytes);
      if (oversizedFiles.length > 0) {
        setError(`Files must be smaller than ${maxSizeMB}MB`);
        return;
      }

      // Initialize uploading state
      const newUploadingFiles: UploadingFile[] = acceptedFiles.map((file) => ({
        file,
        progress: 0,
        preview: file.type.startsWith('image/') ? URL.createObjectURL(file) : undefined,
      }));

      setUploadingFiles((prev) => [...prev, ...newUploadingFiles]);

      // Upload files sequentially
      for (let i = 0; i < acceptedFiles.length; i++) {
        const file = acceptedFiles[i];
        try {
          const uploadedFile = await uploadFile(file, i);

          // Update progress to 100% and store uploaded file
          setUploadingFiles((prev) =>
            prev.map((uf) =>
              uf.file === file ? { ...uf, progress: 100, uploaded: uploadedFile } : uf
            )
          );

          // Add to uploaded files
          setUploadedFiles((prev) => {
            const newFiles = [...prev, uploadedFile];
            onUploadComplete(newFiles);
            return newFiles;
          });
        } catch (err) {
          const errorMessage = err instanceof Error ? err.message : 'Upload failed';
          setUploadingFiles((prev) =>
            prev.map((uf) =>
              uf.file === file ? { ...uf, error: errorMessage } : uf
            )
          );
        }
      }

      // Clean up completed/failed uploads after 2 seconds
      setTimeout(() => {
        setUploadingFiles((prev) =>
          prev.filter((uf) => uf.progress < 100 && !uf.error)
        );
      }, 2000);
    },
    [announcementId, maxFiles, maxSizeBytes, uploadedFiles.length, onUploadComplete]
  );

  const uploadFile = async (file: File, index: number): Promise<AnnouncementFile> => {
    const fileExt = file.name.split('.').pop();
    const fileName = `${Date.now()}-${index}.${fileExt}`;
    const filePath = `announcements/images/${announcementId}/${fileName}`;

    // Simulate progress updates
    const progressInterval = setInterval(() => {
      setUploadingFiles((prev) =>
        prev.map((uf) =>
          uf.file === file && uf.progress < 90
            ? { ...uf, progress: uf.progress + 10 }
            : uf
        )
      );
    }, 200);

    try {
      const { data, error } = await supabase.storage
        .from('announcements')
        .upload(filePath, file, {
          cacheControl: '3600',
          upsert: false,
        });

      clearInterval(progressInterval);

      if (error) {
        throw new Error(error.message);
      }

      // Get public URL
      const { data: urlData } = supabase.storage
        .from('announcements')
        .getPublicUrl(filePath);

      const uploadedFile: AnnouncementFile = {
        id: crypto.randomUUID(),
        file_name: file.name,
        file_path: data.path,
        file_url: urlData.publicUrl,
        file_type: file.type,
        file_size: file.size,
      };

      return uploadedFile;
    } catch (err) {
      clearInterval(progressInterval);
      throw err;
    }
  };

  const handleDelete = async (fileToDelete: AnnouncementFile) => {
    try {
      // Delete from storage
      const { error } = await supabase.storage
        .from('announcements')
        .remove([fileToDelete.file_path]);

      if (error) {
        throw new Error(error.message);
      }

      // Remove from state
      setUploadedFiles((prev) => {
        const newFiles = prev.filter((f) => f.id !== fileToDelete.id);
        onUploadComplete(newFiles);
        return newFiles;
      });
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Delete failed');
    }
  };

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: accept.split(',').reduce((acc, type) => {
      acc[type.trim()] = [];
      return acc;
    }, {} as Record<string, string[]>),
    maxFiles: maxFiles - uploadedFiles.length,
  });

  const formatFileSize = (bytes: number): string => {
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
  };

  return (
    <Box>
      {error && (
        <Alert severity="error" onClose={() => setError(null)} sx={{ mb: 2 }}>
          {error}
        </Alert>
      )}

      {/* Dropzone */}
      <Paper
        {...getRootProps()}
        sx={{
          p: 3,
          border: '2px dashed',
          borderColor: isDragActive ? 'primary.main' : 'grey.300',
          backgroundColor: isDragActive ? 'action.hover' : 'background.paper',
          cursor: 'pointer',
          textAlign: 'center',
          transition: 'all 0.2s',
          '&:hover': {
            borderColor: 'primary.main',
            backgroundColor: 'action.hover',
          },
        }}
      >
        <input {...getInputProps()} />
        <CloudUploadIcon sx={{ fontSize: 48, color: 'primary.main', mb: 1 }} />
        <Typography variant="h6" gutterBottom>
          {isDragActive ? 'Drop files here' : 'Drag & drop files here'}
        </Typography>
        <Typography variant="body2" color="text.secondary">
          or click to select files
        </Typography>
        <Box sx={{ mt: 2, display: 'flex', gap: 1, justifyContent: 'center', flexWrap: 'wrap' }}>
          <Chip label={`Max ${maxFiles} files`} size="small" />
          <Chip label={`Max ${maxSizeMB}MB per file`} size="small" />
          <Chip
            label={accept === 'image/*' ? 'Images only' : accept === 'application/pdf' ? 'PDFs only' : 'Images & PDFs'}
            size="small"
          />
        </Box>
      </Paper>

      {/* Uploading Files Progress */}
      {uploadingFiles.length > 0 && (
        <Box sx={{ mt: 3 }}>
          <Typography variant="subtitle2" gutterBottom>
            Uploading Files
          </Typography>
          {uploadingFiles.map((uf, index) => (
            <Box key={index} sx={{ mb: 2 }}>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 0.5 }}>
                {uf.file.type.startsWith('image/') ? (
                  <ImageIcon sx={{ mr: 1, color: 'primary.main' }} />
                ) : (
                  <FileIcon sx={{ mr: 1, color: 'error.main' }} />
                )}
                <Typography variant="body2" sx={{ flex: 1 }}>
                  {uf.file.name} ({formatFileSize(uf.file.size)})
                </Typography>
                <Typography variant="caption" color={uf.error ? 'error' : 'text.secondary'}>
                  {uf.error ? uf.error : `${uf.progress}%`}
                </Typography>
              </Box>
              {!uf.error && (
                <LinearProgress
                  variant="determinate"
                  value={uf.progress}
                  sx={{
                    height: 6,
                    borderRadius: 1,
                  }}
                />
              )}
            </Box>
          ))}
        </Box>
      )}

      {/* Uploaded Files Preview */}
      {uploadedFiles.length > 0 && (
        <Box sx={{ mt: 3 }}>
          <Typography variant="subtitle2" gutterBottom>
            Uploaded Files ({uploadedFiles.length})
          </Typography>
          <ImageList cols={4} gap={12} sx={{ maxHeight: 400 }}>
            {uploadedFiles.map((file) => (
              <ImageListItem key={file.id}>
                {file.file_type.startsWith('image/') ? (
                  <img
                    src={file.file_url}
                    alt={file.file_name}
                    loading="lazy"
                    style={{
                      height: 150,
                      objectFit: 'cover',
                      borderRadius: 8,
                    }}
                  />
                ) : (
                  <Box
                    sx={{
                      height: 150,
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      backgroundColor: 'grey.100',
                      borderRadius: 2,
                    }}
                  >
                    <FileIcon sx={{ fontSize: 48, color: 'error.main' }} />
                  </Box>
                )}
                <ImageListItemBar
                  title={file.file_name}
                  subtitle={formatFileSize(file.file_size)}
                  actionIcon={
                    <IconButton
                      sx={{ color: 'white' }}
                      onClick={() => handleDelete(file)}
                    >
                      <DeleteIcon />
                    </IconButton>
                  }
                />
              </ImageListItem>
            ))}
          </ImageList>
        </Box>
      )}
    </Box>
  );
};
