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
-- Name: housing_announcements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.housing_announcements (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    title text NOT NULL,
    subtitle text,
    category text NOT NULL,
    source text NOT NULL,
    source_id text NOT NULL,
    raw_data jsonb DEFAULT '{}'::jsonb NOT NULL,
    display_config jsonb DEFAULT '{"commonSections": []}'::jsonb NOT NULL,
    housing_types jsonb DEFAULT '[]'::jsonb NOT NULL,
    status text DEFAULT 'draft'::text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.housing_announcements OWNER TO postgres;

--
-- Name: housing_announcements announcements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.housing_announcements
    ADD CONSTRAINT announcements_pkey PRIMARY KEY (id);


--
-- Name: housing_announcements announcements_source_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.housing_announcements
    ADD CONSTRAINT announcements_source_id_key UNIQUE (source_id);


--
-- Name: idx_announcements_source_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_source_id ON public.housing_announcements USING btree (source_id);


--
-- Name: housing_announcements update_announcements_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_announcements_updated_at BEFORE UPDATE ON public.housing_announcements FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: housing_announcements Anyone can view published announcements; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Anyone can view published announcements" ON public.housing_announcements FOR SELECT USING ((status = 'active'::text));


--
-- Name: housing_announcements Authenticated users can manage announcements; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Authenticated users can manage announcements" ON public.housing_announcements USING ((auth.role() = 'authenticated'::text));


--
-- Name: housing_announcements; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.housing_announcements ENABLE ROW LEVEL SECURITY;

--
-- Name: TABLE housing_announcements; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.housing_announcements TO anon;
GRANT ALL ON TABLE public.housing_announcements TO authenticated;
GRANT ALL ON TABLE public.housing_announcements TO service_role;


--
-- PostgreSQL database dump complete
--

