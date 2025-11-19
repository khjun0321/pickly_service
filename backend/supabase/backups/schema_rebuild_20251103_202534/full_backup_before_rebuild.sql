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
-- Name: auth; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA auth;


ALTER SCHEMA auth OWNER TO supabase_admin;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'Pickly Benefit Announcement System - Migration 20251024000000';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


ALTER TYPE auth.aal_level OWNER TO supabase_auth_admin;

--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


ALTER TYPE auth.code_challenge_method OWNER TO supabase_auth_admin;

--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


ALTER TYPE auth.factor_status OWNER TO supabase_auth_admin;

--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


ALTER TYPE auth.factor_type OWNER TO supabase_auth_admin;

--
-- Name: oauth_authorization_status; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_authorization_status AS ENUM (
    'pending',
    'approved',
    'denied',
    'expired'
);


ALTER TYPE auth.oauth_authorization_status OWNER TO supabase_auth_admin;

--
-- Name: oauth_client_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_client_type AS ENUM (
    'public',
    'confidential'
);


ALTER TYPE auth.oauth_client_type OWNER TO supabase_auth_admin;

--
-- Name: oauth_registration_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_registration_type AS ENUM (
    'dynamic',
    'manual'
);


ALTER TYPE auth.oauth_registration_type OWNER TO supabase_auth_admin;

--
-- Name: oauth_response_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_response_type AS ENUM (
    'code'
);


ALTER TYPE auth.oauth_response_type OWNER TO supabase_auth_admin;

--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


ALTER TYPE auth.one_time_token_type OWNER TO supabase_auth_admin;

--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


ALTER FUNCTION auth.email() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


ALTER FUNCTION auth.jwt() OWNER TO supabase_auth_admin;

--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


ALTER FUNCTION auth.role() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


