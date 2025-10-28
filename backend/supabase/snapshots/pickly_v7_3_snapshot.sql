pg_dump: warning: there are circular foreign-key constraints on this table:
pg_dump: detail: benefit_categories
pg_dump: hint: You might not be able to restore the dump without using --disable-triggers or temporarily dropping the constraints.
pg_dump: hint: Consider using a full dump instead of a --data-only dump to avoid this problem.
pg_dump: warning: there are circular foreign-key constraints on this table:
pg_dump: detail: announcement_comments
pg_dump: hint: You might not be able to restore the dump without using --disable-triggers or temporarily dropping the constraints.
pg_dump: hint: Consider using a full dump instead of a --data-only dump to avoid this problem.
--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: tenants; Type: TABLE DATA; Schema: _realtime; Owner: supabase_admin
--

INSERT INTO _realtime.tenants VALUES ('eebb1fb1-97c9-4fce-a9bf-fcb0ebe27c09', 'realtime-dev', 'realtime-dev', 'iNjicxc4+llvc9wovDvqymwfnj9teWMlyOIbJ8Fh6j2WNU8CIJ2ZgjR6MUIKqSmeDmvpsKLsZ9jgXJmQPpwL8w==', 200, '2025-10-28 10:14:50', '2025-10-28 10:14:50', 100, 'postgres_cdc_rls', 100000, 100, 100, false, '{"keys": [{"k": "c3VwZXItc2VjcmV0LWp3dC10b2tlbi13aXRoLWF0LWxlYXN0LTMyLWNoYXJhY3RlcnMtbG9uZw", "kty": "oct"}]}', false, false, 64, 'gen_rpc', 10000, 3000);


--
-- Data for Name: extensions; Type: TABLE DATA; Schema: _realtime; Owner: supabase_admin
--

INSERT INTO _realtime.extensions VALUES ('0fa7d1f9-fcbe-4cd7-b28c-6c47dc5e60c2', 'postgres_cdc_rls', '{"region": "us-east-1", "db_host": "Ru3TRmezn8rTccHyJeRQLxB7elrPFUeivvOQgO7Xw8Y=", "db_name": "sWBpZNdjggEPTQVlI52Zfw==", "db_port": "+enMDFi1J/3IrrquHHwUmA==", "db_user": "uxbEq/zz8DXVD53TOI1zmw==", "slot_name": "supabase_realtime_replication_slot", "db_password": "sWBpZNdjggEPTQVlI52Zfw==", "publication": "supabase_realtime", "ssl_enforced": false, "poll_interval_ms": 100, "poll_max_changes": 100, "poll_max_record_bytes": 1048576}', 'realtime-dev', '2025-10-28 10:14:50', '2025-10-28 10:14:50');


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: _realtime; Owner: supabase_admin
--

INSERT INTO _realtime.schema_migrations VALUES (20210706140551, '2025-10-28 09:35:47');
INSERT INTO _realtime.schema_migrations VALUES (20220329161857, '2025-10-28 09:35:47');
INSERT INTO _realtime.schema_migrations VALUES (20220410212326, '2025-10-28 09:35:47');
INSERT INTO _realtime.schema_migrations VALUES (20220506102948, '2025-10-28 09:35:47');
INSERT INTO _realtime.schema_migrations VALUES (20220527210857, '2025-10-28 09:35:47');
INSERT INTO _realtime.schema_migrations VALUES (20220815211129, '2025-10-28 09:35:47');
INSERT INTO _realtime.schema_migrations VALUES (20220815215024, '2025-10-28 09:35:47');
INSERT INTO _realtime.schema_migrations VALUES (20220818141501, '2025-10-28 09:35:47');
INSERT INTO _realtime.schema_migrations VALUES (20221018173709, '2025-10-28 09:35:47');
INSERT INTO _realtime.schema_migrations VALUES (20221102172703, '2025-10-28 09:35:47');
INSERT INTO _realtime.schema_migrations VALUES (20221223010058, '2025-10-28 09:35:47');
INSERT INTO _realtime.schema_migrations VALUES (20230110180046, '2025-10-28 09:35:47');
INSERT INTO _realtime.schema_migrations VALUES (20230810220907, '2025-10-28 09:35:47');
INSERT INTO _realtime.schema_migrations VALUES (20230810220924, '2025-10-28 09:35:47');
INSERT INTO _realtime.schema_migrations VALUES (20231024094642, '2025-10-28 09:35:47');
INSERT INTO _realtime.schema_migrations VALUES (20240306114423, '2025-10-28 09:35:47');
INSERT INTO _realtime.schema_migrations VALUES (20240418082835, '2025-10-28 09:35:47');
INSERT INTO _realtime.schema_migrations VALUES (20240625211759, '2025-10-28 09:35:47');
INSERT INTO _realtime.schema_migrations VALUES (20240704172020, '2025-10-28 09:35:47');
INSERT INTO _realtime.schema_migrations VALUES (20240902173232, '2025-10-28 09:35:47');
INSERT INTO _realtime.schema_migrations VALUES (20241106103258, '2025-10-28 09:35:47');
INSERT INTO _realtime.schema_migrations VALUES (20250424203323, '2025-10-28 09:35:47');
INSERT INTO _realtime.schema_migrations VALUES (20250613072131, '2025-10-28 09:35:47');
INSERT INTO _realtime.schema_migrations VALUES (20250711044927, '2025-10-28 09:35:47');
INSERT INTO _realtime.schema_migrations VALUES (20250811121559, '2025-10-28 09:35:47');


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_authorizations; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_consents; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO auth.schema_migrations VALUES ('20171026211738');
INSERT INTO auth.schema_migrations VALUES ('20171026211808');
INSERT INTO auth.schema_migrations VALUES ('20171026211834');
INSERT INTO auth.schema_migrations VALUES ('20180103212743');
INSERT INTO auth.schema_migrations VALUES ('20180108183307');
INSERT INTO auth.schema_migrations VALUES ('20180119214651');
INSERT INTO auth.schema_migrations VALUES ('20180125194653');
INSERT INTO auth.schema_migrations VALUES ('00');
INSERT INTO auth.schema_migrations VALUES ('20210710035447');
INSERT INTO auth.schema_migrations VALUES ('20210722035447');
INSERT INTO auth.schema_migrations VALUES ('20210730183235');
INSERT INTO auth.schema_migrations VALUES ('20210909172000');
INSERT INTO auth.schema_migrations VALUES ('20210927181326');
INSERT INTO auth.schema_migrations VALUES ('20211122151130');
INSERT INTO auth.schema_migrations VALUES ('20211124214934');
INSERT INTO auth.schema_migrations VALUES ('20211202183645');
INSERT INTO auth.schema_migrations VALUES ('20220114185221');
INSERT INTO auth.schema_migrations VALUES ('20220114185340');
INSERT INTO auth.schema_migrations VALUES ('20220224000811');
INSERT INTO auth.schema_migrations VALUES ('20220323170000');
INSERT INTO auth.schema_migrations VALUES ('20220429102000');
INSERT INTO auth.schema_migrations VALUES ('20220531120530');
INSERT INTO auth.schema_migrations VALUES ('20220614074223');
INSERT INTO auth.schema_migrations VALUES ('20220811173540');
INSERT INTO auth.schema_migrations VALUES ('20221003041349');
INSERT INTO auth.schema_migrations VALUES ('20221003041400');
INSERT INTO auth.schema_migrations VALUES ('20221011041400');
INSERT INTO auth.schema_migrations VALUES ('20221020193600');
INSERT INTO auth.schema_migrations VALUES ('20221021073300');
INSERT INTO auth.schema_migrations VALUES ('20221021082433');
INSERT INTO auth.schema_migrations VALUES ('20221027105023');
INSERT INTO auth.schema_migrations VALUES ('20221114143122');
INSERT INTO auth.schema_migrations VALUES ('20221114143410');
INSERT INTO auth.schema_migrations VALUES ('20221125140132');
INSERT INTO auth.schema_migrations VALUES ('20221208132122');
INSERT INTO auth.schema_migrations VALUES ('20221215195500');
INSERT INTO auth.schema_migrations VALUES ('20221215195800');
INSERT INTO auth.schema_migrations VALUES ('20221215195900');
INSERT INTO auth.schema_migrations VALUES ('20230116124310');
INSERT INTO auth.schema_migrations VALUES ('20230116124412');
INSERT INTO auth.schema_migrations VALUES ('20230131181311');
INSERT INTO auth.schema_migrations VALUES ('20230322519590');
INSERT INTO auth.schema_migrations VALUES ('20230402418590');
INSERT INTO auth.schema_migrations VALUES ('20230411005111');
INSERT INTO auth.schema_migrations VALUES ('20230508135423');
INSERT INTO auth.schema_migrations VALUES ('20230523124323');
INSERT INTO auth.schema_migrations VALUES ('20230818113222');
INSERT INTO auth.schema_migrations VALUES ('20230914180801');
INSERT INTO auth.schema_migrations VALUES ('20231027141322');
INSERT INTO auth.schema_migrations VALUES ('20231114161723');
INSERT INTO auth.schema_migrations VALUES ('20231117164230');
INSERT INTO auth.schema_migrations VALUES ('20240115144230');
INSERT INTO auth.schema_migrations VALUES ('20240214120130');
INSERT INTO auth.schema_migrations VALUES ('20240306115329');
INSERT INTO auth.schema_migrations VALUES ('20240314092811');
INSERT INTO auth.schema_migrations VALUES ('20240427152123');
INSERT INTO auth.schema_migrations VALUES ('20240612123726');
INSERT INTO auth.schema_migrations VALUES ('20240729123726');
INSERT INTO auth.schema_migrations VALUES ('20240802193726');
INSERT INTO auth.schema_migrations VALUES ('20240806073726');
INSERT INTO auth.schema_migrations VALUES ('20241009103726');
INSERT INTO auth.schema_migrations VALUES ('20250717082212');
INSERT INTO auth.schema_migrations VALUES ('20250731150234');
INSERT INTO auth.schema_migrations VALUES ('20250804100000');
INSERT INTO auth.schema_migrations VALUES ('20250901200500');
INSERT INTO auth.schema_migrations VALUES ('20250903112500');
INSERT INTO auth.schema_migrations VALUES ('20250904133000');


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: age_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.age_categories VALUES ('facbd9a9-d14d-4cd7-a0a6-e6986c9577f7', '신혼부부·예비부부', '결혼 예정 또는 결혼 7년이내', 'bride', 'packages/pickly_design_system/assets/icons/age_categories/bride.svg', NULL, NULL, 2, true, '2025-10-28 09:35:56.738105+00', '2025-10-28 09:35:56.746964+00');
INSERT INTO public.age_categories VALUES ('4b820d3e-0d68-49ca-9e8f-ad16e0904bae', '육아중인 부모', '영유아~초등 자녀 양육 중', 'baby', 'packages/pickly_design_system/assets/icons/age_categories/baby.svg', NULL, NULL, 3, true, '2025-10-28 09:35:56.738105+00', '2025-10-28 09:35:56.746964+00');
INSERT INTO public.age_categories VALUES ('1094ca52-8458-4c97-8b20-ae2c5f340d2f', '다자녀 가구', '자녀 2명 이상 양육중', 'kinder', 'packages/pickly_design_system/assets/icons/age_categories/kinder.svg', NULL, NULL, 4, true, '2025-10-28 09:35:56.738105+00', '2025-10-28 09:35:56.746964+00');
INSERT INTO public.age_categories VALUES ('f29fb555-e67f-4631-86e3-6f4948bb75c9', '어르신', '만 65세 이상', 'old_man', 'packages/pickly_design_system/assets/icons/age_categories/old_man.svg', 65, NULL, 5, true, '2025-10-28 09:35:56.738105+00', '2025-10-28 09:35:56.746964+00');
INSERT INTO public.age_categories VALUES ('af195ab0-681f-4b24-b91e-48caf0798fb0', '장애인', '장애인 등록 대상', 'wheel_chair', 'packages/pickly_design_system/assets/icons/age_categories/wheel_chair.svg', NULL, NULL, 6, true, '2025-10-28 09:35:56.738105+00', '2025-10-28 09:35:56.746964+00');
INSERT INTO public.age_categories VALUES ('202839ff-eab4-4572-92a0-c0401228b912', '청년', '(만 19세-39세) 대학생, 취업준비생, 직장인', 'young_man', 'http://127.0.0.1:54321/storage/v1/object/public/pickly-storage/age_category_icons/1761646241348-zo29vq.svg', 19, 39, 1, true, '2025-10-28 09:35:56.738105+00', '2025-10-28 10:10:41.50835+00');


