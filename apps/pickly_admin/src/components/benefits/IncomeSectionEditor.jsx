import React from 'react';
import './IncomeSectionEditor.css';

/**
 * 소득 기준 섹션 편집기
 *
 * 공고의 소득 조건을 편집할 수 있는 컴포넌트
 * - 소득 필드 추가/수정/삭제
 * - detail 필드 지원
 * - 보임/숨김 토글
 */
function IncomeSectionEditor({ section, onUpdate }) {
  const handleFieldChange = (fieldIndex, key, value) => {
    const updated = { ...section };
    updated.fields[fieldIndex][key] = value;
    onUpdate(updated);
  };

  const handleAddField = () => {
    const updated = { ...section };
    updated.fields.push({
      key: `income_${Date.now()}`,
      label: '새 소득 기준',
      value: '',
      detail: '',
      visible: true,
      order: updated.fields.length + 1,
    });
    onUpdate(updated);
  };

  const handleDeleteField = (fieldIndex) => {
    const updated = { ...section };
    updated.fields.splice(fieldIndex, 1);
    onUpdate(updated);
  };

  return (
    <div className="income-section-editor">
      <div className="section-header">
        <h4>💰 {section.title}</h4>
        <label className="toggle">
          <input
            type="checkbox"
            checked={section.enabled}
            onChange={(e) => onUpdate({ ...section, enabled: e.target.checked })}
          />
          <span>앱에 표시</span>
        </label>
      </div>

      {section.description !== undefined && (
        <input
          type="text"
          value={section.description || ''}
          onChange={(e) => onUpdate({ ...section, description: e.target.value })}
          placeholder="설명 (예: 전년도 도시근로자 가구당 월평균 소득 기준)"
          className="description-input"
        />
      )}

      <div className="fields-list">
        {section.fields?.map((field, idx) => (
          <div key={idx} className="income-field">
            <div className="field-header">
              <input
                type="text"
                value={field.label}
                onChange={(e) => handleFieldChange(idx, 'label', e.target.value)}
                placeholder="필드명 (예: 가구 소득)"
                className="field-label-input"
              />
              <div className="field-actions">
                <label className="visibility">
                  <input
                    type="checkbox"
                    checked={field.visible !== false}
                    onChange={(e) => handleFieldChange(idx, 'visible', e.target.checked)}
                  />
                  {field.visible !== false ? '👁️ 보임' : '🚫 숨김'}
                </label>
                <button
                  type="button"
                  onClick={() => handleDeleteField(idx)}
                  className="btn-delete"
                  title="삭제"
                >
                  🗑️
                </button>
              </div>
            </div>

            <input
              type="text"
              value={field.value}
              onChange={(e) => handleFieldChange(idx, 'value', e.target.value)}
              placeholder="값 (예: 전년도 도시근로자 월평균 소득 100% 이하)"
              className="field-value-input"
            />

            <input
              type="text"
              value={field.detail || ''}
              onChange={(e) => handleFieldChange(idx, 'detail', e.target.value)}
              placeholder="상세 (예: 1인 가구: 4,445,807원)"
              className="field-detail-input"
            />
          </div>
        ))}
      </div>

      <button type="button" className="btn-add-field" onClick={handleAddField}>
        + 소득 조건 추가
      </button>
    </div>
  );
}

export default IncomeSectionEditor;
