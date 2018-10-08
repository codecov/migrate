--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: citext; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = public;

--
--

CREATE TYPE commit_state AS ENUM (
    'pending',
    'complete',
    'error',
    'skipped'
);



--
--

CREATE TYPE languages AS ENUM (
    'javascript',
    'shell',
    'python',
    'ruby',
    'perl',
    'dart',
    'java',
    'c',
    'clojure',
    'd',
    'fortran',
    'go',
    'groovy',
    'kotlin',
    'php',
    'r',
    'scala',
    'swift',
    'objective-c',
    'xtend'
);



--
--

CREATE TYPE plan_providers AS ENUM (
    'github'
);



--
--

CREATE TYPE plans AS ENUM (
    '5m',
    '5y',
    '25m',
    '25y',
    '50m',
    '50y',
    '100m',
    '100y',
    '250m',
    '250y',
    '500m',
    '500y',
    '1000m',
    '1000y',
    '1m',
    '1y',
    'v4-10m',
    'v4-10y',
    'v4-20m',
    'v4-20y',
    'v4-50m',
    'v4-50y',
    'v4-125m',
    'v4-125y',
    'v4-300m',
    'v4-300y',
    'users'
);



--
--

CREATE TYPE pull_state AS ENUM (
    'open',
    'closed',
    'merged'
);



--
--

CREATE TYPE service AS ENUM (
    'github',
    'bitbucket',
    'gitlab',
    'github_enterprise',
    'gitlab_enterprise',
    'bitbucket_server'
);



--
--

CREATE TYPE sessiontype AS ENUM (
    'api',
    'login'
);



--
--

CREATE FUNCTION _agg_report_totals(text[], json) RETURNS text[]
    LANGUAGE sql IMMUTABLE
    AS $_$
  -- fnhmpcbdMs
  select case when $1 is null
         then array[$2->>0, $2->>1, $2->>2, $2->>3,
                    $2->>4, $2->>5, $2->>6, $2->>7,
                    $2->>8, $2->>9]
         else array[($1[1]::int + ($2->>0)::int)::text,
                    ($1[2]::int + ($2->>1)::int)::text,
                    ($1[3]::int + ($2->>2)::int)::text,
                    ($1[4]::int + ($2->>3)::int)::text,
                    ($1[5]::int + ($2->>4)::int)::text,
                    ratio(($1[3]::int + ($2->>2)::int), ($1[2]::int + ($2->>1)::int)),
                    ($1[7]::int + ($2->>6)::int)::text,
                    ($1[8]::int + ($2->>7)::int)::text,
                    ($1[9]::int + ($2->>8)::int)::text,
                    ($1[10]::int + ($2->>9)::int)::text] end;
$_$;



--
--

CREATE FUNCTION _max_coverage(json[], json) RETURNS json[]
    LANGUAGE sql IMMUTABLE
    AS $_$
 select case when $1 is null then array[$2]
             when ($1[1]->>'c')::numeric > ($2->>'c')::numeric then $1
             else array[$2] end;
$_$;



--
--

CREATE FUNCTION _min_coverage(json[], json) RETURNS json[]
    LANGUAGE sql IMMUTABLE
    AS $_$
 select case when $1 is null then array[$2]
             when ($1[1]->>'c')::numeric < ($2->>'c')::numeric then $1
             else array[$2] end;
$_$;



--
--

CREATE FUNCTION _pop_first_as_json(json[]) RETURNS json
    LANGUAGE sql IMMUTABLE
    AS $_$
 select $1[1]::json;
$_$;



--
--

CREATE FUNCTION add_key_to_json(json, text, integer) RETURNS json
    LANGUAGE sql STABLE
    AS $_$
   select case when $1 is null and $3 is null then ('{"'||$2||'":null}')::json
               when $1 is null or $1::text = '{}' then ('{"'||$2||'":'||$3||'}')::json
               when $3 is null then (left($1::text, -1)||',"'||$2||'":null}')::json
               else (left($1::text, -1)||',"'||$2||'":'||$3::text||'}')::json end;
$_$;



--
--

CREATE FUNCTION add_key_to_json(json, text, json) RETURNS json
    LANGUAGE sql STABLE
    AS $_$
   select case when $1 is null and $3 is null then ('{"'||$2||'":null}')::json
               when $1 is null or $1::text = '{}' then ('{"'||$2||'":'||$3||'}')::json
               when $3 is null then (left($1::text, -1)||',"'||$2||'":null}')::json
               else (left($1::text, -1)||',"'||$2||'":'||$3::text||'}')::json end;
$_$;



--
--

CREATE FUNCTION add_key_to_json(json, text, text) RETURNS json
    LANGUAGE sql STABLE
    AS $_$
   select case when $1 is null and $3 is null then ('{"'||$2||'":null}')::json
               when $1 is null or $1::text = '{}' then ('{"'||$2||'":"'||$3||'"}')::json
               when $3 is null then (left($1::text, -1)||',"'||$2||'":null}')::json
               else (left($1::text, -1)||',"'||$2||'":"'||$3::text||'"}')::json end;
$_$;



--
--

CREATE FUNCTION array_append_unique(anyarray, anyelement) RETURNS anyarray
    LANGUAGE sql IMMUTABLE
    AS $_$
   select case when $2 is null
          then $1
          else array_remove($1, $2) || array[$2]
          end;
$_$;



--
--

CREATE FUNCTION branches_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  declare _ownerid int;
  begin
    -- update repos cache if main branch
    update repos
      set updatestamp = now(),
          cache = update_json(cache::json, 'commit', get_commit_minimum(new.repoid, new.head)::json)
      where repoid = new.repoid
        and branch = new.branch
      returning ownerid into _ownerid;

    if found then
      -- default branch updated, so we can update the owners timestamp
      -- to refresh the team list
      update owners
       set updatestamp=now()
       where ownerid=_ownerid;
    end if;

    return null;
  end;
$$;



--
--

CREATE FUNCTION commits_insert_pr_branch() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  begin
    if new.pullid is not null and new.merged is not true then
      begin
        insert into pulls (repoid, pullid, author, head)
          values (new.repoid, new.pullid, new.author, new.commitid);
      exception when unique_violation then
      end;
    end if;

    if new.branch is not null then
      begin
        insert into branches (repoid, updatestamp, branch, authors, head)
          values (new.repoid, new.timestamp,
                  new.branch,
                  case when new.author is not null then array[new.author] else null end,
                  new.commitid);
      exception when unique_violation then
      end;
    end if;

    update repos
      set updatestamp=now()
      where repoid=new.repoid;

    return null;
  end;
$$;



--
--