--
-- Data for Name: benefit_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.benefit_categories VALUES ('2e5d4472-e814-4666-99df-d4579544b6de', '인기', 'popular', '가장 인기있는 혜택 모음', NULL, 0, true, '2025-10-28 09:35:56.827589+00', '2025-10-28 09:35:56.829396+00', '{}', NULL);
INSERT INTO public.benefit_categories VALUES ('16101292-b0e8-4a84-98dd-da78e5299a31', '주거', 'housing', '주거 관련 혜택 (임대, 분양, 주택구입 지원 등)', NULL, 1, true, '2025-10-28 09:35:56.749279+00', '2025-10-28 09:35:56.829396+00', '{"asset_limit": true, "family_size": ["1인", "2인", "3인", "4인 이상"], "housing_type": ["원룸", "투룸", "쓰리룸"], "income_limit": true, "age_categories": ["청년(19-39세)", "신혼부부", "고령자(65세 이상)"], "region_categories": ["서울", "경기", "인천", "부산", "대구", "광주", "대전", "울산", "세종"]}', NULL);
INSERT INTO public.benefit_categories VALUES ('f2d213ce-3193-4aa8-9b28-c3d4467c3df8', '지원', 'support', '각종 지원금 및 보조금', NULL, 7, true, '2025-10-28 09:35:56.827589+00', '2025-10-28 09:35:56.829396+00', '{}', NULL);
INSERT INTO public.benefit_categories VALUES ('b19e6001-598a-4838-b4b0-c50d6bea2e69', '행복주택', 'housing-happiness', '청년, 신혼부부, 대학생을 위한 공공임대주택', NULL, 1, true, '2025-10-28 09:35:56.817468+00', '2025-10-28 09:35:56.817468+00', '{}', '16101292-b0e8-4a84-98dd-da78e5299a31');
INSERT INTO public.benefit_categories VALUES ('b9c6ebfc-d3e3-493f-89d1-eec7ad6e0470', '국민임대주택', 'housing-public', '저소득 무주택 가구를 위한 장기 공공임대주택', NULL, 2, true, '2025-10-28 09:35:56.817468+00', '2025-10-28 09:35:56.817468+00', '{}', '16101292-b0e8-4a84-98dd-da78e5299a31');
INSERT INTO public.benefit_categories VALUES ('34abebb7-f606-4a77-a12c-ae1ab70135a5', '영구임대주택', 'housing-permanent', '생계급여 수급자 등을 위한 영구임대주택', NULL, 3, true, '2025-10-28 09:35:56.817468+00', '2025-10-28 09:35:56.817468+00', '{}', '16101292-b0e8-4a84-98dd-da78e5299a31');
INSERT INTO public.benefit_categories VALUES ('9990f6ba-bd43-4dbd-aca5-1c36c48b9839', '매입임대주택', 'housing-purchased', '기존 주택을 매입하여 저렴하게 임대', NULL, 4, true, '2025-10-28 09:35:56.817468+00', '2025-10-28 09:35:56.817468+00', '{}', '16101292-b0e8-4a84-98dd-da78e5299a31');
INSERT INTO public.benefit_categories VALUES ('2ac201ad-7edf-4516-bc92-271bcc9f3b13', '신혼희망타운', 'housing-newlywed', '신혼부부를 위한 주거 지원', NULL, 5, true, '2025-10-28 09:35:56.817468+00', '2025-10-28 09:35:56.817468+00', '{}', '16101292-b0e8-4a84-98dd-da78e5299a31');
INSERT INTO public.benefit_categories VALUES ('2b7b36c0-be1e-4c9b-9103-f8523714339c', '장학금', 'education-scholarship', '학비 지원 및 장학금 프로그램', NULL, 1, true, '2025-10-28 09:35:56.817468+00', '2025-10-28 09:35:56.817468+00', '{}', '31907788-db46-4182-95cd-180f444dbc7a');
INSERT INTO public.benefit_categories VALUES ('5de99779-8480-4ae3-becb-7438bed51cc7', '직업훈련', 'education-training', '직업 능력 개발 및 훈련 프로그램', NULL, 2, true, '2025-10-28 09:35:56.817468+00', '2025-10-28 09:35:56.817468+00', '{}', '31907788-db46-4182-95cd-180f444dbc7a');
INSERT INTO public.benefit_categories VALUES ('08d7e2bd-64e3-4e99-adfb-7da2d2a9b53e', '평생교육', 'education-lifelong', '성인 대상 평생교육 프로그램', NULL, 3, true, '2025-10-28 09:35:56.817468+00', '2025-10-28 09:35:56.817468+00', '{}', '31907788-db46-4182-95cd-180f444dbc7a');
INSERT INTO public.benefit_categories VALUES ('43e372bb-d1ed-4570-b6d5-568eb094d995', '학자금대출', 'education-loan', '학자금 대출 및 상환 지원', NULL, 4, true, '2025-10-28 09:35:56.817468+00', '2025-10-28 09:35:56.817468+00', '{}', '31907788-db46-4182-95cd-180f444dbc7a');
INSERT INTO public.benefit_categories VALUES ('145d813e-84d0-4f8f-a339-e235da77b930', '청년취업', 'employment-youth', '청년 취업 지원 및 인턴십', NULL, 1, true, '2025-10-28 09:35:56.817468+00', '2025-10-28 09:35:56.817468+00', '{}', 'fda9f12f-f5ea-44ad-b10b-21378d11144c');
INSERT INTO public.benefit_categories VALUES ('f8c98634-ca84-4b2b-a973-81d4e99822e2', '창업지원', 'employment-startup', '창업 자금 및 컨설팅 지원', NULL, 2, true, '2025-10-28 09:35:56.817468+00', '2025-10-28 09:35:56.817468+00', '{}', 'fda9f12f-f5ea-44ad-b10b-21378d11144c');
INSERT INTO public.benefit_categories VALUES ('a9057464-8f62-4d35-9cde-df1494cef5ea', '재취업지원', 'employment-reemployment', '경력단절자 재취업 지원', NULL, 3, true, '2025-10-28 09:35:56.817468+00', '2025-10-28 09:35:56.817468+00', '{}', 'fda9f12f-f5ea-44ad-b10b-21378d11144c');
INSERT INTO public.benefit_categories VALUES ('84e635bc-0274-4f4e-a777-1727110361b2', '고용장려금', 'employment-incentive', '고용 창출 장려금 및 지원', NULL, 4, true, '2025-10-28 09:35:56.817468+00', '2025-10-28 09:35:56.817468+00', '{}', 'fda9f12f-f5ea-44ad-b10b-21378d11144c');
INSERT INTO public.benefit_categories VALUES ('ce73ac2e-d1d6-4642-a22d-3f395fc2dc4b', '생활지원', 'welfare-living', '생계비 및 생활 지원', NULL, 1, true, '2025-10-28 09:35:56.817468+00', '2025-10-28 09:35:56.817468+00', '{}', 'b2bb1f17-366d-446b-86f1-50d9e6eeb9fd');
INSERT INTO public.benefit_categories VALUES ('4f0ebc4b-1cfc-43ee-b481-778a24b88967', '아동복지', 'welfare-child', '아동 양육 및 돌봄 지원', NULL, 2, true, '2025-10-28 09:35:56.817468+00', '2025-10-28 09:35:56.817468+00', '{}', 'b2bb1f17-366d-446b-86f1-50d9e6eeb9fd');
INSERT INTO public.benefit_categories VALUES ('6eaad7ac-7929-4c0d-82f8-519893bec870', '노인복지', 'welfare-senior', '어르신 생활 및 의료 지원', NULL, 3, true, '2025-10-28 09:35:56.817468+00', '2025-10-28 09:35:56.817468+00', '{}', 'b2bb1f17-366d-446b-86f1-50d9e6eeb9fd');
INSERT INTO public.benefit_categories VALUES ('11a7ab54-0de0-4ff7-9c37-66b9845a2e4a', '장애인복지', 'welfare-disabled', '장애인 생활 및 활동 지원', NULL, 4, true, '2025-10-28 09:35:56.817468+00', '2025-10-28 09:35:56.817468+00', '{}', 'b2bb1f17-366d-446b-86f1-50d9e6eeb9fd');
INSERT INTO public.benefit_categories VALUES ('e5beb50d-aee1-4470-9e49-52675aa6d94e', '건강검진', 'health-checkup', '무료 건강검진 프로그램', NULL, 1, true, '2025-10-28 09:35:56.817468+00', '2025-10-28 09:35:56.817468+00', '{}', 'cb49ce61-8d97-485b-b1fa-12f1dfcd69f4');
INSERT INTO public.benefit_categories VALUES ('b82897e5-8fa8-49f0-9922-f129a2af2ad0', '의료비지원', 'health-medical', '의료비 및 치료비 지원', NULL, 2, true, '2025-10-28 09:35:56.817468+00', '2025-10-28 09:35:56.817468+00', '{}', 'cb49ce61-8d97-485b-b1fa-12f1dfcd69f4');
INSERT INTO public.benefit_categories VALUES ('533944d9-9e53-46a8-9446-454e28ddc397', '예방접종', 'health-vaccination', '무료 예방접종 지원', NULL, 3, true, '2025-10-28 09:35:56.817468+00', '2025-10-28 09:35:56.817468+00', '{}', 'cb49ce61-8d97-485b-b1fa-12f1dfcd69f4');
INSERT INTO public.benefit_categories VALUES ('01b3e0bd-33c7-4b06-9cf1-4ffea0caed3a', '정신건강', 'health-mental', '정신건강 상담 및 치료 지원', NULL, 4, true, '2025-10-28 09:35:56.817468+00', '2025-10-28 09:35:56.817468+00', '{}', 'cb49ce61-8d97-485b-b1fa-12f1dfcd69f4');
INSERT INTO public.benefit_categories VALUES ('6554a133-ecdb-4ac9-ad7e-2808c4ccd46f', '공연·전시', 'culture-performance', '공연 및 전시 할인 혜택', NULL, 1, true, '2025-10-28 09:35:56.817468+00', '2025-10-28 09:35:56.817468+00', '{}', '5606fbbe-7567-4bbd-a338-a58d720e9357');
INSERT INTO public.benefit_categories VALUES ('984df2b2-8d69-4aad-a305-90869acbef03', '체육시설', 'culture-sports', '체육시설 이용 지원', NULL, 2, true, '2025-10-28 09:35:56.817468+00', '2025-10-28 09:35:56.817468+00', '{}', '5606fbbe-7567-4bbd-a338-a58d720e9357');
INSERT INTO public.benefit_categories VALUES ('196070e6-dea2-4026-acc7-d18bc6493c6c', '도서관', 'culture-library', '도서관 및 독서 프로그램', NULL, 3, true, '2025-10-28 09:35:56.817468+00', '2025-10-28 09:35:56.817468+00', '{}', '5606fbbe-7567-4bbd-a338-a58d720e9357');
INSERT INTO public.benefit_categories VALUES ('69996c07-990e-436e-ace7-e3ee42bf244e', '여행·관광', 'culture-travel', '여행 및 관광 지원', NULL, 4, true, '2025-10-28 09:35:56.817468+00', '2025-10-28 09:35:56.817468+00', '{}', '5606fbbe-7567-4bbd-a338-a58d720e9357');
INSERT INTO public.benefit_categories VALUES ('31907788-db46-4182-95cd-180f444dbc7a', '교육', 'education', '교육 관련 혜택 (학비지원, 장학금, 교육프로그램 등)', NULL, 2, true, '2025-10-28 09:35:56.749279+00', '2025-10-28 09:35:56.829396+00', '{"income_limit": true, "support_type": ["학비지원", "장학금", "교육프로그램", "교재지원"], "education_level": ["초등", "중등", "고등", "대학", "평생교육"]}', NULL);
INSERT INTO public.benefit_categories VALUES ('cb49ce61-8d97-485b-b1fa-12f1dfcd69f4', '건강', 'health', '건강 관련 혜택 (건강검진, 의료비지원, 예방접종 등)', NULL, 3, true, '2025-10-28 09:35:56.749279+00', '2025-10-28 09:35:56.829396+00', '{"income_limit": true, "service_type": ["건강검진", "의료비지원", "예방접종", "건강교육"], "target_group": ["영유아", "아동", "청소년", "성인", "노인"]}', NULL);
INSERT INTO public.benefit_categories VALUES ('ccf735e6-df95-4240-a657-c2f8ae0f5ac5', '교통', 'transportation', '교통비 지원 및 할인', NULL, 4, true, '2025-10-28 09:35:56.827589+00', '2025-10-28 09:35:56.829396+00', '{}', NULL);
INSERT INTO public.benefit_categories VALUES ('b2bb1f17-366d-446b-86f1-50d9e6eeb9fd', '복지', 'welfare', '복지 관련 혜택 (생활지원, 의료지원, 긴급지원 등)', NULL, 5, true, '2025-10-28 09:35:56.749279+00', '2025-10-28 09:35:56.829396+00', '{"income_limit": true, "program_type": ["현금지원", "바우처", "현물지원", "서비스제공"], "target_group": ["저소득층", "장애인", "한부모가정", "다문화가정", "노인"]}', NULL);
INSERT INTO public.benefit_categories VALUES ('fda9f12f-f5ea-44ad-b10b-21378d11144c', '취업', 'employment', '취업 관련 혜택 (취업지원, 직업훈련, 창업지원 등)', NULL, 6, true, '2025-10-28 09:35:56.749279+00', '2025-10-28 09:35:56.829396+00', '{"job_type": ["정규직", "계약직", "인턴", "아르바이트"], "program_type": ["취업지원", "직업훈련", "창업지원", "자격증지원"], "target_group": ["청년", "경력단절여성", "중장년", "장애인"]}', NULL);
INSERT INTO public.benefit_categories VALUES ('5606fbbe-7567-4bbd-a338-a58d720e9357', '문화', 'culture', '문화 관련 혜택 (문화생활, 여가활동, 체육시설 이용 등)', NULL, 8, true, '2025-10-28 09:35:56.749279+00', '2025-10-28 09:35:56.829396+00', '{"support_type": ["이용권", "할인", "무료이용", "프로그램"], "target_group": ["전체", "청소년", "성인", "노인", "장애인"], "activity_type": ["공연", "전시", "체육", "여가", "도서"]}', NULL);


--
-- Data for Name: benefit_announcements; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: announcement_ai_chats; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: announcement_comments; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: announcement_files; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: announcement_sections; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: announcement_types; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: announcement_unit_types; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: announcements; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: benefit_files; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.benefit_files VALUES ('48482b52-7591-44fd-95d5-c6606ef881c6', NULL, 'banner', 'banners/test/sample.jpg', 'sample.jpg', NULL, 'image/jpeg', 'http://localhost:54321/storage/v1/object/public/pickly-storage/banners/test/sample.jpg', NULL, '2025-10-28 09:35:56.788665+00', '{"is_test": true, "description": "Test banner image"}');


--
-- Data for Name: category_banners; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.category_banners VALUES ('8723276e-5891-40de-81c8-548b0f38bfb5', '16101292-b0e8-4a84-98dd-da78e5299a31', 'ㄴ', 'ㄴ', 'http://127.0.0.1:54321/storage/v1/object/public/benefit-banners/banners/1761646262299-xh5omj.png', '#E3F2FD', NULL, 0, true, '2025-10-28 10:11:02.38954+00', '2025-10-28 10:11:02.38954+00', 'none');


--
-- Data for Name: display_order_history; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: housing_announcements; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.housing_announcements VALUES ('40fb04a8-89eb-42ce-817a-78a5fff8fdcf', '하남미사 C3BL 행복주택', '공고 마감까지 3일 남았어요', '주거', 'LH', '2024000001', '{"PAN_ID": "2024000001", "PAN_NM": "하남미사 C3BL 행복주택", "HSHLD_CO": "1492", "CNP_CD_NM": "경기도", "RCRIT_PBLANC_DE": "20250930", "UPP_AIS_TP_CD_NM": "행복주택", "PRZWNER_PRESNATN_DE": "20251225", "SUBSCRPT_RCEPT_BGNDE": "20250930", "SUBSCRPT_RCEPT_ENDDE": "20251130"}', '{"commonSections": [{"icon": "info", "type": "basic_info", "order": 1, "title": "기본 정보", "fields": [{"key": "source", "label": "공급 기관", "order": 1, "value": "LH 행복 주택", "visible": true}, {"key": "category", "label": "카테고리", "order": 2, "value": "행복주택", "visible": true}], "enabled": true}, {"icon": "calendar_today", "type": "schedule", "order": 2, "title": "일정", "fields": [{"key": "apply_period", "label": "접수 기간", "order": 1, "value": "2025.09.30(월) - 2025.11.30(월)", "visible": true}, {"key": "announcement_date", "label": "당첨자 발표", "order": 2, "value": "2025.12.25", "visible": true}], "enabled": true}, {"icon": "apartment", "type": "property", "order": 3, "title": "단지 정보", "fields": [{"key": "name", "label": "단지명", "order": 1, "value": "하남미사 C3BL 행복주택", "visible": true}, {"key": "address", "label": "주소", "order": 2, "value": "경기도 하남시 미사강변한강로 290-3", "visible": true}, {"key": "total_supply", "label": "총 공급호수", "order": 3, "value": "1,492호", "visible": true}], "enabled": true}, {"icon": "location_on", "type": "map", "order": 4, "title": "위치", "fields": [{"key": "address", "label": "주소", "order": 1, "value": "경기도 하남시 미사강변한강로 290-3", "visible": true}], "enabled": true}]}', '[{"id": "16m-type1a", "area": 16, "type": "타입 1A", "order": 1, "sections": [{"icon": "person", "type": "eligibility", "order": 1, "title": "신청 자격", "fields": [{"key": "age", "label": "연령", "order": 1, "value": "만 19세 ~ 39세", "visible": true}, {"key": "residence", "label": "거주", "order": 2, "value": "경기도 6개월 이상 거주", "visible": true}, {"key": "housing", "label": "주택", "order": 3, "value": "무주택 / 사회초년생", "visible": true}], "enabled": true}, {"icon": "attach_money", "type": "income", "order": 2, "title": "소득 기준", "fields": [{"key": "household_income", "label": "가구 소득", "order": 1, "value": "전년도 도시근로자 월평균 소득 100% 이하", "detail": "1인 가구: 4,445,807원", "visible": true}, {"key": "personal_income", "label": "본인 소득", "order": 2, "value": "전년도 도시근로자 월평균 소득 70% 이하", "detail": "1인 가구: 3,112,065원", "visible": true}, {"key": "asset", "label": "자산", "order": 3, "value": "총자산 2억 8,800만원 이하", "detail": "부동산, 금융자산 등 합산", "visible": true}, {"key": "car", "label": "자동차", "order": 4, "value": "자동차 가액 3,683만원 이하", "detail": "차량 1대 기준", "visible": true}], "enabled": true, "description": "전년도 도시근로자 가구당 월평균 소득 기준"}, {"icon": "home", "type": "pricing", "order": 3, "title": "공급 조건", "fields": [{"key": "supply_count", "label": "공급호수", "order": 1, "value": "200호", "visible": true}, {"key": "deposit_standard", "label": "임대보증금 (표준)", "order": 2, "value": "3,284만원", "detail": "30% 임대료", "visible": true}, {"key": "monthly_rent_standard", "label": "월 임대료 (표준)", "order": 3, "value": "13.89만원", "visible": true}], "enabled": true}], "tabLabel": "타입 1A", "areaLabel": "16㎡ (약 5평)", "targetGroup": "청년", "floorPlanImage": ""}]', 'active', '2025-10-28 09:35:56.830652+00', '2025-10-28 09:35:56.830652+00');


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

