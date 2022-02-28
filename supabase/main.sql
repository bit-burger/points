-- Delete all tables and types to create and replace them again
drop table if exists profiles, relations, chats, messages, notifications, greek_alphabet cascade;
drop domain if exists points, color, icon cascade;
drop type if exists relationship_state, notification_type cascade;
drop trigger if exists on_auth_user_created on auth.users cascade;
drop trigger if exists delete_chat on public.relations;

-- Delete all users, as they will not have a profile in the profiles table
delete from auth.users where true;

-- profiles --
create domain points as bigint check (value >= 0);
create domain color as smallint check ((value >= 0) and (value < 10));
create domain icon as smallint check ((value >= 0) and (value < 229));

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


-- represent users in points
create table public.profiles(
  id uuid primary key references auth.users on delete cascade,
  name varchar(8) not null check(name ~ '^(?!-|\s)([a-z-]|\s)*[a-z]$'),
  status varchar(16) not null default 'im new to points',
  bio varchar(256) not null,
  color color not null default 9,
  icon icon not null default 0, -- icon matches index of pointsIcons in lib/theme/points_ icons.dart
  points points not null default 100,
  gives points not null default 10
);

alter table public.profiles enable row level security;

CREATE POLICY read_all_profiles ON public.profiles
    FOR SELECT USING (true);

-- each time a new user is inserted into the auth.users table, insert one into profiles
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

  insert into public.notifications (
    user_id,
    first_actor,
    notification_type,
    message_data
  ) values (
    new.id,
    new.id,
    'system_message',
    '{"message": "Hi, thanks for joining points"}'::jsonb
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

-- represents a chat in points between two users
create table public.chats(
  id uuid primary key
);

-- represents a relation between two users,

-- relations can be changed using the functions prefixed with "relations_"

-- can be friends, requesting to be friends, etc.
-- allowed combinations are:
-- user 1          | user 2     | Explanation
-------------------+------------+-------------
-- friends         | friends    | Both are friends
-- request_pending | requesting | user 1 is requesting to be friends with user 2
-- blocked         | blocked_by | user 1 has blocked user 2
-- blocked         | blocked    | both users have blocked each other

-- these then need to be inserted both ways (id1, id2) and (id2, id1),
-- which is why the foreign key constraints exist

-- each relation has a chat id, which means that two rows will always have the same chat id
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
-- TODO: RLS
-- represent the messages, which can be in chats
create table public.messages(
  id uuid primary key not null default uuid_generate_v4(),
  sender uuid not null,
  receiver uuid not null,
  chat_id uuid not null,
  content text not null,
  created_at timestamp not null default now(),
  foreign key (sender, receiver, chat_id)
    references relations(id, other_id, chat_id)
    on delete cascade,
  constraint only_one_message_per_chat_per_timestamp
    unique(chat_id, created_at)
);
alter table public.messages enable row level security;

create policy read_own_messages
  on messages
  for select using (auth.uid() = sender or auth.uid() = receiver);

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


-- notifications --

create type notification_type as enum (
'gave_points',
'points_milestone', -- milestones of reaching points, for example 10,000 points
'changed_relation',
'received_message', -- (deprecated)
'profile_update',
'system_message' -- for example when user first joins points, or possibly an update
);

-- TODO: RLS
-- represents notifications
create table notifications(
  id serial primary key,
  user_id uuid not null references profiles on delete cascade,
  first_actor uuid references profiles on delete cascade, --
  second_actor uuid references profiles on delete cascade,
  notification_type notification_type not null,
  message_data jsonb not null,
  has_read boolean not null default false,
  created_at timestamp not null default now(),
  constraint has_to_be_one_actor
    check ((not first_actor is null) or (not second_actor is null)),
  constraint one_actor_has_to_be_user
    check (user_id = first_actor or user_id = second_actor),
  constraint user_can_only_have_one_notification_per_timestamp
    unique(user_id, created_at)
);

create index user_access on notifications(user_id);

create index sort_by_timestamp on notifications(created_at);

alter table notifications enable row level security;

create policy read_own_notifications
  on notifications
  for select using (auth.uid() = user_id);


-- Realtime --
begin;
  drop publication if exists supabase_realtime;
  create publication supabase_realtime;
commit;

alter publication supabase_realtime add table profiles, relations, messages, notifications;

-- needed to see the old row on an update (only needed in notifications, see NotificationRepository)
ALTER TABLE notifications REPLICA IDENTITY FULL;


-- Crontab for redistributing points (handled by by the redistribute_points function)
-- Is executed every day at 00:00
drop extension if exists pg_cron;
create extension pg_cron;

grant usage on schema cron to postgres;
grant all privileges on all tables in schema cron to postgres;

select
  cron.schedule(
    'redistribution-points',
    '0 0 * * *',
    $$
      select redistribute_points()
    $$
  );

-- if somebody still has 'ungiven' gives,
-- subtract them from his points,
-- so that he has at minimum 0 points

-- then add all the 'not given' gives together
-- and divide them by the number of users,
-- then give each user that calculated amount.
-- The rest of the ungiven points,
-- will be given to a random user.

-- After that 10 % of every user's points
-- is converted to gives of that user
create or replace function redistribute_points()
returns void as $$
declare
total_users int;
not_given_gives int;
not_given_gives_for_each_person int;
remaining_not_given_gives int;
random_id uuid;
begin
  select count(*) into total_users from profiles;
  select sum(case when points < gives then gives + points else gives * 2 end) into not_given_gives from profiles;
  select not_given_gives / total_users into not_given_gives_for_each_person;
  select mod(not_given_gives, total_users) into remaining_not_given_gives;
  select id into random_id from profiles ORDER BY random() limit 1;

  update profiles set points = greatest(points - gives, 0), gives = 0 where gives > 0;
  update profiles set gives = not_given_gives_for_each_person;
  update profiles set gives = gives + remaining_not_given_gives
    where id = random_id;

  update profiles set
    gives = gives + points / 10,
    points = points - points / 10;
end;
$$
language plpgsql security definer;