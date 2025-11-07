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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: benefit_announcements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.benefit_announcements (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    category_id uuid NOT NULL,
    title character varying(255) NOT NULL,
    subtitle character varying(255),
    organization character varying(255) NOT NULL,
    application_period_start date,
    application_period_end date,
    announcement_date date,
    status character varying(20) DEFAULT 'draft'::character varying NOT NULL,
    is_featured boolean DEFAULT false NOT NULL,
    views_count integer DEFAULT 0 NOT NULL,
    summary text,
    thumbnail_url text,
    external_url text,
    tags text[],
    search_vector tsvector,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    published_at timestamp with time zone,
    display_order integer DEFAULT 0 NOT NULL,
    custom_data jsonb DEFAULT '{}'::jsonb,
    content text,
    CONSTRAINT benefit_announcements_date_order CHECK (((application_period_start IS NULL) OR (application_period_end IS NULL) OR (application_period_start <= application_period_end))),
    CONSTRAINT benefit_announcements_organization_not_empty CHECK ((char_length((organization)::text) > 0)),
    CONSTRAINT benefit_announcements_status_check CHECK (((status)::text = ANY ((ARRAY['draft'::character varying, 'published'::character varying, 'closed'::character varying, 'archived'::character varying])::text[]))),
    CONSTRAINT benefit_announcements_title_not_empty CHECK ((char_length((title)::text) > 0)),
    CONSTRAINT benefit_announcements_views_positive CHECK ((views_count >= 0))
);


ALTER TABLE public.benefit_announcements OWNER TO postgres;

--
-- Name: TABLE benefit_announcements; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.benefit_announcements IS '혜택 공고 메인 정보 테이블';


--
-- Name: COLUMN benefit_announcements.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.benefit_announcements.status IS 'Announcement status: draft, published, closed, archived';


--
-- Name: COLUMN benefit_announcements.is_featured; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.benefit_announcements.is_featured IS 'Whether the announcement is featured on homepage';


--
-- Name: COLUMN benefit_announcements.search_vector; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.benefit_announcements.search_vector IS 'Full-text search vector for Korean/English search';


--
-- Name: benefit_announcements benefit_announcements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.benefit_announcements
    ADD CONSTRAINT benefit_announcements_pkey PRIMARY KEY (id);


--
-- Name: idx_announcements_application_period; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_application_period ON public.benefit_announcements USING btree (application_period_start, application_period_end);


--
-- Name: idx_announcements_category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_category ON public.benefit_announcements USING btree (category_id);


--
-- Name: idx_announcements_custom_data; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_custom_data ON public.benefit_announcements USING gin (custom_data);


--
-- Name: idx_announcements_display_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_display_order ON public.benefit_announcements USING btree (category_id, display_order, created_at);


--
-- Name: idx_announcements_featured; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_featured ON public.benefit_announcements USING btree (is_featured) WHERE (is_featured = true);


--
-- Name: idx_announcements_published_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_published_at ON public.benefit_announcements USING btree (published_at DESC) WHERE ((status)::text = 'published'::text);


--
-- Name: idx_announcements_search; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_search ON public.benefit_announcements USING gin (search_vector);


--
-- Name: idx_announcements_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_status ON public.benefit_announcements USING btree (status);


--
-- Name: idx_announcements_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_tags ON public.benefit_announcements USING gin (tags);


--
-- Name: idx_announcements_views; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_views ON public.benefit_announcements USING btree (views_count DESC);


--
-- Name: benefit_announcements update_announcements_search_vector; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_announcements_search_vector BEFORE INSERT OR UPDATE OF title, subtitle, summary, organization, tags ON public.benefit_announcements FOR EACH ROW EXECUTE FUNCTION public.update_announcement_search_vector();


--
-- Name: benefit_announcements update_benefit_announcements_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_benefit_announcements_updated_at BEFORE UPDATE ON public.benefit_announcements FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: benefit_announcements benefit_announcements_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.benefit_announcements
    ADD CONSTRAINT benefit_announcements_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.benefit_categories(id) ON DELETE RESTRICT;


--
-- Name: benefit_announcements Public can view published announcements; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public can view published announcements" ON public.benefit_announcements FOR SELECT USING (((status)::text = 'published'::text));


--
-- Name: benefit_announcements; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.benefit_announcements ENABLE ROW LEVEL SECURITY;

--
-- Name: TABLE benefit_announcements; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.benefit_announcements TO anon;
GRANT ALL ON TABLE public.benefit_announcements TO authenticated;
GRANT ALL ON TABLE public.benefit_announcements TO service_role;


--
-- PostgreSQL database dump complete
--