ALTER FUNCTION auth.uid() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: generate_announcement_file_path(uuid, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.generate_announcement_file_path(p_announcement_id uuid, p_file_type text, p_file_name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN format('announcements/%s/%s/%s',
    p_file_type,
    p_announcement_id::text,
    p_file_name
  );
END;
$$;


ALTER FUNCTION public.generate_announcement_file_path(p_announcement_id uuid, p_file_type text, p_file_name text) OWNER TO postgres;

--
-- Name: generate_banner_path(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.generate_banner_path(p_category text, p_file_name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN format('banners/%s/%s', p_category, p_file_name);
END;
$$;


ALTER FUNCTION public.generate_banner_path(p_category text, p_file_name text) OWNER TO postgres;

--
-- Name: get_storage_public_url(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_storage_public_url(p_bucket_id text, p_path text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_project_url TEXT;
BEGIN
  -- Get the Supabase project URL from config
  -- In production, this should be the actual project URL
  v_project_url := current_setting('app.settings.supabase_url', true);

  IF v_project_url IS NULL THEN
    v_project_url := 'http://localhost:54321'; -- Local development default
  END IF;

  RETURN format('%s/storage/v1/object/public/%s/%s',
    v_project_url,
    p_bucket_id,
    p_path
  );
END;
$$;


ALTER FUNCTION public.get_storage_public_url(p_bucket_id text, p_path text) OWNER TO postgres;

--
-- Name: is_admin(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.is_admin() RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1
    FROM auth.users
    WHERE id = auth.uid()
    AND email = 'admin@pickly.com'
  );
$$;


ALTER FUNCTION public.is_admin() OWNER TO postgres;

--
-- Name: FUNCTION is_admin(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION public.is_admin() IS 'Returns true if the current user is an admin';


--
-- Name: update_announcement_search_vector(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_announcement_search_vector() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('simple', COALESCE(NEW.title, '')), 'A') ||
        setweight(to_tsvector('simple', COALESCE(NEW.subtitle, '')), 'B') ||
        setweight(to_tsvector('simple', COALESCE(NEW.summary, '')), 'C') ||
        setweight(to_tsvector('simple', COALESCE(NEW.organization, '')), 'D') ||
        setweight(to_tsvector('simple', COALESCE(array_to_string(NEW.tags, ' '), '')), 'B');
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_announcement_search_vector() OWNER TO postgres;

--
-- Name: update_announcement_types_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_announcement_types_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN NEW.updated_at = timezone('utc'::text, now()); RETURN NEW; END;
$$;


ALTER FUNCTION public.update_announcement_types_updated_at() OWNER TO postgres;

--
-- Name: update_announcements_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_announcements_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN NEW.updated_at = timezone('utc'::text, now()); RETURN NEW; END;
$$;


ALTER FUNCTION public.update_announcements_updated_at() OWNER TO postgres;

--
-- Name: update_display_orders(uuid, uuid[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_display_orders(p_category_id uuid, p_announcement_ids uuid[]) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
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
$$;


ALTER FUNCTION public.update_display_orders(p_category_id uuid, p_announcement_ids uuid[]) OWNER TO postgres;

--
-- Name: FUNCTION update_display_orders(p_category_id uuid, p_announcement_ids uuid[]); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION public.update_display_orders(p_category_id uuid, p_announcement_ids uuid[]) IS 'Updates announcement display order and logs changes to audit trail';


--
-- Name: update_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at() OWNER TO postgres;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE auth.audit_log_entries OWNER TO supabase_auth_admin;

--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text NOT NULL,
    code_challenge_method auth.code_challenge_method NOT NULL,
    code_challenge text NOT NULL,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone
);


ALTER TABLE auth.flow_state OWNER TO supabase_auth_admin;

--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.flow_state IS 'stores metadata for pkce logins';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE auth.identities OWNER TO supabase_auth_admin;

--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE auth.instances OWNER TO supabase_auth_admin;

--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


ALTER TABLE auth.mfa_amr_claims OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);


ALTER TABLE auth.mfa_challenges OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid
);


ALTER TABLE auth.mfa_factors OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: oauth_authorizations; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.oauth_authorizations (
    id uuid NOT NULL,
    authorization_id text NOT NULL,
    client_id uuid NOT NULL,
    user_id uuid,
    redirect_uri text NOT NULL,
    scope text NOT NULL,
    state text,
    resource text,
    code_challenge text,
    code_challenge_method auth.code_challenge_method,
    response_type auth.oauth_response_type DEFAULT 'code'::auth.oauth_response_type NOT NULL,
    status auth.oauth_authorization_status DEFAULT 'pending'::auth.oauth_authorization_status NOT NULL,
    authorization_code text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '00:03:00'::interval) NOT NULL,
    approved_at timestamp with time zone,
    CONSTRAINT oauth_authorizations_authorization_code_length CHECK ((char_length(authorization_code) <= 255)),
    CONSTRAINT oauth_authorizations_code_challenge_length CHECK ((char_length(code_challenge) <= 128)),
    CONSTRAINT oauth_authorizations_expires_at_future CHECK ((expires_at > created_at)),
    CONSTRAINT oauth_authorizations_redirect_uri_length CHECK ((char_length(redirect_uri) <= 2048)),
    CONSTRAINT oauth_authorizations_resource_length CHECK ((char_length(resource) <= 2048)),
    CONSTRAINT oauth_authorizations_scope_length CHECK ((char_length(scope) <= 4096)),
    CONSTRAINT oauth_authorizations_state_length CHECK ((char_length(state) <= 4096))
);


ALTER TABLE auth.oauth_authorizations OWNER TO supabase_auth_admin;

--
-- Name: oauth_clients; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.oauth_clients (
    id uuid NOT NULL,
    client_secret_hash text,
    registration_type auth.oauth_registration_type NOT NULL,
    redirect_uris text NOT NULL,
    grant_types text NOT NULL,
    client_name text,
    client_uri text,
    logo_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    client_type auth.oauth_client_type DEFAULT 'confidential'::auth.oauth_client_type NOT NULL,
    CONSTRAINT oauth_clients_client_name_length CHECK ((char_length(client_name) <= 1024)),
    CONSTRAINT oauth_clients_client_uri_length CHECK ((char_length(client_uri) <= 2048)),
    CONSTRAINT oauth_clients_logo_uri_length CHECK ((char_length(logo_uri) <= 2048))
);


ALTER TABLE auth.oauth_clients OWNER TO supabase_auth_admin;

--
-- Name: oauth_consents; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.oauth_consents (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    client_id uuid NOT NULL,
    scopes text NOT NULL,
    granted_at timestamp with time zone DEFAULT now() NOT NULL,
    revoked_at timestamp with time zone,
    CONSTRAINT oauth_consents_revoked_after_granted CHECK (((revoked_at IS NULL) OR (revoked_at >= granted_at))),
    CONSTRAINT oauth_consents_scopes_length CHECK ((char_length(scopes) <= 2048)),
    CONSTRAINT oauth_consents_scopes_not_empty CHECK ((char_length(TRIM(BOTH FROM scopes)) > 0))
);


ALTER TABLE auth.oauth_consents OWNER TO supabase_auth_admin;

--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


ALTER TABLE auth.one_time_tokens OWNER TO supabase_auth_admin;

--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


ALTER TABLE auth.refresh_tokens OWNER TO supabase_auth_admin;

--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: supabase_auth_admin
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE auth.refresh_tokens_id_seq OWNER TO supabase_auth_admin;

--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: supabase_auth_admin
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


ALTER TABLE auth.saml_providers OWNER TO supabase_auth_admin;

--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


ALTER TABLE auth.saml_relay_states OWNER TO supabase_auth_admin;

--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE auth.schema_migrations OWNER TO supabase_auth_admin;

--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text,
    oauth_client_id uuid
);


ALTER TABLE auth.sessions OWNER TO supabase_auth_admin;

--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


ALTER TABLE auth.sso_domains OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    disabled boolean,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


ALTER TABLE auth.sso_providers OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


ALTER TABLE auth.users OWNER TO supabase_auth_admin;

--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: age_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.age_categories (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    title text NOT NULL,
    description text NOT NULL,
    icon_component text NOT NULL,
    icon_url text,
    min_age integer,
    max_age integer,
    sort_order integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.age_categories OWNER TO postgres;

--
-- Name: announcement_ai_chats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.announcement_ai_chats (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    announcement_id uuid,
    user_id uuid NOT NULL,
    session_id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    role character varying(20) NOT NULL,
    content text NOT NULL,
    model_name character varying(100),
    tokens_used integer,
    response_time_ms integer,
    context_data jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ai_chats_content_not_empty CHECK ((char_length(content) > 0)),
    CONSTRAINT ai_chats_response_time_positive CHECK (((response_time_ms IS NULL) OR (response_time_ms > 0))),
    CONSTRAINT ai_chats_tokens_non_negative CHECK (((tokens_used IS NULL) OR (tokens_used >= 0))),
    CONSTRAINT announcement_ai_chats_role_check CHECK (((role)::text = ANY ((ARRAY['user'::character varying, 'assistant'::character varying, 'system'::character varying])::text[])))
);


ALTER TABLE public.announcement_ai_chats OWNER TO postgres;

--
-- Name: TABLE announcement_ai_chats; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.announcement_ai_chats IS 'AI 챗봇 대화 기록 (미래 확장용)';


--
-- Name: COLUMN announcement_ai_chats.session_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.announcement_ai_chats.session_id IS 'Groups messages in a conversation session';


--
-- Name: COLUMN announcement_ai_chats.context_data; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.announcement_ai_chats.context_data IS 'JSON data for AI context and metadata';


--
-- Name: announcement_comments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.announcement_comments (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    announcement_id uuid NOT NULL,
    user_id uuid NOT NULL,
    parent_comment_id uuid,
    content text NOT NULL,
    is_edited boolean DEFAULT false NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    is_reported boolean DEFAULT false NOT NULL,
    moderation_status character varying(20) DEFAULT 'pending'::character varying,
    likes_count integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT announcement_comments_moderation_status_check CHECK (((moderation_status)::text = ANY ((ARRAY['pending'::character varying, 'approved'::character varying, 'rejected'::character varying])::text[]))),
    CONSTRAINT comments_content_not_empty CHECK (((char_length(content) > 0) OR (is_deleted = true))),
    CONSTRAINT comments_likes_non_negative CHECK ((likes_count >= 0))
);


ALTER TABLE public.announcement_comments OWNER TO postgres;

--
-- Name: TABLE announcement_comments; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.announcement_comments IS '공고 댓글 테이블 (미래 확장용)';


--
-- Name: COLUMN announcement_comments.parent_comment_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.announcement_comments.parent_comment_id IS 'For nested/threaded comments';


--
-- Name: announcement_files; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.announcement_files (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    announcement_id uuid NOT NULL,
    file_name character varying(500) NOT NULL,
    file_url character varying(1000) NOT NULL,
    file_type character varying(100),
    file_size bigint,
    display_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.announcement_files OWNER TO postgres;

--
-- Name: TABLE announcement_files; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.announcement_files IS 'File attachments for benefit announcements';


--
-- Name: announcement_sections; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.announcement_sections (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    announcement_id uuid NOT NULL,
    section_type character varying(50) NOT NULL,
    title character varying(255) NOT NULL,
    content text NOT NULL,
    structured_data jsonb,
    display_order integer DEFAULT 0 NOT NULL,
    is_visible boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT sections_content_not_empty CHECK ((char_length(content) > 0)),
    CONSTRAINT sections_title_not_empty CHECK ((char_length((title)::text) > 0))
);


ALTER TABLE public.announcement_sections OWNER TO postgres;

--
-- Name: TABLE announcement_sections; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.announcement_sections IS '공고별 커스텀 섹션 (자격요건, 구비서류 등)';


--
-- Name: COLUMN announcement_sections.section_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.announcement_sections.section_type IS 'Type of section: eligibility, documents, schedule, benefits, etc.';


--
-- Name: COLUMN announcement_sections.structured_data; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.announcement_sections.structured_data IS 'JSON data for complex structures like lists and tables';


--
-- Name: announcement_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.announcement_types (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    benefit_category_id uuid NOT NULL,
    title text NOT NULL,
    description text,
    sort_order integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


ALTER TABLE public.announcement_types OWNER TO postgres;

--
-- Name: announcement_unit_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.announcement_unit_types (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    announcement_id uuid NOT NULL,
    unit_type character varying(50) NOT NULL,
    exclusive_area numeric(10,2),
    supply_area numeric(10,2),
    unit_count integer,
    sale_price numeric(15,2),
    deposit_amount numeric(15,2),
    monthly_rent numeric(15,2),
    room_layout character varying(50),
    special_conditions text,
    display_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT unit_types_areas_positive CHECK ((((exclusive_area IS NULL) OR (exclusive_area > (0)::numeric)) AND ((supply_area IS NULL) OR (supply_area > (0)::numeric)))),
    CONSTRAINT unit_types_count_positive CHECK (((unit_count IS NULL) OR (unit_count > 0))),
    CONSTRAINT unit_types_prices_non_negative CHECK ((((sale_price IS NULL) OR (sale_price >= (0)::numeric)) AND ((deposit_amount IS NULL) OR (deposit_amount >= (0)::numeric)) AND ((monthly_rent IS NULL) OR (monthly_rent >= (0)::numeric)))),
    CONSTRAINT unit_types_unit_type_not_empty CHECK ((char_length((unit_type)::text) > 0))
);


ALTER TABLE public.announcement_unit_types OWNER TO postgres;

--
-- Name: TABLE announcement_unit_types; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.announcement_unit_types IS '공고별 평수 정보 테이블 (주거 카테고리용)';


--
-- Name: COLUMN announcement_unit_types.exclusive_area; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.announcement_unit_types.exclusive_area IS '전용면적 (㎡)';


--
-- Name: COLUMN announcement_unit_types.supply_area; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.announcement_unit_types.supply_area IS '공급면적 (㎡)';


--
-- Name: announcements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.announcements (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    type_id uuid NOT NULL,
    title text NOT NULL,
    organization text NOT NULL,
    region text,
    thumbnail_url text,
    posted_date date,
    status text DEFAULT 'active'::text NOT NULL,
    is_priority boolean DEFAULT false NOT NULL,
    detail_url text,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT announcements_status_check CHECK ((status = ANY (ARRAY['active'::text, 'closed'::text, 'upcoming'::text])))
);


ALTER TABLE public.announcements OWNER TO postgres;

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
-- Name: benefit_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.benefit_categories (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    title character varying(50) NOT NULL,
    slug character varying(50) NOT NULL,
    description text,
    icon_url text,
    sort_order integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    custom_fields jsonb DEFAULT '{}'::jsonb,
    parent_id uuid,
    CONSTRAINT benefit_categories_display_order_positive CHECK ((sort_order >= 0)),
    CONSTRAINT benefit_categories_name_not_empty CHECK ((char_length((title)::text) > 0)),
    CONSTRAINT benefit_categories_slug_not_empty CHECK ((char_length((slug)::text) > 0))
);


ALTER TABLE public.benefit_categories OWNER TO postgres;

--
-- Name: TABLE benefit_categories; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.benefit_categories IS '혜택 카테고리 테이블 (주거, 복지, 교육 등)';


--
-- Name: COLUMN benefit_categories.slug; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.benefit_categories.slug IS 'URL-friendly identifier for the category';


--
-- Name: COLUMN benefit_categories.sort_order; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.benefit_categories.sort_order IS 'Order in which categories are displayed';


--
-- Name: COLUMN benefit_categories.parent_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.benefit_categories.parent_id IS 'Parent category ID for subcategories';


--
-- Name: benefit_files; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.benefit_files (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    announcement_id uuid,
    file_type text NOT NULL,
    storage_path text NOT NULL,
    file_name text NOT NULL,
    file_size integer,
    mime_type text,
    public_url text,
    uploaded_by uuid,
    uploaded_at timestamp with time zone DEFAULT now(),
    metadata jsonb DEFAULT '{}'::jsonb,
    CONSTRAINT benefit_files_file_type_check CHECK ((file_type = ANY (ARRAY['thumbnail'::text, 'image'::text, 'document'::text, 'banner'::text])))
);


ALTER TABLE public.benefit_files OWNER TO postgres;

--
-- Name: TABLE benefit_files; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.benefit_files IS 'Tracks all uploaded files for benefit announcements and banners';


--
-- Name: category_banners; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.category_banners (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    benefit_category_id uuid NOT NULL,
    title character varying(100) NOT NULL,
    subtitle character varying(200),
    image_url text NOT NULL,
    background_color character varying(20) DEFAULT '#E3F2FD'::character varying,
    link_target text,
    sort_order integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    link_type text DEFAULT 'internal'::text,
    CONSTRAINT category_banners_link_type_check CHECK ((link_type = ANY (ARRAY['internal'::text, 'external'::text, 'none'::text])))
);


ALTER TABLE public.category_banners OWNER TO postgres;

--
-- Name: TABLE category_banners; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.category_banners IS 'Category banners - Admin backoffice only, RLS policies allow full access for development';


--
-- Name: COLUMN category_banners.benefit_category_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.category_banners.benefit_category_id IS 'Reference to benefit_categories table';


--
-- Name: COLUMN category_banners.background_color; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.category_banners.background_color IS 'Hex color code for banner background (e.g., #E3F2FD)';


--
-- Name: COLUMN category_banners.sort_order; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.category_banners.sort_order IS 'Order in which banners appear (lower = higher priority)';


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
-- Name: storage_folders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.storage_folders (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text DEFAULT 'pickly-storage'::text NOT NULL,
    path text NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.storage_folders OWNER TO postgres;

--
-- Name: TABLE storage_folders; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.storage_folders IS 'Documents the intended folder structure in pickly-storage bucket';


--
-- Name: user_profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_profiles (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    user_id uuid,
    name text,
    age integer,
    gender text,
    region_sido text,
    region_sigungu text,
    selected_categories uuid[],
    income_level text,
    interest_policies uuid[],
    onboarding_completed boolean DEFAULT false,
    onboarding_step integer DEFAULT 1,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.user_profiles OWNER TO postgres;

--
-- Name: v_announcement_files; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_announcement_files AS
 SELECT bf.id,
    bf.announcement_id,
    ba.title AS announcement_title,
    ba.organization,
    bf.file_type,
    bf.storage_path,
    bf.file_name,
    bf.file_size,
    bf.mime_type,
    bf.public_url,
    bf.uploaded_at,
    bf.metadata
   FROM (public.benefit_files bf
     LEFT JOIN public.benefit_announcements ba ON ((bf.announcement_id = ba.id)))
  ORDER BY bf.uploaded_at DESC;


ALTER VIEW public.v_announcement_files OWNER TO postgres;

--
-- Name: VIEW v_announcement_files; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public.v_announcement_files IS 'Combined view of files with announcement details';


--
-- Name: v_announcement_stats; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_announcement_stats AS
SELECT
    NULL::character varying(50) AS category_name,
    NULL::character varying(50) AS category_slug,
    NULL::bigint AS total_announcements,
    NULL::bigint AS published_count,
    NULL::bigint AS featured_count,
    NULL::bigint AS total_views;


ALTER VIEW public.v_announcement_stats OWNER TO postgres;

--
-- Name: v_announcements_full; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_announcements_full AS
 SELECT a.id,
    a.title,
    a.organization,
    a.region,
    a.thumbnail_url,
    a.posted_date,
    a.status,
    a.is_priority,
    a.detail_url,
    a.created_at,
    a.updated_at,
    at.id AS type_id,
    at.title AS type_title,
    bc.id AS category_id,
    bc.title AS category_title
   FROM ((public.announcements a
     JOIN public.announcement_types at ON ((a.type_id = at.id)))
     JOIN public.benefit_categories bc ON ((at.benefit_category_id = bc.id)));


ALTER VIEW public.v_announcements_full OWNER TO postgres;

--
-- Name: v_published_announcements; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_published_announcements AS
 SELECT a.id,
    a.category_id,
    a.title,
    a.subtitle,
    a.organization,
    a.application_period_start,
    a.application_period_end,
    a.announcement_date,
    a.status,
    a.is_featured,
    a.views_count,
    a.summary,
    a.thumbnail_url,
    a.external_url,
    a.tags,
    a.search_vector,
    a.created_at,
    a.updated_at,
    a.published_at,
    c.title AS category_name,
    c.slug AS category_slug,
        CASE
            WHEN (a.application_period_end IS NULL) THEN NULL::text
            WHEN (a.application_period_end >= CURRENT_DATE) THEN 'active'::text
            ELSE 'expired'::text
        END AS application_status
   FROM (public.benefit_announcements a
     JOIN public.benefit_categories c ON ((a.category_id = c.id)))
  WHERE ((a.status)::text = 'published'::text)
  ORDER BY a.published_at DESC;


ALTER VIEW public.v_published_announcements OWNER TO postgres;

--
-- Name: v_featured_announcements; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_featured_announcements AS
 SELECT id,
    category_id,
    title,
    subtitle,
    organization,
    application_period_start,
    application_period_end,
    announcement_date,
    status,
    is_featured,
    views_count,
    summary,
    thumbnail_url,
    external_url,
    tags,
    search_vector,
    created_at,
    updated_at,
    published_at,
    category_name,
    category_slug,
    application_status
   FROM public.v_published_announcements
  WHERE (is_featured = true)
  ORDER BY published_at DESC
 LIMIT 10;


ALTER VIEW public.v_featured_announcements OWNER TO postgres;

--
-- Name: v_storage_stats; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_storage_stats AS
 SELECT file_type,
    count(*) AS file_count,
    sum(file_size) AS total_size_bytes,
    round((((sum(file_size))::numeric / (1024)::numeric) / (1024)::numeric), 2) AS total_size_mb,
    (avg(file_size))::bigint AS avg_file_size_bytes
   FROM public.benefit_files
  GROUP BY file_type;


ALTER VIEW public.v_storage_stats OWNER TO postgres;

--
-- Name: VIEW v_storage_stats; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public.v_storage_stats IS 'Storage usage statistics by file type';


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) FROM stdin;
\.


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.flow_state (id, user_id, auth_code, code_challenge_method, code_challenge, provider_type, provider_access_token, provider_refresh_token, created_at, updated_at, authentication_method, auth_code_issued_at) FROM stdin;
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) FROM stdin;
admin@pickly.com	0f6e12db-d0c3-4520-b271-92197a303955	{"sub": "0f6e12db-d0c3-4520-b271-92197a303955", "email": "admin@pickly.com"}	email	2025-11-02 11:58:35.644849+00	2025-11-02 11:58:35.644849+00	2025-11-02 11:58:35.644849+00	82145acb-e8ee-4028-8a6d-d6445c17ca7d
\.


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.instances (id, uuid, raw_base_config, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_amr_claims (session_id, created_at, updated_at, authentication_method, id) FROM stdin;
\.


--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_challenges (id, factor_id, created_at, verified_at, ip_address, otp_code, web_authn_session_data) FROM stdin;
\.


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_factors (id, user_id, friendly_name, factor_type, status, created_at, updated_at, secret, phone, last_challenged_at, web_authn_credential, web_authn_aaguid) FROM stdin;
\.


--
-- Data for Name: oauth_authorizations; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.oauth_authorizations (id, authorization_id, client_id, user_id, redirect_uri, scope, state, resource, code_challenge, code_challenge_method, response_type, status, authorization_code, created_at, expires_at, approved_at) FROM stdin;
\.


--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.oauth_clients (id, client_secret_hash, registration_type, redirect_uris, grant_types, client_name, client_uri, logo_uri, created_at, updated_at, deleted_at, client_type) FROM stdin;
\.


--
-- Data for Name: oauth_consents; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.oauth_consents (id, user_id, client_id, scopes, granted_at, revoked_at) FROM stdin;
\.


--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.one_time_tokens (id, user_id, token_type, token_hash, relates_to, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.refresh_tokens (instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id) FROM stdin;
\.


--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.saml_providers (id, sso_provider_id, entity_id, metadata_xml, metadata_url, attribute_mapping, created_at, updated_at, name_id_format) FROM stdin;
\.


--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.saml_relay_states (id, sso_provider_id, request_id, for_email, redirect_to, created_at, updated_at, flow_state_id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.schema_migrations (version) FROM stdin;
20171026211738
20171026211808
20171026211834
20180103212743
20180108183307
20180119214651
20180125194653
00
20210710035447
20210722035447
20210730183235
20210909172000
20210927181326
20211122151130
20211124214934
20211202183645
20220114185221
20220114185340
20220224000811
20220323170000
20220429102000
20220531120530
20220614074223
20220811173540
20221003041349
20221003041400
20221011041400
20221020193600
20221021073300
20221021082433
20221027105023
20221114143122
20221114143410
20221125140132
20221208132122
20221215195500
20221215195800
20221215195900
20230116124310
20230116124412
20230131181311
20230322519590
20230402418590
20230411005111
20230508135423
20230523124323
20230818113222
20230914180801
20231027141322
20231114161723
20231117164230
20240115144230
20240214120130
20240306115329
20240314092811
20240427152123
20240612123726
20240729123726
20240802193726
20240806073726
20241009103726
20250717082212
20250731150234
20250804100000
20250901200500
20250903112500
20250904133000
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sessions (id, user_id, created_at, updated_at, factor_id, aal, not_after, refreshed_at, user_agent, ip, tag, oauth_client_id) FROM stdin;
\.


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sso_domains (id, sso_provider_id, domain, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sso_providers (id, resource_id, created_at, updated_at, disabled) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) FROM stdin;
00000000-0000-0000-0000-000000000000	0f6e12db-d0c3-4520-b271-92197a303955	authenticated	authenticated	admin@pickly.com	$2a$06$Mgf01HX4k.t02sCEO.dpnOi.KPeNk8rD0zg2K2vowtmZLZOZJadIi	2025-11-02 11:58:30.787534+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	{"provider": "email", "providers": ["email"]}	{}	\N	2025-11-02 11:58:30.787534+00	2025-11-02 11:58:30.787534+00	\N	\N			\N		0	\N		\N	f	\N	f
\.


--
-- Data for Name: age_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.age_categories (id, title, description, icon_component, icon_url, min_age, max_age, sort_order, is_active, created_at, updated_at) FROM stdin;
e3f740a5-fe8e-4cb2-8bfd-de8553ad665e	청년	(만 19세-39세) 대학생, 취업준비생, 직장인	young_man	packages/pickly_design_system/assets/icons/age_categories/young_man.svg	19	39	1	t	2025-11-02 11:54:02.657644+00	2025-11-02 11:54:02.665957+00
e54ec703-4f37-4116-93a2-59c9bdec31eb	신혼부부·예비부부	결혼 예정 또는 결혼 7년이내	bride	packages/pickly_design_system/assets/icons/age_categories/bride.svg	\N	\N	2	t	2025-11-02 11:54:02.657644+00	2025-11-02 11:54:02.665957+00
f6c1b16d-eca5-4e89-ab05-e9b325ff82ba	육아중인 부모	영유아~초등 자녀 양육 중	baby	packages/pickly_design_system/assets/icons/age_categories/baby.svg	\N	\N	3	t	2025-11-02 11:54:02.657644+00	2025-11-02 11:54:02.665957+00
86a25686-ccfb-4210-a133-2d8784153cb2	다자녀 가구	자녀 2명 이상 양육중	kinder	packages/pickly_design_system/assets/icons/age_categories/kinder.svg	\N	\N	4	t	2025-11-02 11:54:02.657644+00	2025-11-02 11:54:02.665957+00
b1ebd842-cc83-4ca9-b56e-46323654e2c1	어르신	만 65세 이상	old_man	packages/pickly_design_system/assets/icons/age_categories/old_man.svg	65	\N	5	t	2025-11-02 11:54:02.657644+00	2025-11-02 11:54:02.665957+00
78b1830d-ce0c-4eba-b447-9e0dc703bf64	장애인	장애인 등록 대상	wheel_chair	packages/pickly_design_system/assets/icons/age_categories/wheel_chair.svg	\N	\N	6	t	2025-11-02 11:54:02.657644+00	2025-11-02 11:54:02.665957+00
64edc2de-b4b8-4fcb-954c-b043891480c0	유아	(0~7세) 영유아 및 미취학 아동	baby	packages/pickly_design_system/assets/icons/age_categories/baby.svg	0	7	1	t	2025-11-02 11:54:02.787228+00	2025-11-02 11:54:02.787228+00
4775f9b2-ccad-41fd-b25c-8ffcd9778f81	어린이	(8~13세) 초등학생	kinder	packages/pickly_design_system/assets/icons/age_categories/kinder.svg	8	13	2	t	2025-11-02 11:54:02.787228+00	2025-11-02 11:54:02.787228+00
158bde5a-fb9e-454d-be62-559e0baafc27	청소년	(14~19세) 중고등학생	young_man	packages/pickly_design_system/assets/icons/age_categories/young_man.svg	14	19	3	t	2025-11-02 11:54:02.787228+00	2025-11-02 11:54:02.787228+00
ce1dbf16-b241-4c05-abe7-3c634b39be0a	청년	(20~34세) 대학생, 취업준비생, 직장인	bride	packages/pickly_design_system/assets/icons/age_categories/bride.svg	20	34	4	t	2025-11-02 11:54:02.787228+00	2025-11-02 11:54:02.787228+00
c935ef49-03fb-4c6b-9da1-3dc12abb9b7f	중년	(35~49세) 중장년층	old_man	packages/pickly_design_system/assets/icons/age_categories/old_man.svg	35	49	5	t	2025-11-02 11:54:02.787228+00	2025-11-02 11:54:02.787228+00
fb3a725b-fa17-42f1-8971-b3d927de402c	노년	(50세 이상) 장년 및 어르신	wheel_chair	packages/pickly_design_system/assets/icons/age_categories/wheel_chair.svg	50	\N	6	t	2025-11-02 11:54:02.787228+00	2025-11-02 11:54:02.787228+00
\.


--
-- Data for Name: announcement_ai_chats; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.announcement_ai_chats (id, announcement_id, user_id, session_id, role, content, model_name, tokens_used, response_time_ms, context_data, created_at) FROM stdin;
\.


--
-- Data for Name: announcement_comments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.announcement_comments (id, announcement_id, user_id, parent_comment_id, content, is_edited, is_deleted, is_reported, moderation_status, likes_count, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: announcement_files; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.announcement_files (id, announcement_id, file_name, file_url, file_type, file_size, display_order, created_at) FROM stdin;
\.


--
-- Data for Name: announcement_sections; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.announcement_sections (id, announcement_id, section_type, title, content, structured_data, display_order, is_visible, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: announcement_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.announcement_types (id, benefit_category_id, title, description, sort_order, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: announcement_unit_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.announcement_unit_types (id, announcement_id, unit_type, exclusive_area, supply_area, unit_count, sale_price, deposit_amount, monthly_rent, room_layout, special_conditions, display_order, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: announcements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.announcements (id, type_id, title, organization, region, thumbnail_url, posted_date, status, is_priority, detail_url, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: benefit_announcements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.benefit_announcements (id, category_id, title, subtitle, organization, application_period_start, application_period_end, announcement_date, status, is_featured, views_count, summary, thumbnail_url, external_url, tags, search_vector, created_at, updated_at, published_at, display_order, custom_data, content) FROM stdin;
\.


--
-- Data for Name: benefit_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.benefit_categories (id, title, slug, description, icon_url, sort_order, is_active, created_at, updated_at, custom_fields, parent_id) FROM stdin;
4fd59eb0-0421-48bd-965e-90561e564ab1	인기	popular	가장 인기있는 혜택 모음	popular.svg	0	t	2025-11-02 11:54:02.76071+00	2025-11-03 09:14:29.162371+00	{}	\N
67725679-cb27-4ac8-9467-a02482102004	주거	housing	주거 관련 혜택 및 지원	housing.svg	1	t	2025-11-02 11:54:02.670927+00	2025-11-03 09:14:29.162371+00	{"asset_limit": true, "family_size": ["1인", "2인", "3인", "4인 이상"], "housing_type": ["원룸", "투룸", "쓰리룸"], "income_limit": true, "age_categories": ["청년(19-39세)", "신혼부부", "고령자(65세 이상)"], "region_categories": ["서울", "경기", "인천", "부산", "대구", "광주", "대전", "울산", "세종"]}	\N
803d5bb6-5cc9-4485-8428-b63a29379c4b	복지	welfare	복지 관련 혜택 및 지원	heart.svg	5	t	2025-11-02 11:54:02.670927+00	2025-11-03 09:14:29.162371+00	{"income_limit": true, "program_type": ["현금지원", "바우처", "현물지원", "서비스제공"], "target_group": ["저소득층", "장애인", "한부모가정", "다문화가정", "노인"]}	\N
b614b294-57b6-4226-ae3a-f6386a241c74	취업	employment	취업 관련 혜택 및 지원	employment.svg	6	t	2025-11-02 11:54:02.670927+00	2025-11-03 09:14:29.162371+00	{"job_type": ["정규직", "계약직", "인턴", "아르바이트"], "program_type": ["취업지원", "직업훈련", "창업지원", "자격증지원"], "target_group": ["청년", "경력단절여성", "중장년", "장애인"]}	\N
a45a56c2-d595-4f49-ab7a-67d23fe96a78	문화	culture	문화 관련 혜택 및 지원	culture.svg	7	t	2025-11-03 06:58:42.540074+00	2025-11-03 09:14:29.162371+00	{"support_type": ["이용권", "할인", "무료이용", "프로그램"], "target_group": ["전체", "청소년", "성인", "노인", "장애인"], "activity_type": ["공연", "전시", "체육", "여가", "도서"]}	\N
262b5854-786e-4a0d-b843-976601df96a8	교육	education	교육 관련 혜택 및 지원	education.svg	2	t	2025-11-02 11:54:02.670927+00	2025-11-03 09:14:29.162371+00	{"income_limit": true, "support_type": ["학비지원", "장학금", "교육프로그램", "교재지원"], "education_level": ["초등", "중등", "고등", "대학", "평생교육"]}	\N
89e36b73-c9ef-44b3-bd27-319beccc618e	건강	health	건강 관련 혜택 및 지원	health.svg	3	t	2025-11-02 11:54:02.670927+00	2025-11-03 09:14:29.162371+00	{"income_limit": true, "service_type": ["건강검진", "의료비지원", "예방접종", "건강교육"], "target_group": ["영유아", "아동", "청소년", "성인", "노인"]}	\N
884b1f9c-b782-4a97-bf4c-b155c0ba7d34	교통	transportation	교통비 지원 및 할인	transportation.svg	4	t	2025-11-02 11:54:02.76071+00	2025-11-03 09:14:29.162371+00	{}	\N
\.


--
-- Data for Name: benefit_files; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.benefit_files (id, announcement_id, file_type, storage_path, file_name, file_size, mime_type, public_url, uploaded_by, uploaded_at, metadata) FROM stdin;
a23190b3-bb61-4d33-8b43-3b570d0eeb28	\N	banner	banners/test/sample.jpg	sample.jpg	\N	image/jpeg	http://localhost:54321/storage/v1/object/public/pickly-storage/banners/test/sample.jpg	\N	2025-11-02 11:54:02.713322+00	{"is_test": true, "description": "Test banner image"}
\.


--
-- Data for Name: category_banners; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.category_banners (id, benefit_category_id, title, subtitle, image_url, background_color, link_target, sort_order, is_active, created_at, updated_at, link_type) FROM stdin;
0d0cf37a-33fc-4bf9-bfe2-e01e7c2b8775	67725679-cb27-4ac8-9467-a02482102004	청년 주거 지원	월세 최대 30만원 지원	https://picsum.photos/seed/housing1/800/400	#E3F2FD	/benefits/housing/youth-housing	0	t	2025-11-02 11:54:02.787228+00	2025-11-02 11:54:02.787228+00	internal
af28b0b3-53e1-4e06-8d61-0957e4d1e28f	67725679-cb27-4ac8-9467-a02482102004	전세자금 대출	무이자 전세자금 대출 안내	https://picsum.photos/seed/housing2/800/400	#E3F2FD	/benefits/housing/jeonse-loan	1	t	2025-11-02 11:54:02.787228+00	2025-11-02 11:54:02.787228+00	internal
fdf8aa8b-5787-48b2-8c20-9ce29cb6c417	803d5bb6-5cc9-4485-8428-b63a29379c4b	다자녀 가구 혜택	자녀 3명 이상 가구 지원	https://picsum.photos/seed/welfare1/800/400	#E3F2FD	/benefits/welfare/multi-child	0	t	2025-11-02 11:54:02.787228+00	2025-11-02 11:54:02.787228+00	internal
1291d514-794e-44e6-8e89-e7a90479698c	803d5bb6-5cc9-4485-8428-b63a29379c4b	어르신 복지	65세 이상 종합 복지 안내	https://picsum.photos/seed/welfare2/800/400	#E3F2FD	/benefits/welfare/senior	1	t	2025-11-02 11:54:02.787228+00	2025-11-02 11:54:02.787228+00	internal
c48317c6-474d-4292-9aa9-7c3f0eef852e	262b5854-786e-4a0d-b843-976601df96a8	학자금 지원	대학생 등록금 지원 프로그램	https://picsum.photos/seed/education1/800/400	#E3F2FD	/benefits/education/scholarship	0	t	2025-11-02 11:54:02.787228+00	2025-11-02 11:54:02.787228+00	internal
c2e3367a-7360-48c7-a85c-133f300fb872	262b5854-786e-4a0d-b843-976601df96a8	직업 훈련	무료 직업훈련 과정 안내	https://picsum.photos/seed/education2/800/400	#E3F2FD	/benefits/education/training	1	t	2025-11-02 11:54:02.787228+00	2025-11-02 11:54:02.787228+00	internal
5851784d-4cc4-4c03-b586-80d4f5c9c345	b614b294-57b6-4226-ae3a-f6386a241c74	청년 일자리	청년 취업 지원금 최대 300만원	https://picsum.photos/seed/employment1/800/400	#E3F2FD	/benefits/employment/youth-job	0	t	2025-11-02 11:54:02.787228+00	2025-11-02 11:54:02.787228+00	internal
c3dbc15b-0732-4c78-bab5-1f44d5a17cb4	b614b294-57b6-4226-ae3a-f6386a241c74	창업 지원	초기 창업자 지원 프로그램	https://picsum.photos/seed/employment2/800/400	#E3F2FD	/benefits/employment/startup	1	t	2025-11-02 11:54:02.787228+00	2025-11-02 11:54:02.787228+00	internal
86e80355-f536-4b88-a330-baf44bbc64fa	89e36b73-c9ef-44b3-bd27-319beccc618e	건강검진 지원	무료 종합 건강검진	https://picsum.photos/seed/health1/800/400	#E3F2FD	/benefits/health/checkup	0	t	2025-11-02 11:54:02.787228+00	2025-11-02 11:54:02.787228+00	internal
201b1238-4c51-4f05-9b28-09d2ea2ec1c0	89e36b73-c9ef-44b3-bd27-319beccc618e	의료비 지원	저소득층 의료비 지원 안내	https://picsum.photos/seed/health2/800/400	#E3F2FD	/benefits/health/medical	1	t	2025-11-02 11:54:02.787228+00	2025-11-02 11:54:02.787228+00	internal
\.


--
-- Data for Name: display_order_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.display_order_history (id, category_id, announcement_id, old_order, new_order, changed_by, changed_at) FROM stdin;
\.


--
-- Data for Name: housing_announcements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.housing_announcements (id, title, subtitle, category, source, source_id, raw_data, display_config, housing_types, status, created_at, updated_at) FROM stdin;
7886e243-3498-49d8-82d9-9ec947a6baa9	하남미사 C3BL 행복주택	공고 마감까지 3일 남았어요	주거	LH	2024000001	{"PAN_ID": "2024000001", "PAN_NM": "하남미사 C3BL 행복주택", "HSHLD_CO": "1492", "CNP_CD_NM": "경기도", "RCRIT_PBLANC_DE": "20250930", "UPP_AIS_TP_CD_NM": "행복주택", "PRZWNER_PRESNATN_DE": "20251225", "SUBSCRPT_RCEPT_BGNDE": "20250930", "SUBSCRPT_RCEPT_ENDDE": "20251130"}	{"commonSections": [{"icon": "info", "type": "basic_info", "order": 1, "title": "기본 정보", "fields": [{"key": "source", "label": "공급 기관", "order": 1, "value": "LH 행복 주택", "visible": true}, {"key": "category", "label": "카테고리", "order": 2, "value": "행복주택", "visible": true}], "enabled": true}, {"icon": "calendar_today", "type": "schedule", "order": 2, "title": "일정", "fields": [{"key": "apply_period", "label": "접수 기간", "order": 1, "value": "2025.09.30(월) - 2025.11.30(월)", "visible": true}, {"key": "announcement_date", "label": "당첨자 발표", "order": 2, "value": "2025.12.25", "visible": true}], "enabled": true}, {"icon": "apartment", "type": "property", "order": 3, "title": "단지 정보", "fields": [{"key": "name", "label": "단지명", "order": 1, "value": "하남미사 C3BL 행복주택", "visible": true}, {"key": "address", "label": "주소", "order": 2, "value": "경기도 하남시 미사강변한강로 290-3", "visible": true}, {"key": "total_supply", "label": "총 공급호수", "order": 3, "value": "1,492호", "visible": true}], "enabled": true}, {"icon": "location_on", "type": "map", "order": 4, "title": "위치", "fields": [{"key": "address", "label": "주소", "order": 1, "value": "경기도 하남시 미사강변한강로 290-3", "visible": true}], "enabled": true}]}	[{"id": "16m-type1a", "area": 16, "type": "타입 1A", "order": 1, "sections": [{"icon": "person", "type": "eligibility", "order": 1, "title": "신청 자격", "fields": [{"key": "age", "label": "연령", "order": 1, "value": "만 19세 ~ 39세", "visible": true}, {"key": "residence", "label": "거주", "order": 2, "value": "경기도 6개월 이상 거주", "visible": true}, {"key": "housing", "label": "주택", "order": 3, "value": "무주택 / 사회초년생", "visible": true}], "enabled": true}, {"icon": "attach_money", "type": "income", "order": 2, "title": "소득 기준", "fields": [{"key": "household_income", "label": "가구 소득", "order": 1, "value": "전년도 도시근로자 월평균 소득 100% 이하", "detail": "1인 가구: 4,445,807원", "visible": true}, {"key": "personal_income", "label": "본인 소득", "order": 2, "value": "전년도 도시근로자 월평균 소득 70% 이하", "detail": "1인 가구: 3,112,065원", "visible": true}, {"key": "asset", "label": "자산", "order": 3, "value": "총자산 2억 8,800만원 이하", "detail": "부동산, 금융자산 등 합산", "visible": true}, {"key": "car", "label": "자동차", "order": 4, "value": "자동차 가액 3,683만원 이하", "detail": "차량 1대 기준", "visible": true}], "enabled": true, "description": "전년도 도시근로자 가구당 월평균 소득 기준"}, {"icon": "home", "type": "pricing", "order": 3, "title": "공급 조건", "fields": [{"key": "supply_count", "label": "공급호수", "order": 1, "value": "200호", "visible": true}, {"key": "deposit_standard", "label": "임대보증금 (표준)", "order": 2, "value": "3,284만원", "detail": "30% 임대료", "visible": true}, {"key": "monthly_rent_standard", "label": "월 임대료 (표준)", "order": 3, "value": "13.89만원", "visible": true}], "enabled": true}], "tabLabel": "타입 1A", "areaLabel": "16㎡ (약 5평)", "targetGroup": "청년", "floorPlanImage": ""}]	active	2025-11-02 11:54:02.764466+00	2025-11-02 11:54:02.764466+00
\.


--
-- Data for Name: storage_folders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.storage_folders (id, bucket_id, path, description, created_at) FROM stdin;
b9a83ab5-39cd-4c4d-8c01-ddead7e98e1e	pickly-storage	announcements/	Root folder for benefit announcements	2025-11-02 11:54:02.713322+00
e0223602-28da-4abe-b5ba-724a85bd2281	pickly-storage	announcements/thumbnails/	Thumbnail images for announcement cards	2025-11-02 11:54:02.713322+00
b3a32f80-44ad-4ca1-a4ca-779b1ead4e47	pickly-storage	announcements/images/	Full-size images for announcement details	2025-11-02 11:54:02.713322+00
421f76e5-55c1-448e-9297-f1064bb8f61c	pickly-storage	announcements/documents/	PDF and document attachments	2025-11-02 11:54:02.713322+00
14470c18-91fc-4fee-a138-2fa0794562e2	pickly-storage	banners/	Root folder for category and promotional banners	2025-11-02 11:54:02.713322+00
cce4b68c-cc37-4d01-b9d3-fd32749f570c	pickly-storage	banners/categories/	Category-specific banner images	2025-11-02 11:54:02.713322+00
636105f2-4a4d-4377-a6bd-d418c76128e5	pickly-storage	banners/promotions/	Promotional and featured banners	2025-11-02 11:54:02.713322+00
bc6d512a-4449-4032-bcc0-8f4d5e91a7a1	pickly-storage	test/	Test folder for validation and development	2025-11-02 11:54:02.713322+00
\.


--
-- Data for Name: user_profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_profiles (id, user_id, name, age, gender, region_sido, region_sigungu, selected_categories, income_level, interest_policies, onboarding_completed, onboarding_step, created_at, updated_at) FROM stdin;
\.


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 1, false);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_code_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_code_key UNIQUE (authorization_code);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_id_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_id_key UNIQUE (authorization_id);


--
-- Name: oauth_authorizations oauth_authorizations_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_pkey PRIMARY KEY (id);


--
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_clients
    ADD CONSTRAINT oauth_clients_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_user_client_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_client_unique UNIQUE (user_id, client_id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: age_categories age_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.age_categories
    ADD CONSTRAINT age_categories_pkey PRIMARY KEY (id);


--
-- Name: announcement_ai_chats announcement_ai_chats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement_ai_chats
    ADD CONSTRAINT announcement_ai_chats_pkey PRIMARY KEY (id);


--
-- Name: announcement_comments announcement_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement_comments
    ADD CONSTRAINT announcement_comments_pkey PRIMARY KEY (id);


--
-- Name: announcement_files announcement_files_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement_files
    ADD CONSTRAINT announcement_files_pkey PRIMARY KEY (id);


--
-- Name: announcement_sections announcement_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement_sections
    ADD CONSTRAINT announcement_sections_pkey PRIMARY KEY (id);


--
-- Name: announcement_types announcement_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement_types
    ADD CONSTRAINT announcement_types_pkey PRIMARY KEY (id);


--
-- Name: announcement_unit_types announcement_unit_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement_unit_types
    ADD CONSTRAINT announcement_unit_types_pkey PRIMARY KEY (id);


--
-- Name: housing_announcements announcements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.housing_announcements
    ADD CONSTRAINT announcements_pkey PRIMARY KEY (id);


--
-- Name: announcements announcements_pkey1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_pkey1 PRIMARY KEY (id);


--
-- Name: housing_announcements announcements_source_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.housing_announcements
    ADD CONSTRAINT announcements_source_id_key UNIQUE (source_id);


--
-- Name: benefit_announcements benefit_announcements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.benefit_announcements
    ADD CONSTRAINT benefit_announcements_pkey PRIMARY KEY (id);


--
-- Name: benefit_categories benefit_categories_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.benefit_categories
    ADD CONSTRAINT benefit_categories_name_key UNIQUE (title);


--
-- Name: benefit_categories benefit_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.benefit_categories
    ADD CONSTRAINT benefit_categories_pkey PRIMARY KEY (id);


--
-- Name: benefit_categories benefit_categories_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.benefit_categories
    ADD CONSTRAINT benefit_categories_slug_key UNIQUE (slug);


--
-- Name: benefit_files benefit_files_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.benefit_files
    ADD CONSTRAINT benefit_files_pkey PRIMARY KEY (id);


--
-- Name: category_banners category_banners_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category_banners
    ADD CONSTRAINT category_banners_pkey PRIMARY KEY (id);


--
-- Name: display_order_history display_order_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.display_order_history
    ADD CONSTRAINT display_order_history_pkey PRIMARY KEY (id);


--
-- Name: storage_folders storage_folders_path_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.storage_folders
    ADD CONSTRAINT storage_folders_path_key UNIQUE (path);


--
-- Name: storage_folders storage_folders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.storage_folders
    ADD CONSTRAINT storage_folders_pkey PRIMARY KEY (id);


--
-- Name: benefit_files unique_storage_path; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.benefit_files
    ADD CONSTRAINT unique_storage_path UNIQUE (storage_path);


--
-- Name: announcement_types unique_title_per_category; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement_types
    ADD CONSTRAINT unique_title_per_category UNIQUE (benefit_category_id, title);


--
-- Name: user_profiles user_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_pkey PRIMARY KEY (id);


--
-- Name: user_profiles user_profiles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_user_id_key UNIQUE (user_id);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: oauth_auth_pending_exp_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_auth_pending_exp_idx ON auth.oauth_authorizations USING btree (expires_at) WHERE (status = 'pending'::auth.oauth_authorization_status);


--
-- Name: oauth_clients_deleted_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_clients_deleted_at_idx ON auth.oauth_clients USING btree (deleted_at);


--
-- Name: oauth_consents_active_client_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_consents_active_client_idx ON auth.oauth_consents USING btree (client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_active_user_client_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_consents_active_user_client_idx ON auth.oauth_consents USING btree (user_id, client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_user_order_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_consents_user_order_idx ON auth.oauth_consents USING btree (user_id, granted_at DESC);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_oauth_client_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_oauth_client_id_idx ON auth.sessions USING btree (oauth_client_id);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: sso_providers_resource_id_pattern_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_providers_resource_id_pattern_idx ON auth.sso_providers USING btree (resource_id text_pattern_ops);


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: idx_ai_chats_announcement; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ai_chats_announcement ON public.announcement_ai_chats USING btree (announcement_id) WHERE (announcement_id IS NOT NULL);


--
-- Name: idx_ai_chats_context; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ai_chats_context ON public.announcement_ai_chats USING gin (context_data);


--
-- Name: idx_ai_chats_session; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ai_chats_session ON public.announcement_ai_chats USING btree (session_id, created_at);


--
-- Name: idx_ai_chats_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ai_chats_user ON public.announcement_ai_chats USING btree (user_id, created_at DESC);


--
-- Name: idx_announcement_files_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcement_files_order ON public.announcement_files USING btree (announcement_id, display_order);


--
-- Name: idx_announcement_types_benefit_category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcement_types_benefit_category ON public.announcement_types USING btree (benefit_category_id);


--
-- Name: idx_announcement_types_is_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcement_types_is_active ON public.announcement_types USING btree (is_active);


--
-- Name: idx_announcement_types_sort_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcement_types_sort_order ON public.announcement_types USING btree (sort_order);


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
-- Name: idx_announcements_is_priority; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_is_priority ON public.announcements USING btree (is_priority);


--
-- Name: idx_announcements_organization; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_organization ON public.announcements USING btree (organization);


--
-- Name: idx_announcements_posted_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_posted_date ON public.announcements USING btree (posted_date DESC);


--
-- Name: idx_announcements_published_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_published_at ON public.benefit_announcements USING btree (published_at DESC) WHERE ((status)::text = 'published'::text);


--
-- Name: idx_announcements_search; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_search ON public.benefit_announcements USING gin (search_vector);


--
-- Name: idx_announcements_source_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_source_id ON public.housing_announcements USING btree (source_id);


--
-- Name: idx_announcements_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_status ON public.benefit_announcements USING btree (status);


--
-- Name: idx_announcements_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_tags ON public.benefit_announcements USING gin (tags);


--
-- Name: idx_announcements_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_type_id ON public.announcements USING btree (type_id);


--
-- Name: idx_announcements_type_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_type_status ON public.announcements USING btree (type_id, status);


--
-- Name: idx_announcements_v73_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_v73_status ON public.announcements USING btree (status);


--
-- Name: idx_announcements_views; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_views ON public.benefit_announcements USING btree (views_count DESC);


--
-- Name: idx_benefit_categories_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_benefit_categories_active ON public.benefit_categories USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_benefit_categories_is_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_benefit_categories_is_active ON public.benefit_categories USING btree (is_active);


--
-- Name: idx_benefit_categories_parent; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_benefit_categories_parent ON public.benefit_categories USING btree (parent_id);


--
-- Name: idx_benefit_categories_slug; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_benefit_categories_slug ON public.benefit_categories USING btree (slug);


--
-- Name: idx_benefit_categories_sort_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_benefit_categories_sort_order ON public.benefit_categories USING btree (sort_order);


--
-- Name: idx_benefit_files_announcement; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_benefit_files_announcement ON public.benefit_files USING btree (announcement_id);


--
-- Name: idx_benefit_files_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_benefit_files_type ON public.benefit_files USING btree (file_type);


--
-- Name: idx_benefit_files_uploaded_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_benefit_files_uploaded_at ON public.benefit_files USING btree (uploaded_at DESC);


--
-- Name: idx_categories_custom_fields; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_categories_custom_fields ON public.benefit_categories USING gin (custom_fields);


--
-- Name: idx_category_banners_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_category_banners_active ON public.category_banners USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_category_banners_benefit_category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_category_banners_benefit_category ON public.category_banners USING btree (benefit_category_id);


--
-- Name: idx_category_banners_category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_category_banners_category ON public.category_banners USING btree (benefit_category_id);


--
-- Name: idx_category_banners_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_category_banners_order ON public.category_banners USING btree (sort_order);


--
-- Name: idx_category_banners_sort_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_category_banners_sort_order ON public.category_banners USING btree (sort_order);


--
-- Name: idx_comments_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_comments_active ON public.announcement_comments USING btree (announcement_id) WHERE (is_deleted = false);


--
-- Name: idx_comments_announcement; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_comments_announcement ON public.announcement_comments USING btree (announcement_id, created_at DESC);


--
-- Name: idx_comments_moderation; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_comments_moderation ON public.announcement_comments USING btree (moderation_status, created_at);


--
-- Name: idx_comments_parent; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_comments_parent ON public.announcement_comments USING btree (parent_comment_id) WHERE (parent_comment_id IS NOT NULL);


--
-- Name: idx_comments_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_comments_user ON public.announcement_comments USING btree (user_id);


--
-- Name: idx_order_history_announcement; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_order_history_announcement ON public.display_order_history USING btree (announcement_id, changed_at DESC);


--
-- Name: idx_order_history_category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_order_history_category ON public.display_order_history USING btree (category_id, changed_at DESC);


--
-- Name: idx_sections_announcement; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sections_announcement ON public.announcement_sections USING btree (announcement_id);


--
-- Name: idx_sections_display_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sections_display_order ON public.announcement_sections USING btree (announcement_id, display_order);


--
-- Name: idx_sections_structured_data; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sections_structured_data ON public.announcement_sections USING gin (structured_data);


--
-- Name: idx_sections_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sections_type ON public.announcement_sections USING btree (section_type);


--
-- Name: idx_unit_types_announcement; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_unit_types_announcement ON public.announcement_unit_types USING btree (announcement_id);


--
-- Name: idx_unit_types_display_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_unit_types_display_order ON public.announcement_unit_types USING btree (announcement_id, display_order);


--
-- Name: idx_unit_types_exclusive_area; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_unit_types_exclusive_area ON public.announcement_unit_types USING btree (exclusive_area);


--
-- Name: idx_unit_types_pricing; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_unit_types_pricing ON public.announcement_unit_types USING btree (sale_price, monthly_rent);


--
-- Name: v_announcement_stats _RETURN; Type: RULE; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW public.v_announcement_stats AS
 SELECT c.title AS category_name,
    c.slug AS category_slug,
    count(a.id) AS total_announcements,
    count(
        CASE
            WHEN ((a.status)::text = 'published'::text) THEN 1
            ELSE NULL::integer
        END) AS published_count,
    count(
        CASE
            WHEN a.is_featured THEN 1
            ELSE NULL::integer
        END) AS featured_count,
    sum(a.views_count) AS total_views
   FROM (public.benefit_categories c
     LEFT JOIN public.benefit_announcements a ON ((c.id = a.category_id)))
  GROUP BY c.id, c.title, c.slug
  ORDER BY c.sort_order;


--
-- Name: age_categories age_categories_updated; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER age_categories_updated BEFORE UPDATE ON public.age_categories FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: announcement_types trigger_announcement_types_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_announcement_types_updated_at BEFORE UPDATE ON public.announcement_types FOR EACH ROW EXECUTE FUNCTION public.update_announcement_types_updated_at();


--
-- Name: announcements trigger_announcements_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_announcements_updated_at BEFORE UPDATE ON public.announcements FOR EACH ROW EXECUTE FUNCTION public.update_announcements_updated_at();


--
-- Name: announcement_comments update_announcement_comments_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_announcement_comments_updated_at BEFORE UPDATE ON public.announcement_comments FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: announcement_sections update_announcement_sections_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_announcement_sections_updated_at BEFORE UPDATE ON public.announcement_sections FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: announcement_unit_types update_announcement_unit_types_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_announcement_unit_types_updated_at BEFORE UPDATE ON public.announcement_unit_types FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: benefit_announcements update_announcements_search_vector; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_announcements_search_vector BEFORE INSERT OR UPDATE OF title, subtitle, summary, organization, tags ON public.benefit_announcements FOR EACH ROW EXECUTE FUNCTION public.update_announcement_search_vector();


--
-- Name: housing_announcements update_announcements_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_announcements_updated_at BEFORE UPDATE ON public.housing_announcements FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: benefit_announcements update_benefit_announcements_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_benefit_announcements_updated_at BEFORE UPDATE ON public.benefit_announcements FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: benefit_categories update_benefit_categories_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_benefit_categories_updated_at BEFORE UPDATE ON public.benefit_categories FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: category_banners update_category_banners_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_category_banners_updated_at BEFORE UPDATE ON public.category_banners FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: user_profiles user_profiles_updated; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER user_profiles_updated BEFORE UPDATE ON public.user_profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_oauth_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_oauth_client_id_fkey FOREIGN KEY (oauth_client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: announcement_ai_chats announcement_ai_chats_announcement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement_ai_chats
    ADD CONSTRAINT announcement_ai_chats_announcement_id_fkey FOREIGN KEY (announcement_id) REFERENCES public.benefit_announcements(id) ON DELETE SET NULL;


--
-- Name: announcement_comments announcement_comments_announcement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement_comments
    ADD CONSTRAINT announcement_comments_announcement_id_fkey FOREIGN KEY (announcement_id) REFERENCES public.benefit_announcements(id) ON DELETE CASCADE;


--
-- Name: announcement_comments announcement_comments_parent_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement_comments
    ADD CONSTRAINT announcement_comments_parent_comment_id_fkey FOREIGN KEY (parent_comment_id) REFERENCES public.announcement_comments(id) ON DELETE CASCADE;


--
-- Name: announcement_files announcement_files_announcement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement_files
    ADD CONSTRAINT announcement_files_announcement_id_fkey FOREIGN KEY (announcement_id) REFERENCES public.benefit_announcements(id) ON DELETE CASCADE;


--
-- Name: announcement_sections announcement_sections_announcement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement_sections
    ADD CONSTRAINT announcement_sections_announcement_id_fkey FOREIGN KEY (announcement_id) REFERENCES public.benefit_announcements(id) ON DELETE CASCADE;


--
-- Name: announcement_types announcement_types_benefit_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement_types
    ADD CONSTRAINT announcement_types_benefit_category_id_fkey FOREIGN KEY (benefit_category_id) REFERENCES public.benefit_categories(id) ON DELETE CASCADE;


--
-- Name: announcement_unit_types announcement_unit_types_announcement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement_unit_types
    ADD CONSTRAINT announcement_unit_types_announcement_id_fkey FOREIGN KEY (announcement_id) REFERENCES public.benefit_announcements(id) ON DELETE CASCADE;


--
-- Name: announcements announcements_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.announcement_types(id) ON DELETE CASCADE;


--
-- Name: benefit_announcements benefit_announcements_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.benefit_announcements
    ADD CONSTRAINT benefit_announcements_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.benefit_categories(id) ON DELETE RESTRICT;


--
-- Name: benefit_categories benefit_categories_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.benefit_categories
    ADD CONSTRAINT benefit_categories_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.benefit_categories(id) ON DELETE CASCADE;


--
-- Name: benefit_files benefit_files_announcement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.benefit_files
    ADD CONSTRAINT benefit_files_announcement_id_fkey FOREIGN KEY (announcement_id) REFERENCES public.benefit_announcements(id) ON DELETE CASCADE;


--
-- Name: benefit_files benefit_files_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.benefit_files
    ADD CONSTRAINT benefit_files_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES auth.users(id);


--
-- Name: category_banners category_banners_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category_banners
    ADD CONSTRAINT category_banners_category_id_fkey FOREIGN KEY (benefit_category_id) REFERENCES public.benefit_categories(id) ON DELETE CASCADE;


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
-- Name: storage_folders fk_bucket; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.storage_folders
    ADD CONSTRAINT fk_bucket FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id) ON DELETE CASCADE;


--
-- Name: user_profiles user_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- Name: benefit_categories Admin can delete benefit_categories; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admin can delete benefit_categories" ON public.benefit_categories FOR DELETE TO authenticated USING (public.is_admin());


--
-- Name: benefit_categories Admin can insert benefit_categories; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admin can insert benefit_categories" ON public.benefit_categories FOR INSERT TO authenticated WITH CHECK (public.is_admin());


--
-- Name: benefit_categories Admin can update benefit_categories; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admin can update benefit_categories" ON public.benefit_categories FOR UPDATE TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());


--
-- Name: age_categories Admins manage categories; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins manage categories" ON public.age_categories USING (true) WITH CHECK (true);


--
-- Name: category_banners Anyone can delete banners; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Anyone can delete banners" ON public.category_banners FOR DELETE USING (true);


--
-- Name: category_banners Anyone can insert banners; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Anyone can insert banners" ON public.category_banners FOR INSERT WITH CHECK (true);


--
-- Name: category_banners Anyone can read banners; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Anyone can read banners" ON public.category_banners FOR SELECT USING (true);


--
-- Name: category_banners Anyone can update banners; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Anyone can update banners" ON public.category_banners FOR UPDATE USING (true);


--
-- Name: housing_announcements Anyone can view published announcements; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Anyone can view published announcements" ON public.housing_announcements FOR SELECT USING ((status = 'active'::text));


--
-- Name: age_categories Anyone views active categories; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Anyone views active categories" ON public.age_categories FOR SELECT USING ((is_active = true));


--
-- Name: announcement_files Authenticated users can manage announcement files; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Authenticated users can manage announcement files" ON public.announcement_files USING ((auth.role() = 'authenticated'::text)) WITH CHECK ((auth.role() = 'authenticated'::text));


--
-- Name: housing_announcements Authenticated users can manage announcements; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Authenticated users can manage announcements" ON public.housing_announcements USING ((auth.role() = 'authenticated'::text));


--
-- Name: benefit_files Authenticated users can upload files; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Authenticated users can upload files" ON public.benefit_files FOR INSERT TO authenticated WITH CHECK (true);


--
-- Name: display_order_history Authenticated users can view order history; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Authenticated users can view order history" ON public.display_order_history FOR SELECT USING ((auth.role() = 'authenticated'::text));


--
-- Name: benefit_categories Public can view active categories; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public can view active categories" ON public.benefit_categories FOR SELECT USING ((is_active = true));


--
-- Name: announcement_comments Public can view approved comments; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public can view approved comments" ON public.announcement_comments FOR SELECT USING (((is_deleted = false) AND ((moderation_status)::text = 'approved'::text)));


--
-- Name: announcement_files Public can view files of published announcements; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public can view files of published announcements" ON public.announcement_files FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.benefit_announcements
  WHERE ((benefit_announcements.id = announcement_files.announcement_id) AND ((benefit_announcements.status)::text = 'published'::text)))));


--
-- Name: benefit_announcements Public can view published announcements; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public can view published announcements" ON public.benefit_announcements FOR SELECT USING (((status)::text = 'published'::text));


--
-- Name: announcement_sections Public can view sections of published announcements; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public can view sections of published announcements" ON public.announcement_sections FOR SELECT USING (((is_visible = true) AND (EXISTS ( SELECT 1
   FROM public.benefit_announcements
  WHERE ((benefit_announcements.id = announcement_sections.announcement_id) AND ((benefit_announcements.status)::text = 'published'::text))))));


--
-- Name: announcement_unit_types Public can view unit types of published announcements; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public can view unit types of published announcements" ON public.announcement_unit_types FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.benefit_announcements
  WHERE ((benefit_announcements.id = announcement_unit_types.announcement_id) AND ((benefit_announcements.status)::text = 'published'::text)))));


--
-- Name: benefit_files Public read access to benefit files; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public read access to benefit files" ON public.benefit_files FOR SELECT USING (true);


--
-- Name: announcement_comments Users can delete their own comments; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can delete their own comments" ON public.announcement_comments FOR DELETE USING ((auth.uid() = user_id));


--
-- Name: benefit_files Users can delete their own uploads; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can delete their own uploads" ON public.benefit_files FOR DELETE TO authenticated USING ((uploaded_by = auth.uid()));


--
-- Name: announcement_ai_chats Users can insert their own AI chats; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert their own AI chats" ON public.announcement_ai_chats FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- Name: announcement_comments Users can insert their own comments; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert their own comments" ON public.announcement_comments FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- Name: announcement_comments Users can update their own comments; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update their own comments" ON public.announcement_comments FOR UPDATE USING ((auth.uid() = user_id)) WITH CHECK ((auth.uid() = user_id));


--
-- Name: benefit_files Users can update their own uploads; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update their own uploads" ON public.benefit_files FOR UPDATE TO authenticated USING ((uploaded_by = auth.uid()));


--
-- Name: announcement_ai_chats Users can view their own AI chats; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view their own AI chats" ON public.announcement_ai_chats FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: user_profiles Users manage own profile; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users manage own profile" ON public.user_profiles USING ((auth.uid() = user_id));


--
-- Name: age_categories; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.age_categories ENABLE ROW LEVEL SECURITY;

--
-- Name: announcement_ai_chats; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.announcement_ai_chats ENABLE ROW LEVEL SECURITY;

--
-- Name: announcement_comments; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.announcement_comments ENABLE ROW LEVEL SECURITY;

--
-- Name: announcement_files; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.announcement_files ENABLE ROW LEVEL SECURITY;

--
-- Name: announcement_sections; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.announcement_sections ENABLE ROW LEVEL SECURITY;

--
-- Name: announcement_types; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.announcement_types ENABLE ROW LEVEL SECURITY;

--
-- Name: announcement_types announcement_types: public read access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "announcement_types: public read access" ON public.announcement_types FOR SELECT USING (true);


--
-- Name: announcement_unit_types; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.announcement_unit_types ENABLE ROW LEVEL SECURITY;

--
-- Name: announcements; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;

--
-- Name: announcements announcements: public read access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "announcements: public read access" ON public.announcements FOR SELECT USING (true);


--
-- Name: benefit_announcements; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.benefit_announcements ENABLE ROW LEVEL SECURITY;

--
-- Name: benefit_categories; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.benefit_categories ENABLE ROW LEVEL SECURITY;

--
-- Name: benefit_files; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.benefit_files ENABLE ROW LEVEL SECURITY;

--
-- Name: category_banners; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.category_banners ENABLE ROW LEVEL SECURITY;

--
-- Name: display_order_history; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.display_order_history ENABLE ROW LEVEL SECURITY;

--
-- Name: housing_announcements; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.housing_announcements ENABLE ROW LEVEL SECURITY;

--
-- Name: user_profiles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

--
-- Name: SCHEMA auth; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA auth TO anon;
GRANT USAGE ON SCHEMA auth TO authenticated;
GRANT USAGE ON SCHEMA auth TO service_role;
GRANT ALL ON SCHEMA auth TO supabase_auth_admin;
GRANT ALL ON SCHEMA auth TO dashboard_user;
GRANT USAGE ON SCHEMA auth TO postgres;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO postgres;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;


--
-- Name: FUNCTION email(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.email() TO dashboard_user;


--
-- Name: FUNCTION jwt(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.jwt() TO postgres;
GRANT ALL ON FUNCTION auth.jwt() TO dashboard_user;


--
-- Name: FUNCTION role(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.role() TO dashboard_user;


--
-- Name: FUNCTION uid(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.uid() TO dashboard_user;


--
-- Name: FUNCTION generate_announcement_file_path(p_announcement_id uuid, p_file_type text, p_file_name text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.generate_announcement_file_path(p_announcement_id uuid, p_file_type text, p_file_name text) TO anon;
GRANT ALL ON FUNCTION public.generate_announcement_file_path(p_announcement_id uuid, p_file_type text, p_file_name text) TO authenticated;
GRANT ALL ON FUNCTION public.generate_announcement_file_path(p_announcement_id uuid, p_file_type text, p_file_name text) TO service_role;


--
-- Name: FUNCTION generate_banner_path(p_category text, p_file_name text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.generate_banner_path(p_category text, p_file_name text) TO anon;
GRANT ALL ON FUNCTION public.generate_banner_path(p_category text, p_file_name text) TO authenticated;
GRANT ALL ON FUNCTION public.generate_banner_path(p_category text, p_file_name text) TO service_role;


--
-- Name: FUNCTION get_storage_public_url(p_bucket_id text, p_path text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_storage_public_url(p_bucket_id text, p_path text) TO anon;
GRANT ALL ON FUNCTION public.get_storage_public_url(p_bucket_id text, p_path text) TO authenticated;
GRANT ALL ON FUNCTION public.get_storage_public_url(p_bucket_id text, p_path text) TO service_role;


--
-- Name: FUNCTION is_admin(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.is_admin() TO anon;
GRANT ALL ON FUNCTION public.is_admin() TO authenticated;
GRANT ALL ON FUNCTION public.is_admin() TO service_role;


--
-- Name: FUNCTION update_announcement_search_vector(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_announcement_search_vector() TO anon;
GRANT ALL ON FUNCTION public.update_announcement_search_vector() TO authenticated;
GRANT ALL ON FUNCTION public.update_announcement_search_vector() TO service_role;


--
-- Name: FUNCTION update_announcement_types_updated_at(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_announcement_types_updated_at() TO anon;
GRANT ALL ON FUNCTION public.update_announcement_types_updated_at() TO authenticated;
GRANT ALL ON FUNCTION public.update_announcement_types_updated_at() TO service_role;


--
-- Name: FUNCTION update_announcements_updated_at(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_announcements_updated_at() TO anon;
GRANT ALL ON FUNCTION public.update_announcements_updated_at() TO authenticated;
GRANT ALL ON FUNCTION public.update_announcements_updated_at() TO service_role;


--
-- Name: FUNCTION update_display_orders(p_category_id uuid, p_announcement_ids uuid[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_display_orders(p_category_id uuid, p_announcement_ids uuid[]) TO anon;
GRANT ALL ON FUNCTION public.update_display_orders(p_category_id uuid, p_announcement_ids uuid[]) TO authenticated;
GRANT ALL ON FUNCTION public.update_display_orders(p_category_id uuid, p_announcement_ids uuid[]) TO service_role;


--
-- Name: FUNCTION update_updated_at(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_updated_at() TO anon;
GRANT ALL ON FUNCTION public.update_updated_at() TO authenticated;
GRANT ALL ON FUNCTION public.update_updated_at() TO service_role;


--
-- Name: FUNCTION update_updated_at_column(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_updated_at_column() TO anon;
GRANT ALL ON FUNCTION public.update_updated_at_column() TO authenticated;
GRANT ALL ON FUNCTION public.update_updated_at_column() TO service_role;


--
-- Name: TABLE audit_log_entries; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.audit_log_entries TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.audit_log_entries TO postgres;
GRANT SELECT ON TABLE auth.audit_log_entries TO postgres WITH GRANT OPTION;


--
-- Name: TABLE flow_state; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.flow_state TO postgres;
GRANT SELECT ON TABLE auth.flow_state TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.flow_state TO dashboard_user;


--
-- Name: TABLE identities; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.identities TO postgres;
GRANT SELECT ON TABLE auth.identities TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.identities TO dashboard_user;


--
-- Name: TABLE instances; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.instances TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.instances TO postgres;
GRANT SELECT ON TABLE auth.instances TO postgres WITH GRANT OPTION;


--
-- Name: TABLE mfa_amr_claims; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.mfa_amr_claims TO postgres;
GRANT SELECT ON TABLE auth.mfa_amr_claims TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_amr_claims TO dashboard_user;


--
-- Name: TABLE mfa_challenges; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.mfa_challenges TO postgres;
GRANT SELECT ON TABLE auth.mfa_challenges TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_challenges TO dashboard_user;


--
-- Name: TABLE mfa_factors; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.mfa_factors TO postgres;
GRANT SELECT ON TABLE auth.mfa_factors TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_factors TO dashboard_user;


--
-- Name: TABLE oauth_authorizations; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.oauth_authorizations TO postgres;
GRANT ALL ON TABLE auth.oauth_authorizations TO dashboard_user;


--
-- Name: TABLE oauth_clients; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.oauth_clients TO postgres;
GRANT ALL ON TABLE auth.oauth_clients TO dashboard_user;


--
-- Name: TABLE oauth_consents; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.oauth_consents TO postgres;
GRANT ALL ON TABLE auth.oauth_consents TO dashboard_user;


--
-- Name: TABLE one_time_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.one_time_tokens TO postgres;
GRANT SELECT ON TABLE auth.one_time_tokens TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.one_time_tokens TO dashboard_user;


--
-- Name: TABLE refresh_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.refresh_tokens TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.refresh_tokens TO postgres;
GRANT SELECT ON TABLE auth.refresh_tokens TO postgres WITH GRANT OPTION;


--
-- Name: SEQUENCE refresh_tokens_id_seq; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO dashboard_user;
GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO postgres;


--
-- Name: TABLE saml_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.saml_providers TO postgres;
GRANT SELECT ON TABLE auth.saml_providers TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.saml_providers TO dashboard_user;


--
-- Name: TABLE saml_relay_states; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.saml_relay_states TO postgres;
GRANT SELECT ON TABLE auth.saml_relay_states TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.saml_relay_states TO dashboard_user;


--
-- Name: TABLE schema_migrations; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT SELECT ON TABLE auth.schema_migrations TO postgres WITH GRANT OPTION;


--
-- Name: TABLE sessions; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.sessions TO postgres;
GRANT SELECT ON TABLE auth.sessions TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sessions TO dashboard_user;


--
-- Name: TABLE sso_domains; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.sso_domains TO postgres;
GRANT SELECT ON TABLE auth.sso_domains TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sso_domains TO dashboard_user;


--
-- Name: TABLE sso_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.sso_providers TO postgres;
GRANT SELECT ON TABLE auth.sso_providers TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sso_providers TO dashboard_user;


--
-- Name: TABLE users; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.users TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.users TO postgres;
GRANT SELECT ON TABLE auth.users TO postgres WITH GRANT OPTION;


--
-- Name: TABLE age_categories; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.age_categories TO anon;
GRANT ALL ON TABLE public.age_categories TO authenticated;
GRANT ALL ON TABLE public.age_categories TO service_role;


--
-- Name: TABLE announcement_ai_chats; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.announcement_ai_chats TO anon;
GRANT ALL ON TABLE public.announcement_ai_chats TO authenticated;
GRANT ALL ON TABLE public.announcement_ai_chats TO service_role;


--
-- Name: TABLE announcement_comments; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.announcement_comments TO anon;
GRANT ALL ON TABLE public.announcement_comments TO authenticated;
GRANT ALL ON TABLE public.announcement_comments TO service_role;


--
-- Name: TABLE announcement_files; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.announcement_files TO anon;
GRANT ALL ON TABLE public.announcement_files TO authenticated;
GRANT ALL ON TABLE public.announcement_files TO service_role;


--
-- Name: TABLE announcement_sections; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.announcement_sections TO anon;
GRANT ALL ON TABLE public.announcement_sections TO authenticated;
GRANT ALL ON TABLE public.announcement_sections TO service_role;


--
-- Name: TABLE announcement_types; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.announcement_types TO anon;
GRANT ALL ON TABLE public.announcement_types TO authenticated;
GRANT ALL ON TABLE public.announcement_types TO service_role;


--
-- Name: TABLE announcement_unit_types; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.announcement_unit_types TO anon;
GRANT ALL ON TABLE public.announcement_unit_types TO authenticated;
GRANT ALL ON TABLE public.announcement_unit_types TO service_role;


--
-- Name: TABLE announcements; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.announcements TO anon;
GRANT ALL ON TABLE public.announcements TO authenticated;
GRANT ALL ON TABLE public.announcements TO service_role;


--
-- Name: TABLE benefit_announcements; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.benefit_announcements TO anon;
GRANT ALL ON TABLE public.benefit_announcements TO authenticated;
GRANT ALL ON TABLE public.benefit_announcements TO service_role;


--
-- Name: TABLE benefit_categories; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.benefit_categories TO anon;
GRANT ALL ON TABLE public.benefit_categories TO authenticated;
GRANT ALL ON TABLE public.benefit_categories TO service_role;


--
-- Name: TABLE benefit_files; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.benefit_files TO anon;
GRANT ALL ON TABLE public.benefit_files TO authenticated;
GRANT ALL ON TABLE public.benefit_files TO service_role;


--
-- Name: TABLE category_banners; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.category_banners TO anon;
GRANT ALL ON TABLE public.category_banners TO authenticated;
GRANT ALL ON TABLE public.category_banners TO service_role;


--
-- Name: TABLE display_order_history; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.display_order_history TO anon;
GRANT ALL ON TABLE public.display_order_history TO authenticated;
GRANT ALL ON TABLE public.display_order_history TO service_role;


--
-- Name: TABLE housing_announcements; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.housing_announcements TO anon;
GRANT ALL ON TABLE public.housing_announcements TO authenticated;
GRANT ALL ON TABLE public.housing_announcements TO service_role;


--
-- Name: TABLE storage_folders; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.storage_folders TO anon;
GRANT ALL ON TABLE public.storage_folders TO authenticated;
GRANT ALL ON TABLE public.storage_folders TO service_role;


--
-- Name: TABLE user_profiles; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.user_profiles TO anon;
GRANT ALL ON TABLE public.user_profiles TO authenticated;
GRANT ALL ON TABLE public.user_profiles TO service_role;


--
-- Name: TABLE v_announcement_files; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.v_announcement_files TO anon;
GRANT ALL ON TABLE public.v_announcement_files TO authenticated;
GRANT ALL ON TABLE public.v_announcement_files TO service_role;


--
-- Name: TABLE v_announcement_stats; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.v_announcement_stats TO anon;
GRANT ALL ON TABLE public.v_announcement_stats TO authenticated;
GRANT ALL ON TABLE public.v_announcement_stats TO service_role;


--
-- Name: TABLE v_announcements_full; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.v_announcements_full TO anon;
GRANT ALL ON TABLE public.v_announcements_full TO authenticated;
GRANT ALL ON TABLE public.v_announcements_full TO service_role;


--
-- Name: TABLE v_published_announcements; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.v_published_announcements TO anon;
GRANT ALL ON TABLE public.v_published_announcements TO authenticated;
GRANT ALL ON TABLE public.v_published_announcements TO service_role;


--
-- Name: TABLE v_featured_announcements; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.v_featured_announcements TO anon;
GRANT ALL ON TABLE public.v_featured_announcements TO authenticated;
GRANT ALL ON TABLE public.v_featured_announcements TO service_role;


--
-- Name: TABLE v_storage_stats; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.v_storage_stats TO anon;
GRANT ALL ON TABLE public.v_storage_stats TO authenticated;
GRANT ALL ON TABLE public.v_storage_stats TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO service_role;


--
-- PostgreSQL database dump complete
--

