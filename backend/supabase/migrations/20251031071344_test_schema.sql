alter table "public"."announcements" drop constraint "announcements_status_check";

alter table "public"."announcements" drop constraint "check_views_count";

drop index if exists "public"."idx_announcements_view_count";

drop index if exists "public"."idx_announcements_views";

alter table "public"."announcements" drop column "view_count";

alter table "public"."announcements" add column "views_count" integer default 0;

CREATE INDEX idx_announcements_views ON public.announcements USING btree (views_count DESC);

alter table "public"."announcements" add constraint "announcements_status_check" CHECK ((status = ANY (ARRAY['recruiting'::text, 'closed'::text, 'upcoming'::text, 'draft'::text]))) not valid;

alter table "public"."announcements" validate constraint "announcements_status_check";

alter table "public"."announcements" add constraint "check_views_count" CHECK ((views_count >= 0)) not valid;

alter table "public"."announcements" validate constraint "check_views_count";


