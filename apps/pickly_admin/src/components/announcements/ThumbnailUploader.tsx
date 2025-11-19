/**
 * ThumbnailUploader Component
 * PRD v9.12.0 - Announcement Thumbnail Upload
 * Purpose: Upload and manage announcement thumbnail images to Supabase Storage
 */

import { useState } from 'react';
import { createClient } from '@supabase/supabase-js';
import { Button } from '@/components/ui/button';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Loader2, Upload, X, Image as ImageIcon } from 'lucide-react';

// Supabase client configuration
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || '';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || '';
const supabase = createClient(supabaseUrl, supabaseAnonKey);

interface ThumbnailUploaderProps {
  announcementId: string;
  value?: string | null;
  onChange: (url: string) => void;
  onError?: (error: string) => void;
}

export default function ThumbnailUploader({
  announcementId,
  value,
  onChange,
  onError
}: ThumbnailUploaderProps) {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [preview, setPreview] = useState<string | null>(value || null);

  const handleFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    // Reset error state
    setError(null);

    // Validate file type
    const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
    if (!allowedTypes.includes(file.type)) {
      const errorMsg = '지원하지 않는 파일 형식입니다. JPEG, PNG, WebP만 업로드 가능합니다.';
      setError(errorMsg);
      if (onError) onError(errorMsg);
      return;
    }

    // Validate file size (5MB limit)
    const maxSize = 5 * 1024 * 1024; // 5MB
    if (file.size > maxSize) {
      const errorMsg = '파일 크기는 5MB를 초과할 수 없습니다.';
      setError(errorMsg);
      if (onError) onError(errorMsg);
      return;
    }

    setLoading(true);

    try {
      // Generate unique file path
      const ext = file.name.split('.').pop() || 'jpg';
      const timestamp = Date.now();
      const path = `${announcementId}/${timestamp}.${ext}`;

      // Upload to Supabase Storage
      const { error: uploadError } = await supabase.storage
        .from('announcement-thumbnails')
        .upload(path, file, {
          cacheControl: '3600',
          upsert: true
        });

      if (uploadError) {
        throw uploadError;
      }

      // Get public URL
      const { data: urlData } = supabase.storage
        .from('announcement-thumbnails')
        .getPublicUrl(path);

      const publicUrl = urlData.publicUrl;

      // Update preview and notify parent
      setPreview(publicUrl);
      onChange(publicUrl);

      console.log('✅ Thumbnail uploaded successfully:', publicUrl);
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : '업로드 중 오류가 발생했습니다';
      console.error('❌ Thumbnail upload error:', err);
      setError(errorMsg);
      if (onError) onError(errorMsg);
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async () => {
    if (!preview || !window.confirm('썸네일을 삭제하시겠습니까?')) return;

    setLoading(true);

    try {
      // Extract file path from public URL
      const urlParts = preview.split('/announcement-thumbnails/');
      if (urlParts.length > 1) {
        const filePath = urlParts[1];

        // Delete from Storage
        const { error: deleteError } = await supabase.storage
          .from('announcement-thumbnails')
          .remove([filePath]);

        if (deleteError) {
          throw deleteError;
        }
      }

      // Clear preview and notify parent
      setPreview(null);
      onChange('');

      console.log('✅ Thumbnail deleted successfully');
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : '삭제 중 오류가 발생했습니다';
      console.error('❌ Thumbnail delete error:', err);
      setError(errorMsg);
      if (onError) onError(errorMsg);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-3">
      {/* Preview Area */}
      <div className="relative">
        {preview ? (
          <div className="relative w-full h-48 rounded-lg border-2 border-gray-200 overflow-hidden group">
            <img
              src={preview}
              alt="Thumbnail preview"
              className="w-full h-full object-cover"
            />
            {/* Delete button overlay */}
            <button
              onClick={handleDelete}
              disabled={loading}
              className="absolute top-2 right-2 p-2 bg-red-500 text-white rounded-full opacity-0 group-hover:opacity-100 transition-opacity disabled:opacity-50"
              title="썸네일 삭제"
            >
              <X className="w-4 h-4" />
            </button>
          </div>
        ) : (
          <div className="w-full h-48 rounded-lg border-2 border-dashed border-gray-300 flex items-center justify-center bg-gray-50">
            <div className="text-center text-gray-400">
              <ImageIcon className="w-12 h-12 mx-auto mb-2" />
              <p className="text-sm">썸네일 이미지 없음</p>
            </div>
          </div>
        )}
      </div>

      {/* Upload Button */}
      <div>
        <input
          id={`thumbnail-${announcementId}`}
          type="file"
          accept="image/jpeg,image/jpg,image/png,image/webp"
          className="hidden"
          onChange={handleFileChange}
          disabled={loading}
        />
        <Button
          type="button"
          variant="outline"
          className="w-full"
          disabled={loading}
          asChild
        >
          <label htmlFor={`thumbnail-${announcementId}`} className="cursor-pointer">
            {loading ? (
              <>
                <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                업로드 중...
              </>
            ) : (
              <>
                <Upload className="w-4 h-4 mr-2" />
                썸네일 업로드
              </>
            )}
          </label>
        </Button>
      </div>

      {/* File Info */}
      <p className="text-xs text-gray-500 text-center">
        JPEG, PNG, WebP 형식 / 최대 5MB
      </p>

      {/* Error Message */}
      {error && (
        <Alert variant="destructive">
          <AlertDescription>{error}</AlertDescription>
        </Alert>
      )}
    </div>
  );
}
