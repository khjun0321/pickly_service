-- =============================================
-- 🏷️ Pickly v7.2 기본 연령 카테고리 초기 세팅
-- =============================================

-- 기존 데이터 초기화
delete from age_categories;

-- 기본 카테고리 삽입
insert into age_categories (id, name, description, min_age, max_age)
values
(1, '청년', '(만 19세~39세) 대학생, 취업준비생, 직장인', 19, 39),
(2, '신혼부부·예비부부', '결혼 예정 또는 결혼 7년 이내', null, null),
(3, '육아중인 부모', '영유아~초등 자녀 양육 중', null, null),
(4, '다자녀 가구', '자녀 2명 이상 양육 중', null, null),
(5, '어르신', '만 65세 이상', 65, null),
(6, '장애인', '장애인 등록 대상', null, null);

-- 확인용 출력
select * from age_categories order by id;
