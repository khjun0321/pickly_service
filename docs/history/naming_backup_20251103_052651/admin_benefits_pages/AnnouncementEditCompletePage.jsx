import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { supabase } from '../../lib/supabase';
import HousingTypeEditor from '../../components/benefits/HousingTypeEditor';
import './AnnouncementEditComplete.css';

/**
 * 공고 편집 페이지 (완전판)
 *
 * LH API에서 동기화된 공고 데이터를 편집합니다.
 * - 기본 정보 편집
 * - 평형별 탭 관리
 * - 소득 조건 편집
 * - 필드 노출 제어
 */
function AnnouncementEditCompletePage() {
  const { id } = useParams();
  const navigate = useNavigate();

  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [announcement, setAnnouncement] = useState(null);

  useEffect(() => {
    if (id) {
      fetchAnnouncement();
    }
  }, [id]);

  const fetchAnnouncement = async () => {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('announcements')
        .select('*')
        .eq('id', id)
        .single();

      if (error) throw error;

      setAnnouncement(data);
    } catch (error) {
      console.error('공고 조회 실패:', error);
      alert('공고를 불러오는데 실패했습니다.');
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async () => {
    try {
      setSaving(true);

      const { error } = await supabase
        .from('announcements')
        .update({
          title: announcement.title,
          subtitle: announcement.subtitle,
          category: announcement.category,
          display_config: announcement.display_config,
          housing_types: announcement.housing_types,
          status: announcement.status,
        })
        .eq('id', id);

      if (error) throw error;

      alert('✅ 저장되었습니다!');
      navigate('/benefits/announcements');
    } catch (error) {
      console.error('저장 실패:', error);
      alert('❌ 저장에 실패했습니다: ' + error.message);
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="announcement-edit-page">
        <div className="loading">로딩 중...</div>
      </div>
    );
  }

  if (!announcement) {
    return (
      <div className="announcement-edit-page">
        <div className="error">공고를 찾을 수 없습니다.</div>
      </div>
    );
  }

  return (
    <div className="announcement-edit-page">
      <div className="page-header">
        <h1>📝 공고 편집</h1>
        <div className="header-actions">
          <button
            type="button"
            onClick={() => navigate('/benefits/announcements')}
            className="btn-cancel"
          >
            취소
          </button>
          <button
            type="button"
            onClick={handleSave}
            disabled={saving}
            className="btn-save"
          >
            {saving ? '저장 중...' : '💾 저장'}
          </button>
        </div>
      </div>

      <div className="edit-content">
        {/* 기본 정보 */}
        <section className="edit-section">
          <h2>기본 정보</h2>
          <div className="form-group">
            <label>제목</label>
            <input
              type="text"
              value={announcement.title}
              onChange={(e) =>
                setAnnouncement({ ...announcement, title: e.target.value })
              }
              placeholder="공고 제목"
            />
          </div>

          <div className="form-group">
            <label>부제목</label>
            <input
              type="text"
              value={announcement.subtitle || ''}
              onChange={(e) =>
                setAnnouncement({ ...announcement, subtitle: e.target.value })
              }
              placeholder="공고 마감까지 3일 남았어요"
            />
          </div>

          <div className="form-group">
            <label>카테고리</label>
            <select
              value={announcement.category}
              onChange={(e) =>
                setAnnouncement({ ...announcement, category: e.target.value })
              }
            >
              <option value="주거">주거</option>
              <option value="고용">고용</option>
              <option value="교육">교육</option>
              <option value="복지">복지</option>
            </select>
          </div>

          <div className="form-group">
            <label>상태</label>
            <select
              value={announcement.status}
              onChange={(e) =>
                setAnnouncement({ ...announcement, status: e.target.value })
              }
            >
              <option value="draft">임시저장</option>
              <option value="active">활성</option>
              <option value="inactive">비활성</option>
            </select>
          </div>

          <div className="form-group">
            <label>출처 ID (LH API)</label>
            <input type="text" value={announcement.source_id} disabled />
          </div>
        </section>

        {/* 공통 섹션 */}
        <section className="edit-section">
          <h2>공통 섹션 (모든 평형 공통)</h2>
          <div className="info-box">
            <p>
              💡 공통 섹션은 모든 평형 타입에 공통으로 표시되는 정보입니다.
              <br />
              (일정, 단지 정보, 위치 등)
            </p>
          </div>
          <pre className="json-preview">
            {JSON.stringify(announcement.display_config?.commonSections || [], null, 2)}
          </pre>
        </section>

        {/* 평형별 탭 */}
        <section className="edit-section">
          <h2>평형별 탭</h2>
          <HousingTypeEditor
            housingTypes={announcement.housing_types || []}
            onUpdate={(updated) =>
              setAnnouncement({ ...announcement, housing_types: updated })
            }
          />
        </section>

        {/* 원본 데이터 */}
        <section className="edit-section">
          <details>
            <summary>🔍 원본 데이터 (LH API)</summary>
            <pre className="json-preview">
              {JSON.stringify(announcement.raw_data, null, 2)}
            </pre>
          </details>
        </section>
      </div>

      {/* 고정 하단 버튼 */}
      <div className="fixed-bottom-actions">
        <button
          type="button"
          onClick={() => navigate('/benefits/announcements')}
          className="btn-cancel"
        >
          취소
        </button>
        <button
          type="button"
          onClick={handleSave}
          disabled={saving}
          className="btn-save"
        >
          {saving ? '저장 중...' : '💾 저장'}
        </button>
      </div>
    </div>
  );
}

export default AnnouncementEditCompletePage;
