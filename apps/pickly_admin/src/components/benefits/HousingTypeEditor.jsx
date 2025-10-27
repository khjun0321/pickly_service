import React from 'react';
import IncomeSectionEditor from './IncomeSectionEditor';
import './HousingTypeEditor.css';

/**
 * 평형 타입 편집기
 *
 * 공고의 평형별 탭을 관리하는 컴포넌트
 * - 평형 타입 추가/수정/삭제
 * - 각 평형별 섹션 편집 (신청 자격, 소득 기준, 공급 조건 등)
 * - 드래그 앤 드롭으로 순서 변경
 */
function HousingTypeEditor({ housingTypes, onUpdate }) {
  const handleTypeChange = (typeIndex, key, value) => {
    const updated = [...housingTypes];
    updated[typeIndex][key] = value;
    onUpdate(updated);
  };

  const handleSectionChange = (typeIndex, sectionIndex, updatedSection) => {
    const updated = [...housingTypes];
    updated[typeIndex].sections[sectionIndex] = updatedSection;
    onUpdate(updated);
  };

  const handleAddType = () => {
    const newType = {
      id: `type-${Date.now()}`,
      area: 16,
      areaLabel: '16㎡ (약 5평)',
      type: '새 타입',
      targetGroup: '청년',
      tabLabel: '새 타입',
      order: housingTypes.length + 1,
      floorPlanImage: '',
      sections: [
        {
          type: 'eligibility',
          title: '신청 자격',
          icon: 'person',
          enabled: true,
          order: 1,
          fields: [
            { key: 'age', label: '연령', value: '', visible: true, order: 1 },
            { key: 'residence', label: '거주', value: '', visible: true, order: 2 },
            { key: 'housing', label: '주택', value: '', visible: true, order: 3 },
          ],
        },
        {
          type: 'income',
          title: '소득 기준',
          icon: 'attach_money',
          enabled: true,
          order: 2,
          description: '전년도 도시근로자 가구당 월평균 소득 기준',
          fields: [
            {
              key: 'household_income',
              label: '가구 소득',
              value: '',
              detail: '',
              visible: true,
              order: 1,
            },
          ],
        },
        {
          type: 'pricing',
          title: '공급 조건',
          icon: 'home',
          enabled: true,
          order: 3,
          fields: [
            { key: 'supply_count', label: '공급호수', value: '', visible: true, order: 1 },
          ],
        },
      ],
    };

    onUpdate([...housingTypes, newType]);
  };

  const handleDeleteType = (typeIndex) => {
    const updated = [...housingTypes];
    updated.splice(typeIndex, 1);
    onUpdate(updated);
  };

  return (
    <div className="housing-type-editor">
      <div className="editor-header">
        <h3>평형 타입 관리</h3>
        <button type="button" className="btn-add-type" onClick={handleAddType}>
          + 평형 추가
        </button>
      </div>

      {housingTypes.map((housingType, typeIndex) => (
        <div key={housingType.id} className="housing-type-card">
          <div className="type-header">
            <div className="type-info">
              <input
                type="text"
                value={housingType.tabLabel}
                onChange={(e) => handleTypeChange(typeIndex, 'tabLabel', e.target.value)}
                placeholder="탭 레이블 (예: 타입 1A)"
                className="tab-label-input"
              />
              <input
                type="text"
                value={housingType.areaLabel}
                onChange={(e) => handleTypeChange(typeIndex, 'areaLabel', e.target.value)}
                placeholder="면적 (예: 16㎡ (약 5평))"
                className="area-label-input"
              />
            </div>
            <button
              type="button"
              onClick={() => handleDeleteType(typeIndex)}
              className="btn-delete-type"
              title="평형 삭제"
            >
              🗑️ 삭제
            </button>
          </div>

          <div className="type-fields">
            <label>
              대상 그룹:
              <select
                value={housingType.targetGroup}
                onChange={(e) => handleTypeChange(typeIndex, 'targetGroup', e.target.value)}
              >
                <option value="청년">청년</option>
                <option value="신혼부부">신혼부부</option>
                <option value="고령자">고령자</option>
                <option value="일반">일반</option>
              </select>
            </label>
          </div>

          <div className="sections-container">
            {housingType.sections.map((section, sectionIndex) => (
              <div key={sectionIndex} className="section-wrapper">
                {section.type === 'income' ? (
                  <IncomeSectionEditor
                    section={section}
                    onUpdate={(updated) =>
                      handleSectionChange(typeIndex, sectionIndex, updated)
                    }
                  />
                ) : (
                  <div className="generic-section-editor">
                    <div className="section-header">
                      <h4>
                        {section.icon && `${section.icon} `}
                        {section.title}
                      </h4>
                      <label className="toggle">
                        <input
                          type="checkbox"
                          checked={section.enabled}
                          onChange={(e) =>
                            handleSectionChange(typeIndex, sectionIndex, {
                              ...section,
                              enabled: e.target.checked,
                            })
                          }
                        />
                        <span>앱에 표시</span>
                      </label>
                    </div>

                    <div className="fields-list">
                      {section.fields?.map((field, fieldIndex) => (
                        <div key={fieldIndex} className="field-item">
                          <input
                            type="text"
                            value={field.label}
                            onChange={(e) => {
                              const updated = { ...section };
                              updated.fields[fieldIndex].label = e.target.value;
                              handleSectionChange(typeIndex, sectionIndex, updated);
                            }}
                            placeholder="필드명"
                            className="field-label"
                          />
                          <textarea
                            value={field.value}
                            onChange={(e) => {
                              const updated = { ...section };
                              updated.fields[fieldIndex].value = e.target.value;
                              handleSectionChange(typeIndex, sectionIndex, updated);
                            }}
                            placeholder="값"
                            className="field-value"
                            rows={2}
                          />
                          <label className="visibility">
                            <input
                              type="checkbox"
                              checked={field.visible !== false}
                              onChange={(e) => {
                                const updated = { ...section };
                                updated.fields[fieldIndex].visible = e.target.checked;
                                handleSectionChange(typeIndex, sectionIndex, updated);
                              }}
                            />
                            {field.visible !== false ? '👁️ 보임' : '🚫 숨김'}
                          </label>
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>
      ))}

      {housingTypes.length === 0 && (
        <div className="empty-state">
          <p>평형 타입이 없습니다.</p>
          <button type="button" className="btn-add-type" onClick={handleAddType}>
            + 첫 번째 평형 추가
          </button>
        </div>
      )}
    </div>
  );
}

export default HousingTypeEditor;
