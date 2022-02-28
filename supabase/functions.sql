------------------
-- connectivity --
------------------

-- ping the server to check the connection
create or replace function check_connection() returns boolean as $$
begin
return true;
end;
$$ language plpgsql
security definer;


----------
-- auth --
----------

-- delete a user (not currently used in the app)
create or replace function delete_user() returns void as $$
begin
delete from auth.users where id = auth.uid();
end;
$$ language plpgsql
security definer;


----------------------
-- profile updating --
----------------------

-- set the own profile
create or replace function profile_update(
  new_bio varchar, new_color smallint, new_icon smallint, new_name varchar, new_status varchar
) returns void as $$
begin
update public.profiles
set
  name = new_name,
  status = new_status,
  bio = new_bio,
  color = new_color,
  icon = new_icon
where (id = auth.uid());
end;
$$ language plpgsql
security definer;


---------------------
-- profile queries --
---------------------

-- get a profile (or no profile) from an email
create or replace function profile_from_email(_email varchar) returns setof profiles as $func$
select profiles.* from auth.users
left join profiles on users.id = profiles.id
where users.email = _email;
$func$ language sql
security definer;


-- sorts out profiles with relation to auth.uid()
create or replace function query_profiles()
returns setof public.profiles as $func$
  select profiles.*
  from public.profiles
  left join relations on relations.id = auth.uid() and relations.other_id = profiles.id
  where relations.id is null and profiles.id <> auth.uid();
$func$
language sql;

-- get profiles sorted by popularity
create or replace function query_profiles_popularity()
returns setof public.profiles as $func$
  select *
  from query_profiles()
  order by points;
$func$
language sql;

-- get profiles queried by name
create or replace function query_profiles_name(_name varchar(8))
returns setof public.profiles as $func$
  select *
  from query_profiles() as profiles
  where levenshtein(_name, profiles.name) < 4
  order by levenshtein(_name, profiles.name) + levenshtein(substring(_name, 0, 1), substring(profiles.name, 0, 1)) * 2;
$func$
language sql;

-- get profiles queried by name and then sorted by popularity
create or replace function query_profiles_name_popularity(_name varchar(8))
returns setof public.profiles as $func$
  select *
  from query_profiles() as profiles
  order by levenshtein(_name, profiles.name) / 10, profiles.points;
$func$
language sql;


----------
-- chat --
----------
-- send a message to somebody
create or replace function send_message(chat_id uuid, other_id uuid, content text)
returns void as
$$
begin
insert into messages(chat_id, sender, receiver, content)
values (chat_id, auth.uid(), other_id, content);
end;
$$
language plpgsql
security definer;

-------------------
-- notifications --
-------------------

-- mark a single notification as read
create or replace function mark_message_read(message_id int)
returns void as $$
begin
update notifications set has_read=true where id = message_id and user_id = auth.uid();
end;
$$
language plpgsql security definer;

-- mark a single notification as unread
create or replace function mark_message_unread(message_id int)
returns void as $$
begin
update notifications set has_read=false where id = message_id and user_id = auth.uid();
end;
$$
language plpgsql security definer;

-- mark all messages of the current user as read
create or replace function mark_all_messages_read()
returns void as $$
begin
update notifications set has_read=true where user_id = auth.uid() and has_read=false;
end;
$$
language plpgsql security definer;

-- get the number of unread messages
create or replace function all_unread_messages_count()
returns int as $$
  select count(*) from notifications
  where user_id = auth.uid() and has_read = false
$$
language sql security definer;

------------
-- points --
------------

-- give somebody points (and send the appropriate notifications to both users)
create or replace function give_points(_id uuid, amount int)
returns void as $$
  declare
    relations_between_found int;
    message_data jsonb;
  begin
    select count(*)
    into relations_between_found
    from relations
    where relations.id = auth.uid() and other_id = _id and state = 'friends';

    if relations_between_found <> 1 then
      raise exception 'not_friends';
    end if;

    update profiles set gives = gives - amount where id = auth.uid();
    update profiles set points = points + amount where id = _id;

    message_data := concat('{"amount": ', amount, '}')::jsonb;

    insert into notifications(
    user_id,
    first_actor,
    second_actor,
    notification_type,
    message_data,
    has_read
  ) values
    (auth.uid(), auth.uid(), _id, 'gave_points', message_data, true),
    (_id, auth.uid(), _id, 'gave_points', message_data, false);
  end;
$$
language plpgsql security definer;


---------------
-- relations --
---------------

-- all relation methods to request, cancelRequest,accept, reject, unfriend, block, unblock

-- get all relations back of the current user
create or replace function get_relations() returns
table (
  id uuid,
  name varchar,
  status varchar,
  bio varchar,
  color int,
  icon int,
  points int,
  gives int,
  chat_id uuid,
  state relationship_state
)
as $$
  select profiles.*, relations.chat_id as chat_id, relations.state
  from relations
  left join profiles on relations.other_id = profiles.id
  where relations.id = auth.uid()
$$
language sql;

-- used by all private "relations_" prefixed methods
create or replace function insert_relation(
  id uuid,
  other_id uuid,
  state relationship_state,
  other_state relationship_state
) returns void as $$
declare
chat_id uuid;
begin
select uuid_generate_v4() into chat_id;

insert into chats values (chat_id);

insert into relations values
(id, other_id, chat_id, state),
(other_id, id, chat_id, other_state);
end;
$$
language plpgsql;