INSERT INTO storage.buckets VALUES ('pickly-storage', 'pickly-storage', NULL, '2025-10-28 09:35:56.788665+00', '2025-10-28 09:35:56.788665+00', true, false, 52428800, '{image/jpeg,image/jpg,image/png,image/gif,image/webp,image/svg+xml,application/pdf,application/msword,application/vnd.openxmlformats-officedocument.wordprocessingml.document}', NULL, 'STANDARD');
INSERT INTO storage.buckets VALUES ('benefit-banners', 'benefit-banners', NULL, '2025-10-28 09:35:56.850525+00', '2025-10-28 09:35:56.850525+00', true, false, 5242880, '{image/jpeg,image/png,image/gif,image/webp,image/svg+xml}', NULL, 'STANDARD');
INSERT INTO storage.buckets VALUES ('benefit-thumbnails', 'benefit-thumbnails', NULL, '2025-10-28 09:35:56.850525+00', '2025-10-28 09:35:56.850525+00', true, false, 3145728, '{image/jpeg,image/png,image/gif,image/webp}', NULL, 'STANDARD');
INSERT INTO storage.buckets VALUES ('benefit-icons', 'benefit-icons', NULL, '2025-10-28 09:35:56.850525+00', '2025-10-28 09:35:56.850525+00', true, false, 1048576, '{image/png,image/svg+xml,image/webp}', NULL, 'STANDARD');


--
-- Data for Name: storage_folders; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.storage_folders VALUES ('692d9407-fb47-49cf-9b09-0d5f75c2286c', 'pickly-storage', 'announcements/', 'Root folder for benefit announcements', '2025-10-28 09:35:56.788665+00');
INSERT INTO public.storage_folders VALUES ('68cd9904-cda2-4939-b5ac-39a17ecfcafd', 'pickly-storage', 'announcements/thumbnails/', 'Thumbnail images for announcement cards', '2025-10-28 09:35:56.788665+00');
INSERT INTO public.storage_folders VALUES ('d4ce9f66-fcbf-4afe-96c8-1f8f7d3efd94', 'pickly-storage', 'announcements/images/', 'Full-size images for announcement details', '2025-10-28 09:35:56.788665+00');
INSERT INTO public.storage_folders VALUES ('725ea803-a334-4042-a9d1-4d7952126e57', 'pickly-storage', 'announcements/documents/', 'PDF and document attachments', '2025-10-28 09:35:56.788665+00');
INSERT INTO public.storage_folders VALUES ('3020eee5-a855-4a9f-b50b-e7f08c7f4ee0', 'pickly-storage', 'banners/', 'Root folder for category and promotional banners', '2025-10-28 09:35:56.788665+00');
INSERT INTO public.storage_folders VALUES ('82c61821-fbd8-4c26-a6ee-64e4c8bfc741', 'pickly-storage', 'banners/categories/', 'Category-specific banner images', '2025-10-28 09:35:56.788665+00');
INSERT INTO public.storage_folders VALUES ('8fba72a8-5dbc-4906-8d87-af41d4eaa550', 'pickly-storage', 'banners/promotions/', 'Promotional and featured banners', '2025-10-28 09:35:56.788665+00');
INSERT INTO public.storage_folders VALUES ('ba15d9cc-16e6-467d-aa8a-965eebe6092c', 'pickly-storage', 'test/', 'Test folder for validation and development', '2025-10-28 09:35:56.788665+00');


--
-- Data for Name: user_profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: messages_2025_10_27; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--



--
-- Data for Name: messages_2025_10_28; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--



--
-- Data for Name: messages_2025_10_29; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--



--
-- Data for Name: messages_2025_10_30; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--



--
-- Data for Name: messages_2025_10_31; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--



--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

INSERT INTO realtime.schema_migrations VALUES (20211116024918, '2025-10-28 09:35:47');
INSERT INTO realtime.schema_migrations VALUES (20211116045059, '2025-10-28 09:35:47');
INSERT INTO realtime.schema_migrations VALUES (20211116050929, '2025-10-28 09:35:47');
INSERT INTO realtime.schema_migrations VALUES (20211116051442, '2025-10-28 09:35:47');
INSERT INTO realtime.schema_migrations VALUES (20211116212300, '2025-10-28 09:35:47');
INSERT INTO realtime.schema_migrations VALUES (20211116213355, '2025-10-28 09:35:47');
INSERT INTO realtime.schema_migrations VALUES (20211116213934, '2025-10-28 09:35:47');
INSERT INTO realtime.schema_migrations VALUES (20211116214523, '2025-10-28 09:35:47');
INSERT INTO realtime.schema_migrations VALUES (20211122062447, '2025-10-28 09:35:47');
INSERT INTO realtime.schema_migrations VALUES (20211124070109, '2025-10-28 09:35:47');
INSERT INTO realtime.schema_migrations VALUES (20211202204204, '2025-10-28 09:35:47');
INSERT INTO realtime.schema_migrations VALUES (20211202204605, '2025-10-28 09:35:47');
INSERT INTO realtime.schema_migrations VALUES (20211210212804, '2025-10-28 09:35:47');
INSERT INTO realtime.schema_migrations VALUES (20211228014915, '2025-10-28 09:35:47');
INSERT INTO realtime.schema_migrations VALUES (20220107221237, '2025-10-28 09:35:47');
INSERT INTO realtime.schema_migrations VALUES (20220228202821, '2025-10-28 09:35:47');
INSERT INTO realtime.schema_migrations VALUES (20220312004840, '2025-10-28 09:35:47');
INSERT INTO realtime.schema_migrations VALUES (20220603231003, '2025-10-28 09:35:47');
INSERT INTO realtime.schema_migrations VALUES (20220603232444, '2025-10-28 09:35:47');
INSERT INTO realtime.schema_migrations VALUES (20220615214548, '2025-10-28 09:35:47');
INSERT INTO realtime.schema_migrations VALUES (20220712093339, '2025-10-28 09:35:47');
INSERT INTO realtime.schema_migrations VALUES (20220908172859, '2025-10-28 09:35:47');
INSERT INTO realtime.schema_migrations VALUES (20220916233421, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20230119133233, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20230128025114, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20230128025212, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20230227211149, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20230228184745, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20230308225145, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20230328144023, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20231018144023, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20231204144023, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20231204144024, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20231204144025, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20240108234812, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20240109165339, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20240227174441, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20240311171622, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20240321100241, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20240401105812, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20240418121054, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20240523004032, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20240618124746, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20240801235015, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20240805133720, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20240827160934, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20240919163303, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20240919163305, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20241019105805, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20241030150047, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20241108114728, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20241121104152, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20241130184212, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20241220035512, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20241220123912, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20241224161212, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20250107150512, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20250110162412, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20250123174212, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20250128220012, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20250506224012, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20250523164012, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20250714121412, '2025-10-28 09:35:48');
INSERT INTO realtime.schema_migrations VALUES (20250905041441, '2025-10-28 09:35:48');


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--



--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: iceberg_namespaces; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: iceberg_tables; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

INSERT INTO storage.migrations VALUES (0, 'create-migrations-table', 'e18db593bcde2aca2a408c4d1100f6abba2195df', '2025-10-28 09:35:55.57783');
INSERT INTO storage.migrations VALUES (1, 'initialmigration', '6ab16121fbaa08bbd11b712d05f358f9b555d777', '2025-10-28 09:35:55.579116');
INSERT INTO storage.migrations VALUES (2, 'storage-schema', '5c7968fd083fcea04050c1b7f6253c9771b99011', '2025-10-28 09:35:55.579713');
INSERT INTO storage.migrations VALUES (3, 'pathtoken-column', '2cb1b0004b817b29d5b0a971af16bafeede4b70d', '2025-10-28 09:35:55.583947');
INSERT INTO storage.migrations VALUES (4, 'add-migrations-rls', '427c5b63fe1c5937495d9c635c263ee7a5905058', '2025-10-28 09:35:55.593369');
INSERT INTO storage.migrations VALUES (5, 'add-size-functions', '79e081a1455b63666c1294a440f8ad4b1e6a7f84', '2025-10-28 09:35:55.594657');
INSERT INTO storage.migrations VALUES (6, 'change-column-name-in-get-size', 'f93f62afdf6613ee5e7e815b30d02dc990201044', '2025-10-28 09:35:55.596361');
INSERT INTO storage.migrations VALUES (7, 'add-rls-to-buckets', 'e7e7f86adbc51049f341dfe8d30256c1abca17aa', '2025-10-28 09:35:55.597215');
INSERT INTO storage.migrations VALUES (8, 'add-public-to-buckets', 'fd670db39ed65f9d08b01db09d6202503ca2bab3', '2025-10-28 09:35:55.597904');
INSERT INTO storage.migrations VALUES (9, 'fix-search-function', '3a0af29f42e35a4d101c259ed955b67e1bee6825', '2025-10-28 09:35:55.598747');
INSERT INTO storage.migrations VALUES (10, 'search-files-search-function', '68dc14822daad0ffac3746a502234f486182ef6e', '2025-10-28 09:35:55.599833');
INSERT INTO storage.migrations VALUES (11, 'add-trigger-to-auto-update-updated_at-column', '7425bdb14366d1739fa8a18c83100636d74dcaa2', '2025-10-28 09:35:55.600811');
INSERT INTO storage.migrations VALUES (12, 'add-automatic-avif-detection-flag', '8e92e1266eb29518b6a4c5313ab8f29dd0d08df9', '2025-10-28 09:35:55.601997');
INSERT INTO storage.migrations VALUES (13, 'add-bucket-custom-limits', 'cce962054138135cd9a8c4bcd531598684b25e7d', '2025-10-28 09:35:55.602642');
INSERT INTO storage.migrations VALUES (14, 'use-bytes-for-max-size', '941c41b346f9802b411f06f30e972ad4744dad27', '2025-10-28 09:35:55.603309');
INSERT INTO storage.migrations VALUES (15, 'add-can-insert-object-function', '934146bc38ead475f4ef4b555c524ee5d66799e5', '2025-10-28 09:35:55.608604');
INSERT INTO storage.migrations VALUES (16, 'add-version', '76debf38d3fd07dcfc747ca49096457d95b1221b', '2025-10-28 09:35:55.60957');
INSERT INTO storage.migrations VALUES (17, 'drop-owner-foreign-key', 'f1cbb288f1b7a4c1eb8c38504b80ae2a0153d101', '2025-10-28 09:35:55.610261');
INSERT INTO storage.migrations VALUES (18, 'add_owner_id_column_deprecate_owner', 'e7a511b379110b08e2f214be852c35414749fe66', '2025-10-28 09:35:55.611038');
INSERT INTO storage.migrations VALUES (19, 'alter-default-value-objects-id', '02e5e22a78626187e00d173dc45f58fa66a4f043', '2025-10-28 09:35:55.612132');
INSERT INTO storage.migrations VALUES (20, 'list-objects-with-delimiter', 'cd694ae708e51ba82bf012bba00caf4f3b6393b7', '2025-10-28 09:35:55.612899');
INSERT INTO storage.migrations VALUES (21, 's3-multipart-uploads', '8c804d4a566c40cd1e4cc5b3725a664a9303657f', '2025-10-28 09:35:55.614239');
INSERT INTO storage.migrations VALUES (22, 's3-multipart-uploads-big-ints', '9737dc258d2397953c9953d9b86920b8be0cdb73', '2025-10-28 09:35:55.617128');
INSERT INTO storage.migrations VALUES (23, 'optimize-search-function', '9d7e604cddc4b56a5422dc68c9313f4a1b6f132c', '2025-10-28 09:35:55.619225');
INSERT INTO storage.migrations VALUES (24, 'operation-function', '8312e37c2bf9e76bbe841aa5fda889206d2bf8aa', '2025-10-28 09:35:55.620229');
INSERT INTO storage.migrations VALUES (25, 'custom-metadata', 'd974c6057c3db1c1f847afa0e291e6165693b990', '2025-10-28 09:35:55.620846');
INSERT INTO storage.migrations VALUES (26, 'objects-prefixes', 'ef3f7871121cdc47a65308e6702519e853422ae2', '2025-10-28 09:35:55.621498');
INSERT INTO storage.migrations VALUES (27, 'search-v2', '33b8f2a7ae53105f028e13e9fcda9dc4f356b4a2', '2025-10-28 09:35:55.625053');
INSERT INTO storage.migrations VALUES (28, 'object-bucket-name-sorting', 'ba85ec41b62c6a30a3f136788227ee47f311c436', '2025-10-28 09:35:55.654884');
INSERT INTO storage.migrations VALUES (29, 'create-prefixes', 'a7b1a22c0dc3ab630e3055bfec7ce7d2045c5b7b', '2025-10-28 09:35:55.656124');
INSERT INTO storage.migrations VALUES (30, 'update-object-levels', '6c6f6cc9430d570f26284a24cf7b210599032db7', '2025-10-28 09:35:55.656918');
INSERT INTO storage.migrations VALUES (31, 'objects-level-index', '33f1fef7ec7fea08bb892222f4f0f5d79bab5eb8', '2025-10-28 09:35:55.657672');
INSERT INTO storage.migrations VALUES (32, 'backward-compatible-index-on-objects', '2d51eeb437a96868b36fcdfb1ddefdf13bef1647', '2025-10-28 09:35:55.658514');
INSERT INTO storage.migrations VALUES (33, 'backward-compatible-index-on-prefixes', 'fe473390e1b8c407434c0e470655945b110507bf', '2025-10-28 09:35:55.659176');
INSERT INTO storage.migrations VALUES (34, 'optimize-search-function-v1', '82b0e469a00e8ebce495e29bfa70a0797f7ebd2c', '2025-10-28 09:35:55.659344');
INSERT INTO storage.migrations VALUES (35, 'add-insert-trigger-prefixes', '63bb9fd05deb3dc5e9fa66c83e82b152f0caf589', '2025-10-28 09:35:55.660713');
INSERT INTO storage.migrations VALUES (36, 'optimise-existing-functions', '81cf92eb0c36612865a18016a38496c530443899', '2025-10-28 09:35:55.661183');
INSERT INTO storage.migrations VALUES (37, 'add-bucket-name-length-trigger', '3944135b4e3e8b22d6d4cbb568fe3b0b51df15c1', '2025-10-28 09:35:55.66304');
INSERT INTO storage.migrations VALUES (38, 'iceberg-catalog-flag-on-buckets', '19a8bd89d5dfa69af7f222a46c726b7c41e462c5', '2025-10-28 09:35:55.664346');
INSERT INTO storage.migrations VALUES (39, 'add-search-v2-sort-support', '39cf7d1e6bf515f4b02e41237aba845a7b492853', '2025-10-28 09:35:55.670484');
INSERT INTO storage.migrations VALUES (40, 'fix-prefix-race-conditions-optimized', 'fd02297e1c67df25a9fc110bf8c8a9af7fb06d1f', '2025-10-28 09:35:55.672159');
INSERT INTO storage.migrations VALUES (41, 'add-object-level-update-trigger', '44c22478bf01744b2129efc480cd2edc9a7d60e9', '2025-10-28 09:35:55.675258');
INSERT INTO storage.migrations VALUES (42, 'rollback-prefix-triggers', 'f2ab4f526ab7f979541082992593938c05ee4b47', '2025-10-28 09:35:55.676546');
INSERT INTO storage.migrations VALUES (43, 'fix-object-level', 'ab837ad8f1c7d00cc0b7310e989a23388ff29fc6', '2025-10-28 09:35:55.677941');


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

INSERT INTO storage.objects VALUES ('9f2b3b49-d35e-4219-aeec-c1174b0242a5', 'pickly-storage', 'age_category_icons/1761646241348-zo29vq.svg', NULL, '2025-10-28 10:10:41.486506+00', '2025-10-28 10:10:41.486506+00', '2025-10-28 10:10:41.486506+00', '{"eTag": "\"b6f28d69adcd9d3c02262f3d9b47ce89\"", "size": 3655, "mimetype": "image/svg+xml", "cacheControl": "max-age=3600", "lastModified": "2025-10-28T10:10:41.477Z", "contentLength": 3655, "httpStatusCode": 200}', DEFAULT, '7b9eeff0-723a-4d32-9c12-6b771cff09b0', NULL, '{}', 2);
INSERT INTO storage.objects VALUES ('20e164ce-5b5c-4a8f-a501-d0e45f6cc3d9', 'benefit-banners', 'banners/1761646262299-xh5omj.png', NULL, '2025-10-28 10:11:02.362983+00', '2025-10-28 10:11:02.362983+00', '2025-10-28 10:11:02.362983+00', '{"eTag": "\"e83763a7c43d2292e895069b6e5ea2fc\"", "size": 11170, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-10-28T10:11:02.356Z", "contentLength": 11170, "httpStatusCode": 200}', DEFAULT, '033f983c-6e9e-47f9-95f7-7cf651009e7f', NULL, '{}', 2);


--
-- Data for Name: prefixes; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

