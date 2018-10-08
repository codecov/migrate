create table yaml_history(
  ownerid             int references owners on delete cascade not null,
  timestamp           timestamptz not null,
  author              int references owners on delete cascade,
  message             text,
  source              text not null,
  diff                text
);

create index yaml_history_ownerid_timestamp on yaml_history (ownerid, timestamp);
