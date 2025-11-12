/**
 * FeaturedManagementPage
 * PRD v9.12.0 - Featured Announcements Management
 * Purpose: Manage featured announcements by section with drag-and-drop reordering
 */

import { useState, useEffect } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { createClient } from '@supabase/supabase-js';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Loader2, Home, Star, Image as ImageIcon, ArrowUpDown } from 'lucide-react';

// Supabase client configuration
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || '';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || '';
const supabase = createClient(supabaseUrl, supabaseAnonKey);

interface FeaturedAnnouncement {
  id: string;
  title: string;
  organization: string;
  thumbnail_url: string | null;
  featured_section: string | null;
  featured_order: number;
  is_featured: boolean;
  status: string;
}

interface SectionGroup {
  section: string;
  announcements: FeaturedAnnouncement[];
}

export default function FeaturedManagementPage() {
  const queryClient = useQueryClient();
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  // Fetch featured announcements
  const { data: announcements, isLoading, error } = useQuery({
    queryKey: ['featured-announcements'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('announcements')
        .select('id, title, organization, thumbnail_url, featured_section, featured_order, is_featured, status')
        .eq('is_featured', true)
        .order('featured_section', { ascending: true })
        .order('featured_order', { ascending: true });

      if (error) throw error;
      return data as FeaturedAnnouncement[];
    }
  });

  // Group announcements by section
  const groupedSections: SectionGroup[] = announcements
    ? Object.entries(
        announcements.reduce((acc, announcement) => {
          const section = announcement.featured_section || 'default';
          if (!acc[section]) acc[section] = [];
          acc[section].push(announcement);
          return acc;
        }, {} as Record<string, FeaturedAnnouncement[]>)
      ).map(([section, announcements]) => ({ section, announcements }))
    : [];

  // Update order mutation
  const updateOrderMutation = useMutation({
    mutationFn: async (updates: { id: string; featured_order: number }[]) => {
      const promises = updates.map(({ id, featured_order }) =>
        supabase
          .from('announcements')
          .update({ featured_order })
          .eq('id', id)
      );

      const results = await Promise.all(promises);
      const errors = results.filter(r => r.error);
      if (errors.length > 0) throw errors[0].error;

      return results.length;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['featured-announcements'] });
      setMessage({ type: 'success', text: '✅ 정렬 순서가 저장되었습니다' });
      setTimeout(() => setMessage(null), 3000);
    },
    onError: (error: Error) => {
      setMessage({ type: 'error', text: `❌ 저장 실패: ${error.message}` });
    }
  });

  // Move announcement up/down within section
  const handleReorder = (section: string, fromIndex: number, direction: 'up' | 'down') => {
    const sectionData = groupedSections.find(s => s.section === section);
    if (!sectionData) return;

    const toIndex = direction === 'up' ? fromIndex - 1 : fromIndex + 1;
    if (toIndex < 0 || toIndex >= sectionData.announcements.length) return;

    // Swap orders
    const updates = [
      { id: sectionData.announcements[fromIndex].id, featured_order: toIndex },
      { id: sectionData.announcements[toIndex].id, featured_order: fromIndex }
    ];

    updateOrderMutation.mutate(updates);
  };

  // Render section card
  const renderSection = ({ section, announcements }: SectionGroup) => (
    <Card key={section}>
      <CardHeader>
        <div className="flex items-center justify-between">
          <div>
            <CardTitle className="flex items-center gap-2">
              <Star className="w-5 h-5 text-yellow-500" />
              {getSectionLabel(section)}
            </CardTitle>
            <CardDescription>{announcements.length}개 공고 노출 중</CardDescription>
          </div>
          <Badge variant="outline">{section}</Badge>
        </div>
      </CardHeader>
      <CardContent>
        <div className="space-y-2">
          {announcements.map((announcement, index) => (
            <div
              key={announcement.id}
              className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors"
            >
              {/* Order Number */}
              <div className="flex-shrink-0 w-8 h-8 flex items-center justify-center bg-blue-100 text-blue-700 font-semibold rounded">
                {index + 1}
              </div>

              {/* Thumbnail */}
              {announcement.thumbnail_url ? (
                <img
                  src={announcement.thumbnail_url}
                  alt={announcement.title}
                  className="w-16 h-16 object-cover rounded"
                />
              ) : (
                <div className="w-16 h-16 bg-gray-200 rounded flex items-center justify-center">
                  <ImageIcon className="w-6 h-6 text-gray-400" />
                </div>
              )}

              {/* Info */}
              <div className="flex-1 min-w-0">
                <h4 className="font-medium truncate">{announcement.title}</h4>
                <p className="text-sm text-gray-500 truncate">{announcement.organization}</p>
              </div>

              {/* Status Badge */}
              <Badge variant={announcement.status === 'recruiting' ? 'default' : 'secondary'}>
                {getStatusLabel(announcement.status)}
              </Badge>

              {/* Reorder Buttons */}
              <div className="flex flex-col gap-1">
                <Button
                  size="sm"
                  variant="outline"
                  onClick={() => handleReorder(section, index, 'up')}
                  disabled={index === 0 || updateOrderMutation.isPending}
                  className="h-6 px-2"
                >
                  ↑
                </Button>
                <Button
                  size="sm"
                  variant="outline"
                  onClick={() => handleReorder(section, index, 'down')}
                  disabled={index === announcements.length - 1 || updateOrderMutation.isPending}
                  className="h-6 px-2"
                >
                  ↓
                </Button>
              </div>
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  );

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-screen">
        <Loader2 className="w-8 h-8 animate-spin text-gray-400" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="p-6">
        <Alert variant="destructive">
          <AlertDescription>
            ❌ 데이터 로드 실패: {error instanceof Error ? error.message : '알 수 없는 오류'}
          </AlertDescription>
        </Alert>
      </div>
    );
  }

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold flex items-center gap-3">
            <Home className="w-8 h-8" />
            홈 노출 관리
          </h1>
          <p className="text-gray-500 mt-1">
            홈 화면에 표시될 공고의 섹션별 노출 순서를 관리합니다
          </p>
        </div>
        <Badge variant="outline" className="text-lg px-4 py-2">
          총 {announcements?.length || 0}개 노출
        </Badge>
      </div>

      {/* Success/Error Message */}
      {message && (
        <Alert variant={message.type === 'error' ? 'destructive' : 'default'}>
          <AlertDescription>{message.text}</AlertDescription>
        </Alert>
      )}

      {/* Instructions */}
      <Card className="bg-blue-50 border-blue-200">
        <CardContent className="pt-6">
          <div className="flex items-start gap-3">
            <ArrowUpDown className="w-5 h-5 text-blue-600 mt-0.5" />
            <div>
              <h3 className="font-semibold text-blue-900">정렬 순서 변경 방법</h3>
              <p className="text-sm text-blue-700 mt-1">
                각 공고 우측의 ↑↓ 버튼을 클릭하여 섹션 내 순서를 변경할 수 있습니다.
                변경 사항은 즉시 저장되며, 앱에 실시간 반영됩니다.
              </p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Empty State */}
      {groupedSections.length === 0 && (
        <Card>
          <CardContent className="py-12 text-center text-gray-500">
            <Star className="w-12 h-12 mx-auto mb-3 text-gray-300" />
            <p>홈 노출로 설정된 공고가 없습니다</p>
            <p className="text-sm mt-1">공고 상세 페이지에서 "홈 노출 설정"을 활성화하세요</p>
          </CardContent>
        </Card>
      )}

      {/* Section Cards */}
      <div className="grid gap-6">
        {groupedSections.map(renderSection)}
      </div>
    </div>
  );
}

// Helper functions
function getSectionLabel(section: string): string {
  const labels: Record<string, string> = {
    'home': '홈 메인',
    'home_hot': '인기 공고',
    'city_seoul': '서울 특별',
    'city_gyeonggi': '경기 특별',
    'default': '기본 섹션'
  };
  return labels[section] || section;
}

function getStatusLabel(status: string): string {
  const labels: Record<string, string> = {
    'recruiting': '모집중',
    'scheduled': '예정',
    'closed': '마감',
    'draft': '임시저장'
  };
  return labels[status] || status;
}