INSERT INTO storage.prefixes VALUES ('pickly-storage', 'age_category_icons', DEFAULT, '2025-10-28 10:10:41.486506+00', '2025-10-28 10:10:41.486506+00');
INSERT INTO storage.prefixes VALUES ('benefit-banners', 'banners', DEFAULT, '2025-10-28 10:11:02.362983+00', '2025-10-28 10:11:02.362983+00');


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: hooks; Type: TABLE DATA; Schema: supabase_functions; Owner: supabase_functions_admin
--



--
-- Data for Name: migrations; Type: TABLE DATA; Schema: supabase_functions; Owner: supabase_functions_admin
--

INSERT INTO supabase_functions.migrations VALUES ('initial', '2025-10-28 09:35:43.727931+00');
INSERT INTO supabase_functions.migrations VALUES ('20210809183423_update_grants', '2025-10-28 09:35:43.727931+00');


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: supabase_migrations; Owner: postgres
--

INSERT INTO supabase_migrations.schema_migrations VALUES ('20251007035747', '{"-- 사용자 프로필 (통합)
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) UNIQUE,
  
  -- 001: 개인정보
  name TEXT,
  age INTEGER,
  gender TEXT,
  
  -- 002: 지역
  region_sido TEXT,
  region_sigungu TEXT,
  
  -- 003: 연령/세대
  selected_categories UUID[],
  
  -- 004: 소득
  income_level TEXT,
  
  -- 005: 관심 정책
  interest_policies UUID[],
  
  -- 메타
  onboarding_completed BOOLEAN DEFAULT false,
  onboarding_step INTEGER DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
)","-- 연령/세대 카테고리 (003)
CREATE TABLE IF NOT EXISTS age_categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  icon_component TEXT NOT NULL,
  icon_url TEXT,
  min_age INTEGER,
  max_age INTEGER,
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
)","-- 자동 업데이트 트리거
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql","CREATE TRIGGER age_categories_updated
  BEFORE UPDATE ON age_categories
  FOR EACH ROW EXECUTE FUNCTION update_updated_at()","CREATE TRIGGER user_profiles_updated
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at()","-- RLS
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY","ALTER TABLE age_categories ENABLE ROW LEVEL SECURITY","CREATE POLICY \"Users manage own profile\"
  ON user_profiles FOR ALL
  USING (auth.uid() = user_id)","CREATE POLICY \"Anyone views active categories\"
  ON age_categories FOR SELECT
  USING (is_active = true)","-- Permissive policy for development (allows all operations)
CREATE POLICY \"Admins manage categories\"
  ON age_categories FOR ALL
  TO public
  USING (true)
  WITH CHECK (true)","-- 초기 데이터
INSERT INTO age_categories (title, description, icon_component, min_age, max_age, sort_order) VALUES
(''청년'', ''(만 19세-39세) 대학생, 취업준비생, 직장인'', ''young_man'', 19, 39, 1),
(''신혼부부·예비부부'', ''결혼 예정 또는 결혼 7년이내'', ''bride'', NULL, NULL, 2),
(''육아중인 부모'', ''영유아~초등 자녀 양육 중'', ''baby'', NULL, NULL, 3),
(''다자녀 가구'', ''자녀 2명 이상 양육중'', ''kinder'', NULL, NULL, 4),
(''어르신'', ''만 65세 이상'', ''old_man'', 65, NULL, 5),
(''장애인'', ''장애인 등록 대상'', ''wheel_chair'', NULL, NULL, 6)
ON CONFLICT DO NOTHING"}', 'onboarding_schema');
INSERT INTO supabase_migrations.schema_migrations VALUES ('20251007999999', '{"-- Update icon URLs for age categories to use SVG assets from design system

UPDATE age_categories
SET icon_url = ''packages/pickly_design_system/assets/icons/age_categories/young_man.svg''
WHERE icon_component = ''young_man''","UPDATE age_categories
SET icon_url = ''packages/pickly_design_system/assets/icons/age_categories/bride.svg''
WHERE icon_component = ''bride''","UPDATE age_categories
SET icon_url = ''packages/pickly_design_system/assets/icons/age_categories/baby.svg''
WHERE icon_component = ''baby''","UPDATE age_categories
SET icon_url = ''packages/pickly_design_system/assets/icons/age_categories/kinder.svg''
WHERE icon_component = ''kinder''","UPDATE age_categories
SET icon_url = ''packages/pickly_design_system/assets/icons/age_categories/old_man.svg''
WHERE icon_component = ''old_man''","UPDATE age_categories
SET icon_url = ''packages/pickly_design_system/assets/icons/age_categories/wheel_chair.svg''
WHERE icon_component = ''wheel_chair''"}', 'update_icon_urls');
INSERT INTO supabase_migrations.schema_migrations VALUES ('20251024000000', '{"-- =============================================================================
-- Pickly Service - Benefit Announcement System
-- Migration: 20251024000000_benefit_system.sql
-- Description: Create comprehensive benefit announcement database schema
-- =============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\"","CREATE EXTENSION IF NOT EXISTS \"pg_trgm\"","-- For text search optimization

-- =============================================================================
-- 1. BENEFIT CATEGORIES TABLE
-- Description: Stores benefit categories (주거, 복지, 교육, 취업, 건강, 문화)
-- =============================================================================
CREATE TABLE IF NOT EXISTS benefit_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL UNIQUE,
    slug VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    icon_url TEXT,
    display_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT benefit_categories_name_not_empty CHECK (char_length(name) > 0),
    CONSTRAINT benefit_categories_slug_not_empty CHECK (char_length(slug) > 0),
    CONSTRAINT benefit_categories_display_order_positive CHECK (display_order >= 0)
)","-- Indexes for benefit_categories
CREATE INDEX idx_benefit_categories_slug ON benefit_categories(slug)","CREATE INDEX idx_benefit_categories_display_order ON benefit_categories(display_order)","CREATE INDEX idx_benefit_categories_active ON benefit_categories(is_active) WHERE is_active = TRUE","-- Comments for benefit_categories
COMMENT ON TABLE benefit_categories IS ''혜택 카테고리 테이블 (주거, 복지, 교육 등)''","COMMENT ON COLUMN benefit_categories.slug IS ''URL-friendly identifier for the category''","COMMENT ON COLUMN benefit_categories.display_order IS ''Order in which categories are displayed''","-- =============================================================================
-- 2. BENEFIT ANNOUNCEMENTS TABLE
-- Description: Main table for benefit announcements (공고)
-- =============================================================================
CREATE TABLE IF NOT EXISTS benefit_announcements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID NOT NULL REFERENCES benefit_categories(id) ON DELETE RESTRICT,

    -- Basic Information
    title VARCHAR(255) NOT NULL,
    subtitle VARCHAR(255),
    organization VARCHAR(255) NOT NULL, -- 주관 기관
    application_period_start DATE,
    application_period_end DATE,
    announcement_date DATE,

    -- Status
    status VARCHAR(20) NOT NULL DEFAULT ''draft'' CHECK (status IN (''draft'', ''published'', ''closed'', ''archived'')),
    is_featured BOOLEAN NOT NULL DEFAULT FALSE,
    views_count INTEGER NOT NULL DEFAULT 0,

    -- Content
    summary TEXT,
    thumbnail_url TEXT,
    external_url TEXT, -- Link to original announcement

    -- Metadata
    tags TEXT[], -- Array of tags for search
    search_vector TSVECTOR, -- Full-text search vector

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    published_at TIMESTAMPTZ,

    -- Constraints
    CONSTRAINT benefit_announcements_title_not_empty CHECK (char_length(title) > 0),
    CONSTRAINT benefit_announcements_organization_not_empty CHECK (char_length(organization) > 0),
    CONSTRAINT benefit_announcements_views_positive CHECK (views_count >= 0),
    CONSTRAINT benefit_announcements_date_order CHECK (
        application_period_start IS NULL OR
        application_period_end IS NULL OR
        application_period_start <= application_period_end
    )
)","-- Indexes for benefit_announcements
CREATE INDEX idx_announcements_category ON benefit_announcements(category_id)","CREATE INDEX idx_announcements_status ON benefit_announcements(status)","CREATE INDEX idx_announcements_featured ON benefit_announcements(is_featured) WHERE is_featured = TRUE","CREATE INDEX idx_announcements_published_at ON benefit_announcements(published_at DESC) WHERE status = ''published''","CREATE INDEX idx_announcements_application_period ON benefit_announcements(application_period_start, application_period_end)","CREATE INDEX idx_announcements_views ON benefit_announcements(views_count DESC)","CREATE INDEX idx_announcements_tags ON benefit_announcements USING GIN(tags)","CREATE INDEX idx_announcements_search ON benefit_announcements USING GIN(search_vector)","-- Comments for benefit_announcements
COMMENT ON TABLE benefit_announcements IS ''혜택 공고 메인 정보 테이블''","COMMENT ON COLUMN benefit_announcements.status IS ''Announcement status: draft, published, closed, archived''","COMMENT ON COLUMN benefit_announcements.is_featured IS ''Whether the announcement is featured on homepage''","COMMENT ON COLUMN benefit_announcements.search_vector IS ''Full-text search vector for Korean/English search''","-- =============================================================================
-- 3. ANNOUNCEMENT UNIT TYPES TABLE
-- Description: Stores unit type information (평수별 정보) for housing announcements
-- =============================================================================
CREATE TABLE IF NOT EXISTS announcement_unit_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    announcement_id UUID NOT NULL REFERENCES benefit_announcements(id) ON DELETE CASCADE,

    -- Unit Information
    unit_type VARCHAR(50) NOT NULL, -- e.g., \"59㎡\", \"84㎡\"
    exclusive_area DECIMAL(10,2), -- 전용면적
    supply_area DECIMAL(10,2), -- 공급면적
    unit_count INTEGER, -- 세대수

    -- Pricing
    sale_price DECIMAL(15,2), -- 분양가
    deposit_amount DECIMAL(15,2), -- 보증금
    monthly_rent DECIMAL(15,2), -- 월세

    -- Additional Info
    room_layout VARCHAR(50), -- e.g., \"3Bay\", \"4Bay\"
    special_conditions TEXT,

    -- Metadata
    display_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT unit_types_unit_type_not_empty CHECK (char_length(unit_type) > 0),
    CONSTRAINT unit_types_areas_positive CHECK (
        (exclusive_area IS NULL OR exclusive_area > 0) AND
        (supply_area IS NULL OR supply_area > 0)
    ),
    CONSTRAINT unit_types_prices_non_negative CHECK (
        (sale_price IS NULL OR sale_price >= 0) AND
        (deposit_amount IS NULL OR deposit_amount >= 0) AND
        (monthly_rent IS NULL OR monthly_rent >= 0)
    ),
    CONSTRAINT unit_types_count_positive CHECK (unit_count IS NULL OR unit_count > 0)
)","-- Indexes for announcement_unit_types
CREATE INDEX idx_unit_types_announcement ON announcement_unit_types(announcement_id)","CREATE INDEX idx_unit_types_display_order ON announcement_unit_types(announcement_id, display_order)","CREATE INDEX idx_unit_types_exclusive_area ON announcement_unit_types(exclusive_area)","CREATE INDEX idx_unit_types_pricing ON announcement_unit_types(sale_price, monthly_rent)","-- Comments for announcement_unit_types
COMMENT ON TABLE announcement_unit_types IS ''공고별 평수 정보 테이블 (주거 카테고리용)''","COMMENT ON COLUMN announcement_unit_types.exclusive_area IS ''전용면적 (㎡)''","COMMENT ON COLUMN announcement_unit_types.supply_area IS ''공급면적 (㎡)''","-- =============================================================================
-- 4. ANNOUNCEMENT SECTIONS TABLE
-- Description: Custom sections for announcements (e.g., eligibility, documents)
-- =============================================================================
CREATE TABLE IF NOT EXISTS announcement_sections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    announcement_id UUID NOT NULL REFERENCES benefit_announcements(id) ON DELETE CASCADE,

    -- Section Information
    section_type VARCHAR(50) NOT NULL, -- e.g., \"eligibility\", \"documents\", \"schedule\"
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,

    -- Structured Data (JSON for flexibility)
    structured_data JSONB, -- For complex data structures (lists, tables, etc.)

    -- Metadata
    display_order INTEGER NOT NULL DEFAULT 0,
    is_visible BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT sections_title_not_empty CHECK (char_length(title) > 0),
    CONSTRAINT sections_content_not_empty CHECK (char_length(content) > 0)
)","-- Indexes for announcement_sections
CREATE INDEX idx_sections_announcement ON announcement_sections(announcement_id)","CREATE INDEX idx_sections_type ON announcement_sections(section_type)","CREATE INDEX idx_sections_display_order ON announcement_sections(announcement_id, display_order)","CREATE INDEX idx_sections_structured_data ON announcement_sections USING GIN(structured_data)","-- Comments for announcement_sections
COMMENT ON TABLE announcement_sections IS ''공고별 커스텀 섹션 (자격요건, 구비서류 등)''","COMMENT ON COLUMN announcement_sections.section_type IS ''Type of section: eligibility, documents, schedule, benefits, etc.''","COMMENT ON COLUMN announcement_sections.structured_data IS ''JSON data for complex structures like lists and tables''","-- =============================================================================
-- 5. ANNOUNCEMENT COMMENTS TABLE (Future Expansion)
-- Description: User comments and discussions on announcements
-- =============================================================================
CREATE TABLE IF NOT EXISTS announcement_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    announcement_id UUID NOT NULL REFERENCES benefit_announcements(id) ON DELETE CASCADE,
    user_id UUID NOT NULL, -- References auth.users, but no FK to avoid dependency
    parent_comment_id UUID REFERENCES announcement_comments(id) ON DELETE CASCADE,

    -- Comment Content
    content TEXT NOT NULL,
    is_edited BOOLEAN NOT NULL DEFAULT FALSE,

    -- Moderation
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    is_reported BOOLEAN NOT NULL DEFAULT FALSE,
    moderation_status VARCHAR(20) DEFAULT ''pending'' CHECK (moderation_status IN (''pending'', ''approved'', ''rejected'')),

    -- Engagement
    likes_count INTEGER NOT NULL DEFAULT 0,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,

    -- Constraints
    CONSTRAINT comments_content_not_empty CHECK (char_length(content) > 0 OR is_deleted = TRUE),
    CONSTRAINT comments_likes_non_negative CHECK (likes_count >= 0)
)","-- Indexes for announcement_comments
CREATE INDEX idx_comments_announcement ON announcement_comments(announcement_id, created_at DESC)","CREATE INDEX idx_comments_user ON announcement_comments(user_id)","CREATE INDEX idx_comments_parent ON announcement_comments(parent_comment_id) WHERE parent_comment_id IS NOT NULL","CREATE INDEX idx_comments_moderation ON announcement_comments(moderation_status, created_at)","CREATE INDEX idx_comments_active ON announcement_comments(announcement_id) WHERE is_deleted = FALSE","-- Comments for announcement_comments
COMMENT ON TABLE announcement_comments IS ''공고 댓글 테이블 (미래 확장용)''","COMMENT ON COLUMN announcement_comments.parent_comment_id IS ''For nested/threaded comments''","-- =============================================================================
-- 6. ANNOUNCEMENT AI CHATS TABLE (Future Expansion)
-- Description: AI chatbot conversations related to announcements
-- =============================================================================
CREATE TABLE IF NOT EXISTS announcement_ai_chats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    announcement_id UUID REFERENCES benefit_announcements(id) ON DELETE SET NULL,
    user_id UUID NOT NULL, -- References auth.users
    session_id UUID NOT NULL DEFAULT uuid_generate_v4(),

    -- Message Content
    role VARCHAR(20) NOT NULL CHECK (role IN (''user'', ''assistant'', ''system'')),
    content TEXT NOT NULL,

    -- AI Metadata
    model_name VARCHAR(100),
    tokens_used INTEGER,
    response_time_ms INTEGER,

    -- Context
    context_data JSONB, -- Additional context for AI processing

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT ai_chats_content_not_empty CHECK (char_length(content) > 0),
    CONSTRAINT ai_chats_tokens_non_negative CHECK (tokens_used IS NULL OR tokens_used >= 0),
    CONSTRAINT ai_chats_response_time_positive CHECK (response_time_ms IS NULL OR response_time_ms > 0)
)","-- Indexes for announcement_ai_chats
CREATE INDEX idx_ai_chats_session ON announcement_ai_chats(session_id, created_at)","CREATE INDEX idx_ai_chats_user ON announcement_ai_chats(user_id, created_at DESC)","CREATE INDEX idx_ai_chats_announcement ON announcement_ai_chats(announcement_id) WHERE announcement_id IS NOT NULL","CREATE INDEX idx_ai_chats_context ON announcement_ai_chats USING GIN(context_data)","-- Comments for announcement_ai_chats
COMMENT ON TABLE announcement_ai_chats IS ''AI 챗봇 대화 기록 (미래 확장용)''","COMMENT ON COLUMN announcement_ai_chats.session_id IS ''Groups messages in a conversation session''","COMMENT ON COLUMN announcement_ai_chats.context_data IS ''JSON data for AI context and metadata''","-- =============================================================================
-- FUNCTIONS AND TRIGGERS
-- =============================================================================

