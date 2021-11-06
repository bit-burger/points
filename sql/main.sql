-- Delete all tables and types to create and replace them again --
drop table if exists profiles, relations, audit_log, greek_alphabet;
drop domain if exists points, color, icon;
drop type if exists relationship_state;

-- profiles --
create domain points as bigint check (value >= 0);
create domain color as smallint check ((value >= 0) and (value < 10));
create domain icon as smallint check ((value >= 0) and (value < 256));

create table public.greek_alphabet(
  letter varchar(8)
);

insert into greek_alphabet values
('Alpha'),
('Beta'),
('Gamma'),
('Delta'),
('Epsilon'),
('Zeta'),
('Eta'),
('Theta'),
('Iota'),
('Kappa'),
('Lamba'),
('My'),
('Ny'),
('Xi'),
('Omikron'),
('Pi'),
('Rho'),
('Sigma'),
('Tau'),
('Ypsilon'),
('Phi'),
('Chi'),
('Psi'),
('Omega');

create table public.profiles(
  id uuid primary key references auth.users on delete cascade,
  name varchar(8),
  status varchar(16),
  bio varchar(256),
  color color,
  icon icon,
  points points,
  gives points
);

alter table public.profiles enable row level security;

CREATE POLICY delete_own_profile ON public.profiles
    FOR DELETE USING (
      auth.uid() = id
    );

-- Now done via funciton, to ensure that points and gives are not changed
--CREATE POLICY update_own_profile ON public.profiles
--    FOR UPDATE USING (
--      auth.uid() = id
--    ) WITH CHECK (
--      auth.uid() = id
--    );

CREATE POLICY read_all_profiles ON public.profiles
    FOR SELECT USING (true);

-- relations --

create type relationship_state as enum (
'friends',
'blocked_by',
'blocked',
'request_pending',
'requesting'
);

create table public.relations(
  id uuid not null references auth.users (id) on delete cascade,
  other_id uuid not null references auth.users (id) on delete cascade,
  state relationship_state not null,
  primary key (id, other_id),
  foreign key (id, other_id) references relations(other_id, id)
);

alter table public.relations enable row level security;

CREATE POLICY read_own_relations ON public.relations
    FOR SELECT USING (
      auth.uid() = id
    );

-- audit log --

create table public.audit_log(
  created_at timestamp
);

create index on audit_log_entries (created_at);

-- Realtime --

begin;
  drop publication if exists supabase_realtime;
  create publication supabase_realtime;
commit;
alter publication supabase_realtime add table profiles, relations;