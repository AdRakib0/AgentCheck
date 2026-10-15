create extension if not exists pgcrypto;
create type public.review_status as enum ('pending','approved','rejected','hidden_pending_review');
create type public.dispute_status as enum ('received','investigating','resolved','rejected');
create type public.reply_status as enum ('pending','approved','rejected');
create table public.reviews (id uuid primary key default gen_random_uuid(), agent_name text not null check(char_length(agent_name) between 1 and 150), agency_name text, counsellor_name text, state text not null, suburb text, country text, rating smallint not null check(rating between 1 and 5), topic_tags text[] not null default '{}', experience_text text not null check(char_length(experience_text) between 50 and 4000), experience_month date, status public.review_status not null default 'pending', created_at timestamptz not null default now(), updated_at timestamptz not null default now());
create table public.review_contacts (review_id uuid primary key references public.reviews(id) on delete cascade, email text not null, verified boolean not null default false, verification_token_hash text, verification_expires_at timestamptz, created_at timestamptz not null default now());
create table public.disputes (id uuid primary key default gen_random_uuid(), review_id uuid references public.reviews(id) on delete cascade, complainant_name text not null, complainant_email text not null, role text not null check(role in ('agent','counsellor','other')), details text not null check(char_length(details) between 20 and 4000), status public.dispute_status not null default 'received', reference_code text not null unique default encode(gen_random_bytes(6),'hex'), received_at timestamptz not null default now(), actioned_at timestamptz, action_taken text, admin_user_id uuid);
create table public.replies (id uuid primary key default gen_random_uuid(), review_id uuid not null references public.reviews(id) on delete cascade, author_name text not null, body text not null check(char_length(body) between 1 and 2000), verified boolean not null default false, status public.reply_status not null default 'pending', created_at timestamptz not null default now());
create table public.audit_log (id bigint generated always as identity primary key, admin_user_id uuid not null, action text not null, target_type text not null, target_id uuid not null, details jsonb not null default '{}', created_at timestamptz not null default now());
create index reviews_status_created_idx on public.reviews(status,created_at desc);
create index reviews_agent_lower_idx on public.reviews(lower(agent_name));
create index disputes_status_received_idx on public.disputes(status,received_at desc);
create index review_contacts_email_created_idx on public.review_contacts(lower(email),created_at desc);
alter table public.reviews enable row level security;
alter table public.review_contacts enable row level security;
alter table public.disputes enable row level security;
alter table public.replies enable row level security;
alter table public.audit_log enable row level security;
create policy "Public reads approved reviews" on public.reviews for select to anon,authenticated using(status='approved');
-- No public insert/update policies. Implement verified submission and admin actions through secure server-side routes.
-- Never expose review_contacts, disputes or audit_log to anonymous/public roles. Configure admin policies only after MFA and role enforcement.