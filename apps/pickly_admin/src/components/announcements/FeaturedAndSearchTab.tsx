/**
 * FeaturedAndSearchTab Component
 * PRD v9.12.0 - Featured Sections & Search Management
 * Purpose: Manage announcement featured status, sections, and search tags
 */

import { useState, useEffect } from 'react';
import { createClient } from '@supabase/supabase-js';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Switch } from '@/components/ui/switch';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Loader2, Save, RefreshCw, Tag, Home } from 'lucide-react';
import ThumbnailUploader from './ThumbnailUploader';

// Supabase client configuration
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || '';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || '';
const supabase = createClient(supabaseUrl, supabaseAnonKey);

interface FeaturedData {
  thumbnail_url: string | null;
  is_featured: boolean;
  featured_section: string | null;
  featured_order: number;
  tags: string[];
}

interface FeaturedAndSearchTabProps {
  id: string;
  onSuccess?: () => void;
  onError?: (error: string) => void;
}

export default function FeaturedAndSearchTab({
  id,
  onSuccess,
  onError
}: FeaturedAndSearchTabProps) {
  const [data, setData] = useState<FeaturedData>({
    thumbnail_url: null,
    is_featured: false,
    featured_section: null,
    featured_order: 0,
    tags: []
  });

  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [reindexing, setReindexing] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  // Fetch announcement data
  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      try {
        const { data: announcement, error } = await supabase
          .from('announcements')
          .select('thumbnail_url, is_featured, featured_section, featured_order, tags')
          .eq('id', id)
          .single();

        if (error) throw error;

        setData({
          thumbnail_url: announcement?.thumbnail_url || null,
          is_featured: announcement?.is_featured || false,
          featured_section: announcement?.featured_section || null,
          featured_order: announcement?.featured_order || 0,
          tags: announcement?.tags || []
        });
      } catch (err) {
        const errorMsg = err instanceof Error ? err.message : '데이터 로드 실패';
        console.error('❌ Failed to fetch announcement data:', err);
        setMessage({ type: 'error', text: errorMsg });
        if (onError) onError(errorMsg);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [id, onError]);

  // Save featured and search data
  const handleSave = async () => {
    setSaving(true);
    setMessage(null);

    try {
      const { error } = await supabase
        .from('announcements')
        .update({
          thumbnail_url: data.thumbnail_url,
          is_featured: data.is_featured,
          featured_section: data.featured_section,
          featured_order: data.featured_order,
          tags: data.tags
        })
        .eq('id', id);

      if (error) throw error;

      setMessage({ type: 'success', text: '✅ 저장되었습니다' });
      if (onSuccess) onSuccess();
      console.log('✅ Featured and search data saved successfully');
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : '저장 실패';
      console.error('❌ Failed to save data:', err);
      setMessage({ type: 'error', text: `❌ ${errorMsg}` });
      if (onError) onError(errorMsg);
    } finally {
      setSaving(false);
    }
  };

  // Reindex all announcements
  const handleReindex = async () => {
    if (!window.confirm('전체 공고 검색 인덱스를 재생성하시겠습니까?\n시간이 다소 소요될 수 있습니다.')) {
      return;
    }

    setReindexing(true);
    setMessage(null);

    try {
      const { data: result, error } = await supabase.rpc('reindex_announcements');

      if (error) throw error;

      setMessage({ type: 'success', text: `✅ ${result}개 공고 검색 인덱스 재생성 완료` });
      console.log(`✅ Reindexed ${result} announcements`);
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : '인덱스 재생성 실패';
      console.error('❌ Failed to reindex announcements:', err);
      setMessage({ type: 'error', text: `❌ ${errorMsg}` });
      if (onError) onError(errorMsg);
    } finally {
      setReindexing(false);
    }
  };

  // Update tags from comma-separated string
  const handleTagsChange = (value: string) => {
    const tagArray = value
      .split(',')
      .map(tag => tag.trim())
      .filter(Boolean);
    setData(prev => ({ ...prev, tags: tagArray }));
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center py-12">
        <Loader2 className="w-8 h-8 animate-spin text-gray-400" />
      </div>
    );
  }

  return (
    <div className="space-y-6 p-6">
      {/* Success/Error Message */}
      {message && (
        <Alert variant={message.type === 'error' ? 'destructive' : 'default'}>
          <AlertDescription>{message.text}</AlertDescription>
        </Alert>
      )}

      <div className="grid md:grid-cols-2 gap-6">
        {/* Left Column: Thumbnail */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Home className="w-5 h-5" />
              썸네일 관리
            </CardTitle>
            <CardDescription>리스트 및 홈 화면에 표시될 썸네일 이미지</CardDescription>
          </CardHeader>
          <CardContent>
            <ThumbnailUploader
              announcementId={id}
              value={data.thumbnail_url}
              onChange={(url) => setData(prev => ({ ...prev, thumbnail_url: url }))}
              onError={(error) => setMessage({ type: 'error', text: error })}
            />
          </CardContent>
        </Card>

        {/* Right Column: Featured Settings */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Home className="w-5 h-5" />
              홈 노출 설정
            </CardTitle>
            <CardDescription>홈 화면 섹션별 노출 관리</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            {/* Featured Toggle */}
            <div className="flex items-center justify-between">
              <Label htmlFor="is-featured">홈 화면 노출</Label>
              <Switch
                id="is-featured"
                checked={data.is_featured}
                onCheckedChange={(checked) => setData(prev => ({ ...prev, is_featured: checked }))}
              />
            </div>

            {/* Featured Section */}
            <div className="space-y-2">
              <Label htmlFor="featured-section">노출 섹션</Label>
              <Input
                id="featured-section"
                placeholder="예: home, home_hot, city_gyeonggi"
                value={data.featured_section || ''}
                onChange={(e) => setData(prev => ({ ...prev, featured_section: e.target.value }))}
                disabled={!data.is_featured}
              />
              <p className="text-xs text-gray-500">
                home: 홈 메인, home_hot: 인기 공고, city_* : 지역별
              </p>
            </div>

            {/* Featured Order */}
            <div className="space-y-2">
              <Label htmlFor="featured-order">정렬 우선순위</Label>
              <Input
                id="featured-order"
                type="number"
                placeholder="숫자가 낮을수록 상위 노출"
                value={data.featured_order}
                onChange={(e) => setData(prev => ({ ...prev, featured_order: Number(e.target.value) }))}
                disabled={!data.is_featured}
              />
              <p className="text-xs text-gray-500">
                0 = 최상위, 숫자가 클수록 하위 노출
              </p>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Search Tags Section */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Tag className="w-5 h-5" />
            검색 태그 관리
          </CardTitle>
          <CardDescription>
            사용자 검색 시 매칭될 키워드를 추가합니다 (쉼표로 구분)
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-3">
          <div className="space-y-2">
            <Label htmlFor="tags">검색 태그</Label>
            <Input
              id="tags"
              placeholder="예: 행복주택, 청년, 하남, 신혼부부"
              value={data.tags.join(', ')}
              onChange={(e) => handleTagsChange(e.target.value)}
            />
            <p className="text-xs text-gray-500">
              제목과 기관명에 없는 추가 키워드를 입력하세요
            </p>
          </div>

          {/* Tag Preview */}
          {data.tags.length > 0 && (
            <div className="flex flex-wrap gap-2 p-3 bg-gray-50 rounded-md">
              {data.tags.map((tag, index) => (
                <span
                  key={index}
                  className="px-3 py-1 bg-blue-100 text-blue-700 text-sm rounded-full"
                >
                  {tag}
                </span>
              ))}
            </div>
          )}
        </CardContent>
      </Card>

      {/* Action Buttons */}
      <div className="flex gap-3 justify-end">
        <Button
          variant="outline"
          onClick={handleReindex}
          disabled={reindexing || saving}
        >
          {reindexing ? (
            <>
              <Loader2 className="w-4 h-4 mr-2 animate-spin" />
              재생성 중...
            </>
          ) : (
            <>
              <RefreshCw className="w-4 h-4 mr-2" />
              검색 인덱스 전체 재생성
            </>
          )}
        </Button>

        <Button
          onClick={handleSave}
          disabled={saving || reindexing}
        >
          {saving ? (
            <>
              <Loader2 className="w-4 h-4 mr-2 animate-spin" />
              저장 중...
            </>
          ) : (
            <>
              <Save className="w-4 h-4 mr-2" />
              저장
            </>
          )}
        </Button>
      </div>
    </div>
  );
}
