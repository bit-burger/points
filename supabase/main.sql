-- Delete all tables and types to create and replace them again --
drop table if exists profiles, relations, chats, messages, audit_log, greek_alphabet cascade;
drop domain if exists points, color, icon cascade;
drop type if exists relationship_state cascade;
drop trigger if exists on_auth_user_created on auth.users cascade;
drop trigger if exists delete_chat on public.relations;

-- profiles --
create domain points as bigint check (value >= 0);
create domain color as smallint check ((value >= 0) and (value < 10));
create domain icon as smallint check ((value >= 0) and (value < 230));

create table public.greek_alphabet(
  name varchar(8)
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
  name varchar(8) not null check(name ~ '^(?!-|\s)([a-z-]|\s)*[a-z]$'),
  status varchar(16) not null default 'im new to points',
  bio varchar(256) not null,
  color color not null default 9,
  icon icon not null default 0,
  points points not null default 0,
  gives points not null default 0
);

alter table public.profiles enable row level security;

CREATE POLICY read_all_profiles ON public.profiles
    FOR SELECT USING (true);

-- trigger the function every time a user is created

-- TODO: Make newname a random letter of the greek alphabet
create or replace function public.handle_new_user()
returns trigger as $$
declare newname varchar;
begin
  newname := 'alpha';

  insert into public.profiles (id, name, bio)
  values (
    new.id,
    newname,
    concat('Hi im ', newname)
  );
  return new;
end;
$$ language plpgsql security definer;


create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- relations and chatting--

create type relationship_state as enum (
'friends',
'blocked_by',
'blocked',
'request_pending',
'requesting'
);

create table public.chats(
  id uuid primary key
);

create table public.relations(
  id uuid not null references auth.users (id) on delete cascade,
  other_id uuid not null references auth.users (id) on delete cascade,
  chat_id uuid not null references chats(id),
  state relationship_state not null,
  primary key (id, other_id),
  foreign key (id, other_id) references relations(other_id, id),
  unique(id, other_id, chat_id),
  foreign key (id, other_id, chat_id) references relations(other_id, id, chat_id)
);

alter table public.relations enable row level security;

CREATE POLICY read_own_relations ON public.relations
    FOR SELECT USING (
      auth.uid() = id
    );

create table public.messages(
  id uuid primary key not null default uuid_generate_v4(),
  sender uuid not null,
  receiver uuid not null,
  chat_id uuid not null,
  content text not null,
  created_at timestamp not null default now(),
  foreign key (sender, receiver, chat_id) references relations(id, other_id, chat_id) on delete cascade
);


create or replace function chat_delete()
returns trigger as
$$
begin
delete from chats where chats.id = old.chat_id;
return old;
end;
$$
language plpgsql security definer;

create trigger delete_chat
after delete on relations
for each row
execute procedure chat_delete();


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
alter publication supabase_realtime add table profiles, relations, messages;

-- TODO: TEMP FIX REQUIRES ALL RLS TO BE TURNED OFF AND THE FOLLOWING QUERY TO BE RUN:
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA realtime TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA realtime TO postgres;