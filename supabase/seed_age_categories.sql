-- =============================================
-- 🏷️ Pickly v7.2 기본 연령 카테고리 초기 세팅
-- =============================================

-- 기존 데이터 초기화
delete from age_categories;

-- 기본 카테고리 삽입 (UUID 자동 생성)
insert into age_categories (title, description, icon_component, min_age, max_age, sort_order, is_active)
values
('청년', '(만 19세~39세) 대학생, 취업준비생, 직장인', 'young_man', 19, 39, 1, true),
('신혼부부·예비부부', '결혼 예정 또는 결혼 7년 이내', 'bride', null, null, 2, true),
('육아중인 부모', '영유아~초등 자녀 양육 중', 'baby', null, null, 3, true),
('다자녀 가구', '자녀 2명 이상 양육 중', 'kinder', null, null, 4, true),
('어르신', '만 65세 이상', 'old_man', 65, null, 5, true),
('장애인', '장애인 등록 대상', 'wheel_chair', null, null, 6, true);

-- 확인용 출력
select * from age_categories order by id;