/*
change_type:
 - blocked
 - accepted
 - requested
 - rejected
 - cancelled
 - unblocked
 - unfriended
*/
-- another private general method used by "relations_" prefixed methods
create or replace function notify_users(
  changer_id uuid,
  other_id uuid,
  change_type varchar
) returns void as $$
declare
message_data jsonb;
begin
message_data := concat('{"change_type": "', change_type, '"}')::jsonb;

insert into notifications(
    user_id,
    first_actor,
    second_actor,
    notification_type,
    message_data,
    has_read
  ) values
    (changer_id, changer_id, other_id, 'changed_relation', message_data, true),
    (other_id, changer_id, other_id, 'changed_relation', message_data, false);
end;
$$
language plpgsql;

-- all methods used for relations

create or replace function relations_accept(_id uuid) returns void as $$
declare
relations_between_found int;
begin
  select count(*)
  into relations_between_found
  from relations
  where relations.id = auth.uid() and other_id = _id and state = 'request_pending';

  if relations_between_found <> 1 then
    raise exception 'no_request_between_found';
  end if;

  update relations set
  state = 'friends'
  where
  (id = auth.uid() and other_id = _id) or
  (id = _id and other_id = auth.uid());

  perform notify_users(auth.uid(), _id, 'accepted');
end;
$$ language plpgsql
security definer;


create or replace function relations_block(_id uuid) returns void as $$
declare
blocked_relations_by_id_found int;
relations_by_id_found int;
begin
  select count(*)
  into blocked_relations_by_id_found
  from relations
  where relations.other_id = auth.uid() and relations.id = _id and state = 'blocked';

  select count(*)
  into relations_by_id_found
  from relations
  where relations.other_id = auth.uid() and relations.id = _id;

  if blocked_relations_by_id_found = 1 then
    update relations
    set state = 'blocked'
    where id = auth.uid() and other_id = _id;
  else
    if(relations_by_id_found > 0) then
      update relations
      set state = 'blocked'
      where id = auth.uid() and other_id = _id;

      update relations
      set state = 'blocked_by'
      where id = _id and other_id = auth.uid();
    else
      perform insert_relation(auth.uid(), _id, 'blocked', 'blocked_by');
    end if;
  end if;

  perform notify_users(auth.uid(), _id, 'blocked');
end;
$$ language plpgsql
security definer;


create or replace function relations_reject(_id uuid) returns void as $$
declare
relations_between_found int;
begin
  select count(*)
  into relations_between_found
  from relations
  where relations.id = auth.uid() and other_id = _id and state = 'request_pending';

  if relations_between_found <> 1 then
    raise exception 'no_request_between_found';
  end if;

  delete from relations
  where
  (id = auth.uid() and other_id = _id) or
  (id = _id and other_id = auth.uid());

  perform notify_users(auth.uid(), _id, 'rejected');
end;
$$ language plpgsql
security definer;


create or replace function relations_request(_id uuid) returns void as $$
declare
relations_between_found int;
begin
  select count(*)
  into relations_between_found
  from relations
  where relations.id = auth.uid() and other_id = _id;

  if relations_between_found = 1 then
    raise exception 'relation_already_exists';
  end if;

  perform insert_relation(auth.uid(), _id, 'requesting', 'request_pending');
  perform notify_users(auth.uid(), _id, 'requested');
end;
$$ language plpgsql
security definer;


create or replace function relations_take_back_request(_id uuid) returns void as $$
declare
relations_between_found int;
begin
  select count(*)
  into relations_between_found
  from relations
  where relations.id = auth.uid() and other_id = _id and state = 'requesting';

  if relations_between_found <> 1 then
    raise exception 'no_request_between_found';
  end if;

  delete from relations
  where
  (id = auth.uid() and other_id = _id) or
  (id = _id and other_id = auth.uid());

  perform notify_users(auth.uid(), _id, 'cancelled');
end;
$$ language plpgsql
security definer;


create or replace function relations_unblock(_id uuid) returns void as $$
declare
  blocked_relations_found int;
  blocked_by_relations_found int;
begin
  select count(*)
  into blocked_relations_found
  from relations
  where
    id = auth.uid()
    and other_id = _id
    and state = 'blocked';

  select count(*)
  into blocked_by_relations_found
  from relations
  where
    id = _id
    and other_id = auth.uid()
    and state = 'blocked';

  if blocked_relations_found = 0 then
    raise exception 'no_blocked_relations_found';
  end if;

  if blocked_by_relations_found = 1 then
    update relations
    set state = 'blocked_by'
    where id = auth.uid() and other_id = _id;
  else
    delete from relations
    where
      (id = auth.uid() and other_id = _id) or
      (id = _id and other_id = auth.uid());
  end if;

  perform notify_users(auth.uid(), _id, 'unblocked');
end;
$$ language plpgsql
security definer;


create or replace function relations_unfriend(_id uuid) returns void as $$
declare
relations_between_found int;
begin
  select count(*)
  into relations_between_found
  from relations
  where relations.id = auth.uid() and other_id = _id and state = 'friends';

  if relations_between_found <> 1 then
    raise exception 'not_friends';
  end if;

  delete from relations
  where (id = _id and other_id = auth.uid()) or
  (id = auth.uid() and other_id = _id);

  perform notify_users(auth.uid(), _id, 'unfriend');
end;
$$ language plpgsql
security definer;