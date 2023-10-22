SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
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
-- Name: agent_run_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agent_run_events (
    id bigint NOT NULL,
    event jsonb,
    agent_run_id bigint NOT NULL,
    agent_run_ids jsonb DEFAULT '[]'::jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: agent_run_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.agent_run_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: agent_run_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.agent_run_events_id_seq OWNED BY public.agent_run_events.id;


--
-- Name: agent_runs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agent_runs (
    id bigint NOT NULL,
    name character varying,
    arguments jsonb,
    context jsonb,
    output character varying,
    finished_at timestamp without time zone,
    parent_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    parent_ids jsonb DEFAULT '[]'::jsonb,
    error jsonb
);


--
-- Name: agent_runs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.agent_runs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: agent_runs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.agent_runs_id_seq OWNED BY public.agent_runs.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: codebases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.codebases (
    id bigint NOT NULL,
    name character varying,
    url character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    checked_out boolean DEFAULT false,
    name_slug character varying,
    github_app_installation_id character varying,
    github_app_issue_id character varying,
    context jsonb,
    description character varying
);


--
-- Name: codebases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.codebases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: codebases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.codebases_id_seq OWNED BY public.codebases.id;


--
-- Name: github_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.github_access_tokens (
    id bigint NOT NULL,
    codebase_id bigint NOT NULL,
    token character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: github_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.github_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: github_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.github_access_tokens_id_seq OWNED BY public.github_access_tokens.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: shell_tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shell_tasks (
    id bigint NOT NULL,
    description character varying,
    script character varying,
    started_at timestamp without time zone,
    finished_at timestamp without time zone,
    exit_code integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: shell_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shell_tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shell_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shell_tasks_id_seq OWNED BY public.shell_tasks.id;


--
-- Name: agent_run_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_run_events ALTER COLUMN id SET DEFAULT nextval('public.agent_run_events_id_seq'::regclass);


--
-- Name: agent_runs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_runs ALTER COLUMN id SET DEFAULT nextval('public.agent_runs_id_seq'::regclass);


--
-- Name: codebases id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.codebases ALTER COLUMN id SET DEFAULT nextval('public.codebases_id_seq'::regclass);


--
-- Name: github_access_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.github_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.github_access_tokens_id_seq'::regclass);


--
-- Name: shell_tasks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shell_tasks ALTER COLUMN id SET DEFAULT nextval('public.shell_tasks_id_seq'::regclass);


--
-- Name: agent_run_events agent_run_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_run_events
    ADD CONSTRAINT agent_run_events_pkey PRIMARY KEY (id);


--
-- Name: agent_runs agent_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_runs
    ADD CONSTRAINT agent_runs_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: codebases codebases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.codebases
    ADD CONSTRAINT codebases_pkey PRIMARY KEY (id);


--
-- Name: github_access_tokens github_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.github_access_tokens
    ADD CONSTRAINT github_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: shell_tasks shell_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shell_tasks
    ADD CONSTRAINT shell_tasks_pkey PRIMARY KEY (id);


--
-- Name: index_agent_run_events_on_agent_run_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_agent_run_events_on_agent_run_id ON public.agent_run_events USING btree (agent_run_id);


--
-- Name: index_agent_runs_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_agent_runs_on_parent_id ON public.agent_runs USING btree (parent_id);


--
-- Name: index_codebases_on_name_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_codebases_on_name_slug ON public.codebases USING btree (name_slug);


--
-- Name: index_github_access_tokens_on_codebase_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_github_access_tokens_on_codebase_id ON public.github_access_tokens USING btree (codebase_id);


--
-- Name: github_access_tokens fk_rails_25593bec89; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.github_access_tokens
    ADD CONSTRAINT fk_rails_25593bec89 FOREIGN KEY (codebase_id) REFERENCES public.codebases(id);


--
-- Name: agent_run_events fk_rails_4717b8b36a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_run_events
    ADD CONSTRAINT fk_rails_4717b8b36a FOREIGN KEY (agent_run_id) REFERENCES public.agent_runs(id);


--
-- Name: agent_runs fk_rails_f5bc068fd6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_runs
    ADD CONSTRAINT fk_rails_f5bc068fd6 FOREIGN KEY (parent_id) REFERENCES public.agent_runs(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20231008192508'),
('20231007153827'),
('20231007144346'),
('20230731202144'),
('20230731201757'),
('20230728221007'),
('20230723190709'),
('20230717233419'),
('20230717193437'),
('20230716193403'),
('20230709194852'),
('20230709194533'),
('20230408112843'),
('20230316202523');