CREATE FUNCTION commits_update_heads() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  declare trends json;
  declare primary_branch text;
  declare _ownerid int;
  begin

    if new.pullid is not null and new.merged is not true then
      -- update head of pulls
      update pulls p
        set updatestamp = now(),
            head = case when head is not null
                        and (select timestamp > new.timestamp
                             from commits c
                             where c.repoid=new.repoid
                               and c.commitid=p.head
                             limit 1)
                        then head
                        else new.commitid
                        end,
            author = coalesce(author, new.author)
        where repoid = new.repoid
          and pullid = new.pullid;

    end if;

    -- update head of branches
    if new.branch is not null then
      update branches
        set updatestamp = now(),
            authors = array_append_unique(coalesce(authors, '{}'::int[]), new.author),
            head = case
                   when head is null then new.commitid
                   when (
                     head != new.commitid
                     and new.timestamp >= (select timestamp from commits where commitid=head and repoid=new.repoid limit 1)
                   ) then new.commitid
                   else head end
        where repoid = new.repoid
          and branch = new.branch;
      if not found then
        insert into branches (repoid, updatestamp, branch, head, authors)
          values (new.repoid, new.timestamp, new.branch, new.commitid,
                  case when new.author is not null then array[new.author] else null end);
      end if;
    end if;

    return null;
  end;
$$;



--
--

CREATE FUNCTION coverage(service, text, text, text DEFAULT NULL::text, text DEFAULT NULL::text) RETURNS json
    LANGUAGE sql STABLE
    AS $_$
  -- floor is temporary here
  with d as (
    select floor((c.totals->>'c')::numeric) as coverage,
           coalesce((r.yaml->'coverage'->'range')::json,
                    (o.yaml->'coverage'->'range')::json) as coverage_range
      from repos r
      inner join owners o using (ownerid)
      left join branches b using (repoid)
      inner join commits c on b.repoid=c.repoid and c.commitid=b.head
      where o.service = $1
        and o.username = $2
        and r.name = $3
        and (r.image_token = $4 or not r.private)
        and b.branch = coalesce($5, r.branch)
      limit 1
  ) select json_agg(d)->0 from d;
$_$;



--
--

CREATE FUNCTION extract_totals(version smallint, files json, sessionids integer[]) RETURNS json
    LANGUAGE sql IMMUTABLE
    AS $$
  -- return {"filename": <totals list>, ...}
  with files as (
    select case
    when sessionids is not null and version = 3 then (select json_agg(row(key, sum_of_file_totals_filtering_sessionids(value->2, sessionids))) from json_each(files))
    when version = 3 then (select json_agg(row(key, value->1)) from json_each(files))
    -- v1/v2
    else (select json_agg(row(key, coalesce(value->'t', value->'totals'))) from json_each(files))
    end as data
  ) select json_agg(data)->0 from files;
$$;



--
--

CREATE FUNCTION find_parent_commit(_repoid integer, _this_commitid text, _this_timestamp timestamp without time zone, _parent_commitids text[], _branch text, _pullid integer) RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
  declare commitid_ text default null;
  begin
    if array_length(_parent_commitids, 1) > 0 then
      -- first: find a direct decendant
      select commitid into commitid_
      from commits
      where repoid = _repoid
        and array[commitid] <@ _parent_commitids
      limit 1;
    end if;

    if commitid_ is null then
      -- second: find latest on branch
      select commitid into commitid_
      from commits
      where repoid = _repoid
        and branch = _branch
        and pullid is not distinct from _pullid
        and commitid != _this_commitid
        and ci_passed
        and deleted is not true
        and timestamp < _this_timestamp
      order by timestamp desc
      limit 1;

      if commitid_ is null then
        -- third: use pull base
        select base into commitid_
        from pulls
        where repoid = _repoid
          and pullid = _pullid
        limit 1;
      end if;
    end if;

    return commitid_;
  end;
$$;



--
--

CREATE FUNCTION get_access_token(integer) RETURNS json
    LANGUAGE sql STABLE STRICT
    AS $_$
  with data as (
    select ownerid, oauth_token, username
    from owners o
    where ownerid = $1
      and oauth_token is not null
    limit 1
  ) select json_agg(data)->0 from data;
$_$;



--
--

CREATE FUNCTION get_author(integer) RETURNS json
    LANGUAGE sql STABLE STRICT
    AS $_$
  with data as (
    select service, service_id, username, email, name
     from owners
     where ownerid=$1
     limit 1
  ) select json_agg(data)->0 from data;
$_$;



--
--

CREATE FUNCTION get_commit(repoid integer, _commitid text, path text DEFAULT NULL::text, tree_only boolean DEFAULT false) RETURNS json
    LANGUAGE sql STABLE
    AS $_$
  with d as (
    select timestamp, commitid, branch, pullid::text, parent,
           ci_passed, updatestamp, message, deleted, totals, version,
           get_author(author) as author, archived, state, merged,
           get_commit_totals($1, c.parent) as parent_totals, notified,
           case when version = 3 and tree_only is not null then report
                else null end as report,
           case when tree_only is not null and path is null then logs
                else null end as logs,
           case when tree_only is null then null
                -- [rv1] [rv2] report
                when version is null then array[report::text]
                -- no report data needed
                when path is null and tree_only is true then null
                -- [rv3] report
                when path is not null and tree_only is false and chunks is not null then ARRAY[chunks[(report->'files'->path->>0)::int+1]]
                -- full report
                else chunks end as chunks
    from commits c
    where c.repoid = $1
      and commitid = (case when char_length(_commitid) < 40 then get_commitid_from_short($1, _commitid) else _commitid end)
    limit 1
  ) select json_agg(d)->0 from d;
$_$;



--
--

CREATE FUNCTION get_commit_minimum(integer, text) RETURNS json
    LANGUAGE sql STABLE
    AS $_$
  with d as (
    select timestamp, commitid, ci_passed, message,
           get_author(author) as author, totals
    from commits
    where repoid = $1
      and commitid = $2
    limit 1
  ) select json_agg(d)->0 from d;
$_$;



--
--

CREATE FUNCTION get_commit_on_branch(integer, text, text DEFAULT NULL::text, boolean DEFAULT false) RETURNS json
    LANGUAGE sql STABLE
    AS $_$
  select get_commit($1, head, $3, $4)
  from branches
  where repoid = $1 and branch = $2
  limit 1;
$_$;



--
--

CREATE FUNCTION get_commit_totals(integer, text) RETURNS json
    LANGUAGE sql STABLE
    AS $_$
  select totals
  from commits
  where repoid = $1
    and commitid = $2
  limit 1;
$_$;



--
--

CREATE FUNCTION get_commit_totals(integer, text, text) RETURNS json
    LANGUAGE sql STABLE
    AS $_$
  select get_totals_for_file(version, report->'files'->$3)
  from commits
  where repoid = $1
    and commitid = $2
  limit 1;
$_$;



--
--

