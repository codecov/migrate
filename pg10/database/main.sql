create extension if not exists "uuid-ossp";
create extension if not exists "citext";

create table if not exists version (version text);

create or replace function random_string(int) returns char as $$
  select string_agg(((string_to_array('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890', null))[floor(random()*62)+1])::text, '')
  from generate_series(1, $1);
$$ language sql;

\ir types.sql
\ir tables/main.sql
\ir functions/main.sql
\ir triggers/main.sql
