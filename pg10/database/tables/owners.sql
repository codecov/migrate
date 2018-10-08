create table owners(
  ownerid                 serial primary key,
  service                 service not null,
  username                citext,
  email                   text,
  name                    text,
  oauth_token             text,
  stripe_customer_id      text,
  stripe_subscription_id  text,
  createstamp             timestamptz,
  service_id              text not null,
  private_access          boolean,
  staff                   boolean default false,  -- codecov staff
  cache                   jsonb,  -- {"stats": {}}
  plan                    plans default null,
  plan_provider           plan_providers,
  plan_user_count         smallint,
  plan_auto_activate      boolean,
  plan_activated_users    int[],
  did_trial               boolean,
  free                    smallint default 0 not null,
  invoice_details         text,
  -- bot                  int, SEE BELOW
  delinquent              boolean,
  yaml                    jsonb,
  updatestamp             timestamp,
  organizations           int[],  -- what teams I'm member of
  admins                  int[],  -- who can edit my billing
  integration_id          int,  -- github integration id
  permission              int[]
);

create unique index owner_service_username on owners (service, username);

create unique index owner_service_ids on owners (service, service_id);

alter table owners add column bot int references owners on delete set null;