-- Function: Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql","-- Function: Update search vector for announcements
CREATE OR REPLACE FUNCTION update_announcement_search_vector()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector(''simple'', COALESCE(NEW.title, '''')), ''A'') ||
        setweight(to_tsvector(''simple'', COALESCE(NEW.subtitle, '''')), ''B'') ||
        setweight(to_tsvector(''simple'', COALESCE(NEW.summary, '''')), ''C'') ||
        setweight(to_tsvector(''simple'', COALESCE(NEW.organization, '''')), ''D'') ||
        setweight(to_tsvector(''simple'', COALESCE(array_to_string(NEW.tags, '' ''), '''')), ''B'');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql","-- Triggers for updated_at
CREATE TRIGGER update_benefit_categories_updated_at
    BEFORE UPDATE ON benefit_categories
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column()","CREATE TRIGGER update_benefit_announcements_updated_at
    BEFORE UPDATE ON benefit_announcements
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column()","CREATE TRIGGER update_announcement_unit_types_updated_at
    BEFORE UPDATE ON announcement_unit_types
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column()","CREATE TRIGGER update_announcement_sections_updated_at
    BEFORE UPDATE ON announcement_sections
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column()","CREATE TRIGGER update_announcement_comments_updated_at
    BEFORE UPDATE ON announcement_comments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column()","-- Trigger for search vector
CREATE TRIGGER update_announcements_search_vector
    BEFORE INSERT OR UPDATE OF title, subtitle, summary, organization, tags
    ON benefit_announcements
    FOR EACH ROW
    EXECUTE FUNCTION update_announcement_search_vector()","-- =============================================================================
-- ROW LEVEL SECURITY (RLS)
-- =============================================================================

-- Enable RLS on all tables
ALTER TABLE benefit_categories ENABLE ROW LEVEL SECURITY","ALTER TABLE benefit_announcements ENABLE ROW LEVEL SECURITY","ALTER TABLE announcement_unit_types ENABLE ROW LEVEL SECURITY","ALTER TABLE announcement_sections ENABLE ROW LEVEL SECURITY","ALTER TABLE announcement_comments ENABLE ROW LEVEL SECURITY","ALTER TABLE announcement_ai_chats ENABLE ROW LEVEL SECURITY","-- RLS Policies: Public read access for published content

-- benefit_categories: All users can read active categories
CREATE POLICY \"Public can view active categories\"
    ON benefit_categories FOR SELECT
    USING (is_active = TRUE)","-- benefit_announcements: All users can read published announcements
CREATE POLICY \"Public can view published announcements\"
    ON benefit_announcements FOR SELECT
    USING (status = ''published'')","-- announcement_unit_types: All users can read unit types of published announcements
CREATE POLICY \"Public can view unit types of published announcements\"
    ON announcement_unit_types FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM benefit_announcements
            WHERE benefit_announcements.id = announcement_unit_types.announcement_id
            AND benefit_announcements.status = ''published''
        )
    )","-- announcement_sections: All users can read visible sections of published announcements
CREATE POLICY \"Public can view sections of published announcements\"
    ON announcement_sections FOR SELECT
    USING (
        is_visible = TRUE AND
        EXISTS (
            SELECT 1 FROM benefit_announcements
            WHERE benefit_announcements.id = announcement_sections.announcement_id
            AND benefit_announcements.status = ''published''
        )
    )","-- announcement_comments: All users can read approved comments
CREATE POLICY \"Public can view approved comments\"
    ON announcement_comments FOR SELECT
    USING (
        is_deleted = FALSE AND
        moderation_status = ''approved''
    )","-- announcement_comments: Users can insert their own comments
CREATE POLICY \"Users can insert their own comments\"
    ON announcement_comments FOR INSERT
    WITH CHECK (auth.uid() = user_id)","-- announcement_comments: Users can update their own comments
CREATE POLICY \"Users can update their own comments\"
    ON announcement_comments FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id)","-- announcement_comments: Users can delete their own comments
CREATE POLICY \"Users can delete their own comments\"
    ON announcement_comments FOR DELETE
    USING (auth.uid() = user_id)","-- announcement_ai_chats: Users can only access their own chat sessions
CREATE POLICY \"Users can view their own AI chats\"
    ON announcement_ai_chats FOR SELECT
    USING (auth.uid() = user_id)","CREATE POLICY \"Users can insert their own AI chats\"
    ON announcement_ai_chats FOR INSERT
    WITH CHECK (auth.uid() = user_id)","-- =============================================================================
-- INITIAL DATA INSERTION
-- =============================================================================

-- Insert initial 6 benefit categories
INSERT INTO benefit_categories (name, slug, description, display_order) VALUES
    (''주거'', ''housing'', ''주거 관련 혜택 (임대, 분양, 주택구입 지원 등)'', 1),
    (''복지'', ''welfare'', ''복지 관련 혜택 (생활지원, 의료지원, 긴급지원 등)'', 2),
    (''교육'', ''education'', ''교육 관련 혜택 (학비지원, 장학금, 교육프로그램 등)'', 3),
    (''취업'', ''employment'', ''취업 관련 혜택 (취업지원, 직업훈련, 창업지원 등)'', 4),
    (''건강'', ''health'', ''건강 관련 혜택 (건강검진, 의료비지원, 예방접종 등)'', 5),
    (''문화'', ''culture'', ''문화 관련 혜택 (문화생활, 여가활동, 체육시설 이용 등)'', 6)
ON CONFLICT (slug) DO NOTHING","-- =============================================================================
-- UTILITY VIEWS
-- =============================================================================

-- View: Published announcements with category information
CREATE OR REPLACE VIEW v_published_announcements AS
SELECT
    a.*,
    c.name as category_name,
    c.slug as category_slug,
    CASE
        WHEN a.application_period_end IS NULL THEN NULL
        WHEN a.application_period_end >= CURRENT_DATE THEN ''active''
        ELSE ''expired''
    END as application_status
FROM benefit_announcements a
JOIN benefit_categories c ON a.category_id = c.id
WHERE a.status = ''published''
ORDER BY a.published_at DESC","-- View: Featured announcements
CREATE OR REPLACE VIEW v_featured_announcements AS
SELECT * FROM v_published_announcements
WHERE is_featured = TRUE
ORDER BY published_at DESC
LIMIT 10","-- View: Announcement statistics
CREATE OR REPLACE VIEW v_announcement_stats AS
SELECT
    c.name as category_name,
    c.slug as category_slug,
    COUNT(a.id) as total_announcements,
    COUNT(CASE WHEN a.status = ''published'' THEN 1 END) as published_count,
    COUNT(CASE WHEN a.is_featured THEN 1 END) as featured_count,
    SUM(a.views_count) as total_views
FROM benefit_categories c
LEFT JOIN benefit_announcements a ON c.id = a.category_id
GROUP BY c.id, c.name, c.slug
ORDER BY c.display_order","-- =============================================================================
-- GRANTS AND PERMISSIONS
-- =============================================================================

-- Grant usage on schema
GRANT USAGE ON SCHEMA public TO anon, authenticated","-- Grant select on views to authenticated users
GRANT SELECT ON v_published_announcements TO anon, authenticated","GRANT SELECT ON v_featured_announcements TO anon, authenticated","GRANT SELECT ON v_announcement_stats TO anon, authenticated","-- =============================================================================
-- MIGRATION COMPLETE
-- =============================================================================

COMMENT ON SCHEMA public IS ''Pickly Benefit Announcement System - Migration 20251024000000''","-- Log completion
DO $$
BEGIN
    RAISE NOTICE ''Migration 20251024000000_benefit_system.sql completed successfully'';
    RAISE NOTICE ''Created 6 tables: benefit_categories, benefit_announcements, announcement_unit_types, announcement_sections, announcement_comments, announcement_ai_chats'';
    RAISE NOTICE ''Inserted 6 initial categories: 주거, 복지, 교육, 취업, 건강, 문화'';
    RAISE NOTICE ''Created 3 utility views: v_published_announcements, v_featured_announcements, v_announcement_stats'';
    RAISE NOTICE ''Configured RLS policies for public read access and user-specific write access'';
END $$"}', 'benefit_system');
INSERT INTO supabase_migrations.schema_migrations VALUES ('20251024100000', '{"-- =====================================================
-- Storage Setup for Pickly Benefit Files
-- =====================================================
-- This migration sets up:
-- 1. Storage bucket ''pickly-storage''
-- 2. Folder structure for announcements, banners, documents
-- 3. Public access policies
-- 4. RLS policies for secure uploads
-- =====================================================

-- Enable storage if not already enabled
-- Note: Storage must be enabled in Supabase dashboard or config.toml

-- =====================================================
-- 1. CREATE STORAGE BUCKET
-- =====================================================

-- Create the main storage bucket for all benefit-related files
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  ''pickly-storage'',
  ''pickly-storage'',
  true, -- Public access for viewing
  52428800, -- 50MB limit
  ARRAY[
    ''image/jpeg'',
    ''image/jpg'',
    ''image/png'',
    ''image/gif'',
    ''image/webp'',
    ''application/pdf'',
    ''application/msword'',
    ''application/vnd.openxmlformats-officedocument.wordprocessingml.document''
  ]
)
ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 52428800,
  allowed_mime_types = ARRAY[
    ''image/jpeg'',
    ''image/jpg'',
    ''image/png'',
    ''image/gif'',
    ''image/webp'',
    ''application/pdf'',
    ''application/msword'',
    ''application/vnd.openxmlformats-officedocument.wordprocessingml.document''
  ]","-- =====================================================
-- 2. STORAGE POLICIES
-- =====================================================

-- Allow public READ access to all files in pickly-storage bucket
CREATE POLICY \"Public Access to All Files\"
ON storage.objects FOR SELECT
USING (bucket_id = ''pickly-storage'')","-- Allow authenticated users to UPLOAD files
CREATE POLICY \"Authenticated Upload\"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = ''pickly-storage'')","-- Allow authenticated users to UPDATE their own uploads
CREATE POLICY \"Authenticated Update Own Files\"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = ''pickly-storage'')","-- Allow authenticated users to DELETE files
CREATE POLICY \"Authenticated Delete\"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = ''pickly-storage'')","-- Allow service role full access (for admin operations)
CREATE POLICY \"Service Role Full Access\"
ON storage.objects FOR ALL
TO service_role
USING (bucket_id = ''pickly-storage'')","-- =====================================================
-- 3. CREATE FOLDER STRUCTURE METADATA
-- =====================================================
-- Note: In Supabase Storage, folders are virtual and created
-- automatically when files are uploaded with paths.
-- This table tracks the intended folder structure for documentation.

CREATE TABLE IF NOT EXISTS storage_folders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bucket_id TEXT NOT NULL DEFAULT ''pickly-storage'',
  path TEXT NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT fk_bucket FOREIGN KEY (bucket_id)
    REFERENCES storage.buckets(id) ON DELETE CASCADE
)","-- Add folder structure documentation
INSERT INTO storage_folders (path, description) VALUES
  (''announcements/'', ''Root folder for benefit announcements''),
  (''announcements/thumbnails/'', ''Thumbnail images for announcement cards''),
  (''announcements/images/'', ''Full-size images for announcement details''),
  (''announcements/documents/'', ''PDF and document attachments''),
  (''banners/'', ''Root folder for category and promotional banners''),
  (''banners/categories/'', ''Category-specific banner images''),
  (''banners/promotions/'', ''Promotional and featured banners''),
  (''test/'', ''Test folder for validation and development'')
ON CONFLICT (path) DO NOTHING","-- =====================================================
-- 4. FILE METADATA TRACKING
-- =====================================================
-- Track uploaded files for better management

CREATE TABLE IF NOT EXISTS benefit_files (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  announcement_id UUID REFERENCES benefit_announcements(id) ON DELETE CASCADE,
  file_type TEXT NOT NULL CHECK (file_type IN (''thumbnail'', ''image'', ''document'', ''banner'')),
  storage_path TEXT NOT NULL,
  file_name TEXT NOT NULL,
  file_size INTEGER,
  mime_type TEXT,
  public_url TEXT,
  uploaded_by UUID REFERENCES auth.users(id),
  uploaded_at TIMESTAMPTZ DEFAULT NOW(),
  metadata JSONB DEFAULT ''{}''::jsonb,
  CONSTRAINT unique_storage_path UNIQUE (storage_path)
)","-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_benefit_files_announcement ON benefit_files(announcement_id)","CREATE INDEX IF NOT EXISTS idx_benefit_files_type ON benefit_files(file_type)","CREATE INDEX IF NOT EXISTS idx_benefit_files_uploaded_at ON benefit_files(uploaded_at DESC)","-- Enable RLS
ALTER TABLE benefit_files ENABLE ROW LEVEL SECURITY","-- RLS Policies for benefit_files
CREATE POLICY \"Public read access to benefit files\"
  ON benefit_files FOR SELECT
  USING (true)","CREATE POLICY \"Authenticated users can upload files\"
  ON benefit_files FOR INSERT
  TO authenticated
  WITH CHECK (true)","CREATE POLICY \"Users can update their own uploads\"
  ON benefit_files FOR UPDATE
  TO authenticated
  USING (uploaded_by = auth.uid())","CREATE POLICY \"Users can delete their own uploads\"
  ON benefit_files FOR DELETE
  TO authenticated
  USING (uploaded_by = auth.uid())","-- =====================================================
-- 5. HELPER FUNCTIONS
-- =====================================================

-- Function to generate storage path for announcements
CREATE OR REPLACE FUNCTION generate_announcement_file_path(
  p_announcement_id UUID,
  p_file_type TEXT,
  p_file_name TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN format(''announcements/%s/%s/%s'',
    p_file_type,
    p_announcement_id::text,
    p_file_name
  );
END;
$$","-- Function to generate banner path
CREATE OR REPLACE FUNCTION generate_banner_path(
  p_category TEXT,
  p_file_name TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN format(''banners/%s/%s'', p_category, p_file_name);
END;
$$","-- Function to get public URL for storage object
CREATE OR REPLACE FUNCTION get_storage_public_url(
  p_bucket_id TEXT,
  p_path TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
  v_project_url TEXT;
BEGIN
  -- Get the Supabase project URL from config
  -- In production, this should be the actual project URL
  v_project_url := current_setting(''app.settings.supabase_url'', true);

  IF v_project_url IS NULL THEN
    v_project_url := ''http://localhost:54321''; -- Local development default
  END IF;

  RETURN format(''%s/storage/v1/object/public/%s/%s'',
    v_project_url,
    p_bucket_id,
    p_path
  );
END;
$$","-- =====================================================
-- 6. SAMPLE DATA FOR TESTING
-- =====================================================

-- Insert a test file record (actual file upload must be done via API)
INSERT INTO benefit_files (
  file_type,
  storage_path,
  file_name,
  mime_type,
  public_url,
  metadata
) VALUES (
  ''banner'',
  ''banners/test/sample.jpg'',
  ''sample.jpg'',
  ''image/jpeg'',
  get_storage_public_url(''pickly-storage'', ''banners/test/sample.jpg''),
  ''{\"description\": \"Test banner image\", \"is_test\": true}''::jsonb
)
ON CONFLICT (storage_path) DO NOTHING","-- =====================================================
-- 7. VIEWS FOR EASY ACCESS
-- =====================================================

-- View to see all files with announcement details
CREATE OR REPLACE VIEW v_announcement_files AS
SELECT
  bf.id,
  bf.announcement_id,
  ba.title as announcement_title,
  ba.organization,
  bf.file_type,
  bf.storage_path,
  bf.file_name,
  bf.file_size,
  bf.mime_type,
  bf.public_url,
  bf.uploaded_at,
  bf.metadata
FROM benefit_files bf
LEFT JOIN benefit_announcements ba ON bf.announcement_id = ba.id
ORDER BY bf.uploaded_at DESC","-- View for storage statistics
CREATE OR REPLACE VIEW v_storage_stats AS
SELECT
  file_type,
  COUNT(*) as file_count,
  SUM(file_size) as total_size_bytes,
  ROUND(SUM(file_size)::numeric / 1024 / 1024, 2) as total_size_mb,
  AVG(file_size)::bigint as avg_file_size_bytes
FROM benefit_files
GROUP BY file_type","-- =====================================================
-- 8. GRANTS
-- =====================================================

-- Grant access to authenticated users
GRANT SELECT ON storage_folders TO authenticated","GRANT ALL ON benefit_files TO authenticated","GRANT SELECT ON v_announcement_files TO authenticated","GRANT SELECT ON v_storage_stats TO authenticated","-- Grant public read access to views
GRANT SELECT ON v_announcement_files TO anon","GRANT SELECT ON v_storage_stats TO anon","-- =====================================================
-- MIGRATION COMPLETE
-- =====================================================
-- Next steps:
-- 1. Enable storage in Supabase dashboard or config.toml
-- 2. Run: supabase db reset (or supabase migration up)
-- 3. Test upload: Use Supabase Storage API or SDK
-- 4. Verify public URLs are accessible
-- =====================================================

COMMENT ON TABLE storage_folders IS ''Documents the intended folder structure in pickly-storage bucket''","COMMENT ON TABLE benefit_files IS ''Tracks all uploaded files for benefit announcements and banners''","COMMENT ON VIEW v_announcement_files IS ''Combined view of files with announcement details''","COMMENT ON VIEW v_storage_stats IS ''Storage usage statistics by file type''"}', 'storage_setup');
INSERT INTO supabase_migrations.schema_migrations VALUES ('20251024110000', '{"-- ================================================
-- Pickly Benefit Management System - Backoffice Extensions
-- Migration: 20251024100000_benefit_management_phase1.sql
-- ================================================

-- This migration extends the existing benefit system with backoffice features

-- ================================================
-- 1. ADD CUSTOM FIELDS TO EXISTING BENEFIT_CATEGORIES
-- ================================================
-- Add custom_fields column to benefit_categories if it doesn''t exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = ''public''
        AND table_name = ''benefit_categories''
        AND column_name = ''custom_fields''
    ) THEN
        ALTER TABLE public.benefit_categories
        ADD COLUMN custom_fields JSONB DEFAULT ''{}'';

        RAISE NOTICE ''Added custom_fields column to benefit_categories'';
    END IF;
END $$","-- ================================================
-- 2. ADD BACKOFFICE FIELDS TO BENEFIT_ANNOUNCEMENTS
-- ================================================
-- Add display_order column for drag-and-drop ordering
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = ''public''
        AND table_name = ''benefit_announcements''
        AND column_name = ''display_order''
    ) THEN
        ALTER TABLE public.benefit_announcements
        ADD COLUMN display_order INTEGER NOT NULL DEFAULT 0;

        RAISE NOTICE ''Added display_order column to benefit_announcements'';
    END IF;
END $$","-- Add custom_data column for flexible category-specific data
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = ''public''
        AND table_name = ''benefit_announcements''
        AND column_name = ''custom_data''
    ) THEN
        ALTER TABLE public.benefit_announcements
        ADD COLUMN custom_data JSONB DEFAULT ''{}'';

        RAISE NOTICE ''Added custom_data column to benefit_announcements'';
    END IF;
END $$","-- Add content column for rich HTML content
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = ''public''
        AND table_name = ''benefit_announcements''
        AND column_name = ''content''
    ) THEN
        ALTER TABLE public.benefit_announcements
        ADD COLUMN content TEXT;

        RAISE NOTICE ''Added content column to benefit_announcements'';
    END IF;
END $$","-- ================================================
-- 3. CREATE ANNOUNCEMENT FILES TABLE
-- ================================================
CREATE TABLE IF NOT EXISTS public.announcement_files (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    announcement_id UUID NOT NULL REFERENCES public.benefit_announcements(id) ON DELETE CASCADE,
    file_name VARCHAR(500) NOT NULL,
    file_url VARCHAR(1000) NOT NULL,
    file_type VARCHAR(100),
    file_size BIGINT,
    display_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
)","-- Index for file ordering
CREATE INDEX IF NOT EXISTS idx_announcement_files_order
ON public.announcement_files(announcement_id, display_order)","COMMENT ON TABLE public.announcement_files IS ''File attachments for benefit announcements''","-- ================================================
-- 4. CREATE DISPLAY ORDER HISTORY TABLE (Audit Trail)
-- ================================================
CREATE TABLE IF NOT EXISTS public.display_order_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID NOT NULL REFERENCES public.benefit_categories(id) ON DELETE CASCADE,
    announcement_id UUID NOT NULL REFERENCES public.benefit_announcements(id) ON DELETE CASCADE,
    old_order INTEGER NOT NULL,
    new_order INTEGER NOT NULL,
    changed_by UUID,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
)","-- Index for history queries
CREATE INDEX IF NOT EXISTS idx_order_history_announcement
ON public.display_order_history(announcement_id, changed_at DESC)","CREATE INDEX IF NOT EXISTS idx_order_history_category
ON public.display_order_history(category_id, changed_at DESC)","COMMENT ON TABLE public.display_order_history IS ''Audit trail for announcement display order changes''","-- ================================================
-- 5. FUNCTIONS
-- ================================================

-- Function to update display orders (for drag-and-drop reordering in backoffice)
CREATE OR REPLACE FUNCTION update_display_orders(
    p_category_id UUID,
    p_announcement_ids UUID[]
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_announcement_id UUID;
    v_index INTEGER;
    v_old_order INTEGER;
BEGIN
    -- Loop through announcement IDs and update their display orders
    FOREACH v_announcement_id IN ARRAY p_announcement_ids
    LOOP
        v_index := array_position(p_announcement_ids, v_announcement_id) - 1;

        -- Get current order for audit
        SELECT display_order INTO v_old_order
        FROM public.benefit_announcements
        WHERE id = v_announcement_id;

        -- Update display order
        UPDATE public.benefit_announcements
        SET display_order = v_index,
            updated_at = NOW()
        WHERE id = v_announcement_id
          AND category_id = p_category_id;

        -- Record in audit history
        IF v_old_order IS NOT NULL AND v_old_order != v_index THEN
            INSERT INTO public.display_order_history (
                category_id,
                announcement_id,
                old_order,
                new_order,
                changed_at
            ) VALUES (
                p_category_id,
                v_announcement_id,
                v_old_order,
                v_index,
                NOW()
            );
        END IF;
    END LOOP;
END;
$$","COMMENT ON FUNCTION update_display_orders IS ''Updates announcement display order and logs changes to audit trail''","-- ================================================
-- 6. ROW LEVEL SECURITY (RLS) - BACKOFFICE EXTENSIONS
-- ================================================

-- Enable RLS on new tables (existing tables already have RLS enabled)
ALTER TABLE public.announcement_files ENABLE ROW LEVEL SECURITY","ALTER TABLE public.display_order_history ENABLE ROW LEVEL SECURITY","-- RLS Policies for announcement_files
-- Public can view files of published announcements
CREATE POLICY \"Public can view files of published announcements\"
    ON public.announcement_files
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.benefit_announcements
            WHERE id = announcement_id
            AND status = ''published''
        )
    )","-- Authenticated users can manage files (for backoffice)
-- Note: In production, you should restrict this to admin users only
CREATE POLICY \"Authenticated users can manage announcement files\"
    ON public.announcement_files
    FOR ALL
    USING (auth.role() = ''authenticated'')
    WITH CHECK (auth.role() = ''authenticated'')","-- RLS Policies for display_order_history
-- Only authenticated users can view audit history (for backoffice)
CREATE POLICY \"Authenticated users can view order history\"
    ON public.display_order_history
    FOR SELECT
    USING (auth.role() = ''authenticated'')","-- ================================================
-- 7. UPDATE EXISTING DATA WITH CUSTOM FIELDS
-- ================================================

-- Update ''주거'' (housing) category with custom fields for housing-specific data
UPDATE public.benefit_categories
SET custom_fields = ''{
    \"housing_type\": [\"원룸\", \"투룸\", \"쓰리룸\"],
    \"region_categories\": [\"서울\", \"경기\", \"인천\", \"부산\", \"대구\", \"광주\", \"대전\", \"울산\", \"세종\"],
    \"age_categories\": [\"청년(19-39세)\", \"신혼부부\", \"고령자(65세 이상)\"],
    \"income_limit\": true,
    \"asset_limit\": true,
    \"family_size\": [\"1인\", \"2인\", \"3인\", \"4인 이상\"]
}''::jsonb
WHERE slug = ''housing''","-- Update other categories with relevant custom fields
UPDATE public.benefit_categories
SET custom_fields = ''{
    \"program_type\": [\"현금지원\", \"바우처\", \"현물지원\", \"서비스제공\"],
    \"target_group\": [\"저소득층\", \"장애인\", \"한부모가정\", \"다문화가정\", \"노인\"],
    \"income_limit\": true
}''::jsonb
WHERE slug = ''welfare''","UPDATE public.benefit_categories
SET custom_fields = ''{
    \"education_level\": [\"초등\", \"중등\", \"고등\", \"대학\", \"평생교육\"],
    \"support_type\": [\"학비지원\", \"장학금\", \"교육프로그램\", \"교재지원\"],
    \"income_limit\": true
}''::jsonb
WHERE slug = ''education''","UPDATE public.benefit_categories
SET custom_fields = ''{
    \"job_type\": [\"정규직\", \"계약직\", \"인턴\", \"아르바이트\"],
    \"program_type\": [\"취업지원\", \"직업훈련\", \"창업지원\", \"자격증지원\"],
    \"target_group\": [\"청년\", \"경력단절여성\", \"중장년\", \"장애인\"]
}''::jsonb
WHERE slug = ''employment''","UPDATE public.benefit_categories
SET custom_fields = ''{
    \"service_type\": [\"건강검진\", \"의료비지원\", \"예방접종\", \"건강교육\"],
    \"target_group\": [\"영유아\", \"아동\", \"청소년\", \"성인\", \"노인\"],
    \"income_limit\": true
}''::jsonb
WHERE slug = ''health''","UPDATE public.benefit_categories
SET custom_fields = ''{
    \"activity_type\": [\"공연\", \"전시\", \"체육\", \"여가\", \"도서\"],
    \"support_type\": [\"이용권\", \"할인\", \"무료이용\", \"프로그램\"],
    \"target_group\": [\"전체\", \"청소년\", \"성인\", \"노인\", \"장애인\"]
}''::jsonb
WHERE slug = ''culture''","-- ================================================
-- 8. CREATE INDEXES FOR NEW COLUMNS
-- ================================================

-- Index for display_order on benefit_announcements
CREATE INDEX IF NOT EXISTS idx_announcements_display_order
ON public.benefit_announcements(category_id, display_order, created_at)","-- GIN index for custom_data JSONB search
CREATE INDEX IF NOT EXISTS idx_announcements_custom_data
ON public.benefit_announcements USING GIN(custom_data)","-- GIN index for custom_fields on categories
CREATE INDEX IF NOT EXISTS idx_categories_custom_fields
ON public.benefit_categories USING GIN(custom_fields)","-- ================================================
-- 9. MIGRATION COMPLETION LOG
-- ================================================

DO $$
BEGIN
    RAISE NOTICE ''================================================'';
    RAISE NOTICE ''Migration 20251024100000_benefit_management_phase1.sql completed'';
    RAISE NOTICE ''================================================'';
    RAISE NOTICE ''Schema Extensions:'';
    RAISE NOTICE ''  - Added custom_fields column to benefit_categories'';
    RAISE NOTICE ''  - Added display_order, custom_data, content columns to benefit_announcements'';
    RAISE NOTICE ''  - Created announcement_files table for attachments'';
    RAISE NOTICE ''  - Created display_order_history table for audit trail'';
    RAISE NOTICE '''';
    RAISE NOTICE ''Functions:'';
    RAISE NOTICE ''  - Created update_display_orders() for drag-and-drop reordering'';
    RAISE NOTICE '''';
    RAISE NOTICE ''Indexes:'';
    RAISE NOTICE ''  - idx_announcements_display_order'';
    RAISE NOTICE ''  - idx_announcements_custom_data (GIN)'';
    RAISE NOTICE ''  - idx_categories_custom_fields (GIN)'';
    RAISE NOTICE ''  - idx_announcement_files_order'';
    RAISE NOTICE ''  - idx_order_history_announcement'';
    RAISE NOTICE '''';
    RAISE NOTICE ''RLS Policies:'';
    RAISE NOTICE ''  - Public read access for published announcement files'';
    RAISE NOTICE ''  - Authenticated user access for backoffice management'';
    RAISE NOTICE ''================================================'';
END $$"}', 'benefit_management_phase1');
INSERT INTO supabase_migrations.schema_migrations VALUES ('20251025000000', '{"-- Category Banners Table
-- Promotional banners for each benefit category
-- Used in the mobile app benefits screen to highlight featured content

CREATE TABLE IF NOT EXISTS category_banners (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  category_id UUID NOT NULL REFERENCES benefit_categories(id) ON DELETE CASCADE,
  title VARCHAR(100) NOT NULL,
  subtitle VARCHAR(200),
  image_url TEXT NOT NULL,
  background_color VARCHAR(20) DEFAULT ''#E3F2FD'',
  action_url TEXT,
  display_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
)","-- Indexes
CREATE INDEX idx_category_banners_category ON category_banners(category_id)","CREATE INDEX idx_category_banners_active ON category_banners(is_active) WHERE is_active = true","CREATE INDEX idx_category_banners_order ON category_banners(display_order)","-- Auto-update timestamp trigger
CREATE TRIGGER update_category_banners_updated_at
  BEFORE UPDATE ON category_banners
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column()","-- RLS Policies
ALTER TABLE category_banners ENABLE ROW LEVEL SECURITY","-- Public can view active banners
CREATE POLICY \"Public can view active banners\"
  ON category_banners FOR SELECT
  TO public
  USING (is_active = true)","-- Admins can manage all banners (permissive for development)
CREATE POLICY \"Admins can manage banners\"
  ON category_banners FOR ALL
  TO public
  USING (true)
  WITH CHECK (true)","-- Comments
COMMENT ON TABLE category_banners IS ''Promotional banners for benefit categories in the mobile app''","COMMENT ON COLUMN category_banners.category_id IS ''Reference to benefit_categories table''","COMMENT ON COLUMN category_banners.background_color IS ''Hex color code for banner background (e.g., #E3F2FD)''","COMMENT ON COLUMN category_banners.display_order IS ''Order in which banners appear (lower = higher priority)''"}', 'category_banners');
INSERT INTO supabase_migrations.schema_migrations VALUES ('20251025020000', '{"-- Add subcategories for benefit_categories
-- This migration adds parent_id column and subcategories for housing, education, employment, etc.

-- Add parent_id column to benefit_categories
ALTER TABLE benefit_categories
ADD COLUMN IF NOT EXISTS parent_id UUID REFERENCES benefit_categories(id) ON DELETE CASCADE","-- Create index for parent_id
CREATE INDEX IF NOT EXISTS idx_benefit_categories_parent ON benefit_categories(parent_id)","COMMENT ON COLUMN benefit_categories.parent_id IS ''Parent category ID for subcategories (NULL for top-level categories)''","DO $$
DECLARE
    housing_id UUID;
    education_id UUID;
    employment_id UUID;
    welfare_id UUID;
    health_id UUID;
    culture_id UUID;
BEGIN
    -- Get parent category IDs
    SELECT id INTO housing_id FROM benefit_categories WHERE slug = ''housing'';
    SELECT id INTO education_id FROM benefit_categories WHERE slug = ''education'';
    SELECT id INTO employment_id FROM benefit_categories WHERE slug = ''employment'';
    SELECT id INTO welfare_id FROM benefit_categories WHERE slug = ''welfare'';
    SELECT id INTO health_id FROM benefit_categories WHERE slug = ''health'';
    SELECT id INTO culture_id FROM benefit_categories WHERE slug = ''culture'';

    -- 주거 하위 카테고리
    INSERT INTO benefit_categories (parent_id, name, slug, description, display_order) VALUES
    (housing_id, ''행복주택'', ''housing-happiness'', ''청년, 신혼부부, 대학생을 위한 공공임대주택'', 1),
    (housing_id, ''국민임대주택'', ''housing-public'', ''저소득 무주택 가구를 위한 장기 공공임대주택'', 2),
    (housing_id, ''영구임대주택'', ''housing-permanent'', ''생계급여 수급자 등을 위한 영구임대주택'', 3),
    (housing_id, ''매입임대주택'', ''housing-purchased'', ''기존 주택을 매입하여 저렴하게 임대'', 4),
    (housing_id, ''신혼희망타운'', ''housing-newlywed'', ''신혼부부를 위한 주거 지원'', 5)
    ON CONFLICT (slug) DO NOTHING;

    -- 교육 하위 카테고리
    INSERT INTO benefit_categories (parent_id, name, slug, description, display_order) VALUES
    (education_id, ''장학금'', ''education-scholarship'', ''학비 지원 및 장학금 프로그램'', 1),
    (education_id, ''직업훈련'', ''education-training'', ''직업 능력 개발 및 훈련 프로그램'', 2),
    (education_id, ''평생교육'', ''education-lifelong'', ''성인 대상 평생교육 프로그램'', 3),
    (education_id, ''학자금대출'', ''education-loan'', ''학자금 대출 및 상환 지원'', 4)
    ON CONFLICT (slug) DO NOTHING;

    -- 취업 하위 카테고리
    INSERT INTO benefit_categories (parent_id, name, slug, description, display_order) VALUES
    (employment_id, ''청년취업'', ''employment-youth'', ''청년 취업 지원 및 인턴십'', 1),
    (employment_id, ''창업지원'', ''employment-startup'', ''창업 자금 및 컨설팅 지원'', 2),
    (employment_id, ''재취업지원'', ''employment-reemployment'', ''경력단절자 재취업 지원'', 3),
    (employment_id, ''고용장려금'', ''employment-incentive'', ''고용 창출 장려금 및 지원'', 4)
    ON CONFLICT (slug) DO NOTHING;

    -- 복지 하위 카테고리
    INSERT INTO benefit_categories (parent_id, name, slug, description, display_order) VALUES
    (welfare_id, ''생활지원'', ''welfare-living'', ''생계비 및 생활 지원'', 1),
    (welfare_id, ''아동복지'', ''welfare-child'', ''아동 양육 및 돌봄 지원'', 2),
    (welfare_id, ''노인복지'', ''welfare-senior'', ''어르신 생활 및 의료 지원'', 3),
    (welfare_id, ''장애인복지'', ''welfare-disabled'', ''장애인 생활 및 활동 지원'', 4)
    ON CONFLICT (slug) DO NOTHING;

    -- 건강 하위 카테고리
    INSERT INTO benefit_categories (parent_id, name, slug, description, display_order) VALUES
    (health_id, ''건강검진'', ''health-checkup'', ''무료 건강검진 프로그램'', 1),
    (health_id, ''의료비지원'', ''health-medical'', ''의료비 및 치료비 지원'', 2),
    (health_id, ''예방접종'', ''health-vaccination'', ''무료 예방접종 지원'', 3),
    (health_id, ''정신건강'', ''health-mental'', ''정신건강 상담 및 치료 지원'', 4)
    ON CONFLICT (slug) DO NOTHING;

    -- 문화 하위 카테고리
    INSERT INTO benefit_categories (parent_id, name, slug, description, display_order) VALUES
    (culture_id, ''공연·전시'', ''culture-performance'', ''공연 및 전시 할인 혜택'', 1),
    (culture_id, ''체육시설'', ''culture-sports'', ''체육시설 이용 지원'', 2),
    (culture_id, ''도서관'', ''culture-library'', ''도서관 및 독서 프로그램'', 3),
    (culture_id, ''여행·관광'', ''culture-travel'', ''여행 및 관광 지원'', 4)
    ON CONFLICT (slug) DO NOTHING;

END $$","COMMENT ON COLUMN benefit_categories.parent_id IS ''Parent category ID for subcategories''"}', 'add_subcategories');
INSERT INTO supabase_migrations.schema_migrations VALUES ('20251025030000', '{"-- Fix category_banners RLS policies for admin access
-- Allow all users (including anon) to manage banners

-- Drop existing policies
DROP POLICY IF EXISTS \"Public read access to banners\" ON category_banners","DROP POLICY IF EXISTS \"Authenticated users can manage banners\" ON category_banners","-- Create new policies
-- Public can read all banners
CREATE POLICY \"Anyone can read banners\"
ON category_banners FOR SELECT
USING (true)","-- Anyone can insert banners (for admin backoffice)
CREATE POLICY \"Anyone can insert banners\"
ON category_banners FOR INSERT
WITH CHECK (true)","-- Anyone can update banners
CREATE POLICY \"Anyone can update banners\"
ON category_banners FOR UPDATE
USING (true)","-- Anyone can delete banners
CREATE POLICY \"Anyone can delete banners\"
ON category_banners FOR DELETE
USING (true)","COMMENT ON TABLE category_banners IS ''Category banners for mobile app - Admin managed only''"}', 'fix_banner_policies');
INSERT INTO supabase_migrations.schema_migrations VALUES ('20251025040000', '{"-- Cleanup duplicate RLS policies on category_banners

-- Drop old policies
DROP POLICY IF EXISTS \"Public can view active banners\" ON category_banners","DROP POLICY IF EXISTS \"Admins can manage banners\" ON category_banners","-- Ensure we have the simple policies for admin-only management
-- The \"Anyone can...\" policies were created in previous migration
-- This just cleans up the old conflicting policies

COMMENT ON TABLE category_banners IS ''Category banners - Admin backoffice only, RLS policies allow full access for development''"}', 'cleanup_banner_policies');
INSERT INTO supabase_migrations.schema_migrations VALUES ('20251025060000', '{"-- =====================================================
-- Add SVG MIME Type Support to Storage Bucket
-- =====================================================
-- This migration adds image/svg+xml to allowed MIME types
-- for the pickly-storage bucket to support SVG icon uploads
-- =====================================================

-- Update bucket to allow SVG files
UPDATE storage.buckets
SET allowed_mime_types = ARRAY[
  ''image/jpeg'',
  ''image/jpg'',
  ''image/png'',
  ''image/gif'',
  ''image/webp'',
  ''image/svg+xml'',  -- ✅ Added for SVG support (icons, graphics)
  ''application/pdf'',
  ''application/msword'',
  ''application/vnd.openxmlformats-officedocument.wordprocessingml.document''
]
WHERE id = ''pickly-storage''","-- =====================================================
-- MIGRATION COMPLETE
-- =====================================================
-- SVG files (.svg) can now be uploaded to pickly-storage bucket
-- Use case: Age category icons, benefit category icons
-- ====================================================="}', 'add_svg_mime_type');
INSERT INTO supabase_migrations.schema_migrations VALUES ('20251025070000', '{"-- Sync benefit categories with mobile app
-- App order: 인기, 주거, 교육, 지원, 교통, 복지, 취업, 건강, 문화

-- Add missing top-level categories
INSERT INTO benefit_categories (name, slug, description, icon_url, display_order, is_active, parent_id) VALUES
(''인기'', ''popular'', ''가장 인기있는 혜택 모음'', NULL, 0, true, NULL),
(''지원'', ''support'', ''각종 지원금 및 보조금'', NULL, 4, true, NULL),
(''교통'', ''transportation'', ''교통비 지원 및 할인'', NULL, 5, true, NULL)
ON CONFLICT (slug) DO NOTHING","-- Update display_order to match app sequence
-- 인기(0), 주거(1), 교육(2), 지원(3), 교통(4), 복지(5), 취업(6), 건강(7), 문화(8)
UPDATE benefit_categories SET display_order = 0 WHERE slug = ''popular'' AND parent_id IS NULL","UPDATE benefit_categories SET display_order = 1 WHERE slug = ''housing'' AND parent_id IS NULL","UPDATE benefit_categories SET display_order = 2 WHERE slug = ''education'' AND parent_id IS NULL","UPDATE benefit_categories SET display_order = 3 WHERE slug = ''support'' AND parent_id IS NULL","UPDATE benefit_categories SET display_order = 4 WHERE slug = ''transportation'' AND parent_id IS NULL","UPDATE benefit_categories SET display_order = 5 WHERE slug = ''welfare'' AND parent_id IS NULL","UPDATE benefit_categories SET display_order = 6 WHERE slug = ''employment'' AND parent_id IS NULL","UPDATE benefit_categories SET display_order = 7 WHERE slug = ''health'' AND parent_id IS NULL","UPDATE benefit_categories SET display_order = 8 WHERE slug = ''culture'' AND parent_id IS NULL","-- Verify
SELECT id, name, slug, display_order
FROM benefit_categories
WHERE parent_id IS NULL
ORDER BY display_order"}', 'sync_categories_with_app');
INSERT INTO supabase_migrations.schema_migrations VALUES ('20251025080000', '{"-- Reorder benefit categories to match user''s requested order
-- New order: 인기, 주거, 교육, 건강, 교통, 복지, 취업, 지원, 문화

UPDATE benefit_categories SET display_order = 0 WHERE slug = ''popular'' AND parent_id IS NULL","UPDATE benefit_categories SET display_order = 1 WHERE slug = ''housing'' AND parent_id IS NULL","UPDATE benefit_categories SET display_order = 2 WHERE slug = ''education'' AND parent_id IS NULL","UPDATE benefit_categories SET display_order = 3 WHERE slug = ''health'' AND parent_id IS NULL","UPDATE benefit_categories SET display_order = 4 WHERE slug = ''transportation'' AND parent_id IS NULL","UPDATE benefit_categories SET display_order = 5 WHERE slug = ''welfare'' AND parent_id IS NULL","UPDATE benefit_categories SET display_order = 6 WHERE slug = ''employment'' AND parent_id IS NULL","UPDATE benefit_categories SET display_order = 7 WHERE slug = ''support'' AND parent_id IS NULL","UPDATE benefit_categories SET display_order = 8 WHERE slug = ''culture'' AND parent_id IS NULL","-- Verify
SELECT display_order, name, slug
FROM benefit_categories
WHERE parent_id IS NULL
ORDER BY display_order"}', 'reorder_categories');
INSERT INTO supabase_migrations.schema_migrations VALUES ('20251026000000', '{"-- ============================================
-- LH 공고 시스템 - announcements 테이블
-- ============================================
-- 목표: LH API 데이터 저장 + 평형별 탭 + 소득 조건 지원

-- ============================================
-- 1. announcements 테이블 생성
-- ============================================
CREATE TABLE IF NOT EXISTS announcements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- 기본 정보
  title TEXT NOT NULL,
  subtitle TEXT,
  category TEXT NOT NULL,
  source TEXT NOT NULL,
  source_id TEXT UNIQUE NOT NULL,

  -- 원본 데이터 (LH API 원본 JSON)
  raw_data JSONB NOT NULL DEFAULT ''{}''::jsonb,

  -- 공통 섹션 (모든 평형 공통)
  display_config JSONB NOT NULL DEFAULT ''{\"commonSections\": []}''::jsonb,

  -- 평형별 탭 (소득 조건 포함)
  housing_types JSONB NOT NULL DEFAULT ''[]''::jsonb,

  -- 상태
  status TEXT DEFAULT ''draft'',

  -- 메타
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
)","-- ============================================
-- 2. 인덱스 생성
-- ============================================
CREATE INDEX IF NOT EXISTS idx_announcements_source_id ON announcements(source_id)","CREATE INDEX IF NOT EXISTS idx_announcements_status ON announcements(status)","CREATE INDEX IF NOT EXISTS idx_announcements_category ON announcements(category)","-- ============================================
-- 3. 샘플 데이터 삽입
-- ============================================
INSERT INTO announcements (
  title,
  subtitle,
  category,
  source,
  source_id,
  raw_data,
  display_config,
  housing_types,
  status
) VALUES (
  ''하남미사 C3BL 행복주택'',
  ''공고 마감까지 3일 남았어요'',
  ''주거'',
  ''LH'',
  ''2024000001'',
  ''{
    \"PAN_ID\": \"2024000001\",
    \"PAN_NM\": \"하남미사 C3BL 행복주택\",
    \"UPP_AIS_TP_CD_NM\": \"행복주택\",
    \"CNP_CD_NM\": \"경기도\",
    \"HSHLD_CO\": \"1492\",
    \"RCRIT_PBLANC_DE\": \"20250930\",
    \"SUBSCRPT_RCEPT_BGNDE\": \"20250930\",
    \"SUBSCRPT_RCEPT_ENDDE\": \"20251130\",
    \"PRZWNER_PRESNATN_DE\": \"20251225\"
  }''::jsonb,
  ''{
    \"commonSections\": [
      {
        \"type\": \"basic_info\",
        \"title\": \"기본 정보\",
        \"icon\": \"info\",
        \"enabled\": true,
        \"order\": 1,
        \"fields\": [
          {\"key\": \"source\", \"label\": \"공급 기관\", \"value\": \"LH 행복 주택\", \"visible\": true, \"order\": 1},
          {\"key\": \"category\", \"label\": \"카테고리\", \"value\": \"행복주택\", \"visible\": true, \"order\": 2}
        ]
      },
      {
        \"type\": \"schedule\",
        \"title\": \"일정\",
        \"icon\": \"calendar_today\",
        \"enabled\": true,
        \"order\": 2,
        \"fields\": [
          {\"key\": \"apply_period\", \"label\": \"접수 기간\", \"value\": \"2025.09.30(월) - 2025.11.30(월)\", \"visible\": true, \"order\": 1},
          {\"key\": \"announcement_date\", \"label\": \"당첨자 발표\", \"value\": \"2025.12.25\", \"visible\": true, \"order\": 2}
        ]
      },
      {
        \"type\": \"property\",
        \"title\": \"단지 정보\",
        \"icon\": \"apartment\",
        \"enabled\": true,
        \"order\": 3,
        \"fields\": [
          {\"key\": \"name\", \"label\": \"단지명\", \"value\": \"하남미사 C3BL 행복주택\", \"visible\": true, \"order\": 1},
          {\"key\": \"address\", \"label\": \"주소\", \"value\": \"경기도 하남시 미사강변한강로 290-3\", \"visible\": true, \"order\": 2},
          {\"key\": \"total_supply\", \"label\": \"총 공급호수\", \"value\": \"1,492호\", \"visible\": true, \"order\": 3}
        ]
      },
      {
        \"type\": \"map\",
        \"title\": \"위치\",
        \"icon\": \"location_on\",
        \"enabled\": true,
        \"order\": 4,
        \"fields\": [
          {\"key\": \"address\", \"label\": \"주소\", \"value\": \"경기도 하남시 미사강변한강로 290-3\", \"visible\": true, \"order\": 1}
        ]
      }
    ]
  }''::jsonb,
  ''[
    {
      \"id\": \"16m-type1a\",
      \"area\": 16,
      \"areaLabel\": \"16㎡ (약 5평)\",
      \"type\": \"타입 1A\",
      \"targetGroup\": \"청년\",
      \"tabLabel\": \"타입 1A\",
      \"order\": 1,
      \"floorPlanImage\": \"\",
      \"sections\": [
        {
          \"type\": \"eligibility\",
          \"title\": \"신청 자격\",
          \"icon\": \"person\",
          \"enabled\": true,
          \"order\": 1,
          \"fields\": [
            {\"key\": \"age\", \"label\": \"연령\", \"value\": \"만 19세 ~ 39세\", \"visible\": true, \"order\": 1},
            {\"key\": \"residence\", \"label\": \"거주\", \"value\": \"경기도 6개월 이상 거주\", \"visible\": true, \"order\": 2},
            {\"key\": \"housing\", \"label\": \"주택\", \"value\": \"무주택 / 사회초년생\", \"visible\": true, \"order\": 3}
          ]
        },
        {
          \"type\": \"income\",
          \"title\": \"소득 기준\",
          \"icon\": \"attach_money\",
          \"enabled\": true,
          \"order\": 2,
          \"description\": \"전년도 도시근로자 가구당 월평균 소득 기준\",
          \"fields\": [
            {\"key\": \"household_income\", \"label\": \"가구 소득\", \"value\": \"전년도 도시근로자 월평균 소득 100% 이하\", \"detail\": \"1인 가구: 4,445,807원\", \"visible\": true, \"order\": 1},
            {\"key\": \"personal_income\", \"label\": \"본인 소득\", \"value\": \"전년도 도시근로자 월평균 소득 70% 이하\", \"detail\": \"1인 가구: 3,112,065원\", \"visible\": true, \"order\": 2},
            {\"key\": \"asset\", \"label\": \"자산\", \"value\": \"총자산 2억 8,800만원 이하\", \"detail\": \"부동산, 금융자산 등 합산\", \"visible\": true, \"order\": 3},
            {\"key\": \"car\", \"label\": \"자동차\", \"value\": \"자동차 가액 3,683만원 이하\", \"detail\": \"차량 1대 기준\", \"visible\": true, \"order\": 4}
          ]
        },
        {
          \"type\": \"pricing\",
          \"title\": \"공급 조건\",
          \"icon\": \"home\",
          \"enabled\": true,
          \"order\": 3,
          \"fields\": [
            {\"key\": \"supply_count\", \"label\": \"공급호수\", \"value\": \"200호\", \"visible\": true, \"order\": 1},
            {\"key\": \"deposit_standard\", \"label\": \"임대보증금 (표준)\", \"value\": \"3,284만원\", \"detail\": \"30% 임대료\", \"visible\": true, \"order\": 2},
            {\"key\": \"monthly_rent_standard\", \"label\": \"월 임대료 (표준)\", \"value\": \"13.89만원\", \"visible\": true, \"order\": 3}
          ]
        }
      ]
    }
  ]''::jsonb,
  ''active''
) ON CONFLICT (source_id) DO NOTHING","-- ============================================
-- 4. RLS (Row Level Security) 정책
-- ============================================
ALTER TABLE announcements ENABLE ROW LEVEL SECURITY","-- 모든 사용자가 읽을 수 있음
CREATE POLICY \"Anyone can view published announcements\"
  ON announcements FOR SELECT
  USING (status = ''active'')","-- 인증된 사용자만 삽입/수정/삭제 가능 (관리자용)
CREATE POLICY \"Authenticated users can manage announcements\"
  ON announcements FOR ALL
  USING (auth.role() = ''authenticated'')","-- ============================================
-- 5. 업데이트 트리거 (updated_at 자동 갱신)
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql","CREATE TRIGGER update_announcements_updated_at
  BEFORE UPDATE ON announcements
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column()"}', 'announcements_with_income');
INSERT INTO supabase_migrations.schema_migrations VALUES ('20251028120000', '{"-- Pickly Service v7.3 Compatibility Patch
-- ALTER existing tables to match v7.3 PRD specification

-- 1. Patch benefit_categories
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = ''public'' AND table_name = ''benefit_categories'' AND column_name = ''name'') THEN
    ALTER TABLE public.benefit_categories RENAME COLUMN name TO title;
    RAISE NOTICE ''Renamed: name → title'';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = ''public'' AND table_name = ''benefit_categories'' AND column_name = ''display_order'') THEN
    ALTER TABLE public.benefit_categories RENAME COLUMN display_order TO sort_order;
    RAISE NOTICE ''Renamed: display_order → sort_order'';
  END IF;
END $$","ALTER TABLE public.benefit_categories ADD COLUMN IF NOT EXISTS description TEXT, ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true","UPDATE public.benefit_categories SET is_active = true WHERE is_active IS NULL","DROP INDEX IF EXISTS idx_benefit_categories_display_order","CREATE INDEX IF NOT EXISTS idx_benefit_categories_sort_order ON public.benefit_categories(sort_order)","CREATE INDEX IF NOT EXISTS idx_benefit_categories_is_active ON public.benefit_categories(is_active)","-- 2. Patch category_banners - Rename columns
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = ''public'' AND table_name = ''category_banners'' AND column_name = ''category_id'') THEN
    ALTER TABLE public.category_banners RENAME COLUMN category_id TO benefit_category_id;
    RAISE NOTICE ''Renamed: category_id → benefit_category_id'';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = ''public'' AND table_name = ''category_banners'' AND column_name = ''display_order'') THEN
    ALTER TABLE public.category_banners RENAME COLUMN display_order TO sort_order;
    RAISE NOTICE ''Renamed: display_order → sort_order'';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = ''public'' AND table_name = ''category_banners'' AND column_name = ''action_url'') THEN
    ALTER TABLE public.category_banners RENAME COLUMN action_url TO link_target;
    RAISE NOTICE ''Renamed: action_url → link_target'';
  END IF;
END $$","-- Add link_type column (outside DO block so UPDATE can see renamed columns)
ALTER TABLE public.category_banners ADD COLUMN IF NOT EXISTS link_type TEXT DEFAULT ''internal'' CHECK (link_type IN (''internal'', ''external'', ''none''))","-- Update link_type based on link_target
UPDATE public.category_banners SET link_type = CASE
  WHEN link_target IS NULL OR link_target = '''' THEN ''none''
  WHEN link_target LIKE ''http%'' THEN ''external''
  ELSE ''internal''
END WHERE link_type IS NULL","DO $$
BEGIN
  RAISE NOTICE ''Added link_type column and set values'';
END $$","DROP INDEX IF EXISTS idx_category_banners_display_order","CREATE INDEX IF NOT EXISTS idx_category_banners_sort_order ON public.category_banners(sort_order)","CREATE INDEX IF NOT EXISTS idx_category_banners_benefit_category ON public.category_banners(benefit_category_id)","-- 3. Create announcement_types
CREATE TABLE IF NOT EXISTS public.announcement_types (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  benefit_category_id UUID NOT NULL REFERENCES public.benefit_categories(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone(''utc''::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone(''utc''::text, now()) NOT NULL,
  CONSTRAINT unique_title_per_category UNIQUE (benefit_category_id, title)
)","CREATE INDEX IF NOT EXISTS idx_announcement_types_benefit_category ON public.announcement_types(benefit_category_id)","CREATE INDEX IF NOT EXISTS idx_announcement_types_sort_order ON public.announcement_types(sort_order)","CREATE INDEX IF NOT EXISTS idx_announcement_types_is_active ON public.announcement_types(is_active)","CREATE OR REPLACE FUNCTION public.update_announcement_types_updated_at() RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = timezone(''utc''::text, now()); RETURN NEW; END;
$$ LANGUAGE plpgsql","DROP TRIGGER IF EXISTS trigger_announcement_types_updated_at ON public.announcement_types","CREATE TRIGGER trigger_announcement_types_updated_at BEFORE UPDATE ON public.announcement_types
  FOR EACH ROW EXECUTE FUNCTION public.update_announcement_types_updated_at()","ALTER TABLE public.announcement_types ENABLE ROW LEVEL SECURITY","DROP POLICY IF EXISTS \"announcement_types: public read access\" ON public.announcement_types","CREATE POLICY \"announcement_types: public read access\" ON public.announcement_types FOR SELECT USING (true)","-- 4. Rename existing announcements table and create new v7.3 announcements
DO $$
BEGIN
  -- Rename existing housing-specific announcements table
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = ''public'' AND table_name = ''announcements'') THEN
    ALTER TABLE public.announcements RENAME TO housing_announcements;
    RAISE NOTICE ''Renamed: announcements → housing_announcements'';
  END IF;
END $$","-- Create new v7.3 announcements table
CREATE TABLE public.announcements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  type_id UUID NOT NULL REFERENCES public.announcement_types(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  organization TEXT NOT NULL,
  region TEXT,
  thumbnail_url TEXT,
  posted_date DATE,
  status TEXT NOT NULL DEFAULT ''active'' CHECK (status IN (''active'', ''closed'', ''upcoming'')),
  is_priority BOOLEAN NOT NULL DEFAULT false,
  detail_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone(''utc''::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone(''utc''::text, now()) NOT NULL
)","CREATE INDEX idx_announcements_type_id ON public.announcements(type_id)","CREATE INDEX idx_announcements_v73_status ON public.announcements(status)","CREATE INDEX idx_announcements_is_priority ON public.announcements(is_priority)","CREATE INDEX idx_announcements_posted_date ON public.announcements(posted_date DESC)","CREATE INDEX idx_announcements_organization ON public.announcements(organization)","CREATE INDEX idx_announcements_type_status ON public.announcements(type_id, status)","CREATE OR REPLACE FUNCTION public.update_announcements_updated_at() RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = timezone(''utc''::text, now()); RETURN NEW; END;
$$ LANGUAGE plpgsql","DROP TRIGGER IF EXISTS trigger_announcements_updated_at ON public.announcements","CREATE TRIGGER trigger_announcements_updated_at BEFORE UPDATE ON public.announcements
  FOR EACH ROW EXECUTE FUNCTION public.update_announcements_updated_at()","ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY","DROP POLICY IF EXISTS \"announcements: public read access\" ON public.announcements","CREATE POLICY \"announcements: public read access\" ON public.announcements FOR SELECT USING (true)","-- 5. Create view
CREATE OR REPLACE VIEW public.v_announcements_full AS
SELECT a.id, a.title, a.organization, a.region, a.thumbnail_url, a.posted_date,
  a.status, a.is_priority, a.detail_url, a.created_at, a.updated_at,
  at.id as type_id, at.title as type_title,
  bc.id as category_id, bc.title as category_title
FROM public.announcements a
JOIN public.announcement_types at ON a.type_id = at.id
JOIN public.benefit_categories bc ON at.benefit_category_id = bc.id","-- Summary
DO $$
BEGIN
  RAISE NOTICE ''================================================'';
  RAISE NOTICE ''✅ v7.3 Compatibility Patch Completed'';
  RAISE NOTICE ''================================================'';
END $$"}', 'patch_v73_compatibility');
INSERT INTO supabase_migrations.schema_migrations VALUES ('20251028130000', '{"-- Create Storage Buckets for v7.3 Benefit Management System
-- This migration creates 4 public storage buckets with RLS policies

-- =====================================================
-- 1. Create Buckets
-- =====================================================

-- pickly-storage (age categories icons)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  ''pickly-storage'',
  ''pickly-storage'',
  true,
  5242880, -- 5MB
  ARRAY[''image/jpeg'', ''image/png'', ''image/gif'', ''image/webp'', ''image/svg+xml'']
)
ON CONFLICT (id) DO NOTHING","-- benefit-banners (carousel banners)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  ''benefit-banners'',
  ''benefit-banners'',
  true,
  5242880, -- 5MB
  ARRAY[''image/jpeg'', ''image/png'', ''image/gif'', ''image/webp'', ''image/svg+xml'']
)
ON CONFLICT (id) DO NOTHING","-- benefit-thumbnails (announcement thumbnails)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  ''benefit-thumbnails'',
  ''benefit-thumbnails'',
  true,
  3145728, -- 3MB
  ARRAY[''image/jpeg'', ''image/png'', ''image/gif'', ''image/webp'']
)
ON CONFLICT (id) DO NOTHING","-- benefit-icons (category icons)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  ''benefit-icons'',
  ''benefit-icons'',
  true,
  1048576, -- 1MB
  ARRAY[''image/png'', ''image/svg+xml'', ''image/webp'']
)
ON CONFLICT (id) DO NOTHING","-- =====================================================
-- 2. RLS Policies - Public Upload & Read
-- =====================================================

-- pickly-storage policies
DROP POLICY IF EXISTS \"public_upload_pickly_storage\" ON storage.objects","CREATE POLICY \"public_upload_pickly_storage\"
ON storage.objects
FOR INSERT
TO public
WITH CHECK (bucket_id = ''pickly-storage'')","DROP POLICY IF EXISTS \"public_read_pickly_storage\" ON storage.objects","CREATE POLICY \"public_read_pickly_storage\"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = ''pickly-storage'')","DROP POLICY IF EXISTS \"public_update_pickly_storage\" ON storage.objects","CREATE POLICY \"public_update_pickly_storage\"
ON storage.objects
FOR UPDATE
TO public
USING (bucket_id = ''pickly-storage'')
WITH CHECK (bucket_id = ''pickly-storage'')","DROP POLICY IF EXISTS \"public_delete_pickly_storage\" ON storage.objects","CREATE POLICY \"public_delete_pickly_storage\"
ON storage.objects
FOR DELETE
TO public
USING (bucket_id = ''pickly-storage'')","-- benefit-banners policies
DROP POLICY IF EXISTS \"public_upload_benefit_banners\" ON storage.objects","CREATE POLICY \"public_upload_benefit_banners\"
ON storage.objects
FOR INSERT
TO public
WITH CHECK (bucket_id = ''benefit-banners'')","DROP POLICY IF EXISTS \"public_read_benefit_banners\" ON storage.objects","CREATE POLICY \"public_read_benefit_banners\"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = ''benefit-banners'')","DROP POLICY IF EXISTS \"public_update_benefit_banners\" ON storage.objects","CREATE POLICY \"public_update_benefit_banners\"
ON storage.objects
FOR UPDATE
TO public
USING (bucket_id = ''benefit-banners'')
WITH CHECK (bucket_id = ''benefit-banners'')","DROP POLICY IF EXISTS \"public_delete_benefit_banners\" ON storage.objects","CREATE POLICY \"public_delete_benefit_banners\"
ON storage.objects
FOR DELETE
TO public
USING (bucket_id = ''benefit-banners'')","-- benefit-thumbnails policies
DROP POLICY IF EXISTS \"public_upload_benefit_thumbnails\" ON storage.objects","CREATE POLICY \"public_upload_benefit_thumbnails\"
ON storage.objects
FOR INSERT
TO public
WITH CHECK (bucket_id = ''benefit-thumbnails'')","DROP POLICY IF EXISTS \"public_read_benefit_thumbnails\" ON storage.objects","CREATE POLICY \"public_read_benefit_thumbnails\"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = ''benefit-thumbnails'')","DROP POLICY IF EXISTS \"public_update_benefit_thumbnails\" ON storage.objects","CREATE POLICY \"public_update_benefit_thumbnails\"
ON storage.objects
FOR UPDATE
TO public
USING (bucket_id = ''benefit-thumbnails'')
WITH CHECK (bucket_id = ''benefit-thumbnails'')","DROP POLICY IF EXISTS \"public_delete_benefit_thumbnails\" ON storage.objects","CREATE POLICY \"public_delete_benefit_thumbnails\"
ON storage.objects
FOR DELETE
TO public
USING (bucket_id = ''benefit-thumbnails'')","-- benefit-icons policies
DROP POLICY IF EXISTS \"public_upload_benefit_icons\" ON storage.objects","CREATE POLICY \"public_upload_benefit_icons\"
ON storage.objects
FOR INSERT
TO public
WITH CHECK (bucket_id = ''benefit-icons'')","DROP POLICY IF EXISTS \"public_read_benefit_icons\" ON storage.objects","CREATE POLICY \"public_read_benefit_icons\"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = ''benefit-icons'')","DROP POLICY IF EXISTS \"public_update_benefit_icons\" ON storage.objects","CREATE POLICY \"public_update_benefit_icons\"
ON storage.objects
FOR UPDATE
TO public
USING (bucket_id = ''benefit-icons'')
WITH CHECK (bucket_id = ''benefit-icons'')","DROP POLICY IF EXISTS \"public_delete_benefit_icons\" ON storage.objects","CREATE POLICY \"public_delete_benefit_icons\"
ON storage.objects
FOR DELETE
TO public
USING (bucket_id = ''benefit-icons'')","-- Summary
DO $$
BEGIN
  RAISE NOTICE ''================================================'';
  RAISE NOTICE ''✅ Storage Buckets Created'';
  RAISE NOTICE ''================================================'';
  RAISE NOTICE ''Created 4 public storage buckets:'';
  RAISE NOTICE ''  - pickly-storage (5MB limit)'';
  RAISE NOTICE ''  - benefit-banners (5MB limit)'';
  RAISE NOTICE ''  - benefit-thumbnails (3MB limit)'';
  RAISE NOTICE ''  - benefit-icons (1MB limit)'';
  RAISE NOTICE '''';
  RAISE NOTICE ''Configured RLS policies for public access (INSERT, SELECT, UPDATE, DELETE)'';
  RAISE NOTICE ''================================================'';
END $$"}', 'create_storage_buckets');


--
-- Data for Name: seed_files; Type: TABLE DATA; Schema: supabase_migrations; Owner: postgres
--



--
-- Data for Name: secrets; Type: TABLE DATA; Schema: vault; Owner: supabase_admin
--



--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 1, false);


--
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: supabase_admin
--

SELECT pg_catalog.setval('realtime.subscription_id_seq', 1, false);


--
-- Name: hooks_id_seq; Type: SEQUENCE SET; Schema: supabase_functions; Owner: supabase_functions_admin
--

SELECT pg_catalog.setval('supabase_functions.hooks_id_seq', 1, false);


--
-- PostgreSQL database dump complete
--