CREATE FUNCTION get_commitid_from_short(integer, text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
  select commitid
  from commits
  where repoid = $1
    and commitid like $2||'%';
$_$;



--
--

CREATE FUNCTION get_customer(integer) RETURNS json
    LANGUAGE sql STABLE STRICT
    AS $_$
  with data as (
    select t.stripe_customer_id,
           t.stripe_subscription_id,
           t.ownerid::text,
           t.service_id,
           t.plan_user_count,
           t.plan_provider,
           t.plan_auto_activate,
           t.plan_activated_users,
           t.plan, t.email,
           t.free, t.did_trial,
           t.invoice_details,
           get_users(t.admins) as admins,
           (select count(*)
            from repos
            where ownerid=t.ownerid
              and private
              and activated) as repos_activated
    from owners t
    where t.ownerid = $1
    limit 1
  ) select json_agg(data)->0 from data limit 1;
$_$;



--
--

CREATE FUNCTION get_graph_for_commits_branch(integer, text, text, text[]) RETURNS json
    LANGUAGE sql STABLE
    AS $_$
  with data as (
    select r.repoid, r.service_id, r.branch,
           coalesce((r.yaml->'coverage'->'range')::json,
                    (o.yaml->'coverage'->'range')::json) as coverage_range
    from repos r
    inner join owners o using (ownerid)
    inner join branches b using (repoid)
    where r.repoid = $1
      and b.branch = case when $2 is null then r.branch else $2 end
      and (not r.private or r.image_token = $3)
    limit 1
  ) select json_agg(data)->0 from data limit 1;
$_$;



--
--

CREATE FUNCTION get_graph_for_commits_pull(integer, text, text, text[]) RETURNS json
    LANGUAGE sql STABLE
    AS $_$
  with data as (
    select r.repoid, r.service_id, r.branch,
           coalesce((r.yaml->'coverage'->'range')::json,
                    (o.yaml->'coverage'->'range')::json) as coverage_range
    from repos r
    inner join owners o using (ownerid)
    inner join pulls p using (repoid)
    where r.repoid = $1
      and p.pullid = $2::int
      and (not r.private or r.image_token = $3)
    limit 1
  ) select json_agg(data)->0 from data limit 1;
$_$;



--
--

CREATE FUNCTION get_graph_for_flare_branch(integer, text, text, text[]) RETURNS json
    LANGUAGE sql STABLE
    AS $_$
  with data as (
    select r.repoid, r.service_id, c.commitid, r.branch,
           extract_totals(c.version, c.report->'files', list_sessionid_by_filtering_flags(c.report->'sessions', $4)) as files_by_total,
           coalesce((r.yaml->'coverage'->'range')::json,
                    (o.yaml->'coverage'->'range')::json) as coverage_range
    from repos r
    inner join owners o using (ownerid)
    inner join branches b using (repoid)
    inner join commits c on c.repoid = r.repoid and c.commitid = b.head
    where r.repoid = $1
      and b.branch = case when $2 is null then r.branch else $2 end
      and (not r.private or r.image_token = $3)
    limit 1
  ) select json_agg(data)->0 from data limit 1;
$_$;



--
--

CREATE FUNCTION get_graph_for_flare_commit(integer, text, text, text[]) RETURNS json
    LANGUAGE sql STABLE
    AS $_$
  with data as (
    select r.repoid, r.service_id, c.commitid, r.branch,
           extract_totals(c.version, c.report->'files', list_sessionid_by_filtering_flags(c.report->'sessions', $4)) as files_by_total,
           coalesce((r.yaml->'coverage'->'range')::json,
                    (o.yaml->'coverage'->'range')::json) as coverage_range
    from repos r
    inner join owners o using (ownerid)
    inner join commits c using (repoid)
    where r.repoid = $1
      and c.commitid = $2
      and (not r.private or r.image_token = $3)
    limit 1
  ) select json_agg(data)->0 from data limit 1;
  $_$;



--
--

CREATE FUNCTION get_graph_for_flare_pull(integer, text, text, text[]) RETURNS json
    LANGUAGE sql STABLE
    AS $_$
  with data as (
    select r.repoid, r.service_id, p.head as commitid, r.branch,
           p.flare,
           case when p.flare is null
                then extract_totals(c.version, c.report->'files', list_sessionid_by_filtering_flags(c.report->'sessions', $4))
                else null
                end as files_by_total,
           coalesce((r.yaml->'coverage'->'range')::json,
                    (o.yaml->'coverage'->'range')::json) as coverage_range
    from repos r
    inner join owners o using (ownerid)
    inner join pulls p using (repoid)
    inner join commits c on c.repoid = r.repoid and c.commitid = p.head
    where r.repoid = $1
      and p.pullid = $2::int
      and (not r.private or r.image_token = $3)
    limit 1
  ) select json_agg(data)->0 from data limit 1;
$_$;



--
--

CREATE FUNCTION get_graph_for_totals_branch(integer, text, text, text[]) RETURNS json
    LANGUAGE sql STABLE
    AS $_$
  with data as (
    select r.repoid, r.service_id, r.branch,
           base.commitid as base_commitid,
           case when $4 is null
                then base.totals
                else sum_session_totals(base.report->'sessions', $4)
                end as base_totals,
           head.commitid as head_commitid,
           case when $4 is null
                then head.totals
                else sum_session_totals(head.report->'sessions', $4)
                end as head_totals,
           coalesce((r.yaml->'coverage'->'range')::json,
                    (o.yaml->'coverage'->'range')::json) as coverage_range
    from repos r
    inner join owners o using (ownerid)
    inner join branches b using (repoid)
    left join commits base on base.repoid = r.repoid
          and base.commitid = b.base
    inner join commits head on head.repoid = r.repoid
           and head.commitid = b.head
    where r.repoid = $1
      and b.branch = case when $2 is null then r.branch else $2 end
      and (not r.private or r.image_token = $3)
    limit 1
  ) select json_agg(data)->0 from data limit 1;
$_$;



--
--

CREATE FUNCTION get_graph_for_totals_commit(integer, text, text, text[]) RETURNS json
    LANGUAGE sql STABLE
    AS $_$
  with data as (
    select r.repoid, r.service_id, r.branch,
           base.commitid as base_commitid,
           case when $4 is null
                then base.totals
                else sum_session_totals(base.report->'sessions', $4)
                end as base_totals,
           head.commitid as head_commitid,
           case when $4 is null
                then head.totals
                else sum_session_totals(head.report->'sessions', $4)
                end as head_totals,
           coalesce((r.yaml->'coverage'->'range')::json,
                    (o.yaml->'coverage'->'range')::json) as coverage_range
    from repos r
    inner join owners o using (ownerid)
    inner join commits head using (repoid)
    left join commits base on base.repoid = r.repoid
          and base.commitid = head.parent
    where r.repoid = $1
      and head.commitid = $2
      and (not r.private or r.image_token = $3)
    limit 1
  ) select json_agg(data)->0 from data limit 1;
  $_$;



--
--

CREATE FUNCTION get_graph_for_totals_pull(integer, text, text, text[]) RETURNS json
    LANGUAGE sql STABLE
    AS $_$
  with data as (
    select r.repoid, r.service_id, r.branch,
           p.base as base_commitid,
           case when $4 is null
                then p.totals->'base'
                else (select sum_session_totals(report->'sessions', $4)
                      from commits
                      where repoid=$1
                        and commitid=p.base
                      limit 1)
                end as base_totals,
           p.head as head_commitid,
           case when $4 is null
                then p.totals->'head'
                else (select sum_session_totals(report->'sessions', $4)
                      from commits
                      where repoid=$1
                        and commitid=p.head
                      limit 1)
                end as head_totals,
           coalesce((r.yaml->'coverage'->'range')::json,
                    (o.yaml->'coverage'->'range')::json) as coverage_range
    from repos r
    inner join owners o using (ownerid)
    inner join pulls p using (repoid)
    where r.repoid = $1
      and p.pullid = $2::int
      and (not r.private or r.image_token = $3)
    limit 1
  ) select json_agg(data)->0 from data limit 1;
$_$;



--
--

CREATE FUNCTION get_new_repos(integer) RETURNS json
    LANGUAGE sql STABLE
    AS $_$
  with _repos as (
    select private, name, language, repoid::text,
           get_repo(forkid) as fork, upload_token
    from repos
    where ownerid = $1
      and active is not true
      and deleted is not true
  ) select coalesce(json_agg(_repos), '[]'::json) from _repos;
$_$;



--
--

CREATE FUNCTION get_or_create_owner(service, text, text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
  declare _ownerid int;
  begin
    update owners
      set username = $3
      where service = $1
      and service_id = $2
      returning ownerid into _ownerid;

    if not found then
      insert into owners (service, service_id, username)
        values ($1, $2, $3)
        returning ownerid into _ownerid;
    end if;

    return _ownerid;

  end;
$_$;



--
--

CREATE FUNCTION get_owner(service, citext) RETURNS json
    LANGUAGE sql STABLE STRICT
    AS $_$
  with data as (
    select service_id, service, ownerid::text, username,
           updatestamp, plan, name, integration_id, free,
           plan_activated_users, plan_auto_activate, plan_user_count
    from owners
    where service=$1
      and username=$2::citext
    limit 1
  ) select json_agg(data)->0
    from data
    limit 1;
$_$;



--
--

CREATE FUNCTION get_ownerid(service, text, citext, text, text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
  declare _ownerid int;
  begin

    select ownerid into _ownerid
      from owners
      where service=$1
        and service_id=$2
      limit 1;

    if not found and $2 is not null then
      insert into owners (service, service_id, username, name, email)
      values ($1, $2, $3::citext, $4, $5)
      returning ownerid into _ownerid;
    end if;

    return _ownerid;
  end;
$_$;



--
--

CREATE FUNCTION get_ownerid_if_member(service, citext, integer) RETURNS integer
    LANGUAGE sql STABLE STRICT
    AS $_$
  select ownerid
  from owners
  where service=$1
    and username=$2::citext
    and array[$3] <@ organizations
    and private_access is true
  limit 1;
$_$;



--
--

CREATE FUNCTION get_pull(integer, integer) RETURNS json
    LANGUAGE sql STABLE
    AS $_$
  with d as (
    select p.pullid, p.commentid,
           coalesce(p.issueid, p.pullid) as issueid,
           p.base, p.head, p.totals, p.compared_to
    from pulls p
    where p.repoid = $1
      and p.pullid = $2
    limit 1
  ) select json_agg(d)->0 from d limit 1;
$_$;



--
--

CREATE FUNCTION get_repo(integer) RETURNS json
    LANGUAGE sql STABLE STRICT
    AS $_$
  with d as (select o.service, o.username, o.service_id as owner_service_id, r.ownerid::text,
                    r.name, r.repoid::text, r.service_id, r.updatestamp,
                    r.branch, r.private, hookid, image_token,
                    r.yaml, o.yaml as org_yaml, r.using_integration, o.plan,
                    (r.cache->>'yaml') as _yaml_location,
                    case when r.using_integration then o.integration_id else null end as integration_id,
                    get_access_token(coalesce(r.bot, o.bot, o.ownerid)) as token,
                    case when private and activated is not true and forkid is not null
                      then (select rr.activated from repos rr where rr.repoid = r.forkid limit 1)
                      else activated end as activated
             from repos r
             inner join owners o using (ownerid)
             where r.repoid = $1
             limit 1) select json_agg(d)->0 from d;
$_$;



--
--

CREATE FUNCTION get_repo(integer, citext) RETURNS json
    LANGUAGE sql STABLE
    AS $_$
  with repo as (
    select yaml, name, "language", repoid::text, private, deleted, active, cache,
           branch, service_id, updatestamp, upload_token, image_token, hookid, using_integration,
           case when private and activated is not true and forkid is not null
             then (select rr.activated from repos rr where rr.repoid = r.forkid limit 1)
             else activated end as activated
    from repos r
    where ownerid = $1 and name = $2::citext
    limit 1
  ) select json_agg(repo)->0 from repo;
$_$;



--
--

CREATE FUNCTION get_repo_by_token(uuid) RETURNS json
    LANGUAGE sql STABLE
    AS $_$
  with d as (
    select get_repo(r.repoid) as repo, o.service
    from repos r
    inner join owners o using (ownerid)
    where r.upload_token = $1
    limit 1
  ) select json_agg(d)->0 from d limit 1;
$_$;



--
--

CREATE FUNCTION get_repoid(service, citext, citext) RETURNS integer
    LANGUAGE sql STABLE
    AS $_$
  select repoid
  from repos r
  inner join owners o using (ownerid)
  where o.service = $1
    and o.username = $2::citext
    and r.name = $3::citext
  limit 1
$_$;



--
--

CREATE FUNCTION get_repos(integer, integer DEFAULT 0, integer DEFAULT 5) RETURNS json
    LANGUAGE sql STABLE
    AS $_$
  with _repos as (
    select private, cache, name, updatestamp, upload_token, branch,
           language, repoid::text, get_repo(forkid) as fork, yaml,
           case when private and activated is not true and forkid is not null
             then (select rr.activated from repos rr where rr.repoid = r.forkid limit 1)
             else activated end as activated
    from repos r
    where ownerid = $1
      and active
    offset $2
    limit $3
  ) select coalesce(json_agg(_repos), '[]'::json) from _repos;
$_$;



--
--

CREATE FUNCTION get_teams(service, integer[]) RETURNS json
    LANGUAGE sql STABLE STRICT
    AS $_$
  with data as (
    select service_id, service, ownerid::text, username, name
    from owners
    where service=$1
      and array[ownerid] <@ $2
  ) select json_agg(data) from data;
$_$;



--
--

CREATE FUNCTION get_tip(integer, text) RETURNS text
    LANGUAGE sql STABLE
    AS $_$
  select case when char_length($2) = 40 then $2
         else coalesce((select head from branches where repoid=$1 and branch=$2 limit 1),
                       (select commitid from commits where repoid=$1 and commitid like $2||'%' limit 1)) end
  limit 1;
$_$;



--
--

CREATE FUNCTION get_tip_of_branch(integer, text) RETURNS text
    LANGUAGE sql STABLE
    AS $_$
  select head
  from branches
  where repoid = $1
    and branch = $2
  limit 1;
$_$;



--
--

CREATE FUNCTION get_tip_of_pull(integer, integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$
  select head
  from pulls
  where repoid = $1
    and pullid = $2
  limit 1;
$_$;



--
--

CREATE FUNCTION get_totals_for_file(smallint, json) RETURNS json
    LANGUAGE sql IMMUTABLE
    AS $_$
  select case when $1 = 3 then $2->1 else $2->'t' end;
$_$;



--
--

CREATE FUNCTION get_user(integer) RETURNS json
    LANGUAGE sql STABLE
    AS $_$
  with data as (
    select ownerid::text, private_access, staff, service, service_id,
           username, organizations,
           oauth_token, plan, permission,
           free, email, name, createstamp
     from owners
     where ownerid=$1
     limit 1
  ) select json_agg(data)->0 from data;
$_$;



--
--

CREATE FUNCTION get_username(integer) RETURNS citext
    LANGUAGE sql STABLE STRICT
    AS $_$
  select username from owners where ownerid=$1 limit 1;
$_$;



--
--

CREATE FUNCTION get_users(integer[]) RETURNS json
    LANGUAGE sql STABLE STRICT
    AS $_$
  with data as (
    select service, service_id::text, ownerid::text, username, name, email
    from owners
    where array[ownerid] <@ $1
    limit array_length($1, 1)
  ) select json_agg(data)
    from data
    limit array_length($1, 1);
$_$;



--
--

CREATE FUNCTION insert_commit(integer, text, text, integer, json) RETURNS void
    LANGUAGE plpgsql
    AS $_$
  begin

    update commits
     set state='pending',
         logs=array_append(logs, $5::json)
     where repoid = $1
       and commitid = $2;

    if not found then
      insert into commits (repoid, commitid, branch, pullid, merged, timestamp, state, logs)
       values ($1, $2, $3, $4, case when $4 is not null then false else null end, now(), 'pending', array[$5]);
    end if;

    update repos
      set active=true, deleted=false, updatestamp=now()
      where repoid = $1
        and (active is not true or deleted is true);

  exception
    when unique_violation
    then null;
  end;
$_$;



--
--

CREATE FUNCTION list_sessionid_by_filtering_flags(sessions json, flags text[]) RETURNS integer[]
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
  -- return session index where flags overlap $1
  with indexes as (
    select (session.key)::int as key
    from json_each(sessions) as session
    where (session.value->>'f')::text is not null
      and flags <@ (select array_agg(trim(f::text, '"')) from json_array_elements((session.value->'f')) f)::text[]
  ) select array_agg(key) from indexes;
$_$;



--
--

CREATE FUNCTION owner_cache_state_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  declare _ownerid int;
  begin
    -- update cache of number of repos
    for _ownerid in (select unnest from unnest(new.organizations)) loop
      update owners o
        set cache=update_json(cache, 'stats', update_json(cache->'stats', 'users', (select count(*)
                                                                                    from owners
                                                                                    where organizations @> array[_ownerid])::int))
        where ownerid=_ownerid;
    end loop;
    return null;
  end;
$$;



--
--

CREATE FUNCTION owner_token_clered() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  begin
    delete from sessions where ownerid=new.ownerid and type='login';
    return new;
  end;
$$;



--
--

CREATE FUNCTION owner_yaml_updated() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  begin
    new.bot = coalesce(get_ownerid_if_member(new.service, (new.yaml->'codecov'->>'bot')::citext, new.ownerid), old.bot);

    -- update repo branches
    update repos r
      set branch = coalesce((r.yaml->'codecov'->>'branch'), (new.yaml->'codecov'->>'branch'), branch)
      where ownerid = new.ownerid;

    return new;
  end;
$$;



--
--

CREATE FUNCTION owners_before_insert_or_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  begin
    -- user has changed name or deleted and invalidate sessions
    with _owners as (update owners
                     set username = null
                     where service = new.service
                       and username = new.username::citext
                     returning ownerid)
      delete from sessions where ownerid in (select ownerid from _owners);
    return new;
  end;
$$;



--
--

CREATE FUNCTION pulls_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  begin
    -- set diff totals
    new.totals = ('{"base":'||coalesce((select totals::text from commits where repoid=new.repoid and commitid=new.base limit 1), 'null')||','||
                   '"head":'||coalesce((select totals::text from commits where repoid=new.repoid and commitid=new.head limit 1), 'null')||'}')::json;

    return new;
  end;
$$;



--
--

CREATE FUNCTION pulls_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  begin
    -- set diff totals
    new.totals = update_json(old.totals, 'base',
                             (select totals
                              from commits
                              where repoid=new.repoid
                                and commitid=new.base
                              limit 1));

    new.totals = update_json(new.totals, 'head',
                             (select totals
                              from commits
                              where repoid=new.repoid
                                and commitid=new.head
                              limit 1));

    return new;
  end;
$$;



--
--

CREATE FUNCTION random_string(integer) RETURNS character
    LANGUAGE sql
    AS $_$
  select string_agg(((string_to_array('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890', null))[floor(random()*62)+1])::text, '')
  from generate_series(1, $1);
$_$;



--
--

CREATE FUNCTION ratio(integer, integer) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
  select case when $2 = 0 then '0' else round(($1::numeric/$2::numeric)*100.0, 5)::text end;
$_$;



--
--

CREATE FUNCTION refresh_repos(service, json, integer, boolean) RETURNS text[]
    LANGUAGE plpgsql
    AS $_$
  declare _ text;
  declare _branch text;
  declare _forkid int;
  declare _previous_ownerid int;
  declare _ownerid int;
  declare _repo record;
  declare _repoid int;
  declare _bot int;
  declare repos text[];
  begin

    for _repo in select d from json_array_elements($2) d loop

      select r.ownerid into _previous_ownerid
        from repos r
        inner join owners o using (ownerid)
        where o.service = $1
          and r.service_id = (_repo.d->'repo'->>'service_id')::text
        limit 1;

      -- owner
      -- =====
      -- its import to check all three below. otherwise update the record.
      select ownerid, bot, (yaml->'codecov'->>'branch')::text
        into _ownerid, _bot, _branch
        from owners
        where service = $1
          and service_id = (_repo.d->'owner'->>'service_id')::text
          and username = (_repo.d->'owner'->>'username')::citext
        limit 1;

      if not found then
        update owners
        set username = (_repo.d->'owner'->>'username')::citext,
            updatestamp = now()
        where service = $1
          and service_id = (_repo.d->'owner'->>'service_id')::text
        returning ownerid, bot, (yaml->'codecov'->>'branch')::text
        into _ownerid, _bot, _branch;

        if not found then
          insert into owners (service, service_id, username, bot)
          values ($1, (_repo.d->'owner'->>'service_id')::text, (_repo.d->'owner'->>'username')::citext, $3)
          returning ownerid, bot into _ownerid, _bot;
        end if;

      end if;

      -- fork
      -- ====
      if (_repo.d->'repo'->>'fork') is not null then
        -- converts fork into array
        select refresh_repos($1, (select json_agg(d.d::json)::json
                                  from (select (_repo.d->'repo'->>'fork')::json d limit 1) d
                                  limit 1), null, null)
          into _
          limit 1;

        -- get owner
        select r.repoid into _forkid
         from repos r
         inner join owners o using (ownerid)
         where o.service = $1
           and o.username = (_repo.d->'repo'->'fork'->'owner'->>'username')::citext
           and r.name = (_repo.d->'repo'->'fork'->'repo'->>'name')::citext
         limit 1;
      else
        _forkid := null;
      end if;

      -- update repo
      -- ===========
      if _previous_ownerid is not null then
        -- repo already existed with this service_id, update it
        update repos set
            private = ((_repo.d)->'repo'->>'private')::boolean,
            forkid = _forkid,
            language = ((_repo.d)->'repo'->>'language')::languages,
            ownerid = _ownerid,
            using_integration=(using_integration or $4),
            name = (_repo.d->'repo'->>'name')::citext,
            deleted = false,
            updatestamp=now()
          where ownerid = _previous_ownerid
            and service_id = (_repo.d->'repo'->>'service_id')::text
          returning repoid
          into _repoid;

      -- new repo
      -- ========
      else
        insert into repos (service_id, ownerid, private, forkid, name, branch, language, using_integration)
          values ((_repo.d->'repo'->>'service_id')::text,
                  _ownerid,
                  (_repo.d->'repo'->>'private')::boolean,
                  _forkid,
                  (_repo.d->'repo'->>'name')::citext,
                  coalesce(_branch, (_repo.d->'repo'->>'branch')),
                  (_repo.d->'repo'->>'language')::languages,
                  $4)
          returning repoid into _repoid;

      end if;

      -- return private repoids
      if (_repo.d->'repo'->>'private')::boolean then
        repos = array_append(repos, _repoid::text);
      end if;

    end loop;

    return repos;
  end;
$_$;



--
--

CREATE FUNCTION refresh_teams(service, json, integer) RETURNS integer[]
    LANGUAGE plpgsql STRICT
    AS $_$
  declare ownerids int[];
  declare _ownerid int;
  declare _team record;
  begin
    for _team in select d from json_array_elements($2) d loop
      update owners o
      set username = (_team.d->>'username')::citext,
          name = (_team.d->>'name')::text,
          email = (_team.d->>'email')::text,
          updatestamp = now(),
          bot = coalesce(o.bot, $3)
      where service = $1
        and service_id = (_team.d->>'id')::text
      returning ownerid into _ownerid;

      if not found then
        insert into owners (service, service_id, username, name, email, bot)
        values ($1, (_team.d->>'id')::text, (_team.d->>'username')::citext, (_team.d->>'name')::text, (_team.d->>'email')::text, $3)
        returning ownerid into _ownerid;
      end if;

      select array_append(ownerids, _ownerid) into ownerids;

    end loop;

    return ownerids;

  end;
$_$;



--
--

CREATE FUNCTION remove_key_from_json(json, text) RETURNS json
    LANGUAGE sql STABLE
    AS $_$
   with drop_key as (
     select key, value::text
     from json_each($1::json)
     where key != $2::text and value is not null
   ) select ('{'||array_to_string((select array_agg('"'||key||'":'||value) from drop_key), ',')||'}')::json;
$_$;



--
--

CREATE FUNCTION repo_cache_state_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  begin
    -- update cache of number of repos
    update owners o
      set cache=update_json(cache, 'stats', update_json(cache->'stats', 'repos', (select count(*) from repos r where r.ownerid=o.ownerid and active)::int)),
          updatestamp=now()
      where ownerid=new.ownerid;
    return null;
  end;
$$;



--
--

CREATE FUNCTION repo_yaml_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  declare _service service;
  declare _branch text;
  begin
    select service, (yaml->'codecov'->>'branch') into _service, _branch
    from owners
    where ownerid=new.ownerid
    limit 1;

    -- update repo bot and branch
    update repos
      set bot = case when (yaml->'codecov'->>'bot') is not null
                     then coalesce(get_ownerid_if_member(_service, (yaml->'codecov'->>'bot')::citext, ownerid), bot)
                     else null end,
          branch = coalesce((yaml->'codecov'->>'branch'), _branch, branch)
      where repoid=new.repoid;
    return null;
  end;
$$;



--
--

CREATE FUNCTION repos_before_insert_or_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  begin
    -- repo name changed or deleted
    update repos
     set name = null
     where ownerid = new.ownerid
       and name = new.name;
    return new;
  end;
$$;



--
--

CREATE FUNCTION sum_of_file_totals_filtering_sessionids(json, integer[]) RETURNS text[]
    LANGUAGE sql IMMUTABLE
    AS $_$
  -- sum totals for filtered flags
  -- in [<totals list a>, <totals list b>, <totals list c>], [1, 2]
  -- out (<totals list b> + <totals list c>) = <sum totals list>
  with totals as (
    select $1->i as t from unnest($2) as i
  ) select agg_totals(totals.t) from totals;
$_$;



--
--

CREATE FUNCTION sum_session_totals(sessions json, flags text[]) RETURNS json
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
  -- sum totals for filtered flags
  -- in {"0": {"t": <totals list a>}, "1": {"t": <totals list b>}, "2", {"t": <totals list c>}], [1, 2]
  -- out (<totals list b> + <totals list c>) = <sum totals list>
  with totals as (
    select sessions->(i::text)->'t' as t from unnest(list_sessionid_by_filtering_flags(sessions, flags)) as i
  ) select total_list_to_json(agg_totals(totals.t)) from totals;
$$;



--
--

CREATE FUNCTION total_list_to_json(totals text[]) RETURNS json
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
  select ('{"f":'||totals[1]||','||
           '"n":'||totals[2]||','||
           '"h":'||totals[3]||','||
           '"m":'||totals[4]||','||
           '"p":'||totals[5]||','||
           '"c":'||totals[6]||','||
           '"b":'||totals[7]||','||
           '"d":'||totals[8]||','||
           '"M":'||totals[9]||','||
           '"s":'||totals[10]||'}')::json;
$$;



--
--

CREATE FUNCTION try_to_auto_activate(integer, integer) RETURNS boolean
    LANGUAGE sql STRICT
    AS $_$
  update owners
  set plan_activated_users = (
    case when coalesce(array_length(plan_activated_users, 1), 0) < plan_user_count  -- we have credits
         then array_append_unique(plan_activated_users, $2)  -- add user
         else plan_activated_users
         end)
  where ownerid=$1
  returning (plan_activated_users @> array[$2]);
$_$;



--
--

CREATE FUNCTION update_json(json, text, integer) RETURNS json
    LANGUAGE sql STABLE
    AS $_$
   select case when $1 is not null then add_key_to_json(coalesce(remove_key_from_json($1, $2), '{}'::json), $2, $3)
               when $3 is null then ('{"'||$2||'":null}')::json
               else ('{"'||$2||'":'||$3::text||'}')::json end;
$_$;



--
--

CREATE FUNCTION update_json(json, text, json) RETURNS json
    LANGUAGE sql STABLE
    AS $_$
   select case when $1 is not null then add_key_to_json(coalesce(remove_key_from_json($1, $2), '{}'::json), $2, $3)
               when $3 is null then ('{"'||$2||'":null}')::json
               else ('{"'||$2||'":'||coalesce($3::text, 'null')::text||'}')::json end;
$_$;



--
--

CREATE FUNCTION update_json(json, text, text) RETURNS json
    LANGUAGE sql STABLE
    AS $_$
   select case when $1 is not null then add_key_to_json(coalesce(remove_key_from_json($1, $2), '{}'::json), $2, $3)
               when $3 is null then ('{"'||$2||'":null}')::json
               else ('{"'||$2||'":"'||$3||'"}')::json end;
$_$;



--
--

CREATE FUNCTION verify_session(text, text, uuid, sessiontype) RETURNS json
    LANGUAGE sql
    AS $_$
  -- try any members
  update sessions
  set lastseen = now(),
      ip = $1,
      useragent = $2
  where token = $3
    and type = $4
  returning get_user(ownerid);
$_$;



--
--

CREATE AGGREGATE agg_totals(json) (
    SFUNC = _agg_report_totals,
    STYPE = text[]
);



--
--

CREATE AGGREGATE max_coverage(json) (
    SFUNC = _max_coverage,
    STYPE = json[],
    FINALFUNC = _pop_first_as_json
);



--
--

CREATE AGGREGATE min_coverage(json) (
    SFUNC = _min_coverage,
    STYPE = json[],
    FINALFUNC = _pop_first_as_json
);



SET default_tablespace = '';

SET default_with_oids = false;

--
--

CREATE TABLE branches (
    repoid integer NOT NULL,
    updatestamp timestamp with time zone NOT NULL,
    branch text NOT NULL,
    base text,
    head text NOT NULL,
    authors integer[]
);



--
--

CREATE TABLE commits (
    commitid text NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    repoid integer NOT NULL,
    branch text,
    pullid integer,
    author integer,
    archived boolean DEFAULT false,
    ci_passed boolean,
    updatestamp timestamp without time zone,
    message text,
    state commit_state,
    merged boolean,
    deleted boolean,
    notified boolean,
    logs json[],
    version smallint,
    chunks text[],
    parent text,
    totals json,
    report json
);



--
--

CREATE TABLE owners (
    ownerid integer NOT NULL,
    service service NOT NULL,
    username citext,
    email text,
    name text,
    oauth_token text,
    stripe_customer_id text,
    stripe_subscription_id text,
    createstamp timestamp with time zone,
    service_id text NOT NULL,
    private_access boolean,
    staff boolean DEFAULT false,
    cache json,
    plan plans,
    plan_provider plan_providers,
    plan_user_count smallint,
    plan_auto_activate boolean,
    plan_activated_users integer[],
    did_trial boolean,
    free smallint DEFAULT 0 NOT NULL,
    invoice_details text,
    delinquent boolean,
    yaml json,
    updatestamp timestamp without time zone,
    organizations integer[],
    admins integer[],
    errors text[],
    integration_id smallint,
    permission integer[],
    bot integer,
    yaml_repoid integer
);



--
--

CREATE SEQUENCE owners_ownerid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
--

ALTER SEQUENCE owners_ownerid_seq OWNED BY owners.ownerid;


--
--

CREATE TABLE pulls (
    repoid integer NOT NULL,
    pullid integer NOT NULL,
    issueid integer,
    updatestamp timestamp without time zone,
    state pull_state DEFAULT 'open'::pull_state NOT NULL,
    title text,
    base text,
    compared_to text,
    head text,
    commentid text,
    totals json,
    flare json,
    author integer
);



--
--

CREATE TABLE repos (
    repoid integer NOT NULL,
    ownerid integer NOT NULL,
    service_id text NOT NULL,
    name citext,
    private boolean default false NOT NULL,
    branch text DEFAULT 'master'::text NOT NULL,
    upload_token uuid DEFAULT uuid_generate_v4(),
    image_token text DEFAULT random_string(10),
    updatestamp timestamp with time zone,
    language languages,
    active boolean,
    deleted boolean DEFAULT false NOT NULL,
    activated boolean DEFAULT false,
    bot integer,
    yaml json,
    cache json,
    hookid text,
    using_integration boolean,
    forkid integer
);



--
--

CREATE SEQUENCE repos_repoid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
--

ALTER SEQUENCE repos_repoid_seq OWNED BY repos.repoid;


--
--

CREATE TABLE sessions (
    sessionid integer NOT NULL,
    token uuid DEFAULT uuid_generate_v4() NOT NULL,
    name text,
    ownerid integer NOT NULL,
    type sessiontype NOT NULL,
    lastseen timestamp with time zone,
    useragent text,
    ip text
);



--
--

CREATE SEQUENCE sessions_sessionid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
--

ALTER SEQUENCE sessions_sessionid_seq OWNED BY sessions.sessionid;


--
--

CREATE TABLE version (
    version text
);



--
--

CREATE TABLE yaml_history (
    ownerid integer NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    author integer,
    message text,
    source text NOT NULL,
    diff text
);



--
--

ALTER TABLE ONLY owners ALTER COLUMN ownerid SET DEFAULT nextval('owners_ownerid_seq'::regclass);


--
--

ALTER TABLE ONLY repos ALTER COLUMN repoid SET DEFAULT nextval('repos_repoid_seq'::regclass);


--
--

ALTER TABLE ONLY sessions ALTER COLUMN sessionid SET DEFAULT nextval('sessions_sessionid_seq'::regclass);


--
--

ALTER TABLE ONLY owners
    ADD CONSTRAINT owners_pkey PRIMARY KEY (ownerid);


--
--

ALTER TABLE ONLY repos
    ADD CONSTRAINT repos_pkey PRIMARY KEY (repoid);


--
--

ALTER TABLE ONLY repos
    ADD CONSTRAINT repos_upload_token_key UNIQUE (upload_token);


--
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (sessionid);


--
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_token_key UNIQUE (token);


--
--

CREATE INDEX branches_repoid ON branches USING btree (repoid);


--
--

CREATE UNIQUE INDEX branches_repoid_branch ON branches USING btree (repoid, branch);


--
--

CREATE UNIQUE INDEX commits_repoid_commitid ON commits USING btree (repoid, commitid);


--
--

CREATE INDEX commits_repoid_timestamp_desc ON commits USING btree (repoid, "timestamp" DESC);


--
--

CREATE UNIQUE INDEX owner_service_ids ON owners USING btree (service, service_id);


--
--

CREATE UNIQUE INDEX owner_service_username ON owners USING btree (service, username);


--
--

CREATE UNIQUE INDEX pulls_repoid_pullid ON pulls USING btree (repoid, pullid);


--
--

CREATE INDEX pulls_repoid_state_open ON pulls USING btree (repoid) WHERE (state = 'open'::pull_state);


--
--

CREATE UNIQUE INDEX repos_service_ids ON repos USING btree (ownerid, service_id);


--
--

CREATE UNIQUE INDEX repos_slug ON repos USING btree (ownerid, name);


--
--

CREATE INDEX yaml_history_ownerid_timestamp ON yaml_history USING btree (ownerid, "timestamp");


--
--

CREATE TRIGGER branch_update AFTER UPDATE ON branches FOR EACH ROW WHEN ((new.head IS DISTINCT FROM old.head)) EXECUTE PROCEDURE branches_update();


--
--

CREATE TRIGGER commits_insert_pr_branch AFTER INSERT ON commits FOR EACH ROW EXECUTE PROCEDURE commits_insert_pr_branch();


--
--

CREATE TRIGGER commits_update_heads AFTER UPDATE ON commits FOR EACH ROW WHEN ((((new.state = 'complete'::commit_state) AND (new.deleted IS NOT TRUE)) AND ((((new.state IS DISTINCT FROM old.state) OR (new.pullid IS DISTINCT FROM old.pullid)) OR (new.merged IS DISTINCT FROM old.merged)) OR (new.branch IS DISTINCT FROM old.branch)))) EXECUTE PROCEDURE commits_update_heads();


--
--

CREATE TRIGGER owner_cache_state_insert AFTER INSERT ON owners FOR EACH ROW EXECUTE PROCEDURE owner_cache_state_update();


--
--

CREATE TRIGGER owner_cache_state_update AFTER UPDATE ON owners FOR EACH ROW WHEN ((new.organizations IS DISTINCT FROM old.organizations)) EXECUTE PROCEDURE owner_cache_state_update();


--
--

CREATE TRIGGER owner_token_clered AFTER UPDATE ON owners FOR EACH ROW WHEN (((new.oauth_token IS DISTINCT FROM old.oauth_token) AND (new.oauth_token IS NULL))) EXECUTE PROCEDURE owner_token_clered();


--
--

CREATE TRIGGER owner_yaml_updated BEFORE UPDATE ON owners FOR EACH ROW WHEN (((((new.yaml -> 'codecov'::text) ->> 'bot'::text) IS DISTINCT FROM ((old.yaml -> 'codecov'::text) ->> 'bot'::text)) OR (((new.yaml -> 'codecov'::text) ->> 'branch'::text) IS DISTINCT FROM ((old.yaml -> 'codecov'::text) ->> 'branch'::text)))) EXECUTE PROCEDURE owner_yaml_updated();


--
--

CREATE TRIGGER owners_before_insert BEFORE INSERT ON owners FOR EACH ROW EXECUTE PROCEDURE owners_before_insert_or_update();


--
--

CREATE TRIGGER owners_before_update BEFORE UPDATE ON owners FOR EACH ROW WHEN (((new.username IS NOT NULL) AND (new.username IS DISTINCT FROM old.username))) EXECUTE PROCEDURE owners_before_insert_or_update();


--
--

CREATE TRIGGER pulls_before_insert BEFORE INSERT ON pulls FOR EACH ROW WHEN (((new.head IS NOT NULL) OR (new.base IS NOT NULL))) EXECUTE PROCEDURE pulls_insert();


--
--

CREATE TRIGGER pulls_before_update BEFORE UPDATE ON pulls FOR EACH ROW WHEN (((new.base IS DISTINCT FROM old.base) OR (new.head IS DISTINCT FROM old.head))) EXECUTE PROCEDURE pulls_update();


--
--

CREATE TRIGGER repo_cache_state_update AFTER UPDATE ON repos FOR EACH ROW WHEN ((new.active IS DISTINCT FROM old.active)) EXECUTE PROCEDURE repo_cache_state_update();


--
--

CREATE TRIGGER repo_yaml_update AFTER UPDATE ON repos FOR EACH ROW WHEN (((((new.yaml -> 'codecov'::text) ->> 'bot'::text) IS DISTINCT FROM ((old.yaml -> 'codecov'::text) ->> 'bot'::text)) OR (((new.yaml -> 'codecov'::text) ->> 'branch'::text) IS DISTINCT FROM ((old.yaml -> 'codecov'::text) ->> 'branch'::text)))) EXECUTE PROCEDURE repo_yaml_update();


--
--

CREATE TRIGGER repos_before_insert BEFORE INSERT ON repos FOR EACH ROW EXECUTE PROCEDURE repos_before_insert_or_update();


--
--

CREATE TRIGGER repos_before_update BEFORE UPDATE ON repos FOR EACH ROW WHEN (((new.name IS NOT NULL) AND (new.name IS DISTINCT FROM old.name))) EXECUTE PROCEDURE repos_before_insert_or_update();


--
--

ALTER TABLE ONLY branches
    ADD CONSTRAINT branches_repoid_fkey FOREIGN KEY (repoid) REFERENCES repos(repoid) ON DELETE CASCADE;


--
--

ALTER TABLE ONLY commits
    ADD CONSTRAINT commits_author_fkey FOREIGN KEY (author) REFERENCES owners(ownerid) ON DELETE SET NULL;


--
--

ALTER TABLE ONLY commits
    ADD CONSTRAINT commits_repoid_fkey FOREIGN KEY (repoid) REFERENCES repos(repoid) ON DELETE CASCADE;


--
--

ALTER TABLE ONLY owners
    ADD CONSTRAINT owners_bot_fkey FOREIGN KEY (bot) REFERENCES owners(ownerid) ON DELETE SET NULL;


--
--

ALTER TABLE ONLY owners
    ADD CONSTRAINT owners_yaml_repoid_fkey FOREIGN KEY (yaml_repoid) REFERENCES repos(repoid) ON DELETE SET NULL;


--
--

ALTER TABLE ONLY pulls
    ADD CONSTRAINT pulls_author_fkey FOREIGN KEY (author) REFERENCES owners(ownerid) ON DELETE SET NULL;


--
--

ALTER TABLE ONLY pulls
    ADD CONSTRAINT pulls_repoid_fkey FOREIGN KEY (repoid) REFERENCES repos(repoid) ON DELETE CASCADE;


--
--

ALTER TABLE ONLY repos
    ADD CONSTRAINT repos_bot_fkey FOREIGN KEY (bot) REFERENCES owners(ownerid) ON DELETE SET NULL;


--
--

ALTER TABLE ONLY repos
    ADD CONSTRAINT repos_forkid_fkey FOREIGN KEY (forkid) REFERENCES repos(repoid);


--
--

ALTER TABLE ONLY repos
    ADD CONSTRAINT repos_ownerid_fkey FOREIGN KEY (ownerid) REFERENCES owners(ownerid) ON DELETE CASCADE;


--
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_ownerid_fkey FOREIGN KEY (ownerid) REFERENCES owners(ownerid) ON DELETE CASCADE;


--
--

ALTER TABLE ONLY yaml_history
    ADD CONSTRAINT yaml_history_author_fkey FOREIGN KEY (author) REFERENCES owners(ownerid) ON DELETE CASCADE;


--
--

ALTER TABLE ONLY yaml_history
    ADD CONSTRAINT yaml_history_ownerid_fkey FOREIGN KEY (ownerid) REFERENCES owners(ownerid) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

insert into version (version) values ('v4.3.9');
