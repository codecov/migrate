alter table commits drop column chunks;

alter table pulls   drop column flare;
alter table pulls   add column  flare json;

alter table owners  drop column if exists errors;
alter table owners  drop column if exists yaml_repoid;
alter table commits drop column if exists logs;
alter table commits drop column if exists archived;
alter table pulls   drop column if exists changes;
alter table pulls   drop column if exists base_branch;
alter table pulls   drop column if exists head_branch;
alter table pulls   rename column totals to diff;

drop table if exists migrated;
drop table if exists migrate_range;

UPDATE public.pulls AS p
SET diff = CASE 
            WHEN p.diff IS NULL THEN NULL
            WHEN p.diff->'diff' IS NOT NULL THEN p.diff->'diff'
            WHEN JSONB_TYPEOF(p.diff) = 'array' THEN p.diff
            WHEN p.diff = 'null' THEN NULL
            ELSE NULL
           END;