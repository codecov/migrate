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

drop table if exists migrated;
drop table if exists migrate_range;
