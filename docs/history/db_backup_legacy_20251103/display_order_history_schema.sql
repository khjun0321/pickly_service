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
-- Name: display_order_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.display_order_history (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    category_id uuid NOT NULL,
    announcement_id uuid NOT NULL,
    old_order integer NOT NULL,
    new_order integer NOT NULL,
    changed_by uuid,
    changed_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.display_order_history OWNER TO postgres;

--
-- Name: TABLE display_order_history; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.display_order_history IS 'Audit trail for announcement display order changes';


--
-- Name: display_order_history display_order_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.display_order_history
    ADD CONSTRAINT display_order_history_pkey PRIMARY KEY (id);


--
-- Name: idx_order_history_announcement; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_order_history_announcement ON public.display_order_history USING btree (announcement_id, changed_at DESC);


--
-- Name: idx_order_history_category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_order_history_category ON public.display_order_history USING btree (category_id, changed_at DESC);


--
-- Name: display_order_history display_order_history_announcement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.display_order_history
    ADD CONSTRAINT display_order_history_announcement_id_fkey FOREIGN KEY (announcement_id) REFERENCES public.benefit_announcements(id) ON DELETE CASCADE;


--
-- Name: display_order_history display_order_history_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.display_order_history
    ADD CONSTRAINT display_order_history_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.benefit_categories(id) ON DELETE CASCADE;


--
-- Name: display_order_history Authenticated users can view order history; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Authenticated users can view order history" ON public.display_order_history FOR SELECT USING ((auth.role() = 'authenticated'::text));


--
-- Name: display_order_history; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.display_order_history ENABLE ROW LEVEL SECURITY;

--
-- Name: TABLE display_order_history; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.display_order_history TO anon;
GRANT ALL ON TABLE public.display_order_history TO authenticated;
GRANT ALL ON TABLE public.display_order_history TO service_role;


--
-- PostgreSQL database dump complete
--

