-- create schema
create schema api;

-- create table
create table api.todos (
  id serial primary key,
  done boolean not null default false,
  task text not null,
  due timestamptz
);

-- insert test data
insert into api.todos (task) values
  ('finish tutorial 0'), ('pat self on back');

-- create role
create role web_anon nologin;

-- grant permissions
grant usage on schema api to web_anon;
grant select on api.todos to web_anon;

-- create authenticator role
create role authenticator noinherit login password 'mysecretpassword';
grant web_anon to authenticator;

-- create user

create role todo_user nologin;
grant todo_user to authenticator;

grant usage on schema api to todo_user;
grant all on api.todos to todo_user;
grant usage, select on sequence api.todos_id_seq to todo_user;

-- create auth schema
create schema auth;
grant usage on schema auth to web_anon, todo_user;

create or replace function auth.check_token() returns void
  language plpgsql
  as $$
begin
  if current_setting('request.jwt.claims', true)::json->>'email' =
     'disgruntled@mycompany.com' then
    raise insufficient_privilege
      using hint = 'Nope, we are on to you';
  end if;
end
$$;